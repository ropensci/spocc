#' Coerce occurrence keys to iNaturalist id objects
#'
#' @export
#' 
#' @family coercion
#'
#' @param x Various inputs, including the output from a call to
#' [occ()] (class occdat), [occ2df()] (class data.frame), or a list, numeric,
#' character, inatkey, or occkey.
#' @param ... curl options; named parameters passed on to [crul::HttpClient()]
#' @return One or more in a list of both class inatkey and occkey
#'
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens',
#'   'Spinus tristis')
#' out <- occ(query=spnames, from='inat', limit=2)
#' res <- occ2df(out)
#' (tt <- as.inat(out))
#' (uu <- as.inat(res))
#' as.inat(res$key[1])
#' as.inat(as.list(res$key[1:2]))
#' as.inat(tt[[1]])
#' as.inat(uu[[1]])
#' as.inat(tt[1:2])
#'
#' library("dplyr")
#' bind_rows(lapply(tt, function(x) {
#'   data.frame(x$taxon[c('id','name','rank','unique_name')],
#'              stringsAsFactors = FALSE)
#' }))
#' }
as.inat <- function(x, ...) UseMethod("as.inat")

#' @export
as.inat.inatkey <- function(x, ...) x

#' @export
as.inat.occkey <- function(x, ...) x

#' @export
as.inat.occdat <- function(x, ...) {
  x <- occ2df(x)
  make_inat_df(x, ...)
}

#' @export
as.inat.data.frame <- function(x, ...) make_inat_df(x, ...)

#' @export
as.inat.numeric <- function(x, ...) make_inat(x, ...)

#' @export
as.inat.character <- function(x, ...) make_inat(x, ...)

#' @export
as.inat.list <- function(x, ...) {
  lapply(x, function(z) {
    if (inherits(z, "inatkey")) {
      as.inat(z, ...)
    } else {
      make_inat(z, ...)
    }
  })
}

make_inat_df <- function(x, ...) {
  tmp <- x[x$prov %in% "inat", ]
  if (NROW(tmp) == 0) {
    stop("no data from inaturalist found", call. = FALSE)
  } else {
    stats::setNames(lapply(tmp$key, make_inat, ...), tmp$key)
  }
}

make_inat <- function(y, ...) {
  structure(spocc_get_inat_obs_id(id = y, callopts = list(...)),
            class = c("inatkey", "occkey"))
}
