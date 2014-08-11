# Plugins for the occ function for each data source
#' @noRd
foo_gbif <- function(sources, query, limit, geometry, callopts, opts) {
  if (any(grepl("gbif", sources))) {

    if(!is.null(query)){
      if(class(query) %in% c("ids","gbifid")){
        if(class(query) %in% "ids"){
          opts$taxonKey <- query$gbif
        } else {
          opts$taxonKey <- query
        }
        UsageKey <- opts$taxonKey
      } else
      {
        UsageKey <- name_backbone(name = query)$usageKey
        if(is.null(UsageKey)){
          warning(sprintf("No GBIF key found for %s", query))
        } else {
          opts$taxonKey <- UsageKey
        }
      }
    } else { UsageKey <- NULL }

    if(is.null(UsageKey) && is.null(geometry)){
      list(time = NULL, found = NULL, data = data.frame(NULL), opts=opts)
    } else{
      time <- now()
      opts$limit <- limit
      if(!is.null(geometry)){
        opts$geometry <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" "))){
          geometry } else { bbox2wkt(bbox=geometry) }
      }
      opts$callopts <- callopts
      #       opts$return <- "data"
      out <- do.call(occ_search, opts)
      if(class(out) == "character") {
        list(time = time, found = NULL, data = data.frame(NULL), opts = opts)
      } else {
        if(class(out$data) == "character"){
          list(time = time, found = NULL, data = data.frame(NULL), opts = opts)
        } else {
          dat <- out$data
          dat$prov <- rep("gbif", nrow(dat))
          dat$prov <- rep("gbif", nrow(dat))
          dat$name <- as.character(dat$name)
          list(time = time, found = out$meta$count, data = dat, opts = opts)
        }
      }
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

#' @noRd
foo_ecoengine <- function(sources, query, limit, geometry, callopts, opts) {
  if (any(grepl("ecoengine", sources))) {
    time <- now()
    opts$scientific_name <- query
    opts$georeferenced <- TRUE
    opts$page_size <- limit
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

    opts$limit <- limit
    opts$georeferenced <- TRUE
    out <- do.call(aw_data, opts)

    if(is.null(out)){
      warning(sprintf("No records found in AntWeb for %s", query))
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      res <- out$data
      res$prov <- rep("antweb", nrow(res))
      res$name <- query
      list(time = time, found = out$count, data = res, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}


#' @noRd
foo_bison <- function(sources, query, limit, geometry, callopts, opts) {
  if(any(grepl("bison", sources))) {
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
    opts$count <- limit
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
      list(time = time, found = out$summary$total, data = dat, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}


#' @noRd
foo_inat <- function(sources, query, limit, geometry, callopts, opts) {
  if (any(grepl("inat", sources))) {
    time <- now()
    opts$query <- query
    opts$maxresults <- limit
    opts$meta <- TRUE
    if(!is.null(geometry)){
      opts$bounds <- if(grepl('POLYGON', paste(as.character(geometry), collapse=" ")))
      {
        # flip lat and long spots in the bounds vector for inat
        temp <- wkt2bbox(geometry)
        c(temp[2], temp[1], temp[4], temp[3])
      } else { c(geometry[2], geometry[1], geometry[4], geometry[3]) }
    }
    out <- do.call(get_inat_obs, opts)
    if(!is.data.frame(out$data)){
      list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
    } else{
      res <- out$data
      res$prov <- rep("inat", nrow(res))
      names(res)[names(res) == 'Scientific.name'] <- "name"
      list(time = time, found = out$meta$found, data = res, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}

#' @noRd
foo_ebird <- function(sources, query, limit, callopts, opts) {
  if (any(grepl("ebird", sources))) {
    time <- now()
    if (is.null(opts$method))
      opts$method <- "ebirdregion"
    if (!opts$method %in% c("ebirdregion", "ebirdgeo"))
      stop("ebird method must be one of ebirdregion or ebirdgeo")
    opts$species <- query
    opts$max <- limit
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
      list(time = time, found = NULL, data = out, opts = opts)
    }
  } else {
    list(time = NULL, found = NULL, data = data.frame(NULL), opts = opts)
  }
}
