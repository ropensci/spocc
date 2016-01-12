#' Coerce occurrence keys to ecoenginekey/occkey objects
#'
#' @export
#' @importFrom httr GET stop_for_status warn_for_status content
#'
#' @param x Various inputs, including the output from a call to \code{\link{occ}}
#' (class occdat), \code{\link{occ2df}} (class data.frame), or a list, numeric,
#' character, or ecoenginekey, or occkey.
#' @return One or more in a list of both class ecoenginekey and occkey
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Carduelis tristis')
#' out <- occ(query=spnames, from='ecoengine', limit=2)
#' res <- occ2df(out)
#' (tt <- as.ecoengine(out))
#' (uu <- as.ecoengine(res))
#' as.ecoengine(res$key[1])
#' as.ecoengine(as.list(res$key[1:2]))
#' as.ecoengine(tt[[1]])
#' as.ecoengine(uu[[1]])
#' as.ecoengine(tt[1:2])
#' }
as.ecoengine <- function(x) UseMethod("as.ecoengine")

#' @export
as.ecoengine.ecoenginekey <- function(x) x

#' @export
as.ecoengine.occkey <- function(x) x

#' @export
as.ecoengine.occdat <- function(x) {
  x <- occ2df(x)
  make_ecoengine_df(x)
}

#' @export
as.ecoengine.data.frame <- function(x) make_ecoengine_df(x)

#' @export
as.ecoengine.character <- function(x) make_ecoengine(x)

#' @export
as.ecoengine.list <- function(x){
  lapply(x, function(z) {
    if (is(z, "ecoenginekey")) {
      as.ecoengine(z)
    } else {
      make_ecoengine(z)
    }
  })
}

make_ecoengine_df <- function(x){
  tmp <- x[ x$prov %in% "ecoengine" ,  ]
  if (NROW(tmp) == 0) {
    stop("no data from ecoengine found", call. = FALSE)
  } else {
    setNames(lapply(tmp$key, make_ecoengine), tmp$key)
  }
}

make_ecoengine <- function(y, ...){
  structure(get_ecoengine(y, ...), class = c("ecoenginekey", "occkey"))
}

get_ecoengine <- function(z) {
  res <- GET(sprintf('https://ecoengine.berkeley.edu/api/observations/%s/?format=json', z))
  stop_for_status(res)
  content(res)
}
