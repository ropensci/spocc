library(leaflet)
library(ggplot2)
library(maps)

data(uspop2000)

shinyServer(function(input, output, session) {
  
  # Create the map; this is not the "real" map, but rather a proxy
  # object that lets us control the leaflet map on the page.
  map <- createLeafletMap(session, 'map')
  
#   observe({
#     map$addMarker
#   })

cities <- data.frame(Lat=30, Long=-120)

observe({
  map$clearShapes()

  map$addCircle(
    cities$Lat,
    cities$Long,
    list(
      weight=1.2,
      fill=TRUE,
      color='#4A9'
    )
  )
})
  
})