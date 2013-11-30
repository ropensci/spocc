#' Search for species occurrence data across many data sources.
#' 
#' Search on a vector or list of species names.
#' 
#' @import rinat rnpn rgbif rebird data.table
#' @importFrom rbison bison bison_data
#' @importFrom plyr compact
#' @importFrom lubridate now
#' @param query Either a single name, or a vetor of names. Either a scientific name 
#' or a common name. Specify whether a scientific or common name in the type parameter.
#' Only scientific names supported right now.
#' @template occtemp
#' @examples \dontrun{
#' # Data from a single source
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' occlist(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))
#' 
#' # Data from many sources
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' occlist(query=spnames, from=c('gbif','bison'), gbifopts=list(georeferenced=TRUE))
#' }
#' @export
occlist <- function(query=NULL, rank="species", from=c("gbif","bison","inat","npn","ebird"), 
                type="sci", gbifopts=list(), bisonopts=list(),
                inatopts=list(), npnopts=list(), ebirdopts=list())
{
  out_gbif=out_bison=out_inat=out_npn=out_ebird=data.frame(NULL)
  sources <- match.arg(from, choices=c("gbif","bison","inat","npn","ebird"), several.ok=TRUE)
  
  time <- now()
  
  foo <- function(x){
    if(any(grepl("gbif",sources))){
      gbifopts$taxonKey <- name_backbone(name=x)$usageKey
      gbifopts$return <- "data"
      out_gbif <- do.call(occ_search, gbifopts)
      out_gbif$prov <- rep("gbif", nrow(out_gbif))
      out_gbif$name <- as.character(out_gbif$name)
    }
    if(any(grepl("bison",sources))){
      bisonopts$species <- x
      out_bison <- do.call(bison, bisonopts)
      out_bison <- bison_data(out_bison, datatype="data_df")
      out_bison$prov <- rep("bison", nrow(out_bison))
    }
    if(any(grepl("inat",sources))){
      inatopts$query <- x
      out_inat <- do.call(get_obs_inat, inatopts)
      out_inat$prov <- rep("inat", nrow(out_inat))
    }
    if(any(grepl("npn",sources))){
      ids <- lookup_names(name=x, type="genus_epithet")[,"species_id"]
      npnopts$speciesid <- as.numeric(as.character(ids))
      df <- do.call(getallobssp, npnopts)
      df <- npn_todf(df)
      out_npn <- df@data
      out_npn$prov <- rep("npn", nrow(out_npn))
    }
    if(any(grepl("ebird",sources))){
      if(is.null(ebirdopts$method))
        ebirdopts$method <- 'ebirdregion'
      if(!ebirdopts$method %in% c('ebirdregion', 'ebirdgeo'))
        stop("ebird method must be one of ebirdregion or ebirdgeo")
      ebirdopts$species <- x
      if(ebirdopts$method == 'ebirdregion'){
        out_ebird <- do.call(ebirdregion, ebirdopts[!names(ebirdopts) %in% 'method'])
      } else {
        out_ebird <- do.call(ebirdgeo, ebirdopts[!names(ebirdopts) %in% 'method'])
      }
      out_ebird$prov <- rep("ebird", nrow(out_ebird))
    }
    list(gbif=out_gbif,bison=out_bison,inat=out_inat,npn=out_npn,ebird=out_ebird)
  }
  
  
  tmp <- lapply(query, foo)
  getsplist <- function(srce){
    tt <- lapply(tmp, "[[", srce)
    names(tt) <- query
    tt
  }
  gbif_sp <- getsplist("gbif")
  bison_sp <- getsplist("bison")
  inat_sp <- getsplist("inat")
  npn_sp <- getsplist("npn")
  ebird_sp <- getsplist("ebird")
  a <- new("occResultList", 
           meta=list(source="gbif", time=time, query=query, type=type, opts=gbifopts),
           data=gbif_sp)
  b <- new("occResultList", 
           meta=list(source="bison", time=time, query=query, type=type, opts=bisonopts),
           data=bison_sp)
  c <- new("occResultList", 
           meta=list(source="inat", time=time, query=query, type=type, opts=inatopts),
           data=inat_sp)
  d <- new("occResultList", 
           meta=list(source="npn", time=time, query=query, type=type, opts=npnopts),
           data=npn_sp)
  e <- new("occResultList", 
           meta=list(source="ebird", time=time, query=query, type=type, opts=ebirdopts),
           data=ebird_sp)
  new("occDatSpp", gbif = a, bison = b, inat = c, npn = d, ebird = e)
}