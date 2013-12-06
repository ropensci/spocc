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
  
  gbif_res <- foo_gbif(sources, query, type, gbifopts)
  bison_res <- foo_bison(sources, query, type, bisonopts)
  inat_res <- foo_inat(sources, query, type, inatopts)
  npn_res <- foo_npn(sources, query, type, npnopts)
  ebird_res <- foo_ebird(sources, query, type, ebirdopts)
  
  a <- new("occResult", meta=gbif_res$meta, data=gbif_res$data)
  b <- new("occResult", meta=bison_res$meta, data=bison_res$data)
  c <- new("occResult", meta=inat_res$meta, data=inat_res$data)
  d <- new("occResult", meta=npn_res$meta, data=npn_res$data)
  e <- new("occResult", meta=ebird_res$meta, data=ebird_res$data)
  new("occDat", gbif = a, bison = b, inat = c, npn = d, ebird = e)
}

foo_gbif <- function(sources, query, type, opts)
{  
  if(any(grepl("gbif", sources))){
    time <- now()
    opts$taxonKey <- name_backbone(name=query)$usageKey
    opts$return <- "data"
    out <- do.call(occ_search, opts)
    out$prov <- rep("gbif", nrow(out))
    out$name <- as.character(out$name)
    meta <- list(source="gbif", time=time, query=query, type=type, opts=opts)
  } else
  {
    meta <- list(source="gbif", time=NULL, query=NULL, type=NULL, opts=list())
    out <- data.frame(NULL)
  }
  list(meta=meta, data=out)
}

foo_bison <- function(sources, query, type, opts)
{  
  if(any(grepl("bison", sources))){
    time <- now()
    opts$species <- query
    out <- do.call(bison, opts)
    out <- bison_data(out, datatype="data_df")
    out$prov <- rep("bison", nrow(out))
    meta <- list(source="bison", time=time, query=query, type=type, opts=opts)
  } else
  {
    meta <- list(source="bison", time=NULL, query=NULL, type=NULL, opts=list())
    out <- data.frame(NULL)
  }
  list(meta=meta, data=out)
}

foo_inat <- function(sources, query, type, opts)
{  
  if(any(grepl("inat", sources))){
    time <- now()
    opts$query <- query
    out <- do.call(get_inat_obs, opts)
    out$prov <- rep("inat", nrow(out))
    meta <- list(source="inat", time=time, query=query, type=type, opts=opts)
  } else
  {
    meta <- list(source="inat", time=NULL, query=NULL, type=NULL, opts=list())
    out <- data.frame(NULL)
  }
  list(meta=meta, data=out)
}

foo_npn <- function(sources, query, type, opts)
{  
  if(any(grepl("npn", sources))){
    time <- now()
    ids <- lookup_names(name=query, type="genus_epithet")[,"species_id"]
    opts$speciesid <- as.numeric(as.character(ids))
    df <- do.call(getallobssp, opts)
    df <- npn_todf(df)
    out <- df@data
    out$prov <- rep("npn", nrow(out))
    meta <- list(source="npn", time=time, query=query, type=type, opts=opts)
  } else
  {
    meta <- list(source="npn", time=NULL, query=NULL, type=NULL, opts=list())
    out <- data.frame(NULL)
  }
  list(meta=meta, data=out)
}

foo_ebird <- function(sources, query, type, opts)
{  
  if(any(grepl("ebird", sources))){
    time <- now()
    if(is.null(opts$method))
      opts$method <- 'ebirdregion'
    if(!opts$method %in% c('ebirdregion', 'ebirdgeo'))
      stop("ebird method must be one of ebirdregion or ebirdgeo")
    opts$species <- query
    if(opts$method == 'ebirdregion'){
      out <- do.call(ebirdregion, opts[!names(opts) %in% 'method'])
    } else {
      out <- do.call(ebirdgeo, opts[!names(opts) %in% 'method'])
    }
    out$prov <- rep("ebird", nrow(out))
    meta <- list(source="ebird", time=time, query=query, type=type, opts=opts)
  } else
  {
    meta <- list(source="ebird", time=NULL, query=NULL, type=NULL, opts=list())
    out <- data.frame(NULL)
  }
  list(meta=meta, data=out)
}