#' @noRd
foo_gbif_dload <- function(sources, query, limit, start, geometry, has_coords,
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
