#' Coerce occurrence keys to NBN id objects
#'
#' @keywords internal
#' @param x Various inputs, including the output from a call to \code{\link{occ}}
#' (class occdat), \code{\link{occ2df}} (class data.frame), or a list, numeric,
#' character, nbnkey, or occkey.
#' @return One or more in a list of both class nbnkey and occkey
#' @examples \dontrun{
#' spnames <- c('Mola mola', 'Loligo vulgaris', 'Stomias boa')
#' out <- occ(query=spnames, from='nbn', limit=2)
#' res <- occ2df(out)
#' (tt <- as.nbn(out))
#' (uu <- as.nbn(res))
#' as.nbn(x = res$key[1])
#' as.nbn(as.list(res$key[1:2]))
#' as.nbn(tt[[1]])
#' as.nbn(uu[[1]])
#' as.nbn(tt[1:2])
#'
#' library("dplyr")
#' rbind_all(lapply(tt, function(x) data.frame(unclass(x)$data)))
#' }
as.nbn <- function(x) {
  UseMethod("as.nbn")
}

#' @export
as.nbn.nbnkey <- function(x) x

#' @export
as.nbn.occkey <- function(x) x

#' @export
as.nbn.occdat <- function(x) {
  x <- occ2df(x)
  make_nbn_df(x)
}

#' @export
as.nbn.data.frame <- function(x) make_nbn_df(x)

#' @export
as.nbn.numeric <- function(x) make_nbn(x)

#' @export
as.nbn.character <- function(x) make_nbn(x)

#' @export
as.nbn.list <- function(x){
  lapply(x, function(z) {
    if (is(z, "nbnkey")) {
      as.nbn(z)
    } else {
      make_nbn(z)
    }
  })
}

make_nbn_df <- function(x){
  tmp <- x[x$prov %in% "nbn", ]
  if (NROW(tmp) == 0) {
    stop("no data from NBN found", call. = FALSE)
  } else {
    setNames(lapply(tmp$key, make_nbn), tmp$key)
  }
}

make_nbn <- function(y, ...){
  structure(idig_view_records(key = y, ...), class = c("nbnkey", "occkey"))
}
