obis_search <- function(scientificName, limit = 200, offset = 0, ...) {
  args <- sc(list(scientificname = scientificName, limit = limit, offset = offset))
  res <- GET(obis_base(), query = args, ...)
  stop_for_status(res)
  jsonlite::fromJSON(content(res, "text"))
}

obis_base <- function(x) "http://api.iobis.org/occurrence"
