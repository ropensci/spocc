#' spocc objects and their print, plot, and summary methods
#'
#'
#' @name spocc_objects
#' @keywords internal
#' @param x Input, of class occdatind
#' @param object Input to summary methods
#' @param ... Further args to print, plot or summary methods
#' @param n Number of rows to show. If `NULL`, the default, will print
#'   all rows if less than option `dplyr.print_max`. Otherwise, will
#'   print `dplyr.print_min`
#'
#' @examples \dontrun{
#' # occdat object
#' res <- occ(query = 'Accipiter striatus', from = 'gbif')
#' res
#' print(res)
#' class(res)
#'
#' # occdatind object
#' res$gbif
#' print(res$gbif)
#' class(res$gbif)
#'
#' # print summary of occdat object
#' summary(res)
#'
#' # print summary of occdatind object
#' summary(res$gbif)
#' 
#' # Geometry based searches print slightly differently
#' bounds <- c(-120, 40, -100, 45)
#' (res <- occ(from = "idigbio", geometry = bounds, limit = 10))
#' res$idigbio
#' ## Many bounding boxes/WKT strings
#' bounds <- list(c(165,-53,180,-29), c(-180,-53,-175,-29))
#' res <- occ(from = "idigbio", geometry = bounds, limit = 10)
#' res$idigbio
#' }
NULL

#' @export
#' @rdname spocc_objects
print.occdat <- function(x, ...) {
  rows <- lapply(x, function(y) vapply(y$data, nrow, numeric(1)))
  perspp <- lapply(rows, function(z) c(sum(z), length(z)))
  searched <- attr(x, "searched")
  found <- pluck(pluck(x[searched], "meta"), "found")
  cat(sprintf("Searched: %s", paste0(searched, collapse = ", ")), sep = "\n")
  cat(sprintf("Occurrences - Found: %s, Returned: %s", founded(found), 
              fdec(rows)), sep = "\n")
  cat(sprintf("Search type: %s", gettype(x)), sep = "\n")
  if (gettype(x) == "Scientific") {
    invisible(lapply(x, catif, type = 
                       unique(
                         unlist(unname(sc(pluck(pluck(x, "meta"), "type")))))))
  }
  cat(founded_mssg(found))
}

gettype <- function(x){
  y <- unique(unlist(unname(sc(pluck(pluck(x, "meta"), "type")))))
  switch(y,
         sci = "Scientific",
         vern = "Vernacular",
         geometry = "Geometry")
}

fdec <- function(x) format(sum(unlist(x, recursive = TRUE)), big.mark = ",")

founded <- function(b){
  tmp <- format(sum(unlist(b, recursive = TRUE)), big.mark = ",")
  tmp
}

founded_mssg <- function(b){
  tmp <- format(sum(unlist(b, recursive = TRUE)), big.mark = ",")
  nofound <- names(b[vapply(b, is.null, logical(1))])
  if (length(nofound) != 0)
    "\nNote: spocc cannot estimate complete additional records found as none available for ebird"
  else
    NULL
}

catif <- function(z, ...){
  if (!is.null(z$meta$time))
    cat(sprintf("  %s: %s", z$meta$source, 
                spocc_wrap(pastemax(z$data, ..., n = 3))), sep = "\n")
}

#' @export
#' @rdname spocc_objects
print.occdatind <- function(x, ...){
  if (!is.null(x$meta$type)) {
    cat( spocc_wrap(sprintf("%s [%s]", 
                            switch(x$meta$type, sci = "Species", 
                                   geometry = "Geometry"), 
                            pastemax(x$data, x$meta$type))), '\n')
  }
  print(occinddf(x))
}

#' @export
#' @method summary occdat
#' @rdname spocc_objects
summary.occdat <- function(object, ...){
  lapply(object, summary.occdatind)
  invisible(TRUE)
}

#' @export
#' @method summary occdatind
#' @rdname spocc_objects
summary.occdatind <- function(object, ...){
  mdat <- object$meta
  cat(sprintf('<source> %s', nn(mdat$source)), "\n")
  cat(sprintf('<time> %s', nn(mdat$time)), "\n")
  cat(sprintf('<found> %s', nn(mdat$found)), "\n")
  cat(sprintf('<returned> %s', nn(mdat$returned)), "\n")
  opts <- unlist(Map(function(x, y) paste(paste(y, x, sep = ": "), "\n"), 
                     mdat$opts, names(mdat$opts), USE.NAMES = FALSE))
  cat('<query options>\n', opts, "\n")
}

nn <- function(x) if (is.null(x)) "" else x

pastemax <- function(w, type, n = 10){
  rrows <- vapply(w, nrow, integer(1))
  tt <- list()
  for (i in seq_along(rrows)) {
    nms <- switch(type, sci = names(rrows[i]), geometry = sprintf('<geo%s>', i))
    tt[[i]] <- sprintf("%s (%s)", gsub("_", " ", nms), rrows[[i]])
  }
  n <- min(n, length(tt))
  paste0(tt[1:n], collapse = ", ")
}

occinddf <- function(obj) {
  if (inherits(obj$data, "list")) {
    if (inherits(tryCatch(obj$data[[1]], error = function(e) e), "error")) {
      obj$data[[1]] <- data.frame(NULL)
    }
  }
  z <- obj$data[[1]]
  nms <- names(obj$data)[1]
  
  if (NROW(z) == 0) {
    notzero <- obj$data[sapply(obj$data, NROW) > 0]
    if (length(notzero) > 0) {
      z <- notzero[[1]]
      nms <- names(notzero)[1]
    }
  }
  
  cat(sprintf("First 10 rows of [%s]\n\n", nms))
  
  df <- data.frame(name = z$name, longitude = z$longitude,
                   latitude = z$latitude, prov = z$prov, 
                   stringsAsFactors = FALSE)
  z <- z[!names(z) %in% c('name','decimalLongitude','decimallongitude',
                          'Longitude','lng','longitude','decimal_longitude',
                          'decimalLatitude','decimallatitude','Latitude','lat',
                          'latitude','decimal_latitude','prov',
                          'geopoint.lat','geopoint.lon')]
  as_data_frame(do.call(cbind, list(df, z)))
}
