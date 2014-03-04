#' Create a spatial points dataframe from a spocc search.
#' 
#' @param occObj The resuslts of a spocc search called by occ()
#' @param coord_string A valid EPGS cooridate string from the sp package, the default is WSGS 84
#' @param just_coords Return data frame with specios names and provenance or just a spatial points object, which is the default.
#' 
#' @details This function will return either a spatial points dataframe or spatial points object. Conversion to spatial points objects allows spocc searches to interact with other spatial data sources. More coordinate system codes can be found at the EPGS registry: http://www.epsg-registry.org/
#' 
#' @import sp
#' @export
#' 
#' @examples \dontrun{
#' library(sp) # for the spplot function below
#' out <- occ(query = "Populus tremuloides", from = c("inat","gbif"))
#' out <- fixnames(out, "query")
#' sp_points <- occ_to_sp(out)
#' spplot(sp_points, "prov")
#' 
#' ### Or see how they line up on a map
#' library(maptools)
#' data(wrld_simpl)
#' plot(wrld_simpl[wrld_simpl$NAME == "United States", ],xlim=c(-70,-60))
#' out <- occ(query = "Accipiter striatus", from = c("inat","gbif"))
#' sp_points <- occ_to_sp(out,just_coords=TRUE)
#' points(sp_points,col=2)
#' }

occ_to_sp <- function(occObj, coord_string = "+proj=longlat +datum=WGS84", just_coords = FALSE){
  
  points <- occ2df(occObj)
  
  ### check valid coords
  index <- 1:dim(points)[1]
  index <- index[(points$longitude < 180) & (points$longitude > -180) & !is.na(points$longitude)]
  index <- index[(points$latitude[index] < 90) & (points$latitude[index] > -90) & !is.na(points$latitude[index])]
  
  spobj <- SpatialPoints(as.matrix(points[index,c('longitude','latitude')]),proj4string=CRS(coord_string))
  
  
  sp_df <- SpatialPointsDataFrame(spobj,data = data.frame(points[index,c('name',"prov")]))
  if(just_coords){return(spobj)
  } else {return(sp_df)}
}