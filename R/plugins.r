# Plugins for the occ function for each data source
## the plugins
#' @noRd
foo_gbif <- function(sources, query, limit, start, geometry, has_coords, 
                     callopts, opts) {
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

    if (is.null(query_use) && is.null(geometry) && length(opts) == 0) {
      warning(sprintf("No records found in GBIF for %s", query), call. = FALSE)
      emptylist(opts)
    } else {
      time <- now()
      if (!'limit' %in% names(opts)) opts$limit <- limit
      if (!'start' %in% names(opts)) opts$start <- start
      if (!is.null(geometry)) {
        opts$geometry <- if (grepl('POLYGON', paste(as.character(geometry), 
                                                    collapse = " "))) {
          geometry
        } else {
          bbox2wkt(bbox = geometry)
        }
      }
      if (length(callopts) > 0) opts$curlopts <- callopts
      out <- tryCatch(do.call("occ_data", opts), error = function(e) e)
      if (inherits(out, "simpleError")) {
        warning(sprintf("No records found in GBIF for %s", query), 
                call. = FALSE)
        emptylist(opts)
      } else {
        if (inherits(out, "character")) { 
          emptylist(opts) 
        } else {
          if (
            all(names(out) %in% c('meta', 'data')) && 
              (is.null(out$data) || 
              inherits(out$data, "character"))
          ) {
            emptylist(opts)
          } else {
            if (length(out) > 1 && !all(c('meta', 'data') %in% names(out))) {
              dat <- setDF(rbindlist(lapply(out, "[[", "data"), 
                                     fill = TRUE, use.names = TRUE))
            } else {
              dat <- out$data
            }
            if (NROW(dat) == 0) {
              return(emptylist(opts))
            }
            dat$prov <- rep("gbif", nrow(dat))
            dat$name <- as.character(dat$name)
            cols <- c('name', 'decimalLongitude', 'decimalLatitude', 
                      'issues', 'prov')
            cols <- cols[ cols %in% sort(names(dat)) ]
            dat <- move_cols(x = dat, y = cols)
            dat <- stand_latlon(dat)
            dat <- add_latlong_if_missing(dat)
            dat <- stand_dates(dat, "gbif")
            list(time = time, found = out$meta$count,
                 data = as_data_frame(dat), opts = opts)
          }
        }
      }
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_ecoengine <- function(sources, query, limit, page, geometry, has_coords, 
                          callopts, opts) {
  if (any(grepl("ecoengine", sources))) {
    opts <- limit_alias(opts, "ecoengine")
    time <- now()
    opts$georeferenced <- has_coords
    opts$scientific_name <- query
    #opts$georeferenced <- TRUE
    if (!'page_size' %in% names(opts)) opts$page_size <- limit
    if (!'page' %in% names(opts)) opts$page <- page
    if (!is.null(geometry)) {
      opts$bbox <- if (grepl('POLYGON', paste(as.character(geometry), 
                                              collapse = " "))) {
        paste0(wkt2bbox(geometry), collapse = ",")
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
    out_ee <- tryCatch(do.call(ee_observations2, opts), error = function(e) e)
    if (out_ee$results == 0 || inherits(out_ee, "simpleError")) {
      warning(sprintf("No records found in Ecoengine for %s",
        if (is.null(query)) paste0(substr(geometry, 1, 20), ' ...') else query
      ), call. = FALSE)
      emptylist(opts)
    } else{
      out <- out_ee$data
      fac_tors <- sapply(out, is.factor)
      out[fac_tors] <- lapply(out[fac_tors], as.character)
      names(out)[names(out) == 'record'] <- "key"
      out$prov <- rep("ecoengine", nrow(out))
      names(out)[names(out) == 'scientific_name'] <- "name"
      out <- add_latlong_if_missing(out)
      out <- stand_dates(out, "ecoengine")
      list(time = time, found = out_ee$results, data = as_data_frame(out), 
           opts = opts)
    }
  } else {
    emptylist(opts)
  }
}


#' @noRd
foo_antweb <- function(sources, query, limit, start, geometry, has_coords, 
                       callopts, opts) {
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

    if (!'limit' %in% names(opts)) opts$limit <- limit
    if (!'offset' %in% names(opts)) opts$offset <- start
    out <- tryCatch(do.call(aw_data2, opts), error = function(e) e)

    if (is.null(out) || inherits(out, "simpleError")) {
      warning(sprintf("No records found in AntWeb for %s", query), 
              call. = FALSE)
      emptylist(opts)
    } else{
      res <- out$data
      res$prov <- rep("antweb", nrow(res))
      res$name <- query
      res <- stand_latlon(res)
      res <- add_latlong_if_missing(res)
      list(time = time, found = out$count, data = as_data_frame(res), 
           opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_bison <- function(sources, query, limit, start, geometry, callopts, opts) {
  if (any(grepl("bison", sources))) {
    opts <- limit_alias(opts, "bison", geometry)
    if (class(query) %in% c("ids","tsn")) {
      if (class(query) %in% "ids") {
        opts$TSNs <- query$itis
      } else {
        opts$TSNs <- query
      }
      bisonfxn <- "bison_solr"
    } else {
      if (is.null(geometry)) {
        opts$scientificName <- query
        bisonfxn <- "bison_solr"
      } else {
        opts$species <- query
        bisonfxn <- "bison"
      }
    }

    time <- now()
    opts$verbose <- FALSE

    if (bisonfxn == "bison") {
      if (!'count' %in% names(opts)) opts$count <- limit
      opts$config <- callopts
    } else {
      if (!'rows' %in% names(opts)) opts$rows <- limit
      opts$callopts <- callopts
    }
    if (!'start' %in% names(opts)) opts$start <- start

    if (!is.null(geometry)) {
      opts$aoi <- if (grepl('POLYGON', paste(as.character(geometry), 
                                             collapse = " "))) {
        geometry
      } else {
        bbox2wkt(bbox = geometry)
      }
    }
    out <- tryCatch(do.call(eval(parse(text = bisonfxn)), opts), 
                    error = function(e) e)
    if (is.null(out$points) || inherits(out, "simpleError")) {
      warning(
        sprintf("No records found in Bison for %s", query), call. = FALSE)
      emptylist(opts)
    } else{
      dat <- out$points
      dat$prov <- rep("bison", nrow(dat))
      if (bisonfxn == "bison_solr") {
        dat <- rename(dat, c('scientificName' = 'name'))
      }
      dat <- stand_latlon(dat)
      dat <- add_latlong_if_missing(dat)
      dat <- stand_dates(dat, "bison")
      found <- if (bisonfxn == "bison_solr") {
        out$num_found 
      } else {
        out$summary$total
      }
      list(time = time, found = found, data = as_data_frame(dat), opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_inat <- function(sources, query, limit, page, geometry, has_coords, 
                     callopts, opts) {
  if (any(grepl("inat", sources))) {
    opts <- limit_alias(opts, "inat")
    opts$geo <- has_coords
    time <- now()
    opts$query <- query
    if (!'maxresults' %in% names(opts)) opts$maxresults <- limit
    if (!'page' %in% names(opts)) opts$page <- page
    if (!is.null(geometry)) {
      opts$bounds <- if (grepl('POLYGON', paste(as.character(geometry), 
                                                collapse = " "))) {
        # flip lat  and long spots in the bounds vector for inat
        temp <- wkt2bbox(geometry)
        c(temp[2], temp[1], temp[4], temp[3])
      } else {
        c(geometry[2], geometry[1], geometry[4], geometry[3])
      }
    }
    opts$callopts <- callopts
    out <- tryCatch(do.call("spocc_inat_obs", opts), error = function(e) e)
    if (!is.data.frame(out$data) || inherits(out, "simpleError")) {
      warning(sprintf("No records found in INAT for %s", query), call. = FALSE)
      emptylist(opts)
    } else{
      res <- out$data
      res$prov <- rep("inat", nrow(res))
      res <- rename(res, c('taxon.name' = 'name'))
      res <- stand_latlon(res)
      res <- add_latlong_if_missing(res)
      res <- stand_dates(res, "inat")
      list(time = time, found = out$meta$found, data = as_data_frame(res),
           opts = opts)
    }
  } else {
    emptylist(opts)
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
      out <- tryCatch(do.call(ebirdregion, opts[!names(opts) %in% "method"]), 
                      error = function(e) e)
    } else {
      out <- tryCatch(do.call(ebirdgeo, opts[!names(opts) %in% "method"]), 
                      error = function(e) e)
    }
    if (!is.data.frame(out) || inherits(out, "simpleError") || NROW(out) == 0) {
      warning(sprintf("No records found in eBird for %s", query), call. = FALSE)
      emptylist(opts)
    } else{
      out$prov <- rep("ebird", nrow(out))
      names(out)[names(out) == 'sciName'] <- "name"
      out <- stand_latlon(out)
      out <- add_latlong_if_missing(out)
      out <- stand_dates(out, "ebird")
      list(time = time, found = NULL, data = as_data_frame(out), opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_vertnet <- function(sources, query, limit, has_coords, callopts, opts) {
  if (any(grepl("vertnet", sources))) {
    time <- now()
    if (!is.null(has_coords)) {
      opts$mappable <- has_coords
    }
    opts$query <- query
    opts$verbose <- FALSE
    if (!'limit' %in% names(opts)) opts$limit <- limit
    opts$config <- callopts
    out <- tryCatch(do.call(rvertnet::searchbyterm, opts), 
                    error = function(e) e)
    if (!is.data.frame(out$data) || inherits(out, "simpleError")) {
      warning(sprintf("No records found in VertNet for %s", query), 
              call. = FALSE)
      emptylist(opts)
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
      list(time = time,
           found = as.numeric(gsub(">|<", "", out$meta$matching_records)),
           data = as_data_frame(df), opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_idigbio <- function(sources, query, limit, start, geometry, has_coords, 
                        callopts, opts) {
  if (any(grepl("idigbio", sources))) {
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
      addopts$rq <- c(addopts$rq, if (is.numeric(geometry) && 
                                      length(geometry) == 4) {
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
      })
    }

    if ("rq" %in% names(opts)) {
      opts$rq <- c(addopts$rq, opts$rq)
    } else {
      opts$rq <- addopts$rq
    }

    if (!"limit" %in% names(opts)) opts$limit <- limit
    if (!'offset' %in% names(opts)) opts$offset <- start
    opts$fields <- "all"

    opts$config <- callopts

    out <- tryCatch(suppressWarnings(
      do.call(ridigbio::idig_search_records, opts)), error = function(e) e)
    if (inherits(out, "simpleError")) {
      # check for meaningful/useful error messages
      warning(out$message)
      #warning(sprintf("No records found in iDigBio for %s", query))
      emptylist(opts)
    } else{
      out$prov <- rep("idigbio", nrow(out))
      out <- rename(out, c('scientificname' = 'name'))
      out <- add_latlong(out, nms = c('geopoint.lon', 'geopoint.lat'))
      out <- stand_latlon(out)
      out <- add_latlong_if_missing(out)
      out <- stand_dates(out, "idigbio")
      list(time = time, found = attr(out, "itemCount"),
           data = as_data_frame(out), opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_obis <- function(sources, query, limit, start, geometry, has_coords, 
                     callopts, opts) {
  
  if (any(grepl("obis", sources))) {
    time <- now()
    opts$scientificName <- query
    
    if (!is.null(geometry)) {
      opts$geometry <- if (grepl('POLYGON', paste(as.character(geometry), 
                                                  collapse = " "))) {
        geometry
      } else {
        bbox2wkt(bbox = geometry)
      }
    }
    
    if (!"limit" %in% names(opts)) opts$limit <- limit
    if (!'offset' %in% names(opts)) opts$offset <- start
    
    opts <- c(opts, callopts)
    
    tmp <- tryCatch(do.call(obis_search, opts), error = function(e) e)
    if (inherits(tmp, "simpleError") || "message" %in% names(tmp)) {
      warning(sprintf("No records found in OBIS for %s", query))
      emptylist(opts)
    } else {
      if (!"results" %in% names(tmp)) {
        warning(sprintf("No records found in OBIS for %s", query))
        emptylist(opts)
      } else {
        out <- tmp$results
        out$prov <- rep("obis", NROW(out))
        out <- rename(out, c('scientificName' = 'name'))
        out <- add_latlong(out, nms = c('decimalLongitude', 'decimalLatitude'))
        out <- stand_latlon(out)
        out <- add_latlong_if_missing(out)
        out <- stand_dates(out, "obis")
        list(time = time, found = tmp$count, data = out, opts = opts)
      }
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_ala <- function(sources, query, limit, start, geometry, has_coords, 
                    callopts, opts) {
  if (any(grepl("ala", sources))) {
    time <- now()
    opts$taxon <- sprintf('taxon_name:"%s"', query)
    
    if (!is.null(geometry)) {
      opts$wkt <- if (grepl('POLYGON', paste(as.character(geometry), 
                                             collapse = " "))) {
        geometry
      } else {
        bbox2wkt(bbox = geometry)
      }
    }
    
    if (!"limit" %in% names(opts)) opts$limit <- limit
    if (!'offset' %in% names(opts)) opts$offset <- start
    
    opts <- c(opts, callopts)
    
    tmp <- tryCatch(do.call(ala_search, opts), error = function(e) e)
    if (inherits(tmp, "simpleError")) {
      warning(sprintf("No records found in ALA for %s", query))
      emptylist(opts)
    } else {
      if (!"occurrences" %in% names(tmp)) {
        warning(sprintf("No records found in ALA for %s", query))
        emptylist(opts)
      } else {
        if (!length(tmp$occurrences)) {
          warning(sprintf("No records found in ALA for %s", query))
          emptylist(opts)
        } else {
          out <- tmp$occurrences
          out$prov <- rep("ala", NROW(out))
          out <- rename(out, c('scientificName' = 'name'))
          out <- add_latlong(out, nms = c('decimalLongitude', 'decimalLatitude'))
          out <- stand_latlon(out)
          out <- add_latlong_if_missing(out)
          out <- stand_dates(out, "ala")
          list(time = time, found = tmp$count, data = out, opts = opts)
        }
      }
    }
  } else {
    emptylist(opts)
  }
}
