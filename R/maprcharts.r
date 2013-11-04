#' Make an interactive map to view in the browser
#' 
#' @import RColorBrewer
#' @param data A data.frame, with any number of columns, but with at least the 
#'    following: name (the taxonomic name), latitude (in dec. deg.), longitude  
#'    (in dec. deg.)
#' @param popup If TRUE (default) popup tooltips are created for each point with
#'    metadta for that point.
#' @param map_provider Base map to use. See \code{basemaps}
#' @param map_zoom Map zoom, 1 being most zoomed in
#' @param height Height of map
#' @param width Width of map
#' @param palette_color Color brewer color palette. See \code{palettes}
#' @param centerview Lat/long position to center map
#' @param fullscreen If TRUE, full screen option avail, if not, not avail.
#' @export
#' @examples \dontrun{
#' library(rCharts)
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
#' dat <- lapply(spp, function(x) occ(query=x, from='gbif'))
#' dat <- do.call(rbind, lapply(dat, function(x) x@data$gbif))
#' maprcharts(data=dat)
#' 
#' # An example with more species, a different base map, and different color palette
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta','Puma concolor','Ursus americanus','Gymnogyps californianus')
#' dat <- lapply(spp, function(x) occ(query=x, from='gbif', gbifopts=list(georeferenced=TRUE)))
#' dat <- do.call(rbind, lapply(dat, function(x) x@data$gbif))
#' maprcharts(dat, map_provider="Acetate.terrain", palette_color="OrangeRed")
#' }
maprcharts <- function(data, popup = TRUE, map_provider = 'MapQuestOpen.OSM', 
  map_zoom = 2, height = 600, width = 870, palette_color = "Blues", 
  centerview = c(30, -73.90), fullscreen = TRUE)
{
  spplist <- as.character(unique(data$name))
  datl <- apply(data, 1, as.list)
  
  # colors
  mycolors <- get_colors(spplist, palette_name=get_palette(palette_color))
  if(length(mycolors) > length(spplist))
    mycolors <- mycolors[1:length(spplist)]
  mycolors_df <- data.frame(taxon=spplist, color=mycolors)
  
  # Add fill color for points
  out_list2 <- lapply(datl, function(x){ 
    x$fillColor = mycolors_df[as.character(mycolors_df$taxon) %in% x$name, "color"]
    x
  })
  
  # popup
  if(popup)
    out_list2 <- lapply(out_list2, function(l){
      l$popup = paste(paste("<b>", names(l), ": </b>", l, "<br/>"), collapse = '\n')
      return(l)
    })
  out_list2 <- Filter(function(x) !is.na(x$latitude), out_list2)
  geojson <- spocc_toGeoJSON(out_list2, lat = 'latitude', lon = 'longitude')
  
  L1 <- Leaflet$new()
  L1$tileLayer(provider = map_provider, urlTemplate = NULL)
  L1$set(height = height, width = width)
  L1$setView(centerview, map_zoom)
  L1$geoJson(geojson, 
             onEachFeature = '#! function(feature, layer){
             layer.bindPopup(feature.properties.popup || feature.properties.taxonName)
            } !#',
             pointToLayer =  "#! function(feature, latlng){
             return L.circleMarker(latlng, {
             radius: 4,
             fillColor: feature.properties.fillColor || 'red',    
             color: '#000',
             weight: 1,
             fillOpacity: 0.8
             })
             } !#"
  )
  L1$fullScreen(fullscreen)
  if(!length(spplist) < 2)
    L1$legend(
      position = 'bottomright',
      colors = get_colors(spplist, get_palette(palette_color)),
      labels = spplist
    )
  L1
}