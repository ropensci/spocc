#' Coerce occurrence keys to gbifkey/occkey objects
#'
#' @export
#'
#' @param x Various inputs, including the output from a call to 
#' \code{\link{occ}} (class occdat), \code{\link{occ2df}} (class data.frame), 
#' or a list, numeric, character, gbifkey, or occkey.
#' @return One or more in a list of both class gbifkey and occkey
#' @details Internally, we use \code{\link[rgbif]{occ_get}}, whereas 
#' \code{\link{occ}} uses \code{\link[rgbif]{occ_data}}. We can use 
#' \code{\link[rgbif]{occ_get}} here because we have the occurrence key to 
#' go directly to the occurrence record.
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 
#'   'Carduelis tristis')
#' out <- occ(query=spnames, from=c('gbif','ebird'), 
#'   gbifopts=list(hasCoordinate=TRUE), limit=2)
#' res <- occ2df(out)
#' (tt <- as.gbif(out))
#' (uu <- as.gbif(res))
#' as.gbif(as.numeric(res$key[1]))
#' as.gbif(res$key[1])
#' as.gbif(as.list(res$key[1:2]))
#' as.gbif(tt[[1]])
#' as.gbif(uu[[1]])
#' as.gbif(tt[1:2])
#' }
as.gbif <- function(x) UseMethod("as.gbif")

#' @export
as.gbif.gbifkey <- function(x) x

#' @export
as.gbif.occkey <- function(x) x

#' @export
as.gbif.occdat <- function(x) {
  x <- occ2df(x)
  make_gbif_df(x)
}

#' @export
as.gbif.data.frame <- function(x) make_gbif_df(x)

#' @export
as.gbif.numeric <- function(x) make_gbif(x)

#' @export
as.gbif.character <- function(x) make_gbif(as.numeric(x))

#' @export
as.gbif.list <- function(x){
  lapply(x, function(z) {
    if (inherits(z, "gbifkey")) {
      as.gbif(z)
    } else {
      make_gbif(as.numeric(z))
    }
  })
}

make_gbif_df <- function(x){
  tmp <- x[ x$prov %in% "gbif" ,  ]
  if (NROW(tmp) == 0) {
    stop("no data from gbif found", call. = FALSE)
  } else {
    stats::setNames(lapply(as.numeric(tmp$key), make_gbif), as.numeric(tmp$key))
  }
}

make_gbif <- function(y, ...){
  structure(occ_get(key = y, fields = "all", ...), 
            class = c("gbifkey", "occkey"))
}
