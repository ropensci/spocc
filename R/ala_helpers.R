ala_base <- function() "http://biocache.ala.org.au/ws/occurrences"

ala_search <- function(taxon = NULL, limit = 500, offset = 0, fq = NULL,
  facet = "off", facets = NULL, sort = NULL, dir = NULL, flimit = NULL, 
  fsort = NULL, foffset = NULL, fprefix = NULL, lat = NULL, lon = NULL,
  radius = NULL, fields = NULL, geometry = NULL, ...) {
  
  args <- sc(list(
    q = taxon, fq = fq, facet = facet, facets = facets, 
    pageSize = limit, startIndex = offset, 
    sort = sort, dir = dir, flimit = flimit, fsort = fsort, 
    foffset = foffset, fprefix = fprefix, lat = lat, lon = lon,
    radius = radius, wkt = geometry
  ))
  res <- httr::GET(file.path(ala_base(), "search"), query = args, ...)
  httr::stop_for_status(res)
  jsonlite::fromJSON(httr::content(res, "text", encoding = "UTF-8"), flatten = TRUE)
}

ala_occ_id <- function(id, ...) {
  if (length(id) > 1) {
    lapply(file.path(ala_base(), id), ala_GET, ...)
  } else {
    ala_GET(file.path(ala_base(), id), ...)
  }
}

ala_GET <- function(url, args = list(), ...) {
  res <- httr::GET(url, args, ...)
  httr::stop_for_status(res)
  jsonlite::fromJSON(httr::content(res, "text", encoding = "UTF-8"), 
                     flatten = TRUE)  
}
