#' Coerce occurrence keys to ALA id objects
#'
#' @export
#' 
#' @family coercion
#' 
#' @param x Various inputs, including the output from a call to
#' [occ()] (class occdat), [occ2df()] (class data.frame),
#' or a list, numeric, alakey, or occkey.
#' @param ... curl options; named parameters passed on to [crul::HttpClient()]
#' @return One or more in a list of both class alakey and occkey
#' @examples \dontrun{
#' spnames <- c('Barnardius zonarius', 'Grus rubicunda', 'Cracticus tibicen')
#' out <- occ(query=spnames, from='ala', limit=2)
#' (res <- occ2df(out))
#' (tt <- as.ala(out))
#' as.ala(x = res$key[1])
#' }
as.ala <- function(x, ...) {
  UseMethod("as.ala")
}

#' @export
as.ala.alakey <- function(x, ...) x

#' @export
as.ala.occkey <- function(x, ...) x

#' @export
as.ala.occdat <- function(x, ...) {
  x <- occ2df(x)
  make_ala_df(x, ...)
}

#' @export
as.ala.data.frame <- function(x, ...) make_ala_df(x, ...)

#' @export
as.ala.character <- function(x, ...) make_ala(x, ...)

#' @export
as.ala.list <- function(x, ...) { 
  lapply(x, function(z) {
    if (inherits(z, "alakey")) {
      as.ala(z, ...)
    } else {
      make_ala(z, ...)
    }
  })
}

make_ala_df <- function(x, ...) {
  tmp <- x[x$prov %in% "ala", ]
  if (NROW(tmp) == 0) {
    stop("no data from ALA found", call. = FALSE)
  } else {
    stats::setNames(lapply(tmp$key, make_ala, ...), tmp$key)
  }
}

make_ala <- function(y, ...) {
  structure(ala_occ_id(id = y, ...), class = c("alakey", "occkey"))
}
