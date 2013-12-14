#' Print brief summary of occ function output
#' 
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))
#' print(out)
#' out # gives the same thing
#' 
#' # you can still drill down into the data easily
#' out$gbif$meta 
#' out$gbif$data
#' }
#' @export
#' @rdname occdat
#' @S3method print occdat
print.occdat <- function(d)
{
  rows <- lapply(d, function(x) sapply(x$data, nrow))
  perspp <- lapply(rows, function(x) c(sum(x), length(x)))
  
  cat("Summary of results - occurrences found for:", "\n")
  cat(" gbif  :", perspp$gbif[1], "records across", perspp$gbif[2], "species", "\n")
  cat(" bison : ", perspp$bison[1], "records across", perspp$bison[2], "species", "\n")
  cat(" inat  : ", perspp$inat[1], "records across", perspp$inat[2], "species", "\n")
  cat(" npn   : ", perspp$npn[1], "records across", perspp$npn[2], "species", "\n")
  cat(" ebird : ", perspp$ebird[1], "records across", perspp$ebird[2], "species", "\n")
  
}

#' Summary of occ function output
#' @import sp maptools rgdal assertthat
#' @param d Input object from occ function, of class occdat
#' @param ... Further args passed on to points fxn
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))
#' plot(out, cex=1, pch=10)
#' }
#' @export
#' @rdname occdat
#' @S3method summary occdat
plot.occdat <- function(d, ...)
{
  assert_that(inherits(d, "occdat"))
  df <- occ2df(d)  
  coordinates(df) <- ~longitude+latitude
  proj4string(df) = CRS("+init=epsg:4326")
  data(wrld_simpl)
  plot(wrld_simpl)
  points(df, col="red", ...)
}