#' Get palette actual name from longer names
#' @param list_ A list
#' @param lat Latitude name
#' @param lon Longitude name
#' @export
#' @keywords internal
spocc_rcharts_togeojson <- function(list_, lat = "latitude", lon = "longitude") {
    x <- lapply(list_, function(l) {
        if (is.null(l[[lat]]) || is.null(l[[lon]])) {
            return(NULL)
        }
        list(type = "Feature", geometry = list(type = "Point", coordinates = as.numeric(c(l[[lon]], 
            l[[lat]]))), properties = l[!(names(l) %in% c(lat, lon))])
    })
    setNames(Filter(function(x) !is.null(x), x), NULL)
}
#' Get colors from a vector of input taxonomic names, and palette
#' @param vec Vector of strings
#' @param palette_name Palette name
#' @importFrom RColorBrewer brewer.pal
#' @export
#' @keywords internal
get_colors <- function(vec, palette_name) {
    num_colours <- length(unique(vec))
    brewer.pal(max(num_colours, 3), palette_name)
}
#' Get palette actual name from longer names
#' @param userselect User input
#' @export
get_palette <- function(userselect) {
    colours_ <- data.frame(actual = c("Blues", "BuGn", "BuPu", "GnBu", "Greens", 
        "Greys", "Oranges", "OrRd", "PuBu", "PuBuGn", "PuRd", "Purples", "RdPu", 
        "Reds", "YlGn", "YlGnBu", "YlOrBr", "YlOrRd", "BrBG", "PiYG", "PRGn", "PuOr", 
        "RdBu", "RdGy", "RdYlBu", "RdYlGn", "Spectral"), choices = c("Blues", "BlueGreen", 
        "BluePurple", "GreenBlue", "Greens", "Greys", "Oranges", "OrangeRed", "PurpleBlue", 
        "PurpleBlueGreen", "PurpleRed", "Purples", "RedPurple", "Reds", "YellowGreen", 
        "YellowGreenBlue", "YellowOrangeBrown", "YellowOrangeRed", "BrownToGreen", 
        "PinkToGreen", "PurpleToGreen", "PurpleToOrange", "RedToBlue", "RedToGrey", 
        "RedYellowBlue", "RedYellowGreen", "Spectral"))
    as.character(colours_[colours_$choices %in% userselect, "actual"])
}
#' Palettes to use with maprcharts function
#' @export
palettes <- function() {
    c("Blues", "BlueGreen", "BluePurple", "GreenBlue", "Greens", "Greys", "Oranges", 
        "OrangeRed", "PurpleBlue", "PurpleBlueGreen", "PurpleRed", "Purples", "RedPurple", 
        "Reds", "YellowGreen", "YellowGreenBlue", "YellowOrangeBrown", "YellowOrangeRed", 
        "BrownToGreen", "PinkToGreen", "PurpleToGreen", "PurpleToOrange", "RedToBlue", 
        "RedToGrey", "RedYellowBlue", "RedYellowGreen", "Spectral")
}
#' Base maps to use with maprcharts function
#' @export
basemaps <- function() {
    c("OpenStreetMap.Mapnik", "OpenStreetMap.BlackAndWhite", "OpenStreetMap.DE", 
        "OpenCycleMap", "Thunderforest.OpenCycleMap", "Thunderforest.Transport", 
        "Thunderforest.Landscape", "MapQuestOpen.OSM", "MapQuestOpen.Aerial", "Stamen.Toner", 
        "Stamen.TonerBackground", "Stamen.TonerHybrid", "Stamen.TonerLines", "Stamen.TonerLabels", 
        "Stamen.TonerLite", "Stamen.Terrain", "Stamen.Watercolor", "Esri.WorldStreetMap", 
        "Esri.DeLorme", "Esri.WorldTopoMap", "Esri.WorldImagery", "Esri.WorldTerrain", 
        "Esri.WorldShadedRelief", "Esri.WorldPhysical", "Esri.OceanBasemap", "Esri.NatGeoWorldMap", 
        "Esri.WorldGrayCanvas", "Acetate.all", "Acetate.basemap", "Acetate.terrain", 
        "Acetate.foreground", "Acetate.roads", "Acetate.labels", "Acetate.hillshading")
} 
