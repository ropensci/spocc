#' Combine results from occ calls to a single data.frame
#' 
#' @export
#' @importFrom uuid UUIDgenerate
#' 
#' @param obj Input from occ
#' @param what (character) One of data (default) or all (with metadata)
#' 
#' @details 
#' This function combines a subset of data from each data provider to a single data.frame, or 
#' metadata plus data if you request \code{what="all"}. The single data.frame contains the 
#' following columns:
#' 
#' \itemize{
#'  \item name - scientific (or common) name
#'  \item longitude - decimal degree longitude
#'  \item latitude - decimal degree latitude
#'  \item prov - data provider
#'  \item date - occurrence record date
#'  \item key - occurrence record key
#' }
#' 
#' AntWeb doesn't provide dates, so occurrence rows from that provider are blank. 
#' 
#' Ecoengine doesn't provide unique keys for each occurrence record, so we generate one 
#' for each record. We cache records returned from the \code{\link{occ}} function on your 
#' machine, and you can use the keys from the output of this function to request 
#' further output in \code{inspect}, which uses that cached data. Other data sources 
#' provide unique keys already, so we can query the database online again for more data.
#' 
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Carduelis tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE), limit=10)
#' occ2df(out)
#' }
occ2df <- function(obj, what = "data") {
  what <- match.arg(what, choices = c("all", "data"))
  foolist <- function(x) do.call(rbind_fill, x$data)
  aa <- foolist(obj$gbif)
  bb <- foolist(obj$bison)
  cc <- foolist(obj$inat)
  dd <- foolist(obj$ebird)
  ee <- foolist(obj$ecoengine)
  aw <- foolist(obj$antweb)
  tmp <- data.frame(rbind_fill(
    Map(
      function(x, y){
        if(NROW(x) == 0){
          data.frame(NULL)
        } else {
          dat <- x[ , c('name','longitude','latitude','prov',datemap[[y]],keymap[[y]]) ]
          if(is.null(datemap[[y]])){
            dat$date <- rep(NA_character_, NROW(dat))
          } else {
            dat <- rename(dat, setNames("date", datemap[[y]]))
          }
          rename(dat, setNames("key", keymap[[y]]))
        }
      }, 
      list(aa, bb, cc, dd, ee, aw), c('gbif','bison','inat','ebird','ecoengine','antweb')
    )
  ))
  tmpout <- list(meta = list(obj$gbif$meta, obj$bison$meta, obj$inat$meta, obj$ebird$meta,
                             obj$ecoengine$meta, obj$aw$meta), data = tmp)
  if(what %in% "data") tmpout$data else tmpout
}

datemap <- list(gbif='eventDate',bison='date',inat='Datetime',ebird='obsDt',
                ecoengine='begin_date',antweb=NULL)
keymap <- list(gbif="key",bison="occurrenceID",inat="Id",ebird="locID",
               ecoengine="key",antweb="catalogNumber")
