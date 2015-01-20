# Plugins for the occ function for each data source
#' @noRd
foo_gbif <- function(sources, query, limit, geometry, callopts, opts) {
  if (any(grepl("gbif", sources))) {

    if(!is.null(query)){
      if(class(query) %in% c("ids","gbifid")){
        if(class(query) %in% "ids"){
          query_use <- opts$taxonKey <- query$gbif
        } else {
          query_use <- opts$taxonKey <- query
        }
      } else {
        query_use <- query
        if(is.null(query_use)){
          warning(sprintf("No GBIF result found for %s", query))
        } else {
          opts$scientificName <- query_use
        }
      }
    } else { 
      query_use <- NULL 
    }

    if(is.null(query_use) && is.null(geometry)){ emptylist(opts) } else {
      time <- now()
      if(!'limit' %in% names(opts)) opts$limit <- limit
      opts$fields <- 'all'
      if(!is.null(geometry)){
        opts$geometry <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){
          geometry } else { bbox2wkt(bbox=geometry) }
      }
      opts$callopts <- callopts
      out <- do.call(occ_search, opts)
      if(class(out) == "character") { emptylist(opts) } else {
        if(class(out$data) == "character"){ emptylist(opts) } else {
          dat <- out$data
          dat$prov <- rep("gbif", nrow(dat))
          dat$name <- as.character(dat$name)
          cols <- c('name','decimalLongitude','decimalLatitude','issues','prov')
          cols <- cols[ cols %in% sort(names(dat)) ]
          dat <- move_cols(x=dat, y=cols)
          dat <- stand_latlon(dat)
          list(time = time, found = out$meta$count, data = dat, opts = opts)
        }
      }
    }
  } else { emptylist(opts) }
}

move_cols <- function(x, y)
  x[ c(y, names(x)[-sapply(y, function(z) grep(paste0('\\b', z, '\\b'), names(x)))]) ]
emptylist <- function(opts) list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
stand_latlon <- function(x){
  lngs <- c('decimalLongitude','Longitude','lng','longitude','decimal_longitude')
  lats <- c('decimalLatitude','Latitude','lat','latitude','decimal_latitude')
  names(x)[ names(x) %in% lngs ] <- 'longitude'
  names(x)[ names(x) %in% lats ] <- 'latitude'
  x
}

#' @noRd
foo_ecoengine <- function(sources, query, limit, geometry, callopts, opts) {
  if (any(grepl("ecoengine", sources))) {
    opts <- limit_alias(opts, "ecoengine")
    time <- now()
    opts$scientific_name <- query
    opts$georeferenced <- TRUE
    if(!'page_size' %in% names(opts)) opts$page_size <- limit
    if(!is.null(geometry)){
      opts$bbox <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){
        wkt2bbox(geometry) } else { geometry }
    }
    # This could hang things if request is super large.  Will deal with this issue
    # when it arises in a usecase
    # For now default behavior is to retrive one page.
    # page = "all" will retrieve all pages.
    if (is.null(opts$page)) {
      opts$page <- 1
    }
    opts$quiet <- TRUE
    opts$progress <- FALSE
    opts$foptions <- callopts
    out_ee <- do.call(ee_observations, opts)
    if(out_ee$results == 0){
      warning(sprintf("No records found in Ecoengine for %s", query))
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      out <- out_ee$data
      fac_tors <- sapply(out, is.factor)
      out[fac_tors] <- lapply(out[fac_tors], as.character)
      out$prov <- rep("ecoengine", nrow(out))
      names(out)[names(out) == 'scientific_name'] <- "name"
      list(time = time, found = out_ee$results, data = out, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}


#' @noRd
foo_antweb <- function(sources, query, limit, geometry, callopts, opts) {
  if (any(grepl("antweb", sources))) {
    time <- now()
    #     limit <- NULL
    geometry <- NULL

    query <- sub("^ +", "", query)
    query <- sub(" +$", "", query)

    if(length(strsplit(query, " ")[[1]]) == 2) {
      opts$scientific_name <- query
    } else {
      opts$genus <- query
      opts$scientific_name <- NULL
    }

    if(!'limit' %in% names(opts)) opts$limit <- limit
    opts$georeferenced <- TRUE
    out <- do.call(aw_data, opts)

    if(is.null(out)){
      warning(sprintf("No records found in AntWeb for %s", query))
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      res <- out$data
      res$prov <- rep("antweb", nrow(res))
      res$name <- query
      res <- stand_latlon(res)
      list(time = time, found = out$count, data = res, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}


#' @noRd
foo_bison <- function(sources, query, limit, geometry, callopts, opts) {
  if(any(grepl("bison", sources))) {
    opts <- limit_alias(opts, "bison")
    if(class(query) %in% c("ids","tsn")){
      if(class(query) %in% "ids"){
        opts$tsn <- query$itis
      } else
      {
        opts$tsn <- query
      }
    } else
    { opts$species <- query }

    time <- now()
    if(!'count' %in% names(opts)) opts$count <- limit
    opts$config <- callopts
    #     opts$what <- 'points'
    if(!is.null(geometry)){
      opts$aoi <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){
        geometry } else { bbox2wkt(bbox=geometry) }
    }
    out <- do.call(bison, opts)
    if(is.null(out$points)){
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      dat <- out$points
      dat$prov <- rep("bison", nrow(dat))
      dat <- stand_latlon(dat)
      list(time = time, found = out$summary$total, data = dat, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}


#' @noRd
foo_inat <- function(sources, query, limit, geometry, callopts, opts) {
  if (any(grepl("inat", sources))) {
    opts <- limit_alias(opts, "inat")
    time <- now()
    opts$query <- query
    if(!'maxresults' %in% names(opts)) opts$maxresults <- limit
    opts$meta <- TRUE
    if(!is.null(geometry)){
      opts$bounds <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" ")))
      {
        # flip lat and long spots in the bounds vector for inat
        temp <- wkt2bbox(geometry)
        c(temp[2], temp[1], temp[4], temp[3])
      } else { c(geometry[2], geometry[1], geometry[4], geometry[3]) }
    }
    out <- do.call(spocc_inat_obs, opts)
    if(!is.data.frame(out$data)){
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      res <- out$data
      res$prov <- rep("inat", nrow(res))
      names(res)[names(res) == 'Scientific.name'] <- "name"
      res <- stand_latlon(res)
      list(time = time, found = out$meta$found, data = res, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

#' @noRd
foo_ebird <- function(sources, query, limit, callopts, opts) {
  if (any(grepl("ebird", sources))) {
    opts <- limit_alias(opts, "ebird")
    time <- now()
    if (is.null(opts$method))
      opts$method <- "ebirdregion"
    if (!opts$method %in% c("ebirdregion", "ebirdgeo"))
      stop("ebird method must be one of ebirdregion or ebirdgeo")
    opts$species <- query
    if(!'max' %in% names(opts)) opts$max <- limit
    opts$config <- callopts
    if (opts$method == "ebirdregion") {
      if (is.null(opts$region)) opts$region <- "US"
      out <- do.call(ebirdregion, opts[!names(opts) %in% "method"])
    } else {
      out <- do.call(ebirdgeo, opts[!names(opts) %in% "method"])
    }
    if(!is.data.frame(out)){
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      out$prov <- rep("ebird", nrow(out))
      names(out)[names(out) == 'sciName'] <- "name"
      out <- stand_latlon(out)
      list(time = time, found = NULL, data = out, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

limit_alias <- function(x, sources){
  if(length(x) != 0){
    lim_name <- switch(sources, ecoengine="page_size", bison="count", inat="maxresults", ebird="max")
    if("limit" %in% names(x)){
      names(x)[ which(names(x) == "limit") ] <- lim_name
      x
    } else { x }
  } else { x }
}
