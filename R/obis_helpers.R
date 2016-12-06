obis_base <- function() "http://api.iobis.org/occurrence"

obis_search <- function(scientificName = NULL, limit = 500, offset = 0, 
  obisid = NULL, aphiaid = NULL, resourceid = NULL, year = NULL,
  startdate = NULL, enddate = NULL, startdepth = NULL,
  enddepth = NULL, geometry = NULL, qc = NULL, ...) {
  
  args <- sc(list(scientificname = scientificName, limit = limit, offset = offset, 
      obisid = obisid, aphiaid = aphiaid, resourceid = resourceid, year = year,
      startdate = startdate, enddate = enddate, startdepth = startdepth,
      enddepth = enddepth, geometry = geometry, qc = qc))
  res <- GET(obis_base(), query = args, ...)
  stop_for_status(res)
  jsonlite::fromJSON(content(res, "text"))
}

obis_occ_id <- function(id, ...) {
  res <- GET(file.path(obis_base(), id), ...)
  stop_for_status(res)
  jsonlite::fromJSON(content(res, "text"))
}
