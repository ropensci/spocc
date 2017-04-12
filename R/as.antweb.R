#' Coerce occurrence keys to antwebkey/occkey objects
#'
#' @export
#'
#' @param x Various inputs, including the output from a call to [occ()]
#' (class occdat), [occ2df()] (class data.frame), or a list, numeric,
#' character, or antwebkey, or occkey.
#' @param ... curl options; named parameters passed on to [crul::HttpClient()]
#' @return One or more in a list of both class antwebkey and occkey
#' @examples \dontrun{
#' spp <- c("linepithema humile", "acanthognathus")
#' out <- occ(query=spp, from='antweb', limit=2)
#' res <- occ2df(out)
#' (tt <- as.antweb(out))
#' (uu <- as.antweb(res))
#' as.antweb(res$key[1])
#' as.antweb(as.list(res$key[1:2]))
#' as.antweb(tt[[1]])
#' as.antweb(uu[[1]])
#' as.antweb(tt[1:2])
#' }
as.antweb <- function(x, ...) UseMethod("as.antweb")

#' @export
as.antweb.antwebkey <- function(x, ...) x

#' @export
as.antweb.occkey <- function(x, ...) x

#' @export
as.antweb.occdat <- function(x, ...) {
  x <- occ2df(x)
  make_antweb_df(x, ...)
}

#' @export
as.antweb.data.frame <- function(x, ...) make_antweb_df(x, ...)

#' @export
as.antweb.character <- function(x, ...) make_antweb(x, ...)

#' @export
as.antweb.list <- function(x, ...) {
  lapply(x, function(z) {
    if (inherits(z, "antwebkey")) {
      as.antweb(z, ...)
    } else {
      make_antweb(z, ...)
    }
  })
}

make_antweb_df <- function(x, ...) {
  tmp <- x[ x$prov %in% "antweb" ,  ]
  if (NROW(tmp) == 0) {
    stop("no data from antweb found", call. = FALSE)
  } else {
    stats::setNames(lapply(tmp$key, make_antweb, ...), tmp$key)
  }
}

make_antweb <- function(y, ...){
  structure(get_antweb(y, ...), class = c("antwebkey", "occkey"))
}

get_antweb <- function(z, ...) {
  cli <- crul::HttpClient$new(url = "http://antweb.org", opts = list(...))
  out <- cli$get(path = paste0('api/v2/?occurrenceId=CAS:ANTWEB:', z))
  out$raise_for_status()
  jsonlite::fromJSON(out$parse("UTF-8"))
}
