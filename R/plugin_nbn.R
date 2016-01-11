#' @noRd
foo_nbn <- function(sources, query, limit, start, geometry, has_coords, callopts, opts) {
  if (any(grepl("nbn", sources))) {
    if (class(query) %in% c("ids", "nbnid")) {
      if (class(query) %in% "ids") {
        opts$tvks <- query$nbnid
      } else {
        opts$tvks <- query[1]
      }
    } else {
      chekforpkg('taxize')
      opts$tvks <- taxize::get_nbnid(query)[1]
    }
    
    time <- now()
    
    if (!is.null(geometry)) {
      opts$polygon <- if (grepl('POLYGON', paste(as.character(geometry), collapse = " "))) {
        geometry
      } else {
        bbox2wkt(bbox = geometry)
      }
    }
    
    opts$silent <- TRUE
    opts$acceptTandC <- TRUE
    tmp <- tryCatch(do.call(getOccurrences, opts), error = function(e) e)
    if (is(tmp, "simpleError") || "message" %in% names(tmp)) {
      warning(sprintf("No records found in NBN for %s", query))
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else {
      tmp$prov <- rep("nbn", NROW(tmp))
      tmp <- rename(tmp, c('pTaxonName' = 'name'))
      tmp <- add_latlong_if_missing(tmp)
      list(time = time, found = NROW(tmp), data = tmp, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

chekforpkg <- function(x) {
  if (!requireNamespace(x, quietly = TRUE)) {
    stop("Please install ", x, call. = FALSE)
  }
}
