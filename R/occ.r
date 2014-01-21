#' Search for species occurrence data across many data sources.
#' 
#' Search on a single species name.
#' 
#' @import rgbif rinat rebird data.table ecoengine
#' @importFrom rbison bison bison_data
#' @importFrom plyr compact
#' @importFrom lubridate now
#' @param query A single name. Either a scientific name 
#' or a common name. Specify whether a scientific or common name in the type parameter.
#' Only scientific names supported right now.
#' @template occtemp
#' @export
#' @examples \dontrun{
#' # Single data sources
#' occ(query = 'Accipiter striatus', from = 'gbif')
#' occ(query = 'Accipiter striatus', from = 'ecoengine')
#' occ(query = 'Danaus plexippus', from = 'inat')
#' occ(query = 'Bison bison', from = 'bison')
#' occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'))
#' occ(query = 'Spinus tristis', from = 'ebird', ebirdopts = list(method = 'ebirdgeo', lat = 42, lng = -76, dist = 50))
#' 
#' # Many data sources
#' out <- occ(query = 'Pinus contorta')
#' 
#' ## Select individual elements
#' out$gbif
#' out$gbif$data
#' 
#' ## Coerce to combined data.frame, selects minimal set of columns (name, lat, long)
#' occ2df(out)
#' 
#' # Many data sources, another example
#' ebirdopts = list(region = 'US'); gbifopts  =  list(country = 'US')
#' out <- occ(query = 'Setophaga caerulescens', from = c('gbif','bison','inat','ebird'), gbifopts = gbifopts, ebirdopts = ebirdopts)
#' occ2df(out)
#' 
#' ## Using a bounding box
#' bounds <- c(38.44047,-125,40.86652,-121.837)
#' aoibbox <- '-111.31,38.81,-110.57,39.21'
#' get_inat_obs(query='Mule Deer', bounds = bounds)
#' occ(query='Danaus plexippus', )
#' 
#' # Pass in many species names
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))
#' occ2df(out)
#' }
occ <- function(query = NULL, from = c("gbif", "bison", "inat", "ebird"), rank = "species", 
    type = "sci", gbifopts = list(), bisonopts = list(), inatopts = list(), ebirdopts = list(), ecoengineopts = list()) {
    out_gbif <- out_bison <- out_inat <- out_ebird <- data.frame(NULL)
    sources <- match.arg(from, choices = c("gbif", "bison", "inat", "ebird", "ecoengine"), several.ok = TRUE)
    loopfun <- function(x) {
        gbif_res <- foo_gbif(sources, x, gbifopts)
        bison_res <- foo_bison(sources, x, bisonopts)
        inat_res <- foo_inat(sources, x, inatopts)
        ebird_res <- foo_ebird(sources, x, ebirdopts)
        ecoengine_res <- foo_ecoengine(sources, x, ecoengineopts)
        list(gbif = gbif_res, bison = bison_res, inat = inat_res, ebird = ebird_res, ecoengine = ecoengine_res)
    }
    tmp <- lapply(query, loopfun)
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
    p <- list(gbif = gbif_sp, bison = bison_sp, inat = inat_sp, ebird = ebird_sp, ecoengine = ecoengine_sp)
    class(p) <- "occdat"
    return(p)
}
# Plugins for the occ function for each data source
foo_gbif <- function(sources, query, opts) {
    if (any(grepl("gbif", sources))) {
        time <- now()
        opts$taxonKey <- name_backbone(name = query)$usageKey
        opts$return <- "data"
        out <- do.call(occ_search, opts)
        if(class(out)=="character"){
          list(time=time, data=data.frame(name=NA, key=NA, longitude=NA, latitude=NA, prov="gbif"))
        } else
        {
          out$prov <- rep("gbif", nrow(out))
          out$name <- as.character(out$name)
          list(time=time, data=out)
        }
    } else {
        list(time = NULL, data = data.frame(NULL))
    }
    # list(meta=meta, data=out)
}
foo_ecoengine <- function(sources, query, opts) {
    if (any(grepl("ecoengine", sources))) {
        time <- now()
        opts$scientific_name <- query
        opts$georeferenced = TRUE
        # This could hang things if request is super large.
        if(is.null(opts$page)) { opts$page <- "all" }
        opts$quiet <- TRUE
        opts$progress <- FALSE
        out_ee <- do.call(ee_observations, opts)
        out <- out_ee$data
        out$prov <- rep("ecoengine", nrow(out))
        list(time = time, data = out)
        # meta <- list(source='ecoengine', time=time, query=query, type=type, opts=opts)
    } else {
        # meta <- list(source='ecoengine', time=NULL, query=NULL, type=NULL, opts=list())
        list(time = NULL, data = data.frame(NULL))
    }
    # list(meta=meta, data=out)
}
foo_bison <- function(sources, query, opts) {
    if (any(grepl("bison", sources))) {
        time <- now()
        opts$species <- query
        out <- do.call(bison, opts)
        out <- bison_data(out, datatype = "data_df")
        out$prov <- rep("bison", nrow(out))
        list(time = time, data = out)
        # meta <- list(source='bison', time=time, query=query, type=type, opts=opts)
    } else {
        # meta <- list(source='bison', time=NULL, query=NULL, type=NULL, opts=list()) out
        # <- data.frame(NULL)
        list(time = NULL, data = data.frame(NULL))
    }
    # list(meta=meta, data=out)
}
foo_inat <- function(sources, query, opts) {
    if (any(grepl("inat", sources))) {
        time <- now()
        opts$query <- query
        out <- do.call(get_inat_obs, opts)
        out$prov <- rep("inat", nrow(out))
        list(time = time, data = out)
        # meta <- list(source='inat', time=time, query=query, type=type, opts=opts)
    } else {
        # meta <- list(source='inat', time=NULL, query=NULL, type=NULL, opts=list()) out
        # <- data.frame(NULL)
        list(time = NULL, data = data.frame(NULL))
    }
    # list(meta=meta, data=out)
}
foo_ebird <- function(sources, query, opts) {
    if (any(grepl("ebird", sources))) {
        time <- now()
        if (is.null(opts$method)) 
            opts$method <- "ebirdregion"
        if (!opts$method %in% c("ebirdregion", "ebirdgeo")) 
            stop("ebird method must be one of ebirdregion or ebirdgeo")
        opts$species <- query
        if (opts$method == "ebirdregion") {
            out <- do.call(ebirdregion, opts[!names(opts) %in% "method"])
        } else {
            out <- do.call(ebirdgeo, opts[!names(opts) %in% "method"])
        }
        out$prov <- rep("ebird", nrow(out))
        list(time = time, data = out)
        # meta <- list(source='ebird', time=time, query=query, type=type, opts=opts)
    } else {
        # meta <- list(source='ebird', time=NULL, query=NULL, type=NULL, opts=list()) out
        # <- data.frame(NULL)
        list(time = NULL, data = data.frame(NULL))
    }
    # list(meta=meta, data=out)
} 
