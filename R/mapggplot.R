#' ggplot2 visualization of species occurences
#'
#' @param df Input \code{data.frame}
#' @import ggmap
#' @export
#' @examples \dontrun{
#' z <- ecoengine::ee_observations(scientific_name__exact = "Lynx rufus californicus", page = "all", georeferenced = TRUE)
#' mapggplot(z$data)
#'}
mapggplot <- function(df) {
	min_lat <- min(df$latitude)
	max_lat <- max(df$latitude)
	min_long <- min(df$longitude)
	max_long <- max(df$longitude)
	species <- unique(df$scientific_name)

	center_lat <- min_lat + (max_lat - min_lat)/2
	center_long <- min_long + (max_long - min_long)/2
	 map_center <- c(lon = center_long, lat =  center_lat)
	 species_map <- get_map(location = map_center, zoom = 8, maptype = "terrain", color = "bw")
	 temp <- df[, c("latitude", "longitude")]
	ggmap(species_map, extent = "panel", maprange = FALSE, fullpage = TRUE) + 
	geom_point(data = temp, aes(x = longitude, y =latitude), color = "#F5C272", size = 2) + ggtitle(paste0("Distribution of ", species))
} 