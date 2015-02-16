#' Coerce occurrence keys to occkey objects
#' 
#' @param obj The output from \code{\link{occ}} call.
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Carduelis tristis')
#' out <- occ(query=spnames, from=c('gbif','ebird'), gbifopts=list(hasCoordinate=TRUE), limit=4)
#' res <- occ2df(out)
#' as.occkey(res)
#' }
as.occkey <- function(x) UseMethod("as.occkey")

#' @export
#' @rdname as.occkey
as.occkey.occkey <- function(x) x

#' @export
#' @rdname as.occkey
as.occkey.occdat <- function(x) {
  
}

#' @export
#' @rdname as.occkey
as.occkey.data.frame <- function(x) {
  
}

#' @export
#' @rdname as.occkey
as.occkey.numeric <- function(x) {
  
}

#' @export
#' @rdname as.occkey
as.occkey.character <- function(x) {
  
}

#' @export
#' @rdname as.occkey
as.occkey.list <- function(x) {
  
}

to_occkey <- function(x){
  
}
