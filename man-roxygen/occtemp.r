#' @param query (character) One to many scientific names. See Details for what parameter
#' in each data source we query. Note: ebird now expects species codes instead of 
#' scientific names - we pass you name through [rebird::species_code()] internally
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' inat, ebird, ecoengine and/or vertnet
#' @param limit (numeric) Number of records to return. This is passed across all sources.
#' To specify different limits for each source, use the options for each source (gbifopts,
#' bisonopts, inatopts, ebirdopts, and ecoengineopts). See Details for more.
#' Default: 500 for each source. BEWARE: if you have a lot of species to query for (e.g.,
#' n = 10), that's 10 * 500 = 5000, which can take a while to collect. So, when you first query,
#' set the limit to something smallish so that you can get a result quickly, then do more as
#' needed.
#' @param start,page (integer) Record to start at or page to start at. See `Paging` in
#' Details for how these parameters are used internally. Optional
#' @param geometry (character or nmeric) One of a Well Known Text (WKT) object or a vector of
#' length 4 specifying a bounding box. This parameter searches for occurrences inside a
#' box given as a bounding box or polygon described in WKT format. A WKT shape written as
#' `POLYGON((30.1 10.1, 20 40, 40 40, 30.1 10.1))` would be queried as is,
#' i.e. http://bit.ly/HwUSif. See Details for more examples of WKT objects. The format of a
#' bounding box is `min-longitude, min-latitude, max-longitude, max-latitude`. Geometry
#' is not possible with vertnet right now, but should be soon. See Details for more info
#' on geometry inputs.
#' @param has_coords (logical) Only return occurrences that have lat/long data. This works
#' for gbif, ecoengine, rinat, idigbio, and vertnet, but is ignored for ebird and
#' bison data sources. You can easily though remove records without lat/long data.
#' @param ids Taxonomic identifiers. This can be a list of length 1 to many. See examples for
#' usage. Currently, identifiers for only 'gbif' and 'bison' for parameter 'from' supported. If
#' this parameter is used, query parameter can not be used - if it is, a warning is thrown.
#' @param date (character/Date) A length 2 vector containing two dates of the form 
#' YYY-MM-DD. These can be character of Date class. These are used to do a date range search.
#' Of course there are other types of date searches one may want to do but date range 
#' seems like the most common date search use case.
#' @param callopts Options passed on to [crul::HttpClient], e.g., 
#' for debugging curl calls, setting timeouts, etc. This parameter is ignored 
#' for sources: inat.
#' @param gbifopts (list) List of named options to pass on to [rgbif::occ_search()]. See
#' also [occ_options()]
#' @param bisonopts (list) List of named options to pass on to [rbison::bison()]. See
#' also [occ_options()]
#' @param inatopts (list) List of named options to pass on to internal function `get_inat_obs`
#' @param ebirdopts (list) List of named options to pass on to [rebird::ebirdregion()]
#' or [rebird::ebirdgeo()]. See also [occ_options()]
#' @param ecoengineopts (list) List of named options to pass on to
#' `ee_observations`. See also [occ_options()].
#' @param vertnetopts (list) List of named options to pass on to
#' [rvertnet::searchbyterm()]. See also [occ_options()].
#' @param idigbioopts (list) List of named options to pass on to
#' [ridigbio::idig_search_records()]. See also [occ_options()].
#' @param obisopts (list) List of named options to pass on to internal function. See 
#' <https://github.com/iobis/api-docs> for possible parameters
#' @param alaopts (list) List of named options to pass on to internal function. 
#' See `Occurrence search` part of the API docs at 
#' <http://api.ala.org.au/#ws3> for possible parameters.
#' @param throw_warnings (logical) `occ()` collects errors returned from each 
#' data provider when they occur, and are accessible in the `$meta$errors` slot for 
#' each data provider. If you set `throw_warnings=TRUE`, we give these request errors as 
#' warnings with [warning()]. if `FALSE`, we don't give warnings, but you can still 
#' access them in the output.
#' 
#' @return an object of class `occdat`, with a print method to give a brief summary. 
#' The print method only shows results for those that have some results (those with no 
#' results are not shown). The `occdat` class is just a thin wrapper around a named 
#' list, wher the top level names are the data sources:
#' 
#' - gbif
#' - bison
#' - inat
#' - ebird
#' - ecoengine
#' - vertnet
#' - idigbio
#' - obis
#' - ala
#' 
#' Note that you only get data back for sources that were specified in the `from` 
#' parameter. All others are present, but empty.
#' 
#' Then within each data source is an object of class `occdatind` holding another 
#' named list that contains:
#' 
#' - meta: metadata
#'   - source: the data source name (e.g., "gbif")
#'   - time: time the request was sent
#'   - found: number of records found (number found across all queries)
#'   - returned: number of records returned (number of rows in all data.frame's
#'     in the `data` slot)
#'   - type: query type, only "sci" for scientific
#'   - opts: a named list with the options you sent to the data source
#'   - errors: a character vector of errors returned, if any occurred
#' - data: named list of data.frame's, named by the queries sent
#'
#' @details The `occ` function is an opinionated wrapper
#' around the rgbif, rbison, rinat, rebird, ecoengine, rvertnet and
#' ridigbio packages (as well as internal custom wrappers around some data
#' sources) to allow data access from a single access point. We take
#' care of making sure you get useful objects out at the cost of
#' flexibility/options - although you can still set options for each of the
#' packages via the gbifopts, bisonopts, inatopts, etc. parameters.
#'
#' @section Inputs:
#' All inputs to `occ` are one of:
#' 
#' - scientific name
#' - taxonomic id
#' - geometry as bounds, WKT, os Spatial classes
#' 
#' To search by common name, first use [occ_names()] to find scientic names or
#' taxonomic IDs, then feed those to this function. Or use the `taxize` package
#' to get names and/or IDs to use here.
#'
#' @section Using the query parameter:
#' When you use the `query` parameter, we pass your search terms on to parameters
#' within functions that query data sources you specify. Those parameters are:
#' 
#' - rgbif - `scientificName` in the [rgbif::occ_search()] function - API
#'  parameter: same as the `occ` parameter
#' - rebird - `species` in the [rebird::ebirdregion()] or
#'  [rebird::ebirdgeo()] functions, depending on whether you set
#'  `method="ebirdregion"` or `method="ebirdgeo"` - API parameters: `sci` for both
#'  [rebird::ebirdregion()] and [rebird::ebirdgeo()]
#' - ecoengine - `scientific_name` in the `ee_observations`
#'  function - API parameter: same as `occ` parameter
#' - rbison - `species` or `scientificName` in the [rbison::bison()] or
#'  [rbison::bison_solr()] functions, respectively. If you don't pass anything to
#'  `geometry` parameter we use `bison_solr`, and if you do we use `bison` - API
#'  parameters: same as `occ` parameters
#' - rvertnet - `taxon` in the [rvertnet::vertsearch()] function - API
#'  parameter: `q`
#' - ridigbio - `scientificname` in the [ridigbio::idig_search_records()]
#'  function - API parameter: `scientificname`
#' - inat - internal function - API parameter: `q`
#' - obis - internal function - API parameter: `scientificName`
#' - ala - internal function - API parameter: `q`
#' 
#' If you have questions about how each of those parameters behaves with respect to
#' the terms you pass to it, lookup documentation for those functions, or get in touch
#' at the development repository <https://github.com/ropensci/spocc/issues>
#'
#' @section iDigBio notes:
#' When searching iDigBio note that by deafult we set `fields = "all"`, so that we return
#' a richer suite of fields than the `ridigbio` R client gives by default. But you can
#' changes this by passing in a `fields` parameter to `idigbioopts` parameter with
#' the specific fields you want.
#' 
#' Maximum of 100,000 results are allowed to be returned. See 
#' <https://github.com/iDigBio/ridigbio/issues/33>
#'
#' @section Ecoengine notes:
#' When searching ecoengine, you can leave the page argument blank to get a single page.
#' Otherwise use page ranges or simply "all" to request all available pages.
#' Note however that this may hang your call if the request is simply too large.
#' 
#' @section BISON notes:
#' We use two different functions when you request data from `bison`. We use 
#' [rbison::bison_solr()] by default as it's more flexible. If you pass a value to the 
#' `geometry` parameter we use [rbison::bison()]. We'd prefer to just use one function 
#' to simplify things, but [rbison::bison_solr()] doesn't support geometry queries.
#'
#' @section limit parameter:
#' The `limit` parameter is set to a default of 25. This means that you will get **up to**
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
#'
#' - 'POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))'
#' - 'POINT((30.1 10.1))'
#' - 'LINESTRING(3 4,10 50,20 25)'
#' - 'MULTIPOINT((3.5 5.6),(4.8 10.5))")'
#' - 'MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))'
#' - 'MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2)),((6 3,9 2,9 4,6 3)))'
#' - 'GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))'
#'
#' Only POLYGON objects are currently supported.
#'
#' Getting WKT polygons or bounding boxes. We will soon introduce a function to help you select
#' a bounding box but for now, you can use a few sites on the web.
#'
#' - Bounding box - <http://boundingbox.klokantech.com/>
#' - Well known text - <http://arthur-e.github.io/Wicket/sandbox-gmaps3.html>
#'
#' @section geometry parameter:
#' The behavior of the `occ` function with respect to the `geometry` parameter
#' varies depending on the inputs to the `query` parameter. Here are the options:
#' 
#' - geometry (single), no query - If a single bounding box/WKT string passed in,
#'  and no query, a single query is made against each data source.
#' - geometry (many), no query - If many bounding boxes/WKT strings are passed in,
#'  we do a separate query for each bounding box/WKT string against each data source.
#' - geometry (single), query - If a single bounding box/WKT string passed in,
#'  and a single query, we do a single query against each data source.
#' - geometry (many), query - If many bounding boxes/WKT strings are passed in,
#'  and a single query, we do a separate query for each bounding box/WKT string with the
#'  same queried name against each data source.
#' - geometry (single), many query - If a single bounding box/WKT string passed in,
#'  and many names to query, we do a separate query for each name, using the same geometry,
#'  for each data source.
#' - geometry (many), many query - If many bounding boxes/WKT strings are passed in,
#'  and many names to query, this poses a problem for all data sources, none of which
#'  accept many bounding boxes of WKT strings. So, in this scenario, we loop over each
#'  name and each geometry query, and then re-combine by queried name, so that you get
#'  back a single group of data for each name.
#'
#' @section Geometry options by data provider:
#' **wkt & bbox allowed, see WKT section above**
#' 
#' - gbif
#' - bison
#' - obis
#' - ala
#'
#' **bbox only**
#' 
#' - ecoengine
#' - inat
#' - idigbio
#'
#' **No spatial search allowed**
#' 
#' - ebird
#' - vertnet
#' 
#' @section Notes on the date parameter:
#' Date searches with the `date` parameter are allowed for all sources 
#' except ebird.
#' 
#' Notes on some special cases
#' 
#' - idigbio: We search on the `datecollected` field. Other date fields can be 
#' searched on, but we chose `datecollected` as it seemed most appropriate.
#' - vertnet: If you want more flexible date searches, you can pass various 
#' types of date searches to `vertnetopts`. See [rvertnet::searchbyterm()]
#' for more information
#' - ala: There's some issues with the dates returned from ALA. They are 
#' returned as time stamps, and some seem to be malformed. So do beware 
#' of using ALA dates for important things.
#' 
#' Get in touch if you have other date search use cases you think 
#' are widely useful
#'
#' @section Paging:
#' All data sources respond to the `limit` parameter passed to `occ`.
#' 
#' Data sources, however, vary as to whether they respond to an offset. Here's
#' the details on which data sources will respond to `start` and which 
#' to the `page` parameter:
#' 
#' - gbif - Responds to `start`. Default: 0
#' - ecoengine - Responds to `page`. Default: 1
#' - bison - Responds to `start`. Default: 0
#' - inat - Responds to `page`. Default: 1
#' - ebird - No paging, both `start` and `page` ignored.
#' - vertnet - No paging implemented here, both `start` and `page`
#'  ignored. VertNet does have a form of paging, but it uses a cursor, and can't
#'  easily be included  here via parameters. However, `rvertnet` does paging
#'  internally for you.  For example, the max records per request for VertNet is
#'  1000; if you request 2000 records, we'll do the first request, and do the
#'  second request for you automatically.
#' - idigbio - Responds to `start`. Default: 0
#' - obis - Responds to `start`. Default: 0
#' - ala - Responds to `start`. Default: 0
#'
#' @section BEWARE:
#' In cases where you request data from multiple providers, especially when
#' including GBIF, there could be duplicate records since many providers' data eventually
#' ends up with GBIF. See [spocc_duplicates()] for more.
