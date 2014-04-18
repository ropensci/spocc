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
#' @method print occdat
#' @export
#' @rdname occdat
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
#' @rdname occdat
plot.occdat <- function(x, ...) {
  df <- occ2df(x)
  coordinates(df) <- ~longitude + latitude
  proj4string(df) <- CRS("+init=epsg:4326")
  #     data(wrld_simpl, envir = new.env())
  #     data(wrld_simpl)
  #     world_simpl_obj <- wrld_simpl
  #     map(wrld_simpl)
  #     map("world")
  plot(getMap())
  points(df, col = "red", ...)
}