e_base <- function() 'https://ebird.org/ws2.0/'

spocc_get_key <- function(key = NULL) {
  if (!is.null(key)) return(key)
  key <- Sys.getenv("EBIRD_KEY")
  if (!nzchar(key)) {
    stop(
    "You must provide an API key from eBird.
    You can pass it to the 'key' argument or store it as 
    an environment variable called EBIRD_KEY in your .Renviron file.
    If you don't have a key, you can obtain one from:
    https://ebird.org/api/keygen.", call. = FALSE
    )
  }
  key
}

spocc_ebird_region <-  function(loc, species = NULL, back = NULL, max = NULL, 
  locale = NULL, provisional = FALSE, hotspot = FALSE, simple = TRUE, 
  sleep = 0, key = NULL, opts = list()) {
  
  Sys.sleep(sleep)
  url <- paste0(e_base(), 'data/obs/', loc, '/recent/', species)
  if (!is.null(back)) back <- round(back)
  args <- sc(list(back=back, maxResults=max, locale=locale))
  if (provisional) args$includeProvisional <- 'true'
  if (hotspot) args$hotspot <- 'true'
  if (!simple) args$detail <- 'full'
  spocc_ebird_GET(url, args, key = key, opts)
}

spocc_ebirdgeo <-  function(species = NULL, lat = NULL, lng = NULL, dist = NULL, 
  back = NULL, max = NULL, locale = NULL, provisional = FALSE, hotspot = FALSE, 
  sleep = 0, key = NULL, opts = list())  {

  Sys.sleep(sleep)
  url <- paste0(e_base(), 'data/obs/', 
    if (!is.null(species)) paste0('geo/recent/',species) else 'geo/recent')

  geoloc <- c(lat,lng)
  if (is.null(geoloc)) geoloc <- rebird::getlatlng()
  if (!is.null(dist)) {
    if (dist > 50) {
      dist <- 50
      warning("Distance supplied was >50km, using 50km.")
    }
    dist <- round(dist)
  }

  if (!is.null(back)) {
    if (back > 30) {
      back <- 30
      warning("'Back' supplied was >30 days, using 30 days.")
    }
    back <- round(back)
  }

  args <- sc(list(speciesCode = species,
    lat = round(geoloc[1], 2), lng = round(geoloc[2], 2),
    dist = dist, back = back, maxResults = max,
    sppLocale = locale
  ))

  if (provisional) args$includeProvisional <- 'true'
  if (hotspot) args$hotspot <- 'true'
  spocc_ebird_GET(url, args, key = key, opts)
}

spocc_ebird_GET <- function(url, args, key = NULL, opts = list()) {
  cli <- crul::HttpClient$new(
    url, 
    headers = list("X-eBirdApiToken" = spocc_get_key(key)),
    opts = opts
  )
  res <- cli$get(query = args)
  if (res$status_code > 203) {
    json <- tryCatch(jsonlite::fromJSON(res$parse("UTF-8"), FALSE), 
      error = function(e) e
    )
    if (inherits(json, "error")) stop(res$status_http()$message)
    stop(json$errors[[1]]$title)
  }
  json <- jsonlite::fromJSON(res$parse("UTF-8"), FALSE)
  json <- lapply(json, function(x) lapply(x, function(a) {
    if (length(a) == 0) { 
      NA 
    } else if (length(a) > 1) {
      paste0(a, collapse = ",")
    } else {
      if (inherits(a, "list")) {
        a[[1]]
      } else {
        a
      }
    }
  }))
  rbindl(json)
}
