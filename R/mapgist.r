#' Make an interactive map to view in the browser as a Github gist
#' 
#' @param data A data.frame, with any number of columns, but with at least the 
#'    following: name (the taxonomic name), latitude (in dec. deg.), longitude  
#'    (in dec. deg.)
#' @param description Description for the Github gist, or leave to default (=no description)
#' @param file File name (without file extension) for your geojson file. Default is 'gistmap'.
#' @param dir Directory for storing file and reading it back in to create gist. 
#'    If none is given, this function gets your working directory and uses that.
#' @param browse If TRUE (default) the map opens in your default browser.
#' @param ... Further arguments passed on to \code{spocc_stylegeojson}
#' @description 
#' You will be asked ot enter you Github credentials (username, password) during
#' each session, but only once for each session. Alternatively, you could enter
#' your credentials into your .Rprofile file with the entries
#' 
#' \itemize{
#'  \item options(github.username = 'your_github_username')
#'  \item options(github.password = 'your_github_password')
#' }
#' 
#' then \code{mapgist} will simply read those options.
#' 
#' \code{mapgist} has modified code from the rCharts package by Ramnath Vaidyanathan 
#' @return Creates a gist on your Github account, and prints out where the geojson file was
#' written on your machinee, the url for the gist, and an embed script in the console.
#' 
#' @export
#' @examples \dontrun{
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
#' dat <- occ(spp, from='gbif', gbifopts=list(hasCoordinate=TRUE))
#' dat <- fixnames(dat)
#' df <- occ2df(dat)
#' 
#' # Define colors
#' mapgist(data=df, color=c('#976AAE','#6B944D','#BD5945'))
#' 
#' # Define colors and marker size
#' mapgist(data=df, color=c('#976AAE','#6B944D','#BD5945'), size=c('small','medium','large'))
#' 
#' # Define symbols
#' mapgist(data=df, symbol=c('park','zoo','garden'))
#' }

mapgist <- function(data, description = "", file = "gistmap", dir = NULL, browse = TRUE, 
                    ...) {
  if (is.null(dir)) 
    dir <- paste0(getwd(), "/")
  spplist <- as.character(unique(data$name))
  datgeojson <- spocc_stylegeojson(input = data, var = "name", ...)
  write.csv(datgeojson, paste(dir, file, ".csv", sep = ""))
  spocc_togeojson(input = paste(dir, file, ".csv", sep = ""), method = "web", destpath = dir, 
                  outfilename = file)
  tt <- spocc_gist(paste(dir, file, ".geojson", sep = ""), description = description)
  if (browse) 
    browseURL(tt)
} 
