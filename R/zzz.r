#' Capitalize the first letter of a character string.
#'
#' @param s A character string
#' @param strict Should the algorithm be strict about capitalizing. Defaults to FALSE.
#' @param onlyfirst Capitalize only first word, lowercase all others. Useful for
#' taxonomic names.
#' @examples  \dontrun{
#' capwords(c('using AIC for model selection'))
#' capwords(c('using AIC for model selection'), strict=TRUE)
#' }
#' @export
#' @keywords internal
spocc_capwords <- function(s, strict = FALSE, onlyfirst = FALSE) {
    cap <- function(s) paste(toupper(substring(s, 1, 1)), {
        s <- substring(s, 2)
        if (strict)
            tolower(s) else s
    }, sep = "", collapse = " ")
    if (!onlyfirst) {
        vapply(strsplit(s, split = " "), cap, "", USE.NAMES = !is.null(names(s)))
    } else {
        vapply(s, function(x) paste(toupper(substring(x, 1, 1)), tolower(substring(x,
            2)), sep = "", collapse = " "), "", USE.NAMES = F)
    }
}

#' Coerces data.frame columns to the specified classes
#'
#' @param d A data.frame.
#' @param colClasses A vector of column attributes, one of:
#'    numeric, factor, character, etc.
#' @examples  \dontrun{
#' dat <- data.frame(xvar = seq(1:10), yvar = rep(c('a','b'),5)) # make a data.frame
#' str(dat)
#' str(colClasses(dat, c('factor','factor')))
#' }
#' @export
#' @keywords internal
spocc_colClasses <- function(d, colClasses) {
    colClasses <- rep(colClasses, len = length(d))
    d[] <- lapply(seq_along(d), function(i) switch(colClasses[i], numeric = as.numeric(d[[i]]),
        character = as.character(d[[i]]), Date = as.Date(d[[i]], origin = "1970-01-01"),
        POSIXct = as.POSIXct(d[[i]], origin = "1970-01-01"), factor = as.factor(d[[i]]),
        as(d[[i]], colClasses[i])))
    d
}

#' Custom ggplot2 theme
#' @import grid
#' @export
#' @keywords internal
spocc_blanktheme <- function() {
    theme(axis.line = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(),
        axis.ticks = element_blank(), axis.title.x = element_blank(), axis.title.y = element_blank(),
        panel.background = element_blank(), panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), plot.background = element_blank(), plot.margin = rep(unit(0,
            "null"), 4))
}

#' Convert a bounding box to a Well Known Text polygon, and a WKT to a bounding box
#'
#' @importFrom rgeos readWKT
#' @importFrom sp bbox
#' @param minx Minimum x value, or the most western longitude
#' @param miny Minimum y value, or the most southern latitude
#' @param maxx Maximum x value, or the most eastern longitude
#' @param maxy Maximum y value, or the most northern latitude
#' @param bbox A vector of length 4, with the elements: minx, miny, maxx, maxy
#' @return bbox2wkt returns an object of class charactere, a Well Known Text string
#' of the form 'POLYGON((minx miny, maxx miny, maxx maxy, minx maxy, minx miny))'.
#'
#' wkt2bbox returns a numeric vector of length 4, like c(minx, miny, maxx, maxy).
#' @export
#' @examples \dontrun{
#' # Convert a bounding box to a WKT
#'
#' ## Pass in a vector of length 4 with all values
#' mm <- bbox2wkt(bbox=c(38.4,-125.0,40.9,-121.8))
#' plot(e)
#'
#' ## Or pass in each value separately
#' mm <- bbox2wkt(minx=38.4, miny=-125.0, maxx=40.9, maxy=-121.8)
#' plot(readWKT(mm))
#'
#' ========================================
#'
#' # Convert a WKT object to a bounding box
#' wkt <- "POLYGON((38.4 -125,40.9 -125,40.9 -121.8,38.4 -121.8,38.4 -125))"
#' wkt2bbox(wkt)
#' }

bbox2wkt <- function(minx=NA, miny=NA, maxx=NA, maxy=NA, bbox=NULL){
  if(is.null(bbox)) bbox <- c(minx, miny, maxx, maxy)

  stopifnot(length(bbox)==4) #check for 4 digits
  stopifnot(!any(is.na(bbox))) #check for NAs
  stopifnot(is.numeric(as.numeric(bbox))) #check for numeric-ness
  paste('POLYGON((',
        sprintf('%s %s',bbox[1],bbox[2]), ',', sprintf(' %s %s',bbox[3],bbox[2]), ',',
        sprintf(' %s %s',bbox[3],bbox[4]), ',', sprintf(' %s %s',bbox[1],bbox[4]), ',',
        sprintf(' %s %s',bbox[1],bbox[2]),
        '))', sep="")
}

#' @param wkt A Well Known Text object.
#' @export
#' @rdname bbox2wkt
wkt2bbox <- function(wkt=NULL){
  stopifnot(!is.null(wkt))
  tmp <- bbox(readWKT(wkt))
  as.vector(tmp)
}

sc <- function(l) Filter(Negate(is.null), l)

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

  if(!is.null(bounds)){
    if(length(bounds) != 4){stop("bounding box specifications must have 4 coordinates")}
    search <- paste(search,"&swlat=",bounds[1],"&swlng=",bounds[2],"&nelat=",bounds[3],"&nelng=",bounds[4],sep="")

  }

  base_url <- "http://www.inaturalist.org/"
  q_path <- "observations.csv"
  ping_path <- "observations.json"
  ping_query <- paste(search,"&per_page=1&page=1",sep="")
  ### Make the first ping to the server to get the number of results
  ### easier to pull down if you make the query in json, but easier to arrange results
  ### that come down in CSV format
  ping <-  GET(base_url, path = ping_path, query = ping_query)
  total_res <- as.numeric(ping$headers$`x-total-entries`)

  if(total_res == 0){
    stop("Your search returned zero results.  Either your species of interest has no records or you entered an invalid search")
  }

  page_query <- paste(search,"&per_page=200&page=1",sep="")
  data <-  GET(base_url, path = q_path, query = page_query)
  data <- spocc_inat_handle(data)
  data_out <- if(is.na(data)) NA else read.csv(textConnection(data), stringsAsFactors = FALSE)

  if(total_res < maxresults) maxresults <- total_res
  if(maxresults > 200){
    for(i in 2:ceiling(maxresults/200)){
      page_query <- paste(search,"&per_page=200&page=",i,sep="")
      data <-  GET(base_url,path = q_path, query = page_query)
      data <- spocc_inat_handle(data)
      data_out <- rbind(data_out, read.csv(textConnection(data), stringsAsFactors = FALSE))
    }
  }

  if(is.data.frame(data_out)){
    if(maxresults < dim(data_out)[1]){
      data_out <- data_out[1:maxresults,]
    }
  }

  if(meta){
    return(list(meta=list(found=total_res, returned=nrow(data_out)), data=data_out))
  } else { return(data_out) }
}

spocc_inat_handle <- function(x){
  res <- content(x, as = "text")
  if(!x$headers$`content-type` == 'text/csv; charset=utf-8' || x$status_code > 202 || nchar(res)==0 ){
    if(!x$headers$`content-type` == 'text/csv; charset=utf-8'){
      warning("Conent type incorrect, should be 'text/csv; charset=utf-8'")
      NA
    }
    if(x$status_code > 202){
      warning(sprintf("Error: HTTP Status %s", data$status_code))
      NA
    }
    if(nchar(res)==0){
      warning("No data found")
      NA
    }
  } else { res }
}

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}
