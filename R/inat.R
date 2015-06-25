spocc_inat_obs <- function(query=NULL, taxon = NULL, quality=NULL, geo=NULL, year=NULL,
                           month=NULL, day=NULL, bounds=NULL, maxresults=100, meta=FALSE) {

  ## Parsing and error-handling of input strings
  search <- ""
  if(!is.null(query)){
    search <- paste(search,"&q=",gsub(" ","+",query),sep="")
  }

  if(!is.null(quality)){
    if(!sum(grepl(quality,c("casual","research")))){
      stop("Please enter a valid quality flag,'casual' or 'research'.")
    }

    search <- paste(search,"&quality_grade=",quality,sep="")
  }

  if(!is.null(taxon)){
    search <-  paste(search,"&taxon_name=",gsub(" ","+",taxon),sep="")
  }

  if(!is.null(geo) && geo){
    search <- paste(search,"&has[]=geo",sep="")
  }

  if(!is.null(year)){
    if(length(year) > 1){
      stop("you can only filter results by one year, please enter only one value for year")
    }
    search <- paste(search,"&year=",year,sep="")
  }

  if(!is.null(month)){
    month <- as.numeric(month)
    if(is.na(month)){
      stop("please enter a month as a number between 1 and 12, not as a word ")
    }
    if(length(month) > 1){
      stop("you can only filter results by one month, please enter only one value for month")
    }
    if(month < 1 || month > 12){ stop("Please enter a valid month between 1 and 12")}
    search <- paste(search,"&month=",month,sep="")
  }

  if(!is.null(day)){
    day <- as.numeric(day)
    if(is.na(day)){
      stop("please enter a day as a number between 1 and 31, not as a word ")
    }
    if(length(day) > 1){
      stop("you can only filter results by one day, please enter only one value for day")
    }
    if(day < 1 || day > 31){ stop("Please enter a valid day between 1 and 31")}

    search <- paste(search,"&day=",day,sep="")
  }

  if (!is.null(bounds)) {
    if (length(bounds) != 4) {
      stop("bounding box specifications must have 4 coordinates")
    }
    search <- paste(search, "&swlat=", bounds[1], "&swlng=", 
                    bounds[2], "&nelat=", bounds[3], "&nelng=", bounds[4], sep = "")

  }

  q_path <- "observations.csv"
  ping_path <- "observations.json"
  ping_query <- paste(search, "&per_page=1&page=1", sep = "")
  ping <-  GET(inat_base_url(), path = ping_path, query = ping_query)
  total_res <- as.numeric(ping$headers$`x-total-entries`)

  if (total_res == 0) {
    stop("Your search returned zero results.  Either your species of interest has no records or you entered an invalid search")
  }

  page_query <- paste(search, "&per_page=200&page=1", sep = "")
  data <-  GET(inat_base_url(), path = q_path, query = page_query)
  data <- spocc_inat_handle(data)
  data_out <- if (is.na(data)) NA else read.csv(textConnection(data), stringsAsFactors = FALSE)

  if (total_res < maxresults) maxresults <- total_res
  if (maxresults > 200) {
    for (i in 2:ceiling(maxresults/200)) {
      page_query <- paste(search, "&per_page=200&page=", i, sep = "")
      data <-  GET(inat_base_url(), path = q_path, query = page_query)
      data <- spocc_inat_handle(data)
      data_out <- rbind(data_out, read.csv(textConnection(data), stringsAsFactors = FALSE))
    }
  }

  if (is.data.frame(data_out)) {
    if (maxresults < dim(data_out)[1]) {
      data_out <- data_out[1:maxresults,]
    }
  }

  if (meta) {
    return(list(meta = list(found = total_res, returned = nrow(data_out)), data = data_out))
  } else { 
    return(data_out) 
  }
}

spocc_inat_handle <- function(x){
  res <- content(x, as = "text")
  if (!x$headers$`content-type` == 'text/csv; charset=utf-8' || x$status_code > 202 || nchar(res) == 0 ) {
    if (!x$headers$`content-type` == 'text/csv; charset=utf-8') {
      warning("Conent type incorrect, should be 'text/csv; charset=utf-8'")
      NA
    }
    if (x$status_code > 202) {
      warning(sprintf("Error: HTTP Status %s", data$status_code))
      NA
    }
    if (nchar(res) == 0) {
      warning("No data found")
      NA
    }
  } else { 
    res 
  }
}

spocc_get_inat_obs_id <- function(id, ...) {
  q_path <- paste("observations/", as.character(id), ".json", sep = "")
  res <- GET(inat_base_url(), path = q_path, ...)
  stop_for_status(res)
  tt <- content(res, as = "text")
  jsonlite::fromJSON(tt)
}

inat_base_url <- function() "http://www.inaturalist.org/"
