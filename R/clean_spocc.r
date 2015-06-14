#' Clean spocc data
#'
#' @export
#' @param input An object of class occdat
#' @details We'll continue to add options for cleaning data, but for now, this function:
#'
#' \itemize{
#'  \item Removes impossible values of latitude and longitude
#'  \item Removes any NA values of latitude and longitude
#'  \item Removes points at 0,0 - these points are likely wrong
#' }
#' @return Returns an object of class occdat+occlean. See attributes of the return object for
#' details on cleaning results.
#' @examples \dontrun{
#' res <- occ(query = c('Ursus','Accipiter','Rubus'), from = 'bison', limit=10)
#' class(res)
#' res_cleaned <- clean_spocc(input=res)
#' class(res_cleaned) # now with classes occdat and occclean
#' }

clean_spocc <- function(input) {
  
  stopifnot(is(input, "occdat") | is(input, "data.frame"))
  
  clean <- function(x){
    if (all(sapply(x$data, nrow) < 1)) {
      x
    } else {
      clean_eachsp <- function(dat, what){
        #         dat <- replacelatlongcols(y, what)
        
        # Make lat/long data numeric
        dat$latitude <- as.numeric(as.character(dat$latitude))
        dat$longitude <- as.numeric(as.character(dat$longitude))
        
        # Remove points that are not physically possible
        notcomplete <- dat[!complete.cases(dat$latitude, dat$longitude), ]
        dat <- dat[complete.cases(dat$latitude, dat$longitude), ]
        notpossible <- dat[!abs(dat$latitude) <= 90 | !abs(dat$longitude) <= 180, ]
        dat <- dat[abs(dat$latitude) <= 90, ]
        dat <- dat[abs(dat$longitude) <= 180, ]
        
        # Remove points at lat 0 & long 0, these are very likely wrong
        dat <- dat[ !dat$latitude == 0 & !dat$longitude == 0, ]
        
        list(nc = notcomplete, np = notpossible, d = dat)
      }
      
      dat_eachsp <- lapply(x$data, clean_eachsp, what = x$meta$source)
      
      nc <- lapply(dat_eachsp, function(x) ifnone(x$nc))
      np <- lapply(dat_eachsp, function(x) ifnone(x$np))
      datdat <- lapply(dat_eachsp, "[[", "d")
      
      # assign to a class and assign attributes
      x$meta <- c(x$meta, removed_incomplete_cases = list(nc), removed_impossible = list(np))
      x$data <- datdat
      x
    }
  }
  
  output <- lapply(input, clean)
  class(output) <- c("occdat","occclean")
  return( output )
}

ifnone <- function(x) {
  if (nrow(x) == 0) { 
    NA 
  } else { 
    x
  }
}
