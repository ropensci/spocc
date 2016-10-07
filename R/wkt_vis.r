#' Visualize well-known text area's on a map.
#'
#' This can be helpful in visualizing the area in which you are searching for
#' occurrences with the \code{\link{occ}} function.
#'
#' @export
#' @importFrom whisker whisker.render
#'
#' @param x Input well-known text area (character)
#' @param zoom Zoom level, defaults to 6 (numeric)
#' @param maptype Map type, default is terrain (character)
#' @param browse Open in browser or not. If not, gives back 
#' path to html file. Default: \code{TRUE} (logical)
#'
#' @details Uses Mapbox's map layers, openes in your default browser
#'
#' @examples \dontrun{
#' poly <- 'POLYGON((-111.06 38.84, -110.80 39.37, -110.20 39.17, -110.20 38.90,
#'      -110.63 38.67, -111.06 38.84))'
#' wkt_vis(poly)
#'
#' poly2 <- 'POLYGON((-125 38.4,-125 40.9,-121.8 40.9,-121.8 38.4,-125 38.4))'
#' wkt_vis(poly2)
#' 
#' # Multiple polygons
#' x <- "POLYGON((-125 38.4, -121.8 38.4, -121.8 40.9, -125 40.9, -125 38.4), 
#' (-115 22.4, -111.8 22.4, -111.8 30.9, -115 30.9, -115 22.4))"
#' wkt_vis(x)
#' 
#' # don't open in browser
#' poly2 <- 'POLYGON((-125 38.4,-125 40.9,-121.8 40.9,-121.8 38.4,-125 38.4))'
#' wkt_vis(poly2, browse = FALSE)
#' }

wkt_vis <- function(x, zoom = 6, maptype = "terrain", browse = TRUE) {
  long = lat = group = NULL
  stopifnot(!is.null(x))
  stopifnot(is.character(x))

  out <- wkt_read(gsub("\n|\n\\s+", "", strtrim(x)))
  
  if (inherits(out$coordinates[,,1], "matrix")) {
    longs <- data.frame(out$coordinates[,,1])
    lats <- data.frame(out$coordinates[,,2])
  } else {
    longs <- t(data.frame(out$coordinates[,,1]))
    lats <- t(data.frame(out$coordinates[,,2]) )
  }
  tocentroid <- list()
  dfs <- list()
  for (i in 1:NROW(longs)) {
    tocentroid[[i]] <- tmp <- data.frame(long = as.numeric(longs[i,]), lat = as.numeric(lats[i,]))
    dfs[[i]] <- apply(tmp, 1, function(x) as.list(x[c('long','lat')]))
  }
  centroid <- get_centroid(do.call("rbind", tocentroid))
  
  whiskout <- list()
  for (i in seq_along(dfs)) {
    dats <- dfs[[i]]
    whiskout[[i]] <- whisker.render(features)
  }
  rend <- paste0(map_header, paste(whiskout, sep = "", collapse = ","), map_end)
  
  foot <- sprintf(footer, centroid[2], centroid[1], zoom)
  res <- paste(rend, foot)
  tmpfile <- tempfile(pattern = 'spocc', fileext = ".html")
  write(res, file = tmpfile)
  if (browse) browseURL(tmpfile) else tmpfile
}

get_centroid <- function(x) {
  x <- unname(as.matrix(x))
  geojson <- jsonlite::toJSON(list(type = "Polygon", coordinates =  list(x)), auto_unbox = TRUE)
  cent$eval(sprintf("var out = centroid(%s);", geojson))
  cent$get("out.geometry.coordinates")
}

map_header <- '
<!DOCTYPE html>
<html>
<head>
<meta charset=utf-8 />
<title>spocc WKT Viewer</title>
<meta name="viewport" content="initial-scale=1,maximum-scale=1,user-scalable=no" />
<script src="https://api.tiles.mapbox.com/mapbox.js/v2.2.2/mapbox.js"></script>
<link href="https://api.tiles.mapbox.com/mapbox.js/v2.2.2/mapbox.css" rel="stylesheet" />
<style>
  body { margin:0; padding:0; }
  #map { position:absolute; top:0; bottom:0; width:100%; }
</style>
</head>
<body>

<div id="map"></div>

<script>
var geojson = [{
  "type": "FeatureCollection",
  "features": [ 
'

map_end <- ']
}];'

features <- '
    {
      "type": "Feature",
      "geometry": {
          "type": "Polygon",
          "coordinates": [
          [
              {{#dats}}
              [ {{long}}, {{lat}} ],
              {{/dats}}
          ]
      ]
      },
      "properties": {
          "title": "Polygon"
      }
    }
'



footer <- '
L.mapbox.accessToken = "pk.eyJ1IjoicmVjb2xvZ3kiLCJhIjoiZWlta1B0WSJ9.u4w33vy6kkbvmPyGnObw7A"
L.mapbox.map("map", "mapbox.streets")
  .setView([ %s , %s ], %s)
  .featureLayer.setGeoJSON(geojson);
</script>

  </body>
  </html>
'
