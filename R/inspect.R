#' Get more data on individual occurrences.
#' 
#' @export
#' 
#' @param obj The output from \code{\link{occ}} call.
#' @param keys You can alternatively pass in keys, in which case you have to pass a named vector
#' or the from param will be used to pick which source to query.
#' @param from The data provider
#' 
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Carduelis tristis')
#' out <- occ(query=spnames, from=c('gbif','bison'), gbifopts=list(hasCoordinate=TRUE), limit=2)
#' res <- occ2df(out)
#' inspect(res)
#' 
#' out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE), limit=4)
#' res <- occ2df(out)
#' inspect(res)
#' 
#' # from occkeys
#' key <- as.gbif(res$key[1])
#' inspect(key)
#' }
inspect <- function(x, from="gbif") UseMethod("inspect")

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
inspect.occkey <- function(x){
  switch(class(x)[1], 
         gbifkey = as.gbif(x),
         bisonkey = as.bison(x))
}

make_df <- function(x){
  obj <- split(x, x$prov)
  out <- list()
  for(i in seq_along(obj)){
    out[[ names(obj)[i] ]] <- 
      switch(names(obj)[i], 
             gbif = as.gbif(obj[[i]]),
             bison = as.bison(obj[[i]])
      )
  }
  out
}
