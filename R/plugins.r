throw_error <- function(src, x) {
  if (as.logical(Sys.getenv("SPOCC_THROW_ERRORS", FALSE))) {
    warning(src, ": ", x, call. = FALSE)
  }
}

# Plugins for the occ function for each data source
## the plugins
#' @noRd
foo_gbif <- function(sources, query, limit, start, geometry, has_coords,
                     date, callopts, opts) {
  if (any(grepl("gbif", sources))) {

    opts$hasCoordinate <- has_coords
    # skip WKT validation for now, GBIF follows "left hand rule"
    opts$skip_validate <- TRUE
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
    if (!is.null(date)) {
      if (length(date) != 2) stop("'date' for GBIF must be length 2")
      opts$eventDate <- paste0(date, collapse = ",")
    }

    if (is.null(query_use) && is.null(geometry) && length(opts) == 0) {
      warning(sprintf("No records returned in GBIF for %s", query), call. = FALSE)
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
      if (inherits(out, "error")) {
        throw_error("gbif", sprintf("No records returned in GBIF for %s", query))
        throw_error("gbif", out$message)
        emptylist(opts, out$message)
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
                 data = as_tibble(dat), opts = opts)
          }
        }
      }
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_bison <- function(sources, query, limit, start, geometry, date, 
  callopts, opts) {

  if (any(grepl("bison", sources))) {
    opts <- limit_alias(opts, "bison", geometry)
    if (class(query) %in% c("ids","tsn")) {
      if (class(query) %in% "ids") {
        opts$TSNs <- query$itis
      } else {
        opts$TSNs <- query
      }
      if (!is.null(date)) opts$eventDate <- date
      bisonfxn <- "bison_solr"
    } else {
      if (is.null(geometry)) {
        opts$ITISscientificName <- query
        if (!is.null(date)) opts$eventDate <- date
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
      throw_error("bison", 
        sprintf("No records returned in Bison for %s", query))
      throw_error("bison", out$message)
      emptylist(opts, out$message)
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
      list(time = time, found = found, data = as_tibble(dat), opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_inat <- function(sources, query, limit, page, geometry, has_coords,
                     date, callopts, opts) {

  if (any(grepl("inat", sources))) {
    opts <- limit_alias(opts, "inat")
    opts$geo <- has_coords
    time <- now()
    opts$taxon_name <- query
    if (!"maxresults" %in% names(opts)) opts$maxresults <- limit
    if (!"page" %in% names(opts)) opts$page <- page
    if (!is.null(geometry)) {
      opts$bounds <- if (grepl("POLYGON", paste(as.character(geometry),
                                                collapse = " "))) {
        # flip lat  and long spots in the bounds vector for inat
        temp <- wkt2bbox(geometry)
        c(temp[2], temp[1], temp[4], temp[3])
      } else {
        c(geometry[2], geometry[1], geometry[4], geometry[3])
      }
    }
    if (!is.null(date)) {
      if (length(date) != 2) stop("'date' for Inaturalist must be length 2")
      opts$date_start <- date[1]
      opts$date_end <- date[2]
    }
    opts$callopts <- callopts
    out <- tryCatch(do.call("spocc_inat_obs", opts), error = function(e) e)
    if (!is.data.frame(out$data) || inherits(out, "simpleError")) {
      throw_error("inat",
        sprintf("No records returned in INAT for %s", query))
      throw_error("inat", out$message)
      emptylist(opts, out$message)
    } else{
      res <- out$data
      res$prov <- rep("inat", nrow(res))
      res <- rename(res, c("taxon.name" = "name"))
      # pull out lon/lat from geojson field
      cds <- res$geojson.coordinates
      lons <- sapply(cds, "[[", 1)
      lons[vapply(lons, is.null, logical(1))] <- NA_character_
      res$longitude <- unlist(lons)
      lats <- sapply(cds, "[[", 2)
      lats[vapply(lats, is.null, logical(1))] <- NA_character_
      res$latitude <- unlist(lats)
      res <- stand_latlon(res)
      res <- add_latlong_if_missing(res)
      res <- stand_dates(res, "inat")
      list(time = time, found = out$meta$found, data = as_tibble(res),
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
    spnm <- tryCatch(suppressMessages(rebird::species_code(query)), 
      error = function(e) e)
    if (inherits(spnm, "error")) {
      warning(spnm$message, ": ", query, call. = FALSE)
      return(emptylist(opts, spnm$message))
    }
    opts$species <- spnm
    if (!'max' %in% names(opts)) opts$max <- limit
    opts$opts <- callopts
    if (opts$method == "ebirdregion") {
      if (is.null(opts$loc)) opts$loc <- "US"
      out <- tryCatch(do.call(spocc_ebird_region, opts[!names(opts) %in% "method"]),
                      error = function(e) e, warning = function(w) w)
    } else {
      out <- tryCatch(do.call(spocc_ebirdgeo, opts[!names(opts) %in% "method"]),
                      error = function(e) e, warning = function(w) w)
    }
    if (!is.data.frame(out) || inherits(out, "simpleError") || NROW(out) == 0) {
      throw_error("ebird", 
        sprintf("No records returned in eBird for %s", query))
      throw_error("ebird", out$message)
      emptylist(opts, out$message)
    } else {
      out$prov <- rep("ebird", nrow(out))
      names(out)[names(out) == 'sciName'] <- "name"
      out <- stand_latlon(out)
      out <- add_latlong_if_missing(out)
      out <- stand_dates(out, "ebird")
      list(time = time, found = NULL, data = as_tibble(out), opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_vertnet <- function(sources, query, limit, has_coords, date, callopts, opts) {
  if (any(grepl("vertnet", sources))) {
    time <- now()
    if (!is.null(has_coords)) {
      opts$mappable <- has_coords
    }
    opts$scientificname <- query
    opts$messages <- FALSE
    if (!is.null(date)) {
      if (length(date) != 2) stop("'date' for Vertnet must be length 2")
      date <- tryCatch(as.Date(date), error = function(e) e)
      if (inherits(date, "error")) stop("'date' values do not appear to be dates")
      opts$year <- c(paste0('>=', format(date[1], "%Y")),
        paste0('<=', format(date[2], "%Y")))
      opts$month <- c(paste0('>=', as.numeric(format(date[1], "%m"))),
        paste0('<=', as.numeric(format(date[2], "%m"))))
      opts$day <- c(paste0('>=', as.numeric(format(date[1], "%d"))),
        paste0('<=', as.numeric(format(date[2], "%d"))))
    }
    if (!'limit' %in% names(opts)) opts$limit <- limit
    opts$callopts <- callopts
    out <- tryCatch(do.call(rvertnet::searchbyterm, opts),
                    error = function(e) e)
    if (!is.data.frame(out$data) || inherits(out, "simpleError")) {
      throw_error("vertnet", 
        sprintf("No records returned in VertNet for %s", query))
      throw_error("vertnet", out$message)
      emptylist(opts, out$message)
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
           data = as_tibble(df), opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_idigbio <- function(sources, query, limit, start, geometry, has_coords,
                        date, callopts, opts) {
  if (any(grepl("idigbio", sources))) {
    time <- now()

    addopts <- list()
    if (!is.null(query)) addopts$rq <- list(scientificname = query)
    if (!is.null(has_coords)) opts$rq$geopoint <- if (has_coords) {
      list(type = "exists")
    } else {
      list(type = "missing")
    }

    if (!is.null(date)) {
      if (length(date) != 2) stop("'date' for IdigBio must be length 2")
      opts$rq$datecollected <- list(type = "range", gte = date[1], lte = date[2])
    }

    if (!is.null(geometry)) {
      if (grepl('POLYGON', paste(as.character(geometry), collapse = " "))) {
        geometry <- unlist(unname(c(wkt2bbox(geometry))))
      }
      # force all geometry requests into this format if possible
      addopts$rq <- c(addopts$rq, 
        list(geopoint = list(
          type = "geo_bounding_box",
          top_left = list(
            lat = geometry[4], lon = geometry[1]
          ),
          bottom_right = list(
            lat = geometry[2], lon = geometry[3]
          )
        ))
      )
    }

    if ("rq" %in% names(opts)) {
      opts$rq <- c(addopts$rq, opts$rq)
    } else {
      opts$rq <- addopts$rq
    }

    if (!"limit" %in% names(opts)) opts$limit <- limit
    if (!'offset' %in% names(opts)) opts$offset <- start
    if (is.null(opts$fields)) opts$fields <- "all"

    opts$config <- callopts

    out <- tryCatch(suppressWarnings(
      do.call(ridigbio::idig_search_records, opts)), error = function(e) e)
    if (inherits(out, "simpleError")) {
      throw_error("idigbio", 
        sprintf("No records returned in iDigBio for %s", query))
      throw_error("idigbio", out$message)
      emptylist(opts, out$message)
    } else{
      out$prov <- rep("idigbio", nrow(out))
      out <- rename(out, c('scientificname' = 'name'))
      out <- add_latlong(out, nms = c('geopoint.lon', 'geopoint.lat'))
      out <- stand_latlon(out)
      out <- add_latlong_if_missing(out)
      out <- stand_dates(out, "idigbio")
      list(time = time, found = attr(out, "itemCount"),
           data = as_tibble(out), opts = opts)
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
foo_obis <- function(sources, query, limit, start, geometry, has_coords,
                     date, callopts, opts) {

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

    if (!is.null(date)) {
      if (length(date) != 2) stop("'date' for OBIS must be length 2")
      opts$startdate <- date[1]
      opts$enddate <- date[2]
    }

    if (!"limit" %in% names(opts)) opts$size <- limit
    if (!'offset' %in% names(opts)) opts$offset <- start

    opts <- c(opts, callopts)

    tmp <- tryCatch(do.call(obis_search, opts), error = function(e) e)
    if (inherits(tmp, "simpleError") || "error" %in% names(tmp)) {
      throw_error("obis", 
        sprintf("No records returned in OBIS for %s", query))
      throw_error("obis", tmp$error)
      emptylist(opts, tmp$error)
    } else {
      if (!"results" %in% names(tmp)) {
        warning(sprintf("No records returned in OBIS for %s", query))
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
                    date, callopts, opts) {

  if (any(grepl("ala", sources))) {
    time <- now()
    opts$taxon <- sprintf('taxon_name:"%s"', query)
    if (!is.null(date)) {
      if (length(date) != 2) stop("'date' for ALA must be length 2")
      opts$taxon <- paste0(opts$taxon, sprintf(" occurrence_date:[%s TO %s]", date[1], date[2]))
    }

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
    if (inherits(tmp, "error")) {
      throw_error("ala", 
        sprintf("No records returned in ALA for %s", query))
      throw_error("ala", tmp$message)
      emptylist(opts, tmp$message)
    } else {
      if (!"occurrences" %in% names(tmp)) {
        warning(sprintf("No records returned in ALA for %s", query))
        emptylist(opts)
      } else {
        if (!length(tmp$occurrences)) {
          warning(sprintf("No records returned in ALA for %s", query))
          emptylist(opts)
        } else {
          out <- tmp$occurrences
          out$prov <- rep("ala", NROW(out))
          out <- rename(out, c('scientificName' = 'name'))
          out <- add_latlong(out, nms = c('decimalLongitude', 'decimalLatitude'))
          out <- stand_latlon(out)
          out <- add_latlong_if_missing(out)
          out <- stand_dates(out, "ala")
          list(time = time, found = tmp$totalRecords, data = out, opts = opts)
        }
      }
    }
  } else {
    emptylist(opts)
  }
}
