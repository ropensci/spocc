#' Search for species occurrence data across many data sources.
#' 
#' Search on a single species name.
#' 
#' @import rinat rnpn rgbif rebird data.table
#' @importFrom rbison bison bison_data
#' @importFrom plyr compact
#' @importFrom lubridate now
#' @param query A single name. Either a scientific name 
#' or a common name. Specify whether a scientific or common name in the type parameter.
#' Only scientific names supported right now.
#' @template occtemp
#' @examples \dontrun{
#' # Single data sources
#' occ(query='Accipiter striatus', from='gbif')
#' occ(query='Danaus plexippus', from='inat')
#' occ(query='Bison bison', from='bison')
#' occ(query='Pinus contorta', from='npn', npnopts=list(startdate='2008-01-01', enddate='2011-12-31'))
#' occ(query='Setophaga caerulescens', from='ebird', ebirdopts=list(region='US'))
#' occ(query='Spinus tristis', from='ebird', ebirdopts=list(method='ebirdgeo', lat=42, lng=-76, dist=50))
#' 
#' # Many data sources
#' npnopts <- list(startdate='2008-01-01', enddate='2011-12-31')
#' out <- occ(query='Pinus contorta', npnopts=npnopts)
#' 
#' ## Select individual elements
#' out@gbif
#' out@gbif@data
#' 
#' ## Coerce to combined data.frame, selects minimal set of columns (name, lat, long)
#' occtodf(out, 'data')
#' 
#' 
#' # Many data sources, another example
#' ebirdopts = list(region='US'); gbifopts = list(country='US')
#' out <- occ(query='Setophaga caerulescens', from=c('gbif','bison','inat','ebird'), gbifopts=gbifopts, ebirdopts=ebirdopts)
#' occtodf(out)
#' 
#' ## Using a bounding box
#' bounds <- c(38.44047,-125,40.86652,-121.837)
#' aoibbox = '-111.31,38.81,-110.57,39.21'
#' get_inat_obs(query="Mule Deer", bounds=bounds)
#' occ(query='Danaus plexippus', )
#' 
#' # Pass in many species names
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' occ(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))
#' }
#' @export
occ <- function(query=NULL, rank="species", from=c("gbif","bison","inat","npn","ebird"), 
                type="sci", gbifopts=list(), bisonopts=list(),
                inatopts=list(), npnopts=list(), ebirdopts=list())
{
  out_gbif=out_bison=out_inat=out_npn=out_ebird=data.frame(NULL)
  sources <- match.arg(from, choices=c("gbif","bison","inat","npn","ebird"), several.ok=TRUE)
  
  time <- now()
  if(any(grepl("gbif",sources))){
    gbifopts$taxonKey <- name_backbone(name=query)$usageKey
    gbifopts$return <- "data"
    out_gbif <- do.call(occ_search, gbifopts)
    out_gbif$prov <- rep("gbif", nrow(out_gbif))
    out_gbif$name <- as.character(out_gbif$name)
  }
  if(any(grepl("bison",sources))){
    bisonopts$species <- query
    out_bison <- do.call(bison, bisonopts)
    out_bison <- bison_data(out_bison, datatype="data_df")
    out_bison$prov <- rep("bison", nrow(out_bison))
  }
  if(any(grepl("inat",sources))){
    inatopts$query <- query
    out_inat <- do.call(get_inat_obs, inatopts)
    out_inat$prov <- rep("inat", nrow(out_inat))
  }
  if(any(grepl("npn",sources))){
    ids <- lookup_names(name=query, type="genus_epithet")[,"species_id"]
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
    ebirdopts$species <- query
    if(ebirdopts$method == 'ebirdregion'){
      out_ebird <- do.call(ebirdregion, ebirdopts[!names(ebirdopts) %in% 'method'])
    } else {
      out_ebird <- do.call(ebirdgeo, ebirdopts[!names(ebirdopts) %in% 'method'])
    }
    out_ebird$prov <- rep("ebird", nrow(out_ebird))
  }
  
  a <- new("occResult", meta=list(source="gbif", time=time, query=query, type=type, opts=gbifopts), data=out_gbif)
  b <- new("occResult", meta=list(source="bison", time=time, query=query, type=type, opts=bisonopts), data=out_bison)
  c <- new("occResult", meta=list(source="inat", time=time, query=query, type=type, opts=inatopts), data=out_inat)
  d <- new("occResult", meta=list(source="npn", time=time, query=query, type=type, opts=npnopts), data=out_npn)
  e <- new("occResult", meta=list(source="ebird", time=time, query=query, type=type, opts=ebirdopts), data=out_ebird)
  new("occDat", gbif = a, bison = b, inat = c, npn = d, ebird = e)
}