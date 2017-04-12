#' Coerce occurrence keys to obis id objects
#' 
#' @export
#' 
#' @param x Various inputs, including the output from a call to 
#' [occ()] (class occdat), [occ2df()] (class data.frame), 
#' or a list, numeric, obiskey, or occkey.
#' @param ... curl options; named parameters passed on to [crul::HttpClient()]
#' @return One or more in a list of both class obiskey and occkey
#' @examples \dontrun{
#' spnames <- c('Mola mola', 'Loligo vulgaris', 'Stomias boa')
#' out <- occ(query=spnames, from='obis', limit=2)
#' (res <- occ2df(out))
#' (tt <- as.obis(out))
#' (uu <- as.obis(res))
#' as.obis(x = res$key[1])
#' as.obis(as.list(res$key[1:2]))
#' as.obis(tt[[1]])
#' as.obis(uu[[1]])
#' as.obis(tt[1:2])
#'
#' library("data.table")
#' rbindlist(tt, use.names = TRUE, fill = TRUE)
#' }
as.obis <- function(x, ...) UseMethod("as.obis")

#' @export
as.obis.obiskey <- function(x, ...) x

#' @export
as.obis.occkey <- function(x, ...) x

#' @export
as.obis.occdat <- function(x, ...) {
  x <- occ2df(x)
  make_obis_df(x, ...)
}

#' @export
as.obis.data.frame <- function(x, ...) make_obis_df(x, ...)

#' @export
as.obis.numeric <- function(x, ...) make_obis(x, ...)

#' @export
as.obis.list <- function(x, ...) {
  lapply(x, function(z) {
    if (inherits(z, "obiskey")) {
      as.obis(z, ...)
    } else {
      make_obis(z, ...)
    }
  })
}

make_obis_df <- function(x, ...) {
  tmp <- x[x$prov %in% "obis", ]
  if (NROW(tmp) == 0) {
    stop("no data from OBIS found", call. = FALSE)
  } else {
    stats::setNames(lapply(tmp$key, make_obis, ...), tmp$key)
  }
}

make_obis <- function(y, ...) {
  structure(obis_occ_id(id = y, ...), class = c("obiskey", "occkey"))
}
