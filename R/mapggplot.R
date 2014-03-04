#' ggplot2 visualization of species occurences
#'
#' @import ggmap
#' @export
#' @param df Input \code{data.frame}
#' @param zoom zoom level for map. Adjust depending on how your data look.
#' @param point_color Default color of your points
#' @examples \dontrun{
#' ecoengine_data <- occ(query = 'Lynx rufus californicus', from = 'ecoengine')
#' mapggplot(ecoengine_data)
#' gbif_data <- occ(query = 'Accipiter striatus', from = 'gbif')
#' mapggplot(gbif_data)
#' bison_data <- occ(query = 'Accipiter striatus', from = 'bison', bisonopts=list(count=100))
#' mapggplot(bison_data)
#'}
mapggplot <- function(df, zoom = 5, point_color = "#86161f") {
    dt <- occ2df(df)
    latitude <- NA
    longitude <- NA
    # Remove rows with missing data
    dt <- dt[complete.cases(dt), ]
    min_lat <- min(dt$latitude, na.rm = TRUE)
    max_lat <- max(dt$latitude, na.rm = TRUE)
    min_long <- min(dt$longitude, na.rm = TRUE)
    max_long <- max(dt$longitude, na.rm = TRUE)
    species <- unique(dt$name)
    center_lat <- min_lat + (max_lat - min_lat)/2
    center_long <- min_long + (max_long - min_long)/2
    map_center <- c(lon = center_long, lat = center_lat)
    species_map <- get_map(location = map_center, zoom = zoom, maptype = "terrain")
    temp <- dt[, c("latitude", "longitude")]
    ggmap(species_map) + geom_point(data = temp, aes(x = longitude, y = latitude), 
        color = point_color, size = 3) + ggtitle(paste0("Distribution of ", species)) + 
        xlab("Longitude") + ylab("Latitude")
}
# [BUGS]: Can't figure out why it leaves out points even after I center the plot
# on the data. Setting zoom = 'auto' leaves out even more points. 
