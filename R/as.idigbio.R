#' Coerce occurrence keys to idigbio objects
#'
#' @export
#'
#' @param x Various inputs, including the output from a call to [occ()]
#' (class occdat), [occ2df()] (class data.frame), or a list, numeric,
#' character, idigbiokey, or occkey.
#' @param ... curl options; named parameters passed on to `httr::GET()`
#' @return One or more in a list of both class idigbiokey and occkey
#' @details Internally, we use `idig_view_records`, whereas we use
#' [idig_search_records()] in the [occ()] function.
#'
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens',
#'   'Spinus tristis')
#' out <- occ(query=spnames, from='idigbio', limit=2)
#' res <- occ2df(out)
#' (tt <- as.idigbio(out))
#' (uu <- as.idigbio(res))
#' as.idigbio(res$key[1])
#' as.idigbio(as.list(res$key[1:2]))
#' as.idigbio(tt[[1]])
#' as.idigbio(uu[[1]])
#' as.idigbio(tt[1:2])
#'
#' library("dplyr")
#' bind_rows(lapply(tt, function(x) data.frame(unclass(x)$data)))
#' }
as.idigbio <- function(x, ...) UseMethod("as.idigbio")

#' @export
as.idigbio.idigbiokey <- function(x, ...) x

#' @export
as.idigbio.occkey <- function(x, ...) x

#' @export
as.idigbio.occdat <- function(x, ...) {
  x <- occ2df(x)
  make_idigbio_df(x, ...)
}

#' @export
as.idigbio.data.frame <- function(x, ...) make_idigbio_df(x, ...)

#' @export
as.idigbio.character <- function(x, ...) make_idigbio(x, ...)

#' @export
as.idigbio.list <- function(x, ...) {
  lapply(x, function(z) {
    if (inherits(z, "idigbiokey")) {
      as.idigbio(z)
    } else {
      make_idigbio(z, ...)
    }
  })
}

make_idigbio_df <- function(x, ...) {
  tmp <- x[x$prov %in% "idigbio", ]
  if (NROW(tmp) == 0) {
    stop("no data from idigbio found", call. = FALSE)
  } else {
    stats::setNames(lapply(tmp$key, make_idigbio, ...), tmp$key)
  }
}

make_idigbio <- function(y, ...){
  structure(ridigbio::idig_view_records(uuid = y, ...),
            class = c("idigbiokey", "occkey"))
}
