#' Print brief summary of occ function output
#'
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query = spnames, from = 'gbif', gbifopts = list(hasCoordinate=TRUE))
#' print(out)
#' out # gives the same thing
#'
#' # you can still drill down into the data easily
#' out$gbif$meta
#' out$gbif$data
#' }
#'
#' @param x Input...
#' @param ... Ignored.
#' @method print occdat
#' @export

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

#' Print method for individual data sources
#'
#' @method print occdatind
#' @export
#' @param x Input, of class occdatind
#' @param ... Further args, ignored
#' @param n Number of data frame rows to print

print.occdatind <- function(x, ..., n = 10){
  cat( spocc_wrap(sprintf("Species [%s]", pastemax(x$data))), '\n')
  cat(sprintf("First 10 rows of [%s]\n\n", names(x$data)[1] ))
  spocc_trunc_mat(occinddf(x), n = n)
}

pastemax <- function(z, n=10){
  rrows <- vapply(z, nrow, integer(1))
  tt <- list(); for(i in seq_along(rrows)){ tt[[i]] <- sprintf("%s (%s)", gsub("_", " ", names(rrows[i])), rrows[[i]]) }
  paste0(tt, collapse = ", ")
}

occinddf <- function(obj) {
  z <- obj$data[[1]]
  df <- switch(obj$meta$source,
         gbif = data.frame(name = z$name, longitude = z$decimalLongitude, latitude = z$decimalLatitude, prov = z$prov),
         bison = data.frame(name = z$name, longitude = z$decimalLongitude, latitude = z$decimalLatitude, prov = z$prov),
         inat = data.frame(name = z$name, longitude = z$Longitude, latitude = z$Latitude, prov = z$prov),
         ebird = data.frame(name = z$name, longitude = z$lng, latitude = z$lat, prov = z$prov),
         ecoengine = data.frame(name = z$name, longitude = z$longitude, latitude = z$latitude, prov = z$prov),
         antweb = data.frame(name = z$name, longitude = z$decimal_longitude, latitude = z$decimal_latitude, prov = z$prov))
  z <- z[!names(z) %in% c('name','decimalLongitude','Longitude','lng','longitude','decimal_longitude',
                       'decimalLatitude','Latitude','lat','latitude','decimal_latitude','prov')]
  do.call(cbind, list(df, z))
}

#' Plot occ function output on a map (uses base plots via the rworldmap package)
#'
#' @import sp rworldmap
#' @param x Input object from occ function, of class occdat
#' @param ... Further args passed on to points fxn
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE))
#' plot(out, cex=1, pch=10)
#' }
#' @method plot occdat
#' @export

plot.occdat <- function(x, ...) {
  df <- occ2df(x)
  coordinates(df) <- ~longitude + latitude
  proj4string(df) <- CRS("+init=epsg:4326")
  plot(getMap())
  points(df, col = "red", ...)
}
