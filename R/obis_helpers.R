obis_base <- function() "https://api.obis.org"

#' OBIS search
#' @export
#' @keywords internal
#' @param scientificname (character) Scientific name. Leave empty to
#' include all taxa. This is what we pass your name query to
#' @param taxonid (character) Taxon AphiaID.
#' @param datasetid (character) Dataset UUID.
#' @param areaid (character) Area ID.
#' @param instituteid (character) Institute ID.
#' @param nodeid (character) Node UUID.
#' @param startdate (character) Start date formatted as YYYY-MM-DD.
#' @param enddate (character) End date formatted as YYYY-MM-DD.
#' @param startdepth (integer) Start depth, in meters.
#' @param enddepth (integer) End depth, in meters.
#' @param geometry (character) Geometry, formatted as WKT.
#' @param exclude (character) set of quality flags to be excluded.
#' one or more in a vector
#' @param fields (character) Field to be included in the result set.
#' one or more in a vector
#' @param after (character) Occurrence UUID up to which to skip.
#' @param size (integer) number of results to fetch
obis_search <- function(scientificName = NULL, size = 500, after = NULL, 
  taxonid = NULL, aphiaid = NULL, areaid = NULL, datasetid = NULL,
  instituteid = NULL, nodeid = NULL, startdate = NULL,
  enddate = NULL, startdepth = NULL,
  enddepth = NULL, geometry = NULL, exclude = NULL, fields = NULL, 
  ...) {
  
  if (!is.null(exclude)) exclude <- paste0(exclude, collapse = ",")
  if (!is.null(fields)) fields <- paste0(fields, collapse = ",")
  args <- sc(list(scientificname = scientificName, size = size, 
      after = after, taxonid = taxonid, aphiaid = aphiaid, 
      areaid = areaid, datasetid = datasetid, instituteid = instituteid,
      nodeid = nodeid, startdate = startdate, 
      enddate = enddate, startdepth = startdepth,
      enddepth = enddepth, geometry = geometry, exclude = exclude,
      fields = fields))
  
  cli <- crul::HttpClient$new(
    url = obis_base(),
    opts = list(...)
  )
  out <- cli$get(path = "v3/occurrence", query = args)
  if (out$status_code > 201) {
    txt <- out$parse("UTF-8")
    tt <- tryCatch(jsonlite::fromJSON(txt, FALSE), error = function(e) e)
    if (inherits(tt, "error")) out$raise_for_status()
    mssg <- strsplit(tt$message, ";")[[1]]
    stop(mssg[length(mssg)], call. = FALSE)
  }
  jsonlite::fromJSON(out$parse("UTF-8"))
}

# id: is the `id` field in the JSON payload response, a UUID string
obis_occ_id <- function(id, ...) {
  cli <- crul::HttpClient$new(
    url = file.path(obis_base(), "v3/occurrence", id),
    opts = list(...)
  )
  out <- cli$get()
  out$raise_for_status()
  jsonlite::fromJSON(out$parse("UTF-8"))
}
