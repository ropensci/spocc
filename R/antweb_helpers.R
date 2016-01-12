aw_data <- function(genus = NULL, species = NULL, scientific_name = NULL, 
  georeferenced = NULL, min_elevation = NULL, max_elevation = NULL, type = NULL, 
  habitat = NULL, country = NULL, min_date = NULL, max_date = NULL, bbox = NULL, 
  limit = NULL, offset = NULL, quiet = FALSE, callopts = list()) {
  
  # Check for minimum arguments to run a query
  main_args <- sc(as.list(c(scientific_name, genus, country, type, habitat, bbox)))
  date_args <- sc(as.list(c(min_date, max_date)))
  elev_args <- sc(as.list(c(min_elevation, max_elevation)))
  arg_lengths <- c(length(main_args), length(date_args), length(elev_args))
  
  stopifnot(any(arg_lengths) > 0)
  decimal_latitude <- decimal_longitude <- NA
  if(!is.null(scientific_name)) {
    genus <- strsplit(scientific_name, " ")[[1]][1]
    species <- strsplit(scientific_name, " ")[[1]][2]
  }
  
  base_url <- "http://www.antweb.org/api/v2/"
  original_limit <- limit
  args <- sc(as.list(c(genus = genus, species = species, bbox = bbox, 
                       min_elevation = min_elevation, max_elevation = max_elevation, 
                       habitat = habitat, country = country, type = type, 
                       min_date = min_date, max_date = max_date, limit = 1, 
                       offset = offset, georeferenced = georeferenced)))
  results <- GET(base_url, query = args, callopts)
  warn_for_status(results)
  data <- jsonlite::fromJSON(content(results, "text"), FALSE)
  data <- sc(data) # Remove NULL
  
  if(data$count > 1000 & is.null(limit)) {
    args$limit <- 1000
    results <- GET(base_url, query = args)
    if(!quiet) message(sprintf("Query contains %s results. First 1000 retrieved. Use the offset argument to retrieve more \n", data$count))
  } else { 
    args$limit <- original_limit
    results <- GET(base_url, query = args)
  }
  
  data <- jsonlite::fromJSON(content(results, "text"), FALSE)
  data <- sc(data)
  
  if (identical(data$specimens$empty_set, "No records found.")) {
    NULL 
  } else {
    if (!quiet) message(sprintf("%s results available for query.", data$count))
    data_df <- lapply(data$specimens, function(x){ 
      x$images <- NULL	 	
      # In a future fix, I should coerce the image data back to a df and add it here.
      df <- data.frame(t(unlist(x)), stringsAsFactors=FALSE)
      df
    })
    final_df <- data.frame(rbindlist(data_df, use.names = TRUE, fill = TRUE))
    names(final_df)[grep("geojson.coord1", names(final_df))] <- "decimal_latitude"
    names(final_df)[grep("geojson.coord2", names(final_df))] <- "decimal_longitude"
    # There seem to be extra field when searching for just a genus
    final_df$decimalLatitude <- NULL
    final_df$decimalLongitude <- NULL
    final_df$minimumElevationInMeters <- as.numeric(final_df$minimumElevationInMeters)
    list(count = data$count, call = args, data = final_df)
  }
}	
