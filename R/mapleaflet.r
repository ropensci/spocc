#' Make an interactive map to view in the browser
#' 
#' @import leafletR
#' @param data A data.frame, with any number of columns, but with at least the 
#'    following: name (the taxonomic name), latitude (in dec. deg.), longitude  
#'    (in dec. deg.)
#' @param popup If TRUE (default) popup tooltips are created for each point with
#'    metadta for that point.
#' @param map_provider Base map to use. One or a list of 'osm' (OpenStreetMap 
#'    standard map), 'tls' (Thunderforest Landscape), 'cm' (CloudMade), 'mqosm' 
#'    (MapQuest OSM) or 'mqsat' (MapQuest Open Aerial). Default is 'osm'. See 
#'    \code{\link[leafletR]{leaflet}} for more information.
#' @param zoom Map zoom, 0 being most zoomed out, and 18 most zoomed out. See 
#'    \code{\link[leafletR]{leaflet}} for more information.
#'    @param size Height and width (in pixels) of map as a length 2 vector. If missing, 
#'    a fullscreen (browser window) map is generated.
#' @param centerview Lat/long position to center map
#' @param dest Specify a path to save an html file of your map. You can open this 
#'    in your browser to view it. If left as NULL (the default) the map opens up in 
#'    your default browser, or if you have a newer version of RStudio open in RStudio
#'    Viewer pane. 
#' @param overwrite Default is \code{TRUE}. Set to \code{FALSE} to prevent overwriting local files
#' @param  incl.data Default is \code{TRUE}. Writes geoJSON data into the html file to get around security restrictions in browsers like Google Chrome. Set to \code{FALSE} to read from a separate local geoJSON file.
#' @param title Map title
#' @details NOTE that with some map_provider options you will have no map layer 
#'    show up at first. This may be because there is no map at that particular 
#'    zoom level. Just zoom in or out to see the map.
#' @export
#' @examples \dontrun{
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
#' dat <- occ(query = spp, from = 'gbif', gbifopts = list(georeferenced=TRUE))
#' data <- occ2df(dat)
#' mapleaflet(data = data, dest = ".")
#' 
#' # An example with more species, a different base map, and different color palette
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta','Puma concolor',
#' 'Ursus americanus','Gymnogyps californianus')
#' dat <- occ(query = spp, from = 'gbif', gbifopts = list(georeferenced = TRUE))
#' data <- occ2df(dat)
#' mapleaflet(data, map_provider = 'cm')
#' }
mapleaflet <- function(data, popup = TRUE, map_provider = "osm", zoom = 3, title = "map", 
    size, centerview = c(30, -73.9), dest = ".", overwrite = TRUE, incl.data = TRUE) {
    dest <- ifelse(is.null(dest), tempdir(), dest)
    dat <- toGeoJSON(data = data, dest = dest, lat.lon = c("latitude", "longitude"))
    map <- leaflet(dat, title = title, size = size, base.map = map_provider, center = centerview, 
        zoom = zoom, popup = popup, overwrite = overwrite, incl.data = incl.data)
    browseURL(map)
} 
