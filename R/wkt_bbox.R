#' Convert a bounding box to a Well Known Text polygon, and a WKT to a bounding box
#'
#' @param minx Minimum x value, or the most western longitude
#' @param miny Minimum y value, or the most southern latitude
#' @param maxx Maximum x value, or the most eastern longitude
#' @param maxy Maximum y value, or the most northern latitude
#' @param bbox A vector of length 4, with the elements: minx, miny, maxx, maxy
#' @return bbox2wkt returns an object of class charactere, a Well Known Text string
#' of the form 'POLYGON((minx miny, maxx miny, maxx maxy, minx maxy, minx miny))'.
#'
#' wkt2bbox returns a numeric vector of length 4, like c(minx, miny, maxx, maxy).
#' @export
#' @examples \dontrun{
#' # Convert a bounding box to a WKT
#'
#' ## Pass in a vector of length 4 with all values
#' bbox2wkt(bbox=c(38.4,-125.0,40.9,-121.8))
#'
#' ## Or pass in each value separately
#' mm <- bbox2wkt(minx=38.4, miny=-125.0, maxx=40.9, maxy=-121.8)
#' wkt_read(mm)
#'
#' # Convert a WKT object to a bounding box
#' wkt <- "POLYGON((38.4 -125,40.9 -125,40.9 -121.8,38.4 -121.8,38.4 -125))"
#' wkt2bbox(wkt)
#' }

bbox2wkt <- function(minx=NA, miny=NA, maxx=NA, maxy=NA, bbox=NULL){
  if (is.null(bbox)) bbox <- c(minx, miny, maxx, maxy)

  stopifnot(length(bbox) == 4) #check for 4 digits
  stopifnot(!any(is.na(bbox))) #check for NAs
  stopifnot(is.numeric(as.numeric(bbox))) #check for numeric-ness
  paste('POLYGON((',
        sprintf('%s %s',bbox[1],bbox[2]), ',', sprintf(' %s %s',bbox[3],bbox[2]), ',',
        sprintf(' %s %s',bbox[3],bbox[4]), ',', sprintf(' %s %s',bbox[1],bbox[4]), ',',
        sprintf(' %s %s',bbox[1],bbox[2]),
        '))', sep = "")
}

#' @param wkt A Well Known Text object.
#' @export
#' @rdname bbox2wkt
wkt2bbox <- function(wkt=NULL){
  stopifnot(!is.null(wkt))
  tmp <- wkt_read(wkt)$bbox
  as.vector(tmp)
}


# internal fxns
bbox2wkt_noclass <- function(minx=NA, miny=NA, maxx=NA, maxy=NA, bbox=NULL){
  if (is.null(bbox)) bbox <- c(minx, miny, maxx, maxy)
  
  stopifnot(length(bbox) == 4) #check for 4 digits
  stopifnot(!any(is.na(bbox))) #check for NAs
  stopifnot(is.numeric(as.numeric(bbox))) #check for numeric-ness
  paste('(',
        sprintf('%s %s',bbox[1],bbox[2]), ',', sprintf(' %s %s',bbox[3],bbox[2]), ',',
        sprintf(' %s %s',bbox[3],bbox[4]), ',', sprintf(' %s %s',bbox[1],bbox[4]), ',',
        sprintf(' %s %s',bbox[1],bbox[2]),
        ')', sep = "")
}

make_multipolygon <- function(x) {
  tmp <- vapply(x, function(z) bbox2wkt_noclass(bbox = z), "")
  sprintf("POLYGON(%s)", paste0(tmp, collapse = ", "))
}
