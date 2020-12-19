## plugin helper functions
move_cols <- function(x, y)
  x[ c(y, names(x)[-sapply(y, function(z) grep(paste0('\\b', z, '\\b'), 
                                               names(x)))]) ]

emptylist <- function(x, err = NULL) {
  list(
    time = NULL, found = NULL, data = tibble(), opts = x, errors = err
  )
}

stand_latlon <- function(x){
  lngs <- c('decimalLongitude', 'decimallongitude', 'Longitude', 'lng', 
            'longitude',
            'decimal_longitude', 'geopoint.lon')
  lats <- c('decimalLatitude', 'decimallatitude', 'Latitude', 'lat', 
            'latitude',
            'decimal_latitude', 'geopoint.lat')
  names(x)[ names(x) %in% lngs ] <- 'longitude'
  names(x)[ names(x) %in% lats ] <- 'latitude'
  x
}

add_latlong_if_missing <- function(x) {
  if (is.null(unclass(x)$longitude)) x$longitude <- NA
  if (is.null(unclass(x)$latitude)) x$latitude <- NA
  return(x)
}

stand_dates <- function(dat, from){
  datevars <- list(gbif = 'eventDate', obis = 'eventDate',
    bison = c('eventDate', 'year'), 
    inat = 'observed_on', ebird = 'obsDt', 
    vertnet = 'eventdate',
    idigbio = 'datecollected', ala = 'eventDate')
  var <- datevars[[from]]
  if (from == "bison") {
    var <- if ( is_null(dat$eventDate) ) "year" else "eventDate"
  }
  if ( is_null(dat[[var]]) ) {
    dat
  } else {
    dat[[var]] <- switch(
      from,
      gbif = as_date(ymd_hms(dat[[var]], truncated = 3, quiet = TRUE)),
      bison = as_date(ymd(dat[[var]], quiet = TRUE)),
      inat = as_date(ymd_hms(dat[[var]], truncated = 3, quiet = TRUE)),
      ebird = as_date(ymd_hm(dat[[var]], truncated = 3, quiet = TRUE)),
      vertnet = as_date(ymd(dat[[var]], truncated = 3, quiet = TRUE)),
      idigbio = as_date(ymd_hms(dat[[var]], truncated = 3, quiet = TRUE)),
      obis = as_date(ymd_hms(dat[[var]], truncated = 3, quiet = TRUE)),
      ala = as_date(date_ala(dat[[var]]))
    )
    if (from == "bison") rename(dat, stats::setNames('date', var)) else dat
  }
}

date_ala <- function(x) {
  x <- as.POSIXct(x/1000, origin = "1970-01-01", tz = "UTC")
  sub("\\sUTC$", "", x)
}


is_null <- function(...) {
  xx <- tryCatch(..., error = function(e) e)
  inherits(xx, "error") || is.null(xx)
}

limit_alias <- function(x, sources, geometry=NULL){
  bisonvar <- if (is.null(geometry)) 'rows' else 'count'
  if (length(x) != 0) {
    lim_name <- switch(sources, bison = bisonvar, 
                       inat = "maxresults", ebird = "max")
    if ("limit" %in% names(x)) {
      names(x)[ which(names(x) == "limit") ] <- lim_name
      x
    } else {
      x
    }
  } else {
    x
  }
}

add_latlong <- function(x, nms) {
  for (i in seq_along(nms)) {
    if (!nms[[i]] %in% names(x)) {
      x[[nms[[i]]]] <- NA
    }
  }
  return(x)
}
