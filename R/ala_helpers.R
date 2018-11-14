ala_base <- function() "http://biocache.ala.org.au"

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
  cli <- crul::HttpClient$new(
    url = ala_base(),
    opts = list(...)
  )
  out <- cli$get(path = "ws/occurrences/search", query = args)
  if (out$status_code > 201) {
    txt <- out$parse("UTF-8")
    if (grepl("html", out$response_headers$`content-type`)) {
      out$raise_for_status()
    } else {
      tt <- tryCatch(jsonlite::fromJSON(txt, FALSE), error = function(e) e)
    }
    if (inherits(tt, "error")) out$raise_for_status()
    mssg <- strsplit(tt$message, ";")[[1]]
    stop(mssg[length(mssg)], call. = FALSE)
  }
  jsonlite::fromJSON(out$parse("UTF-8"), flatten = TRUE)
}

ala_occ_id <- function(id, ...) {
  if (length(id) > 1) {
    lapply(id, ala_GET, ...)
  } else {
    ala_GET(id, ...)
  }
}

ala_GET <- function(id, args = list(), ...) {
  cli <- crul::HttpClient$new(
    url = ala_base(),
    opts = list(...)
  )
  out <- cli$get(path = file.path("ws/occurrence", id), query = args)
  out$raise_for_status()
  jsonlite::fromJSON(out$parse("UTF-8"), flatten = TRUE)
}
