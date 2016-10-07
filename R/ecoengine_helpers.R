ee_observations2 <- function(page = NULL, page_size = 1000, country = "United States",
  state_province = NULL, county = NULL, kingdom  = NULL, phylum = NULL, order  = NULL,
  clss = NULL, family = NULL, genus = NULL, scientific_name = NULL, kingdom__exact = NULL,
  phylum__exact = NULL, order__exact = NULL, clss__exact = NULL, family__exact = NULL,
  genus__exact = NULL, scientific_name__exact = NULL, remote_id = NULL, collection_code = NULL,
  source  = NULL, min_date = NULL, max_date = NULL, georeferenced = FALSE, bbox = NULL,
  exclude = NULL, extra = NULL, quiet = FALSE, progress = TRUE, foptions = list()) {

  # obs_url <- "http://ecoengine.berkeley.edu/api/observations/?format=json"
  obs_url <- paste0(eee_base_url(), "observations/?format=geojson")

  if (georeferenced) georeferenced = "True"
  extra <- ifelse(is.null(extra), "last_modified", paste0(extra,",last_modified"))

  args <- as.list(sc(c(country = country, kingdom = kingdom, phylum = phylum,
      order = order, clss = clss,family = family, genus  = genus,
      scientific_name = scientific_name, kingdom__exact = kingdom__exact,
      phylum__exact = phylum__exact, county = county, order__exact = order__exact,
      clss__exact = clss__exact ,family__exact = family__exact , genus__exact  = genus__exact,
      scientific_name__exact = scientific_name__exact, remote_id = remote_id,
      collection_code = collection_code, source = source, min_date = min_date, max_date = max_date,
      bbox = bbox, exclude = exclude, extra = extra, georeferenced = georeferenced, page_size = page_size)))
  if (is.null(page)) { page <- 1 }
  main_args <- args
  main_args$page <- as.character(page)
  data_sources <- GET(obs_url, query = args, foptions)
  stopifnot(data_sources$status_code < 400)
  warn_for_status(data_sources)
  obs_data <- content(data_sources, type = "application/json", encoding = "UTF-8")
  stopifnot(obs_data$count > 0)
  required_pages <- eee_paginator(page, obs_data$count, page_size = page_size)
  all_the_pages <- ceiling(obs_data$count/page_size)

  if (!quiet)  message(sprintf("Search contains %s observations (downloading %s of %s pages)",
                              obs_data$count, length(required_pages), all_the_pages))
  if (progress) pb <- txtProgressBar(min = 0, max = length(required_pages), style = 3)

  results <- list()
  for (i in required_pages) {
    args$page <- i
    data_sources <- GET(obs_url, query = args, foptions)
    obs_data <- content(data_sources, type = "application/json", encoding = "UTF-8")
    obs_results <- lapply(obs_data$features, function(z) {
      z$properties[vapply(z$properties, is.null, logical(1))] <- NULL
      ll <- z$geometry$coordinates
      if (!is.null(ll)) ll <- stats::setNames(ll, c('longitude', 'latitude'))
      c(ll, z$properties)
    })
    xx <- rbindlist(obs_results, use.names = TRUE, fill = TRUE)
    setDF(xx)
    results[[i]] <- xx
    #results[[i]] <- data.frame(rbindlist(obs_results, use.names = TRUE, fill = TRUE), stringsAsFactors = FALSE)
    if (progress) setTxtProgressBar(pb, i)
  }
  obs_data_all <- do.call(rbind, results)

  if(!is.null(obs_data_all$kingdom)) {  obs_data_all$kingdom <- basename(obs_data_all$kingdom) }
  if(!is.null(obs_data_all$phylum)) {  obs_data_all$phylum <- basename(obs_data_all$phylum) }
  if(!is.null(obs_data_all$class)) {  obs_data_all$class <- basename(obs_data_all$class) }
  if(!is.null(obs_data_all$order)) {  obs_data_all$order <- basename(obs_data_all$order) }
  if(!is.null(obs_data_all$family)) {  obs_data_all$family <- basename(obs_data_all$family) }
  if(!is.null(obs_data_all$genus)) {  obs_data_all$genus <- basename(obs_data_all$genus) }

  ss <- list(results = obs_data$count, call = main_args, type = "FeatureCollection", data = obs_data_all)
  if(progress) close(pb)
  ss
}

eee_search <- function(query = NULL, foptions = list()) {
  search_url <- paste0(eee_base_url(), "search/?format=json")
  result <- GET(search_url, query = as.list(sc(c(q = query))), foptions)
  es_results <- content(result, type = "application/json", encoding = "UTF-8")
  fields_compacted <- Filter(function(i) length(i) > 0, es_results$fields)
  df <- do.call(rbind, Map(function(a, b) {
    tt <- data.frame(type = b, do.call(rbind.data.frame, a), stringsAsFactors = FALSE)
    stats::setNames(tt, c("type", "field", "results", "search_url"))
  }, fields_compacted, names(fields_compacted)))
  row.names(df) <- NULL
  df
}

eee_base_url <- function() "https://ecoengine.berkeley.edu/api/"

eee_paginator <- function(page, total_obs, page_size = 1000) {
  all_pages <- ceiling(total_obs/page_size)
  if (total_obs < page_size) {
    req_pages <- 1
  }
  if (identical(page, "all")) {
    req_pages <- seq_along(1:all_pages)
  }
  if (length(page) == 1 & identical(class(page), "numeric")) {
    req_pages <- page
  }
  if (identical(class(page), "integer")) {
    if (max(page) > all_pages) {
      stop("Pages requested outside the range")
    }
    else {
      req_pages <- seq_along(page)
    }
  }
  req_pages
}
