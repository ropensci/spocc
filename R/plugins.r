# Plugins for the occ function for each data source
## helper functions
move_cols <- function(x, y)
  x[ c(y, names(x)[-sapply(y, function(z) grep(paste0('\\b', z, '\\b'), names(x)))]) ]

emptylist <- function(opts) list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)

stand_latlon <- function(x){
  lngs <- c('decimalLongitude', 'decimallongitude', 'Longitude', 'lng', 'longitude', 
            'decimal_longitude', 'geopoint.lon')
  lats <- c('decimalLatitude', 'decimallatitude', 'Latitude', 'lat', 'latitude', 
            'decimal_latitude', 'geopoint.lat')
  names(x)[ names(x) %in% lngs ] <- 'longitude'
  names(x)[ names(x) %in% lats ] <- 'latitude'
  x
}

add_latlong_if_missing <- function(x) {
  if (is.null(x$longitude)) x$longitude <- NA
  if (is.null(x$latitude)) x$latitude <- NA
  return(x)
}

stand_dates <- function(dat, from){
  datevars <- list(gbif = 'eventDate', bison = c('eventDate', 'year'), inat = 'datetime',
                   ebird = 'obsDt', ecoengine = 'begin_date', vertnet = 'eventdate', 
                   idigbio = 'datecollected')
  var <- datevars[[from]]
  if (from == "bison") {
    var <- if ( is.null(dat$eventDate) ) "year" else "eventDate"
  }
  if ( is.null(dat[[var]]) ) {
    dat
  } else {
    dat[[var]] <- switch(from,
                         gbif = ymd_hms(dat[[var]], truncated = 3, quiet = TRUE),
                         bison = ydm_hm(dat[[var]], truncated = 6, quiet = TRUE),
                         inat = ymd_hms(dat[[var]], truncated = 3, quiet = TRUE),
                         ebird = ymd_hm(dat[[var]], truncated = 3, quiet = TRUE),
                         ecoengine = ymd(dat[[var]], truncated = 3, quiet = TRUE),
                         vertnet = ymd(dat[[var]], truncated = 3, quiet = TRUE),
                         idigbio = ymd_hms(dat[[var]], truncated = 3, quiet = TRUE)
    )
    if (from == "bison") rename(dat, setNames('date', var)) else dat
  }
}

## the plugins
#' @noRd
foo_gbif <- function(sources, query, limit, geometry, has_coords, callopts, opts) {
  if (any(grepl("gbif", sources))) {
    
    opts$hasCoordinate <- has_coords
    if (!is.null(query)) {
      if (class(query) %in% c("ids", "gbifid")) {
        if (class(query) %in% "ids") {
          query_use <- opts$taxonKey <- query$gbif
        } else {
          query_use <- opts$taxonKey <- query
        }
      } else {
        query_use <- query
        if (is.null(query_use)) {
          warning(sprintf("No GBIF result found for %s", query))
        } else {
          opts$scientificName <- query_use
        }
      }
    } else {
      query_use <- NULL
    }
    
    if (is.null(query_use) && is.null(geometry)) {
      warning(sprintf("No records found in GBIF for %s", query), call. = FALSE)
      emptylist(opts)
    } else {
      time <- now()
      if (!'limit' %in% names(opts)) opts$limit <- limit
      opts$fields <- 'all'
      if (!is.null(geometry)) {
        opts$geometry <- if (grepl('POLYGON', paste(as.character(geometry), collapse = " "))) {
          geometry
        } else {
          bbox2wkt(bbox = geometry)
        }
      }
      opts$config <- callopts
      out <- tryCatch(do.call("occ_search", opts), error = function(e) e)
      if (is(out, "simpleError")) {
        warning(sprintf("No records found in GBIF for %s", query), call. = FALSE)
        list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
      } else {
        if (class(out) == "character") { emptylist(opts) } else {
          if (class(out$data) == "character") { emptylist(opts) } else {
            dat <- out$data
            dat$prov <- rep("gbif", nrow(dat))
            dat$name <- as.character(dat$name)
            cols <- c('name', 'decimalLongitude', 'decimalLatitude', 'issues', 'prov')
            cols <- cols[ cols %in% sort(names(dat)) ]
            dat <- move_cols(x = dat, y = cols)
            dat <- stand_latlon(dat)
            dat <- add_latlong_if_missing(dat)
            dat <- stand_dates(dat, "gbif")
            list(time = time, found = out$meta$count, data = dat, opts = opts)
          }
        }
      }
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_ecoengine <- function(sources, query, limit, geometry, has_coords, callopts, opts) {
  if (any(grepl("ecoengine", sources))) {
    opts <- limit_alias(opts, "ecoengine")
    time <- now()
    opts$georeferenced <- has_coords
    opts$scientific_name <- query
    opts$georeferenced <- TRUE
    if (!'page_size' %in% names(opts)) opts$page_size <- limit
    if (!is.null(geometry)) {
      opts$bbox <- if (grepl('POLYGON', paste(as.character(geometry), collapse = " "))) {
        wkt2bbox(geometry) 
      } else {
        geometry 
      }
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
    opts$foptions <- callopts
    out_ee <- tryCatch(do.call(ee_observations, opts), error = function(e) e)
    if (out_ee$results == 0 || is(out_ee, "simpleError")) {
      warning(sprintf("No records found in Ecoengine for %s", query), call. = FALSE)
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      out <- out_ee$data
      fac_tors <- sapply(out, is.factor)
      out[fac_tors] <- lapply(out[fac_tors], as.character)
      names(out)[names(out) == 'record'] <- "key"
      out$prov <- rep("ecoengine", nrow(out))
      names(out)[names(out) == 'scientific_name'] <- "name"
      out <- add_latlong_if_missing(out)
      out <- stand_dates(out, "ecoengine")
      list(time = time, found = out_ee$results, data = out, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}


#' @noRd
foo_antweb <- function(sources, query, limit, geometry, has_coords, callopts, opts) {
  if (any(grepl("antweb", sources))) {
    time <- now()
    opts$georeferenced <- has_coords
    # limit <- NULL
    geometry <- NULL

    query <- sub("^ +", "", query)
    query <- sub(" +$", "", query)

    if (length(strsplit(query, " ")[[1]]) == 2) {
      opts$scientific_name <- query
    } else {
      opts$genus <- query
      opts$scientific_name <- NULL
    }

    if(!'limit' %in% names(opts)) opts$limit <- limit
    out <- tryCatch(do.call(aw_data, opts), error = function(e) e)

    if(is.null(out) || is(out, "simpleError")){
      warning(sprintf("No records found in AntWeb for %s", query), call. = FALSE)
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      res <- out$data
      res$prov <- rep("antweb", nrow(res))
      res$name <- query
      res <- stand_latlon(res)
      res <- add_latlong_if_missing(res)
      list(time = time, found = out$count, data = res, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

#' @noRd
foo_bison <- function(sources, query, limit, geometry, callopts, opts) {
  if(any(grepl("bison", sources))) {
    opts <- limit_alias(opts, "bison", geometry)
    if(class(query) %in% c("ids","tsn")){
      if(class(query) %in% "ids"){
        opts$TSNs <- query$itis
      } else {
        opts$TSNs <- query
      }
      bisonfxn <- "bison_solr"
    } else {
      if(is.null(geometry)){
        opts$scientificName <- query
        bisonfxn <- "bison_solr"
      } else {
        opts$species <- query
        bisonfxn <- "bison"
      }
    }

    time <- now()
    opts$verbose <- FALSE

    if(bisonfxn == "bison"){
      if(!'count' %in% names(opts)) opts$count <- limit
      opts$config <- callopts
    } else {
      if(!'rows' %in% names(opts)) opts$rows <- limit
      opts$callopts <- callopts
    }

    if(!is.null(geometry)){
      opts$aoi <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){
        geometry
      } else {
        bbox2wkt(bbox=geometry)
      }
    }
    out <- tryCatch(do.call(eval(parse(text = bisonfxn)), opts), error = function(e) e)
    if (is.null(out$points) || is(out, "simpleError")){
      warning(sprintf("No records found in Bison for %s", query), call. = FALSE)
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      dat <- out$points
      dat$prov <- rep("bison", nrow(dat))
      if(bisonfxn == "bison_solr") dat <- rename(dat, c('scientificName' = 'name'))
      dat <- stand_latlon(dat)
      dat <- add_latlong_if_missing(dat)
      dat <- stand_dates(dat, "bison")
      found <- if(bisonfxn == "bison_solr") out$num_found else out$summary$total
      list(time = time, found = found, data = dat, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}


#' @noRd
foo_inat <- function(sources, query, limit, geometry, has_coords, callopts, opts) {
  if (any(grepl("inat", sources))) {
    opts <- limit_alias(opts, "inat")
    opts$geo <- has_coords
    time <- now()
    opts$query <- query
    if (!'maxresults' %in% names(opts)) opts$maxresults <- limit
    opts$meta <- TRUE
    if (!is.null(geometry)) {
      opts$bounds <- if (grepl('POLYGON', paste(as.character(geometry), collapse = " "))) {
        # flip lat  and long spots in the bounds vector for inat
        temp <- wkt2bbox(geometry)
        c(temp[2], temp[1], temp[4], temp[3])
      } else {
        c(geometry[2], geometry[1], geometry[4], geometry[3])
      }
    }
    out <- tryCatch(do.call(spocc_inat_obs, opts), error = function(e) e)
    if (!is.data.frame(out$data) || is(out, "simpleError")) {
      warning(sprintf("No records found in INAT for %s", query), call. = FALSE)
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      res <- out$data
      res$prov <- rep("inat", nrow(res))
      res <- rename(res, c('scientific_name' = 'name'))
      res <- stand_latlon(res)
      res <- add_latlong_if_missing(res)
      res <- stand_dates(res, "inat")
      list(time = time, found = out$meta$found, data = res, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

#' @noRd
foo_ebird <- function(sources, query, limit, callopts, opts) {
  if (any(grepl("ebird", sources))) {
    opts <- limit_alias(opts, "ebird")
    time <- now()
    if (is.null(opts$method))
      opts$method <- "ebirdregion"
    if (!opts$method %in% c("ebirdregion", "ebirdgeo"))
      stop("ebird method must be one of ebirdregion or ebirdgeo")
    opts$species <- query
    if (!'max' %in% names(opts)) opts$max <- limit
    opts$config <- callopts
    if (opts$method == "ebirdregion") {
      if (is.null(opts$region)) opts$region <- "US"
      out <- tryCatch(do.call(ebirdregion, opts[!names(opts) %in% "method"]), error = function(e) e)
    } else {
      out <- tryCatch(do.call(ebirdgeo, opts[!names(opts) %in% "method"]), error = function(e) e)
    }
    if (!is.data.frame(out) || is(out, "simpleError")) {
      warning(sprintf("No records found in eBird for %s", query), call. = FALSE)
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      out$prov <- rep("ebird", nrow(out))
      names(out)[names(out) == 'sciName'] <- "name"
      out <- stand_latlon(out)
      out <- add_latlong_if_missing(out)
      out <- stand_dates(out, "ebird")
      list(time = time, found = NULL, data = out, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

#' @noRd
foo_vertnet <- function(sources, query, limit, has_coords, callopts, opts) {
  if (any(grepl("vertnet", sources))) {
    time <- now()
    if (!is.null(has_coords)) {
      opts$mappable <- ifelse(has_coords, 1, 0)
    }
    opts$taxon <- query
    opts$verbose <- FALSE
    if (!'limit' %in% names(opts)) opts$limit <- limit
    opts$config <- callopts
    out <- tryCatch(do.call(vertsearch, opts), error = function(e) e)
    if (!is.data.frame(out$data) || is(out, "simpleError")) {
      warning(sprintf("No records found in VertNet for %s", query), call. = FALSE)
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      df <- out$data
      df$prov <- rep("vertnet", NROW(df))
      df <- rename(df, c('scientificname' = 'name'))
      cols <- c('name', 'decimallongitude', 'decimallatitude', 'prov')
      cols <- cols[ cols %in% sort(names(df)) ]
      df <- move_cols(x = df, y = cols)
      df <- stand_latlon(df)
      df <- add_latlong_if_missing(df)
      df <- stand_dates(df, "vertnet")
      names(df) <- tolower(names(df))
      list(time = time, found = as.numeric(gsub(">|<", "", out$meta$matching_records)), data = df, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

#' @noRd
foo_idigbio <- function(sources, query, limit, geometry, has_coords, callopts, opts) {
  if (any(grepl("idigbio", sources))) {
    # opts <- limit_alias(opts, "idigbio")
    time <- now()
    
    addopts <- list()
    if (!is.null(query)) addopts$rq <- list(scientificname = query)
    if (!is.null(has_coords)) opts$rq$geopoint <- if (has_coords) {
      list(type = "exists")
    } else {
      list(type = "missing")
    }
    
    if (!is.null(geometry)) {
      if (grepl('POLYGON', paste(as.character(geometry), collapse = " "))) {
        geometry <- wkt2bbox(geometry)
      }
      addopts$rq <- if (is.numeric(geometry) && length(geometry) == 4) {
        list(geopoint = list(
          type = "geo_bounding_box", 
          top_left = list(
            lat = geometry[4], lon = geometry[1]
          ), 
          bottom_right = list(
            lat = geometry[2], lon = geometry[3]
          )
        ))
      } else {
        geometry
      }
    }
    
    if ("rq" %in% names(opts)) {
      opts$rq <- c(addopts$rq, opts$rq)
    } else {
      opts$rq <- addopts$rq
    }
    
    if (is.null(opts$limit)) opts$limit <- limit
    opts$fields <- "all"
    
    out <- tryCatch(do.call(idig_search_records, opts), error = function(e) e)
    if (is(out, "simpleError")) {
      warning(sprintf("No records found in iDigBio for %s", query))
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      out$prov <- rep("idigbio", nrow(out))
      out <- rename(out, c('scientificname' = 'name'))
      out <- add_latlong(out, nms = c('geopoint.lon', 'geopoint.lat'))
      out <- stand_latlon(out)
      out <- add_latlong_if_missing(out)
      out <- stand_dates(out, "idigbio")
      list(time = time, found = attr(out, "itemCount"), data = out, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

limit_alias <- function(x, sources, geometry=NULL){
  bisonvar <- if (is.null(geometry)) 'rows' else 'count'
  if (length(x) != 0) {
    lim_name <- switch(sources, ecoengine = "page_size", bison = bisonvar, inat = "maxresults", ebird = "max")
    if ("limit" %in% names(x)) {
      names(x)[ which(names(x) == "limit") ] <- lim_name
      x
    } else {
      x
    }
  } else {
    x
  }
}

add_latlong <- function(x, nms) {
  for (i in seq_along(nms)) {
    if (!nms[[i]] %in% names(x)) {
      x[[nms[[i]]]] <- NA
    }
  }
  return(x)
}
