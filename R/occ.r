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
#' (res <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 50))
#' res$gbif
#' (res <- occ(query = 'Accipiter striatus', from = 'ecoengine', limit = 50))
#' res$ecoengine
#' (res <- occ(query = 'Accipiter striatus', from = 'ebird', limit = 50))
#' res$ebird
#' (res <- occ(query = 'Danaus plexippus', from = 'inat', limit = 50))
#' res$inat
#' (res <- occ(query = 'Bison bison', from = 'bison', limit = 50))
#' res$bison
#' # Data from AntWeb
#' # By species
#' (by_species <- occ(query = "linepithema humile", from = "antweb"))
#' # or by genus
#' (by_genus <- occ(query = "acanthognathus", from = "antweb"))
#'
#' occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'))
#' occ(query = 'Spinus tristis', from = 'ebird', ebirdopts = 
#'    list(method = 'ebirdgeo', lat = 42, lng = -76, dist = 50))
#'    
#' # You can pass on limit param to all sources even though its a different param in that source
#' ## ecoengine example
#' res <- occ(query = 'Accipiter striatus', from = 'ecoengine', ecoengineopts=list(limit = 5))
#' res$ecoengine
#' ## This is particularly useful when you want to set different limit for each source
#' res <- occ(query = 'Accipiter striatus', from = c('gbif','ecoengine'), 
#'    gbifopts=list(limit = 10), ecoengineopts=list(limit = 5))
#' res
#'
#' # Many data sources
#' (out <- occ(query = 'Pinus contorta', from=c('gbif','bison')))
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
#' ## Check out \url{http://arthur-e.github.io/Wicket/sandbox-gmaps3.html} to get a WKT string
#' occ(query='Accipiter', from='gbif', 
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
#' # Use this website: \url{http://boundingbox.klokantech.com/} to quickly grab a bbox.
#' Just set the format on the bottom left to CSV.
#' occ(query='Accipiter striatus', from='ecoengine', limit=10, 
#'    geometry=c(-125.0,38.4,-121.8,40.9))
#' 
#' ## lots of results, can see how many by indexing to meta   
#' res <- occ(query='Accipiter striatus', from='gbif', 
#'    geometry='POLYGON((-69.9 49.2,-69.9 29.0,-123.3 29.0,-123.3 49.2,-69.9 49.2))')
#' res$gbif
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
#' ## Using geometry only for the query
#' ### A single bounding box
#' occ(geometry = bounds, from = "gbif")
#' ### Many bounding boxes
#' occ(geometry = list(c(-125.0,38.4,-121.8,40.9), c(-115.0,22.4,-111.8,30.9)), from = "gbif")
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
#' out <- occ(query = spnames, from = 'gbif', gbifopts = list(hasCoordinate = TRUE))
#' df <- occ2df(out)
#' head(df)
#' 
#' # taxize integration
#' ## You can pass in taxonomic identifiers
#' library("taxize")
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
#' 
#' # SpatialPolygons/SpatialPolygonsDataFrame integration
#' library("sp")
#' ## Single polygon in SpatialPolygons class
#' one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
#' spone = Polygons(list(one), "s1")
#' sppoly = SpatialPolygons(list(spone), as.integer(1))
#' out <- occ(geometry = sppoly)
#' out$gbif$data
#' 
#' ## Two polygons in SpatialPolygons class
#' one <- Polygon(cbind(c(-121.0,-117.9,-121.0,-121.0), c(39.4, 37.1, 35.1, 39.4)))
#' two <- Polygon(cbind(c(-123.0,-121.2,-122.3,-124.5,-123.5,-124.1,-123.0), 
#'                      c(44.8,42.9,41.9,42.6,43.3,44.3,44.8)))
#' spone = Polygons(list(one), "s1")
#' sptwo = Polygons(list(two), "s2")
#' sppoly = SpatialPolygons(list(spone, sptwo), 1:2)
#' out <- occ(geometry = sppoly)
#' out$gbif$data
#' 
#' ## Two polygons in SpatialPolygonsDataFrame class
#' sppoly_df <- SpatialPolygonsDataFrame(sppoly, data.frame(a=c(1,2), b=c("a","b"), c=c(TRUE,FALSE),
#'    row.names=row.names(sppoly)))
#' out <- occ(geometry = sppoly_df)
#' out$gbif$data
#' 
#' # curl debugging
#' library('httr')
#' occ(query = 'Accipiter striatus', from = 'gbif', callopts=verbose())
#' occ(query = 'Accipiter striatus', from = 'ebird', callopts=verbose())
#' occ(query = 'Accipiter striatus', from = 'bison', callopts=verbose())
#' occ(query = 'Accipiter striatus', from = 'ecoengine', callopts=verbose())
#' occ(query = 'Accipiter striatus', from = c('ebird','bison'), callopts=verbose())
#' occ(query = 'Accipiter striatus', from = 'ebird', callopts=timeout(seconds = 0.1))
#' ## notice that callopts is ignored when from=inat or from=antweb
#' occ(query = 'Accipiter striatus', from = 'inat', callopts=verbose())
#' occ(query = 'linepithema humile', from = 'antweb', callopts=verbose())
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
occ <- function(query = NULL, from = "gbif", limit = 500, geometry = NULL, rank = "species",
    type = "sci", ids = NULL, callopts=list(), gbifopts = list(), bisonopts = list(), 
    inatopts = list(), ebirdopts = list(), ecoengineopts = list(), antwebopts = list())
{  
  if(!is.null(geometry)){
    if(class(geometry) %in% c('SpatialPolygons','SpatialPolygonsDataFrame')){
      geometry <- as.list(handle_sp(geometry))
    }
  }
  sources <- match.arg(from, choices = c("gbif", "bison", "inat", "ebird", "ecoengine", "antweb"), 
                       several.ok = TRUE)
  if(!all(from %in% sources)){
    stop(sprintf("Woops, the following are not supported or spelled incorrectly: %s", from[!from %in% sources]))
  }
  
  loopfun <- function(x, y, z, w) {
    # x = query; y = limit; z = geometry; w = callopts
    gbif_res <- foo_gbif(sources, x, y, z, w, gbifopts)
    bison_res <- foo_bison(sources, x, y, z, w, bisonopts)
    inat_res <- foo_inat(sources, x, y, z, w, inatopts)
    ebird_res <- foo_ebird(sources, x, y, w, ebirdopts)
    ecoengine_res <- foo_ecoengine(sources, x, y, z, w, ecoengineopts)
    antweb_res <- foo_antweb(sources, x, y, z, w, antwebopts)
    list(gbif = gbif_res, bison = bison_res, inat = inat_res, ebird = ebird_res, 
         ecoengine = ecoengine_res, antweb = antweb_res)
  }
  
  loopids <- function(x, y, z, w) {
    # x = query; y=limit; z=geometry
#     classes <- ifelse(length(x)>1, vapply(x, class, ""), class(x))
    classes <- class(x)
    if(!all(classes %in% c("gbifid","tsn")))
      stop("Currently, taxon identifiers have to be of class gbifid or tsn")
    if(class(x) == 'gbifid'){
      gbif_res <- foo_gbif(sources, x, y, z, w, gbifopts)
      bison_res <- list(time = NULL, data = data.frame(NULL))
    } else if(class(x) == 'tsn') {
      bison_res <- foo_bison(sources, x, y, z, w, bisonopts)
      gbif_res <- list(time = NULL, data = data.frame(NULL))
    }
    list(gbif = gbif_res, 
         bison = bison_res, 
         inat = list(time = NULL, data = data.frame(NULL)), 
         ebird = list(time = NULL, data = data.frame(NULL)), 
         ecoengine = list(time = NULL, data = data.frame(NULL)),
         antweb = list(time = NULL, data = data.frame(NULL)))
  }
  
  # check that one of query or ids is non-NULL
#   assert_that(xor(!is.null(query), !is.null(ids), !is.null(geometry)))
   if(!any(!is.null(query), !is.null(ids), !is.null(geometry)))
     stop("One of query, ids, or geometry parameters must be non-NULL")
  
  if(is.null(ids) && !is.null(query)){
    # If query not null (taxonomic names passed in)
    tmp <- lapply(query, loopfun, y=limit, z=geometry, w=callopts)
  } else if(is.null(query) && is.null(geometry)) {
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
    tmp <- lapply(ids, loopids, y=limit, z=geometry, w=callopts)
  } else {
    type <- 'geometry'
    if(is.numeric(geometry)){
      tmp <- list(loopfun(z=geometry, y=limit, x=query, w=callopts))
    } else if(is.list(geometry)){
      tmp <- lapply(geometry, function(b) loopfun(z=b, y=limit, x=query, w=callopts))
    }
  }
  
  getsplist <- function(srce, opts) {
    tt <- lapply(tmp, function(x) x[[srce]]$data)
    if(!is.null(query) && is.null(geometry)){ # query
      names(tt) <- gsub("\\s", "_", query)
      optstmp <- tmp[[1]][[srce]]$opts
    } else if(is.null(query) && !is.null(geometry)){ # geometry
#       if(is.numeric(geometry)){ gg <- paste(geometry,collapse=",") } else {
#         gg <- lapply(geometry, paste, collapse=",")        
#       }
#       names(tt) <- gg
      tt <- tt
      optstmp <- tmp[[1]][[srce]]$opts
    } else if(!is.null(query) && !is.null(geometry)) { # query & geometry
      names(tt) <- gsub("\\s", "_", query)
      optstmp <- tmp[[1]][[srce]]$opts
    } else if(is.null(query) && is.null(geometry)) {
      names(tt) <- sapply(tmp, function(x) unclass(x[[srce]]$opts[[1]]))
      tt <- tt[!vapply(tt, nrow, 1) == 0]
      opts <- compact(lapply(tmp, function(x) x[[srce]]$opts))
      optstmp <- unlist(opts)
#       optstmp <- as.list(c(optstmp[!names(optstmp) %in% 'limit'], optstmp[names(optstmp) %in% 'limit'][1]))
#       optstmp <- as.list(c(optstmp[!names(optstmp) %in% 'count'], optstmp[names(optstmp) %in% 'count'][1]))
      simplist <- function(b){
        splitup <- unique(names(b))
        sapply(splitup, function(d){
          tmp <- b[names(b) %in% d]
          if(length(unique(unname(unlist(tmp)))) == 1){ as.list(tmp[1]) } else { 
            outout <- list(unname(unlist(tmp)))
            names(outout) <- names(tmp)[1]
            outout
          }
        }, USE.NAMES=FALSE)
      }
      optstmp <- simplist(optstmp)
    }

    if (any(grepl(srce, sources))) {
      ggg <- list(meta = list(source = srce, time = tmp[[1]][[srce]]$time,
          found = tmp[[1]][[srce]]$found, returned = nrow(tmp[[1]][[srce]]$data), 
          type = type, opts = optstmp), data = tt)
      class(ggg) <- "occdatind"
      ggg
    } else {
      ggg <- list(meta = list(source = srce, time = NULL, found = NULL, returned = NULL, 
          type = NULL, opts = NULL), data = tt)
      class(ggg) <- "occdatind"
      ggg
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
