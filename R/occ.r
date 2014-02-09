#' Search for species occurrence data across many data sources.
#' 
#' Search on a single species name, or many. And search across a single 
#' or many data sources.
#' 
#' @import rgbif rinat rebird data.table ecoengine rbison
#' @importFrom plyr compact
#' @importFrom lubridate now
#' @template occtemp
#' @export
#' @examples \dontrun{
#' # Single data sources
#' occ(query = 'Accipiter striatus', from = 'gbif')
#' occ(query = 'Accipiter striatus', from = 'ecoengine')
#' occ(query = 'Danaus plexippus', from = 'inat')
#' occ(query = 'Bison bison', from = 'bison')
#' occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'))
#' occ(query = 'Spinus tristis', from = 'ebird', ebirdopts = 
#'    list(method = 'ebirdgeo', lat = 42, lng = -76, dist = 50))
#'
#' # Many data sources
#' out <- occ(query = 'Pinus contorta', from=c('gbif','inat'))
#' 
#' ## Select individual elements
#' out$gbif
#' out$gbif$data
#' 
#' ## Coerce to combined data.frame, selects minimal set of columns (name, lat, long)
#' occ2df(out)
#' 
#' # Pass in limit parameter to all sources. This limits the number of occurrences
#' # returned to 10, in this example, for all sources, in this case gbif and inat.
#' occ(query='Pinus contorta', from=c('gbif','inat'), limit=10)
#' 
#' # Geometry
#' ## Pass in geometry parameter to all sources. This constraints the search to the 
#' ## specified polygon for all sources, gbif and bison in this example.
#' occ(query='Accipiter striatus', from='gbif', 
#'    geometry='POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))')
#' occ(query='Helianthus annuus', from='bison', 
#'    geometry='POLYGON((-111.06 38.84, -110.80 39.37, -110.20 39.17, -110.20 38.90, -110.63 38.67, -111.06 38.84))')
#'    
#' ## Or pass in a bounding box, which is automatically converted to WKT (required by GBIF)
#' occ(query='Accipiter striatus', from='gbif', geometry=c(38.4,-125.0,40.9,-121.8))
#' 
#' ## WKT's are more flexible than bounding box's. You can pass in a WKT with multiple 
#' ## polygons like so (you can use POLYGON or MULTIPOLYGON) when specifying more than one
#' ## polygon. Note how each polygon is in it's own set of parentheses.
#' occ(query='Accipiter striatus', from='gbif', 
#'    geometry='MULTIPOLYGON((30 10, 10 20, 20 60, 60 60, 30 10), (30 10, 10 20, 20 60, 60 60, 30 10))')
#' 
#' ## You can pass in geometry to each source separately via their opts parameter, at 
#' ## least those that support it
#' bounds <- c(38.44047,-125,40.86652,-121.837)
#' head(occ(query = 'Danaus plexippus', from="inat", inatopts=list(bounds=bounds))$inat$data)
#' 
#' # Specify many data sources, another example
#' ebirdopts = list(region = 'US'); gbifopts  =  list(country = 'US')
#' out <- occ(query = 'Setophaga caerulescens', from = c('gbif','inat','bison','ebird'), 
#' gbifopts = gbifopts, ebirdopts = ebirdopts)
#' occ2df(out)
#' 
#' # Pass in many species names, combine just data to a single data.frame, and
#' # first six rows
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query = spnames, from = 'gbif', gbifopts = list(georeferenced = TRUE))
#' df <- occ2df(out)
#' head(df)
#' }
occ <- function(query  =  NULL, from = "gbif", limit = 25, geometry = NULL, rank = "species",
                type = "sci", gbifopts = list(), bisonopts = list(), inatopts = list(), 
                ebirdopts = list(), ecoengineopts = list()) {
  sources <- match.arg(from, choices = c("gbif", "bison", "inat", "ebird", "ecoengine"), 
                       several.ok = TRUE)
  loopfun <- function(x, y, z) {
    # x=query; y=limit; z=geometry
    gbif_res <- foo_gbif(sources, x, y, z, gbifopts)
    bison_res <- foo_bison(sources, x, y, z, bisonopts)
    inat_res <- foo_inat(sources, x, y, z, inatopts)
    ebird_res <- foo_ebird(sources, x, y, ebirdopts)
    ecoengine_res <- foo_ecoengine(sources, x, y, z, ecoengineopts)
    list(gbif = gbif_res, bison = bison_res, inat = inat_res, ebird = ebird_res, 
         ecoengine = ecoengine_res)
  }
  tmp <- lapply(query, loopfun, y=limit, z=geometry)
  getsplist <- function(srce, opts) {
    tt <- lapply(tmp, function(x) x[[srce]]$data)
    names(tt) <- gsub("\\s", "_", query)
    if (any(grepl(srce, sources))) {
      list(meta = list(source = srce, time = tmp[[1]][[srce]]$time, query = query, 
                       type = type, opts = opts), data = tt)
    } else {
      list(meta = list(source = srce, time = NULL, query = NULL, type = NULL, 
                       opts = NULL), data = tt)
    }
  }
  gbif_sp <- getsplist("gbif", gbifopts)
  bison_sp <- getsplist("bison", bisonopts)
  inat_sp <- getsplist("inat", inatopts)
  ebird_sp <- getsplist("ebird", ebirdopts)
  ecoengine_sp <- getsplist("ecoengine", ecoengineopts)
  p <- list(gbif = gbif_sp, bison = bison_sp, inat = inat_sp, ebird = ebird_sp, 
            ecoengine = ecoengine_sp)
  class(p) <- "occdat"
  return(p)
}

# Plugins for the occ function for each data source
#' @noRd
foo_gbif <- function(sources, query, limit, geometry, opts) {
  if (any(grepl("gbif", sources))) {
    time <- now()
    opts$taxonKey <- name_backbone(name = query)$usageKey
    opts$limit <- limit
    opts$geometry <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){ 
      geometry } else { bbox2wkt(bbox=geometry) }
    opts$return <- "data"
    out <- do.call(occ_search, opts)
    if (class(out) == "character") {
      list(time = time, data = data.frame(name = NA, key = NA, longitude = NA, 
                                          latitude = NA, prov = "gbif"))
    } else {
      out$prov <- rep("gbif", nrow(out))
      out$prov <- rep("gbif", nrow(out))
      out$name <- as.character(out$name)
      list(time = time, data = out)
    }
  } else {
    list(time = NULL, data = data.frame(NULL))
  }
}

#' @noRd
foo_ecoengine <- function(sources, query, limit, geometry, opts) {
  if (any(grepl("ecoengine", sources))) {
    time <- now()
    opts$scientific_name <- query
    opts$georeferenced <- TRUE
    opts$page_size <- limit
    opts$bbox <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){ 
      wkt2bbox(geometry) } else { geometry }
    # This could hang things if request is super large.  Will deal with this issue
    # when it arises in a usecase
    # For now default behavior is to retrive one page.
    # page = "all" will retrieve all pages.
    if (is.null(opts$page)) {
      opts$page <- 1
    }
    opts$quiet <- TRUE
    opts$progress <- FALSE
    out_ee <- do.call(ee_observations, opts)
    out <- out_ee$data
    out$prov <- rep("ecoengine", nrow(out))
    names(out)[names(out) == 'scientific_name'] <- "name"
    list(time = time, data = out)
  } else {
    list(time = NULL, data = data.frame(NULL))
  }
}

#' @noRd
foo_bison <- function(sources, query, limit, geometry, opts) {
  if (any(grepl("bison", sources))) {
    time <- now()
    opts$species <- query
    opts$count <- limit
    opts$aoi <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){ 
      geometry } else { bbox2wkt(bbox=geometry) }
    out <- do.call(bison, opts)
    out <- out$points
    out$prov <- rep("bison", nrow(out))
    list(time = time, data = out)
  } else {
    list(time = NULL, data = data.frame(NULL))
  }
}

#' @noRd
foo_inat <- function(sources, query, limit, geometry, opts) {
  if (any(grepl("inat", sources))) {
    time <- now()
    opts$query <- query
    opts$maxresults <- limit
    opts$bounds <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){ 
      wkt2bbox(geometry) } else { geometry }
    out <- do.call(get_inat_obs, opts)
    out$prov <- rep("inat", nrow(out))
    names(out)[names(out) == 'Scientific.name'] <- "name"
    list(time = time, data = out)
  } else {
    list(time = NULL, data = data.frame(NULL))
  }
}

#' @noRd
foo_ebird <- function(sources, query, limit, opts) {
  if (any(grepl("ebird", sources))) {
    time <- now()
    if (is.null(opts$method)) 
      opts$method <- "ebirdregion"
    if (!opts$method %in% c("ebirdregion", "ebirdgeo")) 
      stop("ebird method must be one of ebirdregion or ebirdgeo")
    opts$species <- query
    opts$max <- limit
    if (opts$method == "ebirdregion") {
      out <- do.call(ebirdregion, opts[!names(opts) %in% "method"])
    } else {
      out <- do.call(ebirdgeo, opts[!names(opts) %in% "method"])
    }
    out$prov <- rep("ebird", nrow(out))
    names(out)[names(out) == 'sciName'] <- "name"
    list(time = time, data = out)
  } else {
    list(time = NULL, data = data.frame(NULL))
  }
}