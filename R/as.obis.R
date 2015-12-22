#' Coerce occurrence keys to obis id objects
#'
#' @keywords internal
#' @param x Various inputs, including the output from a call to \code{\link{occ}}
#' (class occdat), \code{\link{occ2df}} (class data.frame), or a list, numeric,
#' character, obiskey, or occkey.
#' @return One or more in a list of both class obiskey and occkey#'
#' @examples \dontrun{
#' spnames <- c('Mola mola', 'Loligo vulgaris', 'Stomias boa')
#' out <- occ(query=spnames, from='obis', limit=2)
#' res <- occ2df(out)
#' (tt <- as.obis(out))
#' (uu <- as.obis(res))
#' as.obis(x = res$key[1])
#' as.obis(as.list(res$key[1:2]))
#' as.obis(tt[[1]])
#' as.obis(uu[[1]])
#' as.obis(tt[1:2])
#'
#' library("dplyr")
#' rbind_all(lapply(tt, function(x) data.frame(unclass(x)$data)))
#' }
as.obis <- function(x) {
  UseMethod("as.obis")
}

#' @export
as.obis.obiskey <- function(x) x

#' @export
as.obis.occkey <- function(x) x

#' @export
as.obis.occdat <- function(x) {
  x <- occ2df(x)
  make_obis_df(x)
}

#' @export
as.obis.data.frame <- function(x) make_obis_df(x)

#' @export
as.obis.numeric <- function(x) make_obis(x)

#' @export
as.obis.character <- function(x) make_obis(x)

#' @export
as.obis.list <- function(x){
  lapply(x, function(z) {
    if (is(z, "obiskey")) {
      as.obis(z)
    } else {
      make_obis(z)
    }
  })
}

make_obis_df <- function(x){
  tmp <- x[x$prov %in% "obis", ]
  if (NROW(tmp) == 0) {
    stop("no data from OBIS found", call. = FALSE)
  } else {
    setNames(lapply(tmp$key, make_obis), tmp$key)
  }
}

make_obis <- function(y, ...){
  structure(idig_view_records(key = y, ...), class = c("obiskey", "occkey"))
}
