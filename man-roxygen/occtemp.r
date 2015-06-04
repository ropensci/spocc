#' @param query (character) One to many names. Either a scientific name or a common name.
#' Specify whether a scientific or common name in the type parameter. For idigbio, we pass
#' the query to the \code{scientificname} query parameter for their API.
#' Only scientific names supported right now.
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' inat, ebird, ecoengine and/or vertnet
#' @param limit (numeric) Number of records to return. This is passed across all sources.
#' To specify different limits for each source, use the options for each source (gbifopts, 
#' bisonopts, inatopts, ebirdopts, ecoengineopts, and antwebopts). See Details for more. 
#' Default: 500 for each source. BEWARE: if you have a lot of species to query for (e.g., 
#' n = 10), that's 10 * 500 = 5000, which can take a while to collect. So, when you first query,
#' set the limit to something smallish so that you can get a result quickly, then do more as 
#' needed.
#' @param geometry (character or nmeric) One of a Well Known Text (WKT) object or a vector of
#' length 4 specifying a bounding box. This parameter searches for occurrences inside a
#' box given as a bounding box or polygon described in WKT format. A WKT shape written as
#' 'POLYGON((30.1 10.1, 20, 20 40, 40 40, 30.1 10.1))' would be queried as is,
#' i.e. http://bit.ly/HwUSif. See Details for more examples of WKT objects. The format of a
#' bounding box is [min-longitude, min-latitude, max-longitude, max-latitude]. Geometry
#' is not possible with vertnet right now, but should be soon.
#' @param rank (character) Taxonomic rank. Not used right now.
#' @param type (character) Type of search: sci (scientific) or com (common name, vernacular).
#' Not used right now.
#' @param ids Taxonomic identifiers. This can be a list of length 1 to many. See examples for
#' usage. Currently, identifiers for only 'gbif' and 'bison' for parameter 'from' supported. If
#' this parameter is used, query parameter can not be used - if it is, a warning is thrown.
#' @param callopts Options passed on to \code{\link[httr]{GET}}, e.g., for debugging curl calls, 
#' setting timeouts, etc. This parameter is ignored for sources: antweb, inat.
#' @param gbifopts (list) List of named options to pass on to \code{\link[rgbif]{occ_search}}. See
#' also \code{\link{occ_options}}. 
#' @param bisonopts (list) List of named options to pass on to \code{\link[rbison]{bison}}. See 
#' also \code{\link{occ_options}}.
#' @param inatopts (list) List of named options to pass on to \code{\link[rinat]{get_inat_obs}}. 
#' See also \code{\link{occ_options}}.
#' @param ebirdopts (list) List of named options to pass on to \code{\link[rebird]{ebirdregion}} 
#' or \code{\link[rebird]{ebirdgeo}}. See also \code{\link{occ_options}}.
#' @param ecoengineopts (list) List of named options to pass on to 
#' \code{\link[ecoengine]{ee_observations}}. See also \code{\link{occ_options}}.
#' @param antwebopts (list) List of named options to pass on to \code{\link[AntWeb]{aw_data}}. 
#' See also \code{\link{occ_options}}.
#' @param vertnetopts (list) List of named options to pass on to 
#' \code{\link[rvertnet]{searchbyterm}}. See also \code{\link{occ_options}}.
#' @param idigbioopts (list) List of named options to pass on to 
#' \code{idig_search_records}. See also \code{\link{occ_options}}.
#'
#' @details The \code{occ} function is an opinionated wrapper
#' around the rgbif, rbison, rinat, rebird, AntWeb, ecoengine, and rvertnet packages to 
#' allow data access from a single access point. We take care of making sure you get useful
#' objects out at the cost of flexibility/options - although you can still set
#' options for each of the packages via the gbifopts, bisonopts, inatopts,
#' ebirdopts, ecoengineopts, vertnetopts, and antwebopts parameters.
#'
#' When searching ecoengine, you can leave the page argument blank to get a single page.
#' Otherwise use page ranges or simply "all" to request all available pages.
#' Note however that this may hang your call if the request is simply too large.
#' 
#' The \code{limit} parameter is set to a default of 25. This means that you will get \bold{up to} 
#' 25 results back for each data source you ask for data from. If there are no results for a 
#' particular source, you'll get zero back; if there are 8 results for a particular source, you'll 
#' get 8 back. If there are 26 results for a particular source, you'll get 25 back. You can always
#' ask for more or less back by setting the limit parameter to any number. If you want to request
#' a different number for each source, pass the appropriate parameter to each data source via the 
#' respective options parameter for each data source. 
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
