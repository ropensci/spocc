#' spocc objects and their print, plot, and summary methods
#'
#' @keywords internal
#'
#' @param x Input, of class occdatind
#' @param object Input to summary methods
#' @param ... Further args to print, plot or summary methods
#' @param n Number of rows to show. If \code{NULL}, the default, will print
#'   all rows if less than option \code{dplyr.print_max}. Otherwise, will
#'   print \code{dplyr.print_min}
#'
#' @examples \dontrun{
#' # occdat object
#' res <- occ(query = 'Accipiter striatus', from = 'gbif')
#' res
#' print(res)
#' is(res)
#'
#' # occdatind object
#' res$gbif
#' print(res$gbif)
#' is(res$gbif)
#'
#' # print summary of occdat object
#' summary(res)
#'
#' # print summary of occdatind object
#' summary(res$gbif)
#' }
#' @name spocc_objects
NULL

#' @export
#' @rdname spocc_objects
print.occdat <- function(x, ...) {
  rows <- lapply(x, function(y) vapply(y$data, nrow, numeric(1)))
  perspp <- lapply(rows, function(z) c(sum(z), length(z)))
  searched <- attr(x, "searched")
  found <- pluck(pluck(x[searched], "meta"), "found")
  cat(sprintf("Searched: %s", paste0(searched, collapse = ", ")), sep = "\n")
  cat(sprintf("Occurrences - Found: %s, Returned: %s", founded(found), fdec(rows)), sep = "\n")
  cat(sprintf("Search type: %s", gettype(x)), sep = "\n")
  if (gettype(x) == "Scientific") {
    invisible(lapply(x, catif))
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
#   nofound <- names(b[vapply(b, is.null, logical(1))])
#   if (length(nofound) != 0)
#     "spocc cannot estimate complete additional records found as none available for ebird"
#   else
#     tmp
}

founded_mssg <- function(b){
  tmp <- format(sum(unlist(b, recursive = TRUE)), big.mark = ",")
  nofound <- names(b[vapply(b, is.null, logical(1))])
  if (length(nofound) != 0)
    "\nNote: spocc cannot estimate complete additional records found as none available for ebird"
  else
    NULL
}

catif <- function(z){
  if (!is.null(z$meta$time))
    cat(sprintf("  %s: %s", z$meta$source, spocc_wrap(pastemax(z$data, n = 3))), sep = "\n")
}

#' @export
#' @rdname spocc_objects
print.occdatind <- function(x, ..., n = 10){
  cat( spocc_wrap(sprintf("Species [%s]", pastemax(x$data))), '\n')
  cat(sprintf("First 10 rows of [%s]\n\n", names(x$data)[1] ))
  spocc_trunc_mat(occinddf(x), n = n)
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
  # cat(sprintf('<type> %s', nn(mdat$type)), "\n")
  opts <- unlist(Map(function(x, y) paste(paste(y, x, sep = ": "), "\n"), mdat$opts, names(mdat$opts), USE.NAMES = FALSE))
  cat('<query options>\n', opts, "\n")
}

nn <- function(x) if (is.null(x)) "" else x

pastemax <- function(w, n=10){
  rrows <- vapply(w, nrow, integer(1))
  tt <- list()
  for (i in seq_along(rrows)) {
    tt[[i]] <- sprintf("%s (%s)", gsub("_", " ", names(rrows[i])), rrows[[i]])
  }
  n <- min(n, length(tt))
  paste0(tt[1:n], collapse = ", ")
}

occinddf <- function(obj) {
  z <- obj$data[[1]]
  df <- data.frame(name = z$name, longitude = z$longitude,
                   latitude = z$latitude, prov = z$prov, stringsAsFactors = FALSE)
  z <- z[!names(z) %in% c('name','decimalLongitude','decimallongitude','Longitude','lng','longitude','decimal_longitude',
                       'decimalLatitude','decimallatitude','Latitude','lat','latitude','decimal_latitude','prov',
                       'geopoint.lat','geopoint.lon')]
  do.call(cbind, list(df, z))
}
