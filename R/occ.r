#' Search for species occurrence data across many data sources.
#' 
#' @import rinat rnpn rgbif
#' @importFrom rbison bison bison_data
#' @importFrom plyr compact
#' @importFrom lubridate now
#' @param query Query term. Either a scientific name or a common name. Specify
#'    whether a scientific or common name in the type parameter.
#' @param from Data source to get data from, any combination of gbif, bison, or
#'    inat
#' @param type Type of name, sci (scientific) or com (common name, vernacular)
#' @param gbifopts List of options to pass on to rgbif
#' @param bisonopts List of options to pass on to rbison
#' @param inatopts List of options to pass on to rinat
#' @param npnopts List of options to pass on to rnpn
#' @details The \code{occ} function is an opinionated wrapper around the rgbif, 
#' rbison, and rinat packages to allow data access from a single 
#' access point. We take care of making sure you get useful objects out at the 
#' cost of flexibility/options - if you need options you can use the functions
#' inside each of those packages.
#' @examples \dontrun{
#' # Single data sources
#' occ(query='Accipiter striatus', from='gbif')
#' occ(query='Danaus plexippus', from='inat')
#' occ(query='Bison bison', from='bison')
#' occ(query='Pinus contorta', from='npn', npnopts=list(startdate='2008-01-01', enddate='2011-12-31'))
#' 
#' # Many data sources
#' npnopts <- list(startdate='2008-01-01', enddate='2011-12-31')
#' out <- occ(query='Pinus contorta', npnopts=npnopts)
#' 
#' ## Select data from each element
#' out@data
#' 
#' ## Coerce to combined data.frame, selects minimal set of columns (name, lat, long)
#' occ_todf(out)
#' 
#' ## Using a bounding box
#' bounds <- c(38.44047,-125,40.86652,-121.837)
#' aoibbox = '-111.31,38.81,-110.57,39.21'
#' get_obs_inat(query="Mule Deer", bounds=bounds)
#' occ(query='Danaus plexippus', )
#' }
#' @export
occ <- function(query=NULL, rank="species", from=c("gbif","bison","inat","npn"), 
                type="sci", gbifopts=list(), bisonopts=list(),
                inatopts=list(), npnopts=list())
{
  out_gbif=out_bison=out_inat=out_npn=NULL
  sources <- match.arg(from, choices=c("gbif","bison","inat","npn"), several.ok=TRUE)
  
  time <- now()
  if(any(grepl("gbif",sources))){
    gbifopts$taxonKey <- name_backbone(name=query)$usageKey
    gbifopts$return <- "data"
    out_gbif <- do.call(occ_search, gbifopts)
    out_gbif$prov <- rep("gbif", nrow(out_gbif))
  }
  if(any(grepl("bison",sources))){
    bisonopts$species <- query
    out_bison <- do.call(bison, bisonopts)
    out_bison <- bison_data(out_bison, datatype="data_df")
    out_bison$prov <- rep("bison", nrow(out_bison))
  }
  if(any(grepl("inat",sources))){
    inatopts$query <- query
    out_inat <- do.call(get_obs_inat, inatopts)
    out_inat$prov <- rep("inat", nrow(out_inat))
  }
  if(any(grepl("npn",sources))){
    ids <- lookup_names(name=query, type="genus_epithet")[,"species_id"]
    npnopts$speciesid <- as.numeric(as.character(ids))
#     npnopts$startdate <- startdate
#     npnopts$enddate <- enddate
    df <- do.call(getallobssp, npnopts)
    df <- npn_todf(df)
    out_npn <- df@data
    out_npn$prov <- rep("npn", nrow(out_npn))
  }
#   if(any(grepl("vertnet",sources))){
#     out_vertnet <- vertoccurrence(t=query, grp="bird", vertnetopts)
#   }
  out <- compact(list(gbif=out_gbif,bison=out_bison,inat=out_inat,npn=out_npn))
  new("occdat", meta=list(time=time, query=query, from=from, type=type,
                          gbifopts=gbifopts, bisonopts=bisonopts,
                          inatopts=inatopts, npnopts=npnopts), data=out)
}

#' Coerce elements of output from a single occ() call to a single data.frame
#' @importFrom plyr rbind.fill
#' @param x An object of class occdat
#' @return A data.frame
#' @export
occ_todf <- function(x)
{
  if(!is(x,"occdat"))
    stop("Input object must be of class occdat")
  
  parse <- function(y){
    if(y$prov[1]=="gbif"){
      data.frame(name=y$name,longitude=y$longitude,latitude=y$latitude,prov=y$prov)
    } else
      if(y$prov[1]=="bison"){
        data.frame(name=y$name,longitude=y$longitude,latitude=y$latitude,prov=y$prov)
      } else
        if(y$prov[1]=="inat"){
          data.frame(name=y$Scientific.name,latitude=y$Latitude,longitude=y$Longitude,prov=y$prov)
        } else
          if(y$prov[1]=="npn"){
            data.frame(name=y$sciname,latitude=y$latitude,longitude=y$longitude,prov=y$prov)
          }
  }
  tmp <- do.call(rbind, lapply(x@data, parse))
  row.names(tmp) <- NULL
  new("occdf", meta=x@meta, data=tmp)
}

#' Coerce elements of output from many occ() calls to a single data.frame
#' @importFrom plyr rbind.fill
#' @param x A list of objects of class occdat
#' @return A data.frame
#' @examples \dontrun{
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
#' dat <- lapply(spp, function(x) occ(query=x, from='gbif'))
#' occmany_todf(dat) # data with compiled metadata
#' occmany_todf(dat)@data # just data
#' }
#' @export
occmany_todf <- function(x)
{
  if( !all(sapply(x, function(y) is(y,"occdat"))) )
    stop("Input objects must all be of class occdat")
  
  out <- lapply(x, function(z) occ_todf(z)@data)
  tmp <- do.call(rbind, out)
  row.names(tmp) <- NULL
  new("occdfmany", meta=lapply(x, function(x) x@meta), data=tmp)
}

setClass("occdat", slots=list(meta="list", data="list"))

setClass("occdf", slots=list(meta="list", data="data.frame"))

setClass("occdfmany", slots=list(meta="list", data="data.frame"))

#' Coerce to sp object
#' 
#' @name as
#' @family occdat
#' @importClassesFrom sp SpatialPointsDataFrame
setAs("occdat", "SpatialPointsDataFrame", function(from){
  if(length(from@data)==1){ 
    dat <- from@data[[1]]
    dat <- na.omit(dat)
  } else
  { 
    dat <- occ_todf(from)
    dat <- na.omit(dat@data)
  }
  coordinates(dat) <- c("latitude","longitude")
  dat
})
# (out <- occ(query='Accipiter striatus', from='gbif'))
#   as(out, "SpatialPointsDataFrame")
# outdat_sp <- 
# class(outdat_sp)
# spplot(outdat_sp)
# head(meuse)

# (out <- occ(query='Accipiter striatus', from = c('gbif','bison')))
# # out <- occ_todf(out)[,-4]
# # # outdat <- new("occdat", data=out)
# outdat_sp <- as(out, "SpatialPointsDataFrame")
# library(sp)
# spplot(outdat_sp)
# # 
# # dd2dms(outdat_sp)