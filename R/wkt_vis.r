#' Visualize well-known text area's on a map.
#' 
#' This can be helpful in visualizing the area in which you are searching for 
#' occurrences with the \code{occ} function. 
#'
#' 
#' @import ggmap ggplot2 assertthat rgeos whisker
#' @export
#' 
#' @param x Input well-known text area (character)
#' @param zoom Zoom level, defaults to 6 (numeric)
#' @param maptype Map type, default is terrain (character)
#' @param which One of interactive (default) or static. Interactive open Mapbox map in your 
#' browser, and static uses ggplot based ggmap package.
#' 
#' @examples \dontrun{
#' poly <- 'POLYGON((-111.06 38.84, -110.80 39.37, -110.20 39.17, -110.20 38.90, 
#'      -110.63 38.67, -111.06 38.84))'
#' wkt_vis(poly)
#' wkt_vis(poly, which='static')
#' 
#' poly2 <- 'POLYGON((-125 38.4,-125 40.9,-121.8 40.9,-121.8 38.4,-125 38.4))'
#' wkt_vis(poly2)
#' }

wkt_vis <- function(x, zoom = 6, maptype = "terrain", which='interactive')
{
  long = lat = group = NULL
  assert_that(!is.null(x))
  assert_that(is.character(x))
  
  poly_wkt <- readWKT(x)
  df <- fortify(poly_wkt)
  
  which <- match.arg(which, c('static','interactive'))
  if(which=='interactive'){
    pts <- apply(df, 1, function(x) as.list(x[c('long','lat')]))
    centroid <- poly_wkt@polygons[[1]]@labpt
    rend <- whisker.render(map)
    foot <- sprintf(footer, centroid[2], centroid[1])
    res <- paste(rend, foot)
    tmpfile <- tempfile(pattern = 'spocc', fileext = ".html")
    write(res, file = tmpfile)
    browseURL(tmpfile)
  } else {  
    center_lat <- min(df$lat) + (max(df$lat) - min(df$lat))/2
    center_long <- min(df$long) + (max(df$long) - min(df$long))/2
    map_center <- c(lon = center_long, lat = center_lat)
    species_map <- get_map(location = map_center, zoom = zoom, maptype = maptype)
    ggmap(species_map) + 
      geom_path(data = df, aes(x = long, y = lat, group = group, size = 2)) + 
      theme(legend.position = "") +
      xlab("Longitude") +
      ylab("Latitude")
  }
}

map <- '
<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8 />
<title>spocc WKT Viewer</title>
<meta name="viewport" content="initial-scale=1,maximum-scale=1,user-scalable=no" />
<script src="https://api.tiles.mapbox.com/mapbox.js/v1.6.4/mapbox.js"></script>
<link href="https://api.tiles.mapbox.com/mapbox.js/v1.6.4/mapbox.css" rel="stylesheet" />
<style>
  body { margin:0; padding:0; }
  #map { position:absolute; top:0; bottom:0; width:100%; }
</style>
</head>
<body>

<div id="map"></div>

<script>
var geojson = [
{
    "type": "Feature",
    "geometry": {
        "type": "Polygon",
        "coordinates": [ 
        [
            {{#pts}}
            [ {{long}}, {{lat}} ],
            {{/pts}}
        ]
    ]
    },
    "properties": {
        "title": "Polygon"
    }
}
];
'

footer <- '
L.mapbox.map("map", "examples.map-i86nkdio")
  .setView([ %s , %s ], 6)
  .featureLayer.setGeoJSON(geojson);
</script>

  </body>
  </html>
'