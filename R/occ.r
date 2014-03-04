#' Search for species occurrence data across many data sources.
#' 
#' Search on a single species name, or many. And search across a single 
#' or many data sources.
#' 
#' @import rgbif rinat rebird data.table ecoengine rbison AntWeb
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
#' # Data from AntWeb
#' # By species
#' (by_species <- occ(query = "acanthognathus brevicornis", from = "antweb"))
#' # or by genus
#' (by_genus <- occ(query = "acanthognathus", from = "antweb"))
#'
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
#'    geometry='POLYGON((-111.06 38.84, -110.80 39.37, -110.20 39.17, -110.20 38.90, 
#'                       -110.63 38.67, -111.06 38.84))')
#'    
#' ## Or pass in a bounding box, which is automatically converted to WKT (required by GBIF)
#' ## via the bbox2wkt function
#' occ(query='Accipiter striatus', from='gbif', geometry=c(-125.0,38.4,-121.8,40.9))
#' 
#' ## Bounding box constraint with ecoengine 
#' occ(query='Accipiter striatus', from='ecoengine', limit=10, 
#'    geometry=c(-125.0,38.4,-121.8,40.9))
#' 
#' ## You can pass in geometry to each source separately via their opts parameter, at 
#' ## least those that support it. Note that if you use rinat, you reverse the order, with
#' ## latitude first, and longitude second, but here it's the reverse for consistency across
#' ## the spocc package
#' bounds <- c(-125.0,38.4,-121.8,40.9)
#' occ(query = 'Danaus plexippus', from="inat", geometry=bounds)
#' 
#' ## Passing geometry with multiple sources
#' occ(query = 'Danaus plexippus', from=c("inat","gbif","ecoengine"), geometry=bounds)
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
#' 
#' 
#' # taxize integration: Pass in taxonomic identifiers
#' library(taxize)
#' (ids <- get_ids(names=c("Chironomus riparius","Pinus contorta"), db = c('itis','gbif')))
#' occ(ids = ids[[1]], from='bison')
#' occ(ids = ids, from=c('bison','gbif'))
#' 
#' (ids <- get_ids(names="Chironomus riparius", db = 'gbif'))
#' occ(ids = ids, from='gbif')
#' 
#' (ids <- get_gbifid("Chironomus riparius"))
#' occ(ids = ids, from='gbif')
#' 
#' (ids <- get_tsn('Accipiter striatus'))
#' occ(ids = ids, from='bison')
#' }
#' 
#' @examples \donttest{
#' #### NOTE: no support for multipolygons yet
#' ## WKT's are more flexible than bounding box's. You can pass in a WKT with multiple 
#' ## polygons like so (you can use POLYGON or MULTIPOLYGON) when specifying more than one
#' ## polygon. Note how each polygon is in it's own set of parentheses.
#' occ(query='Accipiter striatus', from='gbif', 
#'    geometry='MULTIPOLYGON((30 10, 10 20, 20 60, 60 60, 30 10), 
#'                           (30 10, 10 20, 20 60, 60 60, 30 10))')
#' }
occ <- function(query = NULL, from = "gbif", limit = 25, geometry = NULL, rank = "species",
                type = "sci", ids = NULL, gbifopts = list(), bisonopts = list(), inatopts = list(), 
                ebirdopts = list(), ecoengineopts = list(), antwebopts = list()) {
  sources <- match.arg(from, choices = c("gbif", "bison", "inat", "ebird", "ecoengine", "antweb"), 
                       several.ok = TRUE)
  loopfun <- function(x, y, z) {
    # x = query; y = limit; z = geometry
    gbif_res <- foo_gbif(sources, x, y, z, gbifopts)
    bison_res <- foo_bison(sources, x, y, z, bisonopts)
    inat_res <- foo_inat(sources, x, y, z, inatopts)
    ebird_res <- foo_ebird(sources, x, y, ebirdopts)
    ecoengine_res <- foo_ecoengine(sources, x, y, z, ecoengineopts)
    antweb_res <- foo_antweb(sources, x, y, z, antwebopts)
  list(gbif = gbif_res, bison = bison_res, inat = inat_res, ebird = ebird_res, 
         ecoengine = ecoengine_res, antweb = antweb_res)
  }
  
  loopids <- function(x, y, z) {
    # x = query; y=limit; z=geometry
    classes <- ifelse(length(x)>1, vapply(x, class, ""), class(x))
    if(!all(classes %in% c("gbifid","tsn")))
      stop("Currently, taxon identifiers have to be of class gbifid or tsn")
    if(class(x) == 'gbifid'){
      gbif_res <- foo_gbif(sources, x, y, z, gbifopts)
      bison_res <- list(time = NULL, data = data.frame(NULL))
    } else if(class(x) == 'tsn') {
      bison_res <- foo_bison(sources, x, y, z, bisonopts)
      gbif_res <- list(time = NULL, data = data.frame(NULL))
    }
    list(gbif = gbif_res, bison = bison_res, 
         inat = list(time = NULL, data = data.frame(NULL)), 
         ebird = list(time = NULL, data = data.frame(NULL)), 
         ecoengine = list(time = NULL, data = data.frame(NULL)),
         antweb = list(time = NULL, data = data.frame(NULL)))
  }
  
  # check that one of query or ids is non-NULL
  assert_that(xor(!is.null(query), !is.null(ids)))
  
  if(is.null(ids)){
    # If query not null (taxonomic names passed in)
    tmp <- lapply(query, loopfun, y=limit, z=geometry)
  } else
  {
    unlistids <- function(x){
      if(length(x) == 1){
        if(is.null(names(x))){ list(x) } else {
          if(!names(x) %in% c("gbif","itis"))
            list(x)
          else
            list(x[[1]]) 
        }
      } else {
        gg <- as.list(unlist(x, use.names = FALSE))
        hh <- as.vector(rep(vapply(x, class, ""), vapply(x, length, numeric(1))))
        if(all(hh == "character"))
          hh <- rep(class(x), length(x))
        for(i in seq_along(gg)){  
          class(gg[[i]]) <- hh[[i]]
        }
        return( gg )
      }
    }
    ids <- unlistids(ids)
    # if ids is not null (taxon identifiers passed in)
    # ids can only be passed to gbif and bison for now
    # so don't pass anything on to ecoengine, inat, or ebird
    tmp <- lapply(ids, loopids, y=limit, z=geometry)
  }
  
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
  antweb_sp <- getsplist("antweb", ecoengineopts)
  p <- list(gbif = gbif_sp, bison = bison_sp, inat = inat_sp, ebird = ebird_sp, 
            ecoengine = ecoengine_sp, antweb = antweb_sp)
  class(p) <- "occdat"
  return(p)
}

# Plugins for the occ function for each data source
#' @noRd
foo_gbif <- function(sources, query, limit, geometry, opts) {
  if (any(grepl("gbif", sources))) {
    if(class(query) %in% c("ids","gbifid")){
      if(class(query) %in% "ids")
        opts$taxonKey <- query$gbif
      else
        opts$taxonKey <- query
    } else
    { opts$taxonKey <- name_backbone(name = query)$usageKey }
    
    time <- now()
    opts$limit <- limit
    if(!is.null(geometry)){
      opts$geometry <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){ 
        geometry } else { bbox2wkt(bbox=geometry) }
    }
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
    if(!is.null(geometry)){
      opts$bbox <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){ 
        wkt2bbox(geometry) } else { geometry }
    }
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
foo_antweb <- function(sources, query, limit, geometry,  opts) {
  if (any(grepl("antweb", sources))) {
    time <- now()
    limit <- NULL
    geometry <- NULL

    query <- sub("^ +", "", query)
    query <- sub(" +$", "", query)
    
    if(length(strsplit(query, " ")[[1]]) == 2) {
      opts$scientific_name <- query
    } else {
      opts$genus <- query
      opts$scientific_name <- NULL
    }

    opts$georeferenced <- TRUE
    out <- do.call(aw_data, opts)
    out$prov <- rep("antweb", nrow(out))
    out$scientific_name <- opts$scientific_name
    list(time = time, data = out)
  } else {
    list(time = NULL, data = data.frame(NULL))
  }
}




#' @noRd
foo_bison <- function(sources, query, limit, geometry, opts) {
  if (any(grepl("bison", sources))) {
    if(class(query) %in% c("ids","tsn")){
      if(class(query) %in% "ids"){
        opts$tsn <- query$itis
      } else
      {
        opts$tsn <- query
      }
      opts$itis <- 'true'
    } else
    { opts$species <- query }
    
    time <- now()
    opts$count <- limit
    opts$what <- 'points'
    if(!is.null(geometry)){
      opts$aoi <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){ 
        geometry } else { bbox2wkt(bbox=geometry) }
    }
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
    if(!is.null(geometry)){
      opts$bounds <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" ")))
      { 
        # flip lat and long spots in the bounds vector for inat
        temp <- wkt2bbox(geometry)
        c(temp[2], temp[1], temp[4], temp[3])
      } else { c(geometry[2], geometry[1], geometry[4], geometry[3]) }
    }
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
      if (is.null(opts$region)) opts$region <- "US"
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