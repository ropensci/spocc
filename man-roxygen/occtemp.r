#' @param query (character) One to many names. Either a scientific name or a common name.
#' Specify whether a scientific or common name in the type parameter.
#' Only scientific names supported right now.
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' inat, ebird, and/or ecoengine
#' @param limit (numeric) Number of records to return. This is passed across all sources.
#' To specify different limits for each source, use the options for each source.
#' @param geometry (character or nmeric) One of a Well Known Text (WKT) object or a vector of
#' length 4 specifying a bounding box. This parameter searches for occurrences inside a
#' box given as a bounding box or polygon described in WKT format. A WKT shape written as
#' 'POLYGON((30.1 10.1, 20, 20 40, 40 40, 30.1 10.1))' would be queried as is,
#' i.e. http://bit.ly/HwUSif. See Details for more examples of WKT objects.
#' @param rank (character) Taxonomic rank. Not used right now.
#' @param type (character) Type of search: sci (scientific) or com (common name, vernacular).
#' Not used right now.
#' @param ids Taxonomic identifiers. This can be a list of length 1 to many. See examples for
#' usage. Currently, identifiers for only 'gbif' and 'bison' for parameter 'from' supported. If
#' this parameter is used, query parameter can not be used - if it is, a warning is thrown.
#' @param callopts Options passed on to httr::GET, e.g., for debugging curl calls, setting
#' timeouts, etc. This parameter is ignored for sources: antweb, inat.
#' @param gbifopts (list) List of options to pass on to rgbif
#' @param bisonopts (list) List of options to pass on to rbison
#' @param inatopts (list) List of options to pass on to rinat
#' @param ebirdopts (list) List of options to pass on to ebird
#' @param ecoengineopts (list) List of options to pass on to ecoengine
#' @param antwebopts (list) List of options to pass on to AntWeb
#'
#' @details The \code{occ} function is an opinionated wrapper
#' around the rgbif, rbison, rinat, rebird, AntWeb, and ecoengine packages to allow data
#' access from a single access point. We take care of making sure you get useful
#' objects out at the cost of flexibility/options - although you can still set
#' options for each of the packages via the gbifopts, bisonopts, inatopts,
#' ebirdopts, and ecoengineopts parameters.
#'
#' When searching ecoengine, you can leave the page argument blank to get a single page.
#' Otherwise use page ranges or simply "all" to request all available pages.
#' Note however that this may hang your call if the request is simply too large.
#'
#' WKT objects are strings of pairs of lat/long coordinates that define a shape. Many classes
#' of shapes are supported, including POLYGON, POINT, and MULTIPOLYGON. Within each defined shape
#' define all vertices of the shape with a coordinate like 30.1 10.1, the first of which is the
#' latitude, the second the longitude.
#'
#' Examples of valid WKT objects:
#' \itemize{
#'  \item 'POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))'
#'  \item 'POINT((30.1 10.1))'
#'  \item 'LINESTRING(3 4,10 50,20 25)'
#'  \item 'MULTIPOINT((3.5 5.6),(4.8 10.5))")'
#'  \item 'MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))'
#'  \item 'MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2)),((6 3,9 2,9 4,6 3)))'
#'  \item 'GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))'
#' }
#'
#' Only POLYGON objects are currently supported.
#'
#' Getting WKT polygons or bounding boxes. We will soon introduce a function to help you select
#' a bounding box but for now, you can use a few sites on the web.
#'
#' \itemize{
#'  \item Bounding box - \url{http://boundingbox.klokantech.com/}
#'  \item Well known text - \url{http://arthur-e.github.io/Wicket/sandbox-gmaps3.html}
#' }
#'
#' \bold{BEWARE:} In cases where you request data from multiple providers, especially when including GBIF, 
#' there could be duplicate records since many providers' data eventually ends up with GBIF. See 
#' \code{\link[spocc]{spocc_duplicates}} for more.
