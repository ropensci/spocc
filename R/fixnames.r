#' Change names to be the same for each taxon.
#' 
#' That is, this function attempts to take all the names that are synonyms, for whatever
#' reason (e.g., some names have authorities on them), and collapses them to the same
#' string - making data easier to deal with for making maps, etc. 
#' 
#' @param obj An object of class occdat
#' @param how One of a few different methods: 
#' \itemize{
#'  \item shortest Takes the shortest name string that is likely to be the prettiest
#'  to display name, and replaces alll names with that one, better for maps, etc.
#'  \item query This method takes the names you orginally queried on (in the occdat
#'  object), and replaces names in the occurrence data with them.
#'  \item supplied If this method, supply a vector of names to replace the names with
#' }
#' @param namevec A vector of names to replace names in the occurrence data.frames
#' with. Only used if how="supplied"
#' @return An object of class occdat.
#' @export
#' @examples \dontrun{
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
#' dat <- occ(spp, from='gbif', gbifopts=list(hasCoordinate=TRUE))
#' fixnames(dat, how="shortest")$gbif
#' fixnames(dat, how="query")$gbif
#' fixnames(dat, how="supplied", namevec = c('abc', 'def', 'ghi'))$gbif
#' 
#' dat <- occ(spp, from='ecoengine')
#' ## doesn't changes things
#' fixnames(dat, how="shortest")$ecoengine$data$Danaus_plexippus
#' ## this is better
#' fixnames(dat, how="query")$ecoengine$data$Danaus_plexippus
#' ## or this
#' fixnames(dat, how="supplied", 
#'    namevec = c("Danaus","Accipiter","Pinus"))$ecoengine$data$Danaus_plexippus
#' }

fixnames <- function(obj, how="shortest", namevec = NULL){
  how <- match.arg(how, choices = c("shortest", "query", "supplied"))
#   if(getOption("stringsAsFactors")){warning("Strings are coming back as factors, this may interfere with fixing sames,consider setting 'options(stringsAsFactors = FALSE)'")}
  foo <- function(z){
    if(how=="shortest"){ # shortest
      z$data <- lapply(z$data, function(x, how){
        if(is.factor(x$name)){x$name <- as.character(x$name)}
        uniqnames <- unique(x$name)
        lengths <- vapply(uniqnames, function(y) length(strsplit(y, " ")[[1]]), numeric(1))
        shortest <- names(which.min(lengths))
        if(length(uniqnames) > 1){
          x$name <- rep(shortest, nrow(x))
        }
        x
      })
    } else if (how=="query"){ # query
      for(i in seq_along(z$data)){
        newname <- gsub("_", " ", names(z$data)[i])[[1]]
        z$data[[i]]$name <- rep(newname, nrow(z$data[[i]]))
      }
    } else { # supplied
      # check supplied vector same length as names vector in occdat object
      if(is.null(namevec)) stop("If how='supplied' you must provide a vector of names")
      if(!length(namevec) == length(z$data)) 
        stop("The supplied name vector must be the same length as the length of names you originally queried in occ function")
      
      for(i in seq_along(z$data)){
        z$data[[i]]$name <- rep(namevec[i], nrow(z$data[[i]]))
      }
    }
    return( z )
  } 
  res <- lapply(obj, foo)
  class(res) <- "occdat"
  return( res )
}