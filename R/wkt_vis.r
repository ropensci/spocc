#' Visualize well-known text area's on a map.
#' 
#' This can be helpful in visualizing the area in which you are searching for 
#' occurrences with the \code{occ} function. 
#'
#' 
#' @import ggmap ggplot2 assertthat rgeos
#' @param x Input well-known text area (character)
#' @param zoom Zoom level, defaults to 6 (numeric)
#' @param maptype Map type, default is terrain (character)
#' @export
#' @examples \dontrun{
#' poly <- 'POLYGON((-111.06 38.84, -110.80 39.37, -110.20 39.17, -110.20 38.90, 
#'      -110.63 38.67, -111.06 38.84))'
#' wkt_vis(poly)
#' 
#' poly2 <- 'POLYGON((-125 38.4,-125 40.9,-121.8 40.9,-121.8 38.4,-125 38.4))'
#' wkt_vis(poly2)
#' }

wkt_vis <- function(x, zoom = 6, maptype = "terrain")
{
  long = lat = group = NULL
  assert_that(!is.null(x))
  assert_that(is.character(x))
  
  poly_wkt <- readWKT(x)
  df <- fortify(poly_wkt)
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