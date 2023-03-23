#' Convert a bounding box to a Well Known Text polygon, and a WKT to a 
#' bounding box
#'
#' @export
#' @family bbox
#' @param minx Minimum x value, or the most western longitude
#' @param miny Minimum y value, or the most southern latitude
#' @param maxx Maximum x value, or the most eastern longitude
#' @param maxy Maximum y value, or the most northern latitude
#' @param bbox A vector of length 4, with the elements: minx, miny, maxx, maxy
#' @return bbox2wkt returns an object of class charactere, a Well Known Text 
#' string of the form 
#' 'POLYGON((minx miny, maxx miny, maxx maxy, minx maxy, minx miny))'
#'
#' wkt2bbox returns a numeric vector of length 4, like c(minx, miny, 
#' maxx, maxy).
#' 
#' @examples
#' # Convert a bounding box to a WKT
#'
#' ## Pass in a vector of length 4 with all values
#' bbox2wkt(bbox = c(-125.0,38.4,-121.8,40.9))
#' 
#' ## Or pass in each value separately
#' bbox2wkt(-125.0, 38.4, -121.8, 40.9)
#'
#' # Convert a WKT object to a bounding box
#' wkt <- "POLYGON((-125 38.4,-125 40.9,-121.8 40.9,-121.8 38.4,-125 38.4))"
#' wkt2bbox(wkt)
#' 
#' identical(
#'  bbox2wkt(-125.0, 38.4, -121.8, 40.9),
#'  "POLYGON((-125 38.4,-121.8 38.4,-121.8 40.9,-125 40.9,-125 38.4))"
#' )
#' 
#' identical(
#'  c(-125.0, 38.4, -121.8, 40.9),
#'  as.numeric(
#'    wkt2bbox(
#'      "POLYGON((-125 38.4,-125 40.9,-121.8 40.9,-121.8 38.4,-125 38.4))"
#'    )
#'  )
#' )
bbox2wkt <- function(minx=NA, miny=NA, maxx=NA, maxy=NA, bbox=NULL) {
  if (is.null(bbox)) bbox <- c(minx, miny, maxx, maxy)
  stopifnot(is.numeric(as.numeric(bbox)))
  bbox_template <- 'POLYGON((%s %s,%s %s,%s %s,%s %s,%s %s))'
  sprintf(bbox_template, 
    bbox[1], bbox[2],
    bbox[3], bbox[2],
    bbox[3], bbox[4],
    bbox[1], bbox[4],
    bbox[1], bbox[2]
  )
}

#' @param wkt A Well Known Text string
#' @importFrom wk wkt wk_bbox
#' @export
#' @family bbox
#' @rdname bbox2wkt
wkt2bbox <- function(wkt) {
  as.data.frame(wk::wk_bbox(wk::wkt(wkt)))
}
