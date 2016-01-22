#' @param query (character) One to many scientific names. See Details for what parameter
#' in each data source we query.
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' inat, ebird, ecoengine and/or vertnet
#' @param limit (numeric) Number of records to return. This is passed across all sources.
#' To specify different limits for each source, use the options for each source (gbifopts,
#' bisonopts, inatopts, ebirdopts, ecoengineopts, and antwebopts). See Details for more.
#' Default: 500 for each source. BEWARE: if you have a lot of species to query for (e.g.,
#' n = 10), that's 10 * 500 = 5000, which can take a while to collect. So, when you first query,
#' set the limit to something smallish so that you can get a result quickly, then do more as
#' needed.
#' @param start,page (integer) Record to start at or page to start at. See \code{Paging} in
#' Details for how these parameters are used internally. Optional
#' @param geometry (character or nmeric) One of a Well Known Text (WKT) object or a vector of
#' length 4 specifying a bounding box. This parameter searches for occurrences inside a
#' box given as a bounding box or polygon described in WKT format. A WKT shape written as
#' 'POLYGON((30.1 10.1, 20, 20 40, 40 40, 30.1 10.1))' would be queried as is,
#' i.e. http://bit.ly/HwUSif. See Details for more examples of WKT objects. The format of a
#' bounding box is [min-longitude, min-latitude, max-longitude, max-latitude]. Geometry
#' is not possible with vertnet right now, but should be soon. See Details for more info
#' on geometry inputs.
#' @param has_coords (logical) Only return occurrences that have lat/long data. This works
#' for gbif, ecoengine, antweb, rinat, idigbio, and vertnet, but is ignored for ebird and
#' bison data sources. You can easily though remove records without lat/long data.
#' @param ids Taxonomic identifiers. This can be a list of length 1 to many. See examples for
#' usage. Currently, identifiers for only 'gbif' and 'bison' for parameter 'from' supported. If
#' this parameter is used, query parameter can not be used - if it is, a warning is thrown.
#' @param callopts Options passed on to \code{\link[httr]{GET}}, e.g., for debugging curl calls,
#' setting timeouts, etc. This parameter is ignored for sources: antweb, inat.
#' @param gbifopts (list) List of named options to pass on to \code{\link[rgbif]{occ_search}}. See
#' also \code{\link{occ_options}}.
#' @param bisonopts (list) List of named options to pass on to \code{\link[rbison]{bison}}. See
#' also \code{\link{occ_options}}.
#' @param inatopts (list) List of named options to pass on to internal function \code{get_inat_obs}
#' @param ebirdopts (list) List of named options to pass on to \code{\link[rebird]{ebirdregion}}
#' or \code{\link[rebird]{ebirdgeo}}. See also \code{\link{occ_options}}.
#' @param ecoengineopts (list) List of named options to pass on to
#' \code{ee_observations}. See also \code{\link{occ_options}}.
#' @param antwebopts (list) List of named options to pass on to \code{\link[AntWeb]{aw_data}}.
#' See also \code{\link{occ_options}}.
#' @param vertnetopts (list) List of named options to pass on to
#' \code{\link[rvertnet]{searchbyterm}}. See also \code{\link{occ_options}}..
#' @param idigbioopts (list) List of named options to pass on to
#' \code{\link[ridigbio]{idig_search_records}}. See also \code{\link{occ_options}}.
#'
#' @details The \code{occ} function is an opinionated wrapper
#' around the rgbif, rbison, rinat, rebird, AntWeb, ecoengine, rvertnet and
#' ridigbio packages to allow data access from a single access point. We take
#' care of making sure you get useful objects out at the cost of
#' flexibility/options - although you can still set options for each of the
#' packages via the gbifopts, bisonopts, inatopts, ebirdopts, ecoengineopts,
#' vertnetopts, antwebopts and idigbioopts parameters.
#'
#' @section Inputs:
#' All inputs to \code{occ} are one of:
#' \itemize{
#'  \item scientific name
#'  \item taxonomic id
#'  \item geometry as bounds, WKT, os Spatial classes
#' }
#' To search by common name, first use \code{\link{occ_names}} to find scientic names or
#' taxonomic IDs, then feed those to this function. Or use the \code{taxize} package
#' to get names and/or IDs to use here.
#'
#' @section Using the query parameter:
#' When you use the \code{query} parameter, we pass your search terms on to parameters
#' within functions that query data sources you specify. Those parameters are:
#' \itemize{
#'  \item rgbif - \code{scientificName} in the \code{\link[rgbif]{occ_search}} function - API
#'  parameter: same as the \code{occ} parameter
#'  \item rebird - \code{species} in the \code{\link[rebird]{ebirdregion}} or
#'  \code{\link[rebird]{ebirdgeo}} functions, depending on whether you set
#'  \code{method="ebirdregion"} or \code{method="ebirdgeo"} - API parameters: \code{sci} for both
#'  \code{\link[rebird]{ebirdregion}} and \code{\link[rebird]{ebirdgeo}}
#'  \item ecoengine - \code{scientific_name} in the \code{ee_observations}
#'  function - API parameter: same as \code{occ} parameter
#'  \item rbison - \code{species} or \code{scientificName} in the \code{\link[rbison]{bison}} or
#'  \code{\link[rbison]{bison_solr}} functions, respectively. If you don't pass anything to
#'  \code{geometry} parameter we use \code{bison_solr}, and if you do we use \code{bison} - API
#'  parameters: same as \code{occ} parameters
#'  \item AntWeb - \code{scientific_name} or \code{genus} in the \code{\link[AntWeb]{aw_data}}
#'  function, depending on whether binomial or single name passed - API
#'  parameter: \code{species} for \code{scientific_name} and \code{genus} for
#'  \code{genus}
#'  \item rvertnet - \code{taxon} in the \code{\link[rvertnet]{vertsearch}} function - API
#'  parameter: \code{q}
#'  \item ridigbio - \code{scientificname} in the \code{\link[ridigbio]{idig_search_records}}
#'  function - API parameter: \code{scientificname}
#'  \item inat - internal function - API parameter: \code{q}
#' }
#' If you have questions about how each of those parameters behaves with respect to
#' the terms you pass to it, lookup documentation for those functions, or get in touch
#' at the development repository \url{https://github.com/ropensci/spocc/issues}
#'
#' @section iDigBio notes:
#' When searching iDigBio note that by deafult we set \code{fields = "all"}, so that we return
#' a richer suite of fields than the \code{ridigbio} R client gives by default. But you can
#' changes this by passing in a \code{fields} parameter to \code{idigbioopts} parameter with
#' the specific fields you want.
#'
#' @section Ecoengine notes:
#' When searching ecoengine, you can leave the page argument blank to get a single page.
#' Otherwise use page ranges or simply "all" to request all available pages.
#' Note however that this may hang your call if the request is simply too large.
#'
#' @section limit parameter:
#' The \code{limit} parameter is set to a default of 25. This means that you will get \bold{up to}
#' 25 results back for each data source you ask for data from. If there are no results for a
#' particular source, you'll get zero back; if there are 8 results for a particular source, you'll
#' get 8 back. If there are 26 results for a particular source, you'll get 25 back. You can always
#' ask for more or less back by setting the limit parameter to any number. If you want to request
#' a different number for each source, pass the appropriate parameter to each data source via the
#' respective options parameter for each data source.
#'
#' @section WKT:
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
#' @section geometry parameter:
#' The behavior of the \code{occ} function with respect to the \code{geometry} parameter
#' varies depending on the inputs to the \code{query} parameter. Here are the options:
#' \itemize{
#'  \item geometry (single), no query - If a single bounding box/WKT string passed in,
#'  and no query, a single query is made against each data source.
#'  \item geometry (many), no query - If many bounding boxes/WKT strings are passed in,
#'  we do a separate query for each bounding box/WKT string against each data source.
#'  \item geometry (single), query - If a single bounding box/WKT string passed in,
#'  and a single query, we do a single query against each data source.
#'  \item geometry (many), query - If many bounding boxes/WKT strings are passed in,
#'  and a single query, we do a separate query for each bounding box/WKT string with the
#'  same queried name against each data source.
#'  \item geometry (single), many query - If a single bounding box/WKT string passed in,
#'  and many names to query, we do a separate query for each name, using the same geometry,
#'  for each data source.
#'  \item geometry (many), many query - If many bounding boxes/WKT strings are passed in,
#'  and many names to query, this poses a problem for all data sources, none of which
#'  accept many bounding boxes of WKT strings. So, in this scenario, we loop over each
#'  name and each geometry query, and then re-combine by queried name, so that you get
#'  back a single group of data for each name.
#' }
#'
#' @section Geometry options by data provider:
#' \bold{wkt & bbox allowed, see WKT section above}
#' \itemize{
#'  \item gbif
#'  \item bison
#' }
#'
#' \bold{bbox only}
#' \itemize{
#'  \item ecoengine
#'  \item inat
#'  \item idigbio
#' }
#'
#' \bold{No spatial search allowed}
#' \itemize{
#'  \item antweb
#'  \item ebird
#'  \item vertnet
#' }
#'
#' @section Paging:
#' \itemize{
#'  \item gbif - Responds to \code{start}. Default: 0
#'  \item ecoengine - Responds to \code{page}. Default: 1
#'  \item antweb - Responds to \code{start}. Default: 0
#'  \item bison - Responds to \code{start}. Default: 0
#'  \item inat - Responds to \code{page}. Default: 1
#'  \item ebird - No paging, both \code{start} and \code{page} ignored.
#'  \item vertnet - No paging implemented here, both \code{start} and \code{page}
#'  ignored. VertNet does have a form of paging, but it uses a cursor, and can't
#'  easily be included  here via parameters. However, \code{rvertnet} does paging
#'  internally for you.  For example, the max records per request for VertNet is
#'  1000; if you request 2000 records, we'll do the first request, and do the
#'  second request for you automatically.
#'  \item idigbio - Responds to \code{start}. Default: 0
#' }
#'
#' @section BEWARE:
#' In cases where you request data from multiple providers, especially when
#' including GBIF, there could be duplicate records since many providers' data eventually
#' ends up with GBIF. See \code{\link[spocc]{spocc_duplicates}} for more.
