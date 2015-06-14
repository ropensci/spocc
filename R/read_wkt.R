#' Read or write WKT
#'
#' @export
#' @name wkt
#' @param wkt (character) A Well Known Text string
#' @param geojson (character) GeoJSON as a list, character string or JSON
#' @examples
#' wkt <- 'LINESTRING (30 10, 10 30, 40 40)'
#' read_wkt(wkt)
#' 
#' wkt <- "POLYGON((38.4 -125,40.9 -125,40.9 -121.8,38.4 -121.8,38.4 -125))"
#' read_wkt(wkt)

#' @export
#' @rdname wkt
read_wkt <- function(wkt) {
  terr$eval(sprintf("var out = terrwktparse.parse('%s');", wkt))
  terr$get("out")
}

#' @export
#' @rdname wkt
write_wkt <- function(geojson) {
  terr$eval(sprintf("var out = terrwktparse.convert(%s);", geojson))
  terr$get("out")
}
