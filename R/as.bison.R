#' Coerce occurrence keys to bisonkey/occkey objects
#'
#' @export
#'
#' @param x Various inputs, including the output from a call to \code{\link{occ}} 
#' (class occdat), \code{\link{occ2df}} (class data.frame), or a list, numeric, 
#' character, or bisonkey, or occkey.
#' @return One or more in a list of both class bisonkey and occkey
#' @details Internally, we use \code{\link[rbison]{bison_solr}}, same function we use  
#' internally within the \code{\link{occ}} function. Although, we query here with the 
#' \code{occurrenceID} parameter to get the occurrence directly instead of searching for it.
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Carduelis tristis')
#' out <- occ(query=spnames, from='bison', limit=2)
#' res <- occ2df(out)
#' (tt <- as.bison(out))
#' (uu <- as.bison(res))
#' as.bison(as.numeric(res$key[1]))
#' as.bison(res$key[1])
#' as.bison(as.list(res$key[1:2]))
#' as.bison(tt[[1]])
#' as.bison(uu[[1]])
#' as.bison(tt[1:2])
#' }
as.bison <- function(x) UseMethod("as.bison")

#' @export
as.bison.bisonkey <- function(x) x

#' @export
as.bison.occkey <- function(x) x

#' @export
as.bison.occdat <- function(x) {
  x <- occ2df(x)
  make_bison_df(x)
}

#' @export
as.bison.data.frame <- function(x) make_bison_df(x)

#' @export
as.bison.numeric <- function(x) make_bison(x)

#' @export
as.bison.character <- function(x) make_bison(as.numeric(x))

#' @export
as.bison.list <- function(x){
  lapply(x, function(z) {
    if (is(z, "bisonkey")) {
      as.bison(z)
    } else {
      make_bison(as.numeric(z))
    }
  })
}

make_bison_df <- function(x){
  tmp <- x[ x$prov %in% "bison" ,  ]
  if (NROW(tmp) == 0) {
    stop("no data from bison found", call. = FALSE)
  } else {
    setNames(lapply(as.numeric(tmp$key), make_bison), as.numeric(tmp$key))
  }
}

make_bison <- function(y, ...){
  structure(bison_solr(occurrenceID = y, verbose = FALSE, ...), class = c("bisonkey", "occkey"))
}
