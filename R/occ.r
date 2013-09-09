#' Make a map of species occurrence data.
#' 
#' @importFrom rgbif occurrencelist
#' @importFrom rbison bison
#' @importFrom rinat get_obs_inat
#' @importFrom rvertnet vertoccurrence
#' @importFrom plyr compact
#' @param query Query term. Either a scientific name or a common name. Specify
#'    whether a scientific or common name in the type parameter.
#' @param from Data source to get data from, any combination of gbif, bison, 
#'    vertnet, inat
#' @param type Type of name, sci (scientific) or com (common name, vernacular)
#' @param gbifopts List of options to pass on to rgbif
#' @param bisonopts List of options to pass on to rbison
#' @param inatopts List of options to pass on to rinat
#' @param vertnetopts List of options to pass on to rvertnet
#' @details The \code{occ} function is an opinionated wrapper around the rgbif, 
#' rbison, rvertnet, and rinat packages to allow data access from a single 
#' access point. We take care of making sure you get useful objects out at the 
#' cost of flexibility/options - if you need options you can use the functions
#' inside each of those packages.
#' @examples \dontrun{
#' # Single data sources
#' out <- occ(query='Accipiter striatus', from='gbif')
#' occ('Ursus americanus', from='inat')
#' occ('Danaus plexippus', from='bison')
#' occ('Danaus plexippus', from='vertnet')
#' 
#' # Many data sources
#' out <- occ(query='Accipiter striatus', from = c('gbif','bison'))
#' out
#' occ_todf(out) # coerce to combined data.frame
#' }
#' @export
occ <- function(query=NULL, from=c("gbif","bison","vertnet","inat"), 
                type="sci", gbifopts=NULL, bisonopts=NULL,
                inatopts=NULL, vertnetopts=NULL)
{
  out_gbif=out_bison=out_inat=out_vertnet=NULL
  sources <- match.arg(from, choices=c("gbif","bison","vertnet","inat"), 
                       several.ok=TRUE)
  
  if(any(grepl("gbif",sources))){
    out_gbif <- gbifdata(occurrencelist(scientificname=query, gbifopts))
    out_gbif$prov <- rep("gbif", nrow(out_gbif))
  }
  if(any(grepl("bison",sources))){
    out_bison <- bison_data(bison(species=query, bisonopts), datatype="data_df")
    out_bison$prov <- rep("bison", nrow(out_bison))
  }
#   if(any(grepl("inat",sources))){
#     out_inat <- get_obs_inat(query="Danaus plexippus", inatopts)
#   }
#   if(any(grepl("vertnet",sources))){
#     out_vertnet <- vertoccurrence(t=query, grp="bird", vertnetopts)
#   }
  
#   if(format=="df"){
#     names(out_gbif) <- c("name","latitude","longitude","prov")
#     out_bison <- data.frame(name=out_bison$name,latitude=out_bison$latitude,longitude=out_bison$longitude)
#     rbind.fill(list(out_gbif,out_bison))
#   } else
#   {
  out <- compact(list(gbif=out_gbif,bison=out_bison,inat=out_inat,vertnet=out_vertnet))
  new("occdat", meta=list(query=query, from=from, 
                          type=type, format=format, gbifopts=gbifopts, bisonopts=bisonopts,
                          inatopts=inatopts, vertnetopts=vertnetopts), data=out)
#   }
}

#' Coerce elements of output from a call to occ to a single data.frame
#' @param x An object of class occdat
#' @return A data.frame
#' @export
occ_todf <- function(x){
  parse <- function(y){
    if(y$prov[1]=="gbif"){
      names(y) <- c("name","latitude","longitude","prov")
      y
    } else
      if(y$prov[1]=="bison"){
        data.frame(name=y$name,latitude=y$latitude,longitude=y$longitude,prov=y$prov)
      }
  }
  do.call(rbind.fill, lapply(x, parse))
}

setClass("occdat", representation(meta="list", data="list"))
# dat <- new("occdat", meta=list(a="asdf", b="asfad"), data=mtcars)

# out <- occ(query='Accipiter striatus', from='gbif')[[1]]
# out$var <- rnorm(10)
# out$var2 <- rnorm(10)
# out <- out[,-c(1,4)]
# outdat <- new("occdat", data=out)

setAs("occdat", "SpatialPointsDataFrame", function(from){
  if(length(from@data)==1){ dat <- from@data[[1]] } else
  { 
    dat <- occ_todf(from@data)
  }
  sp::coordinates(dat) <- c("latitude","longitude")
  dat
})
# outdat_sp <- as(outdat, "SpatialPointsDataFrame")
# class(outdat_sp)
# spplot(outdat_sp)
# head(meuse)

# out <- occ(query='Accipiter striatus', from = c('gbif','bison'))
# out <- occ_todf(out)[,-4]
# outdat <- new("occdat", data=out)
# outdat_sp <- as(outdat, "SpatialPointsDataFrame")
# spplot(outdat_sp)