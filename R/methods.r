#' spocc objects and their print, plot, and summary methods
#'
#' @import sp rworldmap
#' @keywords internal
#' 
#' @param x Input, of class occdatind
#' @param object Input to summary methods
#' @param ... Further args to print, plot or summary methods
#' @param n Number of rows to show. If \code{NULL}, the default, will print
#'   all rows if less than option \code{dplyr.print_max}. Otherwise, will
#'   print \code{dplyr.print_min}
#'   
#' @examples \donttest{
#' # occdat object
#' res <- occ(query = 'Accipiter striatus', from = 'gbif')
#' res
#' print(res)
#' is(res)
#'
#' # occdatind object
#' res$gbif
#' print(res$gbif)
#' is(res$gbif)
#' 
#' # print summary of occdat object
#' summary(res)
#' 
#' # print summary of occdatind object
#' summary(res$gbif)
#' 
#' # plot an occdat object
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE))
#' plot(out, cex=1, pch=10)
#' }
#' @name spocc_objects
NULL

#' @export
#' @rdname spocc_objects
print.occdat <- function(x, ...) {
    rows <- lapply(x, function(y) vapply(y$data, nrow, numeric(1)))
    perspp <- lapply(rows, function(z) c(sum(z), length(z)))
    cat("Summary of results - occurrences found for:", "\n")
    cat(" gbif  :", perspp$gbif[1], "records across", perspp$gbif[2], "species",
        "\n")
    cat(" bison : ", perspp$bison[1], "records across", perspp$bison[2], "species",
        "\n")
    cat(" inat  : ", perspp$inat[1], "records across", perspp$inat[2], "species",
        "\n")
    cat(" ebird : ", perspp$ebird[1], "records across", perspp$ebird[2], "species",
        "\n")
    cat(" ecoengine : ", perspp$ecoengine[1], "records across", perspp$ecoengine[2],
        "species", "\n")
    cat(" antweb : ", perspp$antweb[1], "records across", perspp$antweb[2],
        "species", "\n")
}

#' @export
#' @rdname spocc_objects
print.occdatind <- function(x, ..., n = 10){
  cat( spocc_wrap(sprintf("Species [%s]", pastemax(x$data))), '\n')
  cat(sprintf("First 10 rows of [%s]\n\n", names(x$data)[1] ))
  spocc_trunc_mat(occinddf(x), n = n)
}

#' @export
#' @method summary occdat
#' @rdname spocc_objects
summary.occdat <- function(object, ...){
  lapply(object, summary.occdatind)
  invisible(TRUE)
}

#' @export
#' @method summary occdatind
#' @rdname spocc_objects
summary.occdatind <- function(object, ...){
  mdat <- object$meta
  cat(sprintf('<source> %s', nn(mdat$source)), "\n")
  cat(sprintf('<time> %s', nn(mdat$time)), "\n")
  cat(sprintf('<found> %s', nn(mdat$found)), "\n")
  cat(sprintf('<returned> %s', nn(mdat$returned)), "\n")
  cat(sprintf('<type> %s', nn(mdat$type)), "\n")
  opts <- unlist(Map(function(x, y) paste(paste(y, x, sep=": "), "\n"), mdat$opts, names(mdat$opts), USE.NAMES=FALSE))
  cat('<query options>\n', opts, "\n")
}

nn <- function(x) if(is.null(x)) "" else x

pastemax <- function(z, n=10){
  rrows <- vapply(z, nrow, integer(1))
  tt <- list(); for(i in seq_along(rrows)){ tt[[i]] <- sprintf("%s (%s)", gsub("_", " ", names(rrows[i])), rrows[[i]]) }
  paste0(tt, collapse = ", ")
}

occinddf <- function(obj) {
  z <- obj$data[[1]]
  df <- switch(obj$meta$source,
         gbif = data.frame(name = z$name, longitude = z$longitude, latitude = z$latitude, prov = z$prov),
         bison = data.frame(name = z$name, longitude = z$longitude, latitude = z$latitude, prov = z$prov),
         inat = data.frame(name = z$name, longitude = z$longitude, latitude = z$latitude, prov = z$prov),
         ebird = data.frame(name = z$name, longitude = z$longitude, latitude = z$latitude, prov = z$prov),
         ecoengine = data.frame(name = z$name, longitude = z$longitude, latitude = z$latitude, prov = z$prov),
         antweb = data.frame(name = z$name, longitude = z$longitude, latitude = z$latitude, prov = z$prov))
  z <- z[!names(z) %in% c('name','decimalLongitude','Longitude','lng','longitude','decimal_longitude',
                       'decimalLatitude','Latitude','lat','latitude','decimal_latitude','prov')]
  do.call(cbind, list(df, z))
}

# occinddf <- function(obj) {
#   z <- obj$data[[1]]
#   df <- switch(obj$meta$source,
#                gbif = data.frame(name = z$name, longitude = z$decimalLongitude, latitude = z$decimalLatitude, prov = z$prov),
#                bison = data.frame(name = z$name, longitude = z$decimalLongitude, latitude = z$decimalLatitude, prov = z$prov),
#                inat = data.frame(name = z$name, longitude = z$Longitude, latitude = z$Latitude, prov = z$prov),
#                ebird = data.frame(name = z$name, longitude = z$lng, latitude = z$lat, prov = z$prov),
#                ecoengine = data.frame(name = z$name, longitude = z$longitude, latitude = z$latitude, prov = z$prov),
#                antweb = data.frame(name = z$name, longitude = z$decimal_longitude, latitude = z$decimal_latitude, prov = z$prov))
#   z <- z[!names(z) %in% c('name','decimalLongitude','Longitude','lng','longitude','decimal_longitude',
#                           'decimalLatitude','Latitude','lat','latitude','decimal_latitude','prov')]
#   do.call(cbind, list(df, z))
# }

#' @export
#' @method plot occdat
#' @rdname spocc_objects
plot.occdat <- function(x, ...) {
  df <- occ2df(x)
  df <- df[complete.cases(df),]
  coordinates(df) <- ~longitude + latitude
  proj4string(df) <- CRS("+init=epsg:4326")
  plot(getMap())
  points(df, col = "red", ...)
}
