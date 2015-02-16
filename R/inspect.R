#' Get more data on individual occurrences.
#' 
#' @export
#' 
#' @param obj The output from \code{\link{occ}} call.
#' @param keys You can alternatively pass in keys, in which case you have to pass a named vector
#' or the from param will be used to pick which source to query.
#' @param from The data provider
#' 
#' @details 
#' This function xxxx
#' 
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Carduelis tristis')
#' out <- occ(query=spnames, from=c('gbif','ebird'), gbifopts=list(hasCoordinate=TRUE), limit=4)
#' res <- occ2df(out)
#' inspect(res, from="gbif")
#' }
inspect <- function(obj=NULL, keys=NULL, from="gbif") {
  from <- match.arg(from, choices = c("gbif", "bison", "inat", "ebird", "ecoengine", "antweb"),
                       several.ok = TRUE)
  obj <- obj[ obj$prov %in% from ,  ]
  kyz <- obj$key
  tmp <- switch(from,
         rgbif::occ_get(as.numeric(kyz))
  )
  setNames(tmp, kyz)
}


