#' Coerce occurrence keys to idigbio uuid objects
#'
#' @export
#'
#' @param x Various inputs, including the output from a call to \code{\link{occ}}
#' (class occdat), \code{\link{occ2df}} (class data.frame), or a list, numeric,
#' character, idigbiokey, or occkey.
#' @return One or more in a list of both class idigbiokey and occkey
#' @details Internally, we use \code{idig_view_records}, whereas we use 
#' \code{\link{idig_search_records}} in the \code{\link{occ}} function. 
#'
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Carduelis tristis')
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
#' rbind_all(lapply(tt, function(x) data.frame(unclass(x)$data)))
#' }
as.idigbio <- function(x) {
  UseMethod("as.idigbio")
}

#' @export
as.idigbio.idigbiokey <- function(x) x

#' @export
as.idigbio.occkey <- function(x) x

#' @export
as.idigbio.occdat <- function(x) {
  x <- occ2df(x)
  make_idigbio_df(x)
}

#' @export
as.idigbio.data.frame <- function(x) make_idigbio_df(x)

#' @export
as.idigbio.character <- function(x) make_idigbio(x)

#' @export
as.idigbio.list <- function(x){
  lapply(x, function(z) {
    if (is(z, "idigbiokey")) {
      as.idigbio(z)
    } else {
      make_idigbio(z)
    }
  })
}

make_idigbio_df <- function(x){
  tmp <- x[x$prov %in% "idigbio", ]
  if (NROW(tmp) == 0) {
    stop("no data from idigbio found", call. = FALSE)
  } else {
    setNames(lapply(tmp$key, make_idigbio), tmp$key)
  }
}

make_idigbio <- function(y, ...){
  structure(idig_view_records(uuid = y, ...), class = c("idigbiokey", "occkey"))
}
