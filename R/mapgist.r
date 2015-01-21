#' Make an interactive map to view in the browser as a Github gist
#' 
#' @export
#' @importFrom gistr gist_create
#' 
#' @param data A data.frame, with any number of columns, but with at least the 
#'    following: name (the taxonomic name), latitude (in dec. deg.), longitude  
#'    (in dec. deg.)
#' @param description Description for the Github gist, or leave to default (=no description)
#' @param file File name (without file extension) for your geojson file. Default is 'gistmap'.
#' @param dir Directory for storing file and reading it back in to create gist. 
#'    If none is given, this function gets your working directory and uses that.
#' @param public (logical) Whether gist is public (default: TRUE)
#' @param browse If TRUE (default) the map opens in your default browser.
#' @param ... Further arguments passed on to \code{spocc_stylegeojson}
#' 
#' @details See \code{\link[gistr]{gist_auth}} for help on authentication
#' 
#' @examples \dontrun{
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
#' dat <- occ(spp, from=c('gbif','ecoengine'), limit=30, gbifopts=list(hasCoordinate=TRUE))
#' dat <- fixnames(dat, "query")
#' 
#' # Define colors
#' mapgist(data=dat, color=c('#976AAE','#6B944D','#BD5945'))
#' mapgist(data=dat$gbif, color=c('#976AAE','#6B944D','#BD5945'))
#' mapgist(data=dat$ecoengine, color=c('#976AAE','#6B944D','#BD5945'))
#' 
#' # Define colors and marker size
#' mapgist(data=dat, color=c('#976AAE','#6B944D','#BD5945'), size=c('small','medium','large'))
#' 
#' # Define symbols
#' mapgist(data=dat, symbol=c('park','zoo','garden'))
#' }

mapgist <- function(data, description = "", file = "gistmap", dir = NULL, 
  public = TRUE, browse = TRUE, ...) {
  
  stopifnot(is(data, "occdatind") | is(data, "occdat"))
  data <- if(is(data, "occdatind")) {
    do.call(rbind, data$data) 
  } else {
    occ2df(data)
  }
  if (is.null(dir)) dir <- paste0(getwd(), "/")
  spplist <- as.character(unique(data$name))
  datgeojson <- spocc_stylegeojson(input = data, var = "name", ...)
  write.csv(datgeojson, paste(dir, file, ".csv", sep = ""))
  spocc_togeojson(input = paste(dir, file, ".csv", sep = ""), method = "web", destpath = dir, 
                  outfilename = file)
  gist_create(paste(dir, file, ".geojson", sep = ""), description = description, public = public, browse = browse)
} 
