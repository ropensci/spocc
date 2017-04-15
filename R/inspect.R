#' Get more data on individual occurrences.
#'
#' @export
#'
#' @param x The output from \code{\link{occ}} call, output from call to
#' \code{\link{occ2df}}, or an occurrence ID as a occkey class.
#' @param from  (character) The data provider. One of gbif, bison, inat,
#' antweb, ecoengine, or vertnet
#' @return A list, with each slot named for the data source, and then
#' within data sources is a slot for each taxon, named by it's occurrence ID.
#'
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Spinus tristis')
#' out <- occ(query=spnames, from=c('gbif','bison','ecoengine'),
#'    gbifopts=list(hasCoordinate=TRUE), limit=2)
#' res <- occ2df(out)
#' inspect(res)
#'
#' out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE),
#'   limit=4)
#' res <- occ2df(out)
#' inspect(res)
#'
#' # from occkeys
#' key <- as.gbif(res$key[1])
#' inspect(key)
#' key <- as.antweb("amsat-94817")
#' inspect(key)
#'
#' # idigbio
#' spnames <- c('Accipiter striatus', 'Spinus tristis')
#' out <- occ(query=spnames, from='idigbio', limit=20)
#' inspect(out)
#' }
inspect <- function(x, from="gbif") {
  UseMethod("inspect")
}

#' @export
#' @rdname inspect
inspect.data.frame <- function(x, from="gbif") make_df(x)

#' @export
#' @rdname inspect
inspect.occdat <- function(x, from="gbif") {
  x <- occ2df(x)
  make_df(x)
}

#' @export
#' @rdname inspect
inspect.occkey <- function(x, from="gbif"){
  switch(class(x)[1],
         gbifkey = as.gbif(x),
         bisonkey = as.bison(x),
         ecoenginekey = as.ecoengine(x),
         antwebkey = as.antweb(x),
         idigbiokey = as.idigbio(x))
}

make_df <- function(x){
  obj <- split(x, x$prov)
  out <- list()
  for (i in seq_along(obj)) {
    out[[ names(obj)[i] ]] <-
      switch(names(obj)[i],
             gbif = as.gbif(obj[[i]]),
             bison = as.bison(obj[[i]]),
             ecoengine = as.ecoengine(obj[[i]]),
             antweb = as.antweb(obj[[i]]),
             idigbio = as.idigbio(obj[[i]])
      )
  }
  out
}
