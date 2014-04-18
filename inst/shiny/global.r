rcharts_prep1 <- function(sppchar, occurrs, datasource){
  require(RColorBrewer)
  require(plyr)
  species2 <- strsplit(sppchar, ",")[[1]]
  
  if(datasource=="GBIF"){
    dat <- occ(query=species2, from='gbif', gbifopts=list(hasCoordinate=TRUE, limit=occurrs))
    dat <- occ2df(dat)
#     dat <- occtodfspp(dat, 'data')
    apply(dat, 1, as.list)
  } else if(datasource=="BISON"){
    dat <- occ(query=species2, from='bison', bisonopts=list(count=occurrs))
    dat <- occ2df(dat)
#     dat <- occtodfspp(dat, 'data')
    apply(dat, 1, as.list)
  } else
  {
    dat <- occ(query=species2, from='inat', inatopts=list(maxresults=occurrs))
    dat <- occ2df(dat)
#     dat <- occtodfspp(dat, 'data')
    dat <- dat[as.character(dat$name) %in% species2, ]
    apply(dat, 1, as.list)
  } 
}

get_colors <- function(vec, palette_name){
  num_colours <- length(unique(vec))
  brewer.pal(max(num_colours, 3), palette_name)
}

rcharts_prep2 <- function(out, palette_name, popup = FALSE){ 
  require(rgbif)
  
  # colors
  uniq_name_vec <- unique(vapply(out, function(x) x[["name"]], ""))
  
  # colors
  mycolors <- get_colors(uniq_name_vec, palette_name)
  if(length(mycolors) > length(uniq_name_vec))
    mycolors <- mycolors[1:length(uniq_name_vec)]
  mycolors_df <- data.frame(taxon=uniq_name_vec, color=mycolors)
  
  # Add fill color for points
  out_list2 <- lapply(out, function(x){ 
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
  toGeoJSON(out_list2, lat = 'latitude', lon = 'longitude')
}

toGeoJSON <- function(list_, lat = 'latitude', lon = 'longitude'){
  x = lapply(list_, function(l){
    if (is.null(l[[lat]]) || is.null(l[[lon]])){
      return(NULL)
    }
    list(
      type = 'Feature',
      geometry = list(
        type = 'Point',
        coordinates = as.numeric(c(l[[lon]], l[[lat]]))
      ),
      properties = l[!(names(l) %in% c(lat, lon))]
    )
  })
  setNames(Filter(function(x) !is.null(x), x), NULL)
}

gbifmap2 <- function(input_data, map_provider = 'MapQuestOpen.OSM', map_zoom = 2, height = 600, width = 870){
  require(rCharts)
  L1 <- Leaflet$new()
  L1$tileLayer(provider = map_provider, urlTemplate = NULL)
  L1$set(height = height, width = width)
  L1$setView(c(30, -73.90), map_zoom)
  L1$geoJson(input_data, 
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
  L1$fullScreen(TRUE)
  return(L1)
}    

get_palette <- function(userselect){
  colours_ <- data.frame(
    actual=c("Blues","BuGn","BuPu","GnBu","Greens","Greys","Oranges","OrRd","PuBu",
             "PuBuGn","PuRd","Purples","RdPu","Reds","YlGn","YlGnBu","YlOrBr","YlOrRd",
             "BrBG","PiYG","PRGn","PuOr","RdBu","RdGy","RdYlBu","RdYlGn","Spectral"),
    choices=c("Blues","BlueGreen","BluePurple","GreenBlue","Greens","Greys","Oranges","OrangeRed",
              "PurpleBlue","PurpleBlueGreen","PurpleRed","Purples",
              "RedPurple","Reds","YellowGreen","YellowGreenBlue","YellowOrangeBrown","YellowOrangeRed",
              "BrownToGreen","PinkToGreen","PurpleToGreen","PurpleToOrange","RedToBlue","RedToGrey",
              "RedYellowBlue","RedYellowGreen","Spectral"))
  as.character(colours_[colours_$choices %in% userselect, "actual"])
}