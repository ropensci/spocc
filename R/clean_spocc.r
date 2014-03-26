#' Clean spocc data
#' 
#' @examples 
#' library(spocc)
#' res <- occ(query = 'Ursus', from = 'bison', limit=120)
#' x <- occ2df(res)
#' clean_spocc(x=res$bison$data[[1]])

clean_spocc <- function(x, country=NULL, habitat=NULL){  
  assert_that(is(x, "occdat") | is(x, "data.frame"))
  
  x <- x$gbif$data[[1]]
  
  # Make lat/long data numeric
  x$latitude <- as.numeric(as.character(x$latitude))
  x$longitude <- as.numeric(as.character(x$longitude))
  
  # Remove points that are not physically possible
  notcomplete <- x[!complete.cases(x$latitude, x$longitude), ]
  x <- x[complete.cases(x$latitude, x$longitude), ]
  notpossible <- x[!abs(x$latitude) <=90 | !abs(x$longitude) <=180, ]
  x <- x[abs(x$latitude) <=90, ]
  x <- x[abs(x$longitude) <=180, ]
  
  if(!is.null(habitat)){
#     clean_habitat()
    # get polygons for terrestrial vs. marine vs. freshwater
    # calculate whether polygon encompasses points
    # remove points not in polygon
  }
  
  if(!is.null(country)){
#     isocodes
    # get country polygon
    # calculate whether polygon encompasses points
    # remove points not in polygon
  }
  
  # assign to a class and assign attributes
  res <- list(meta=list(removed_incomplete_cases=ifnone(notcomplete),
                        removed_impossible = ifnone(notpossible)), data=x)
  class(res) <- c("occ_clean")
  return( res )
}

ifnone <- function(x) if(nrow(x)==0){ NA } else { x }

clean_country <- function(x){
#   library(rgdal); library(ggplot2)
  ogrListLayers("/Users/sacmac/Downloads/ne_110m_admin_0_countries/")
  country_shp <- readOGR("/Users/sacmac/Downloads/ne_110m_admin_0_countries/", layer = 'ne_110m_admin_0_countries')
  country_shp_usa <- country_shp[country_shp@data$name %in% 'United States',]
  
#   df <- fortify(country_shp_usa)
#   ggplot(df, aes(long, lat, group=group)) + 
#     geom_polygon()
  
  toproj <- na.omit(x)
  coordinates(toproj) <- ~longitude+latitude
  proj4string(toproj) <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
  
  ss <- over(toproj, country_shp)
  x[!apply(ss, 1, function(b) is.na(b['scalerank'])), ]
}

clean_habitat <- function(x){
  #     library(maptools)
  #     res <- map_data("world")
  
  #     library(rgdal)
  # #     ogrListLayers("/Users/sacmac/Downloads/ne_110m_land")
  # #     land <- readOGR("/Users/sacmac/Downloads/ne_110m_land/", layer = 'ne_110m_land')
  #     land <- readOGR("/Users/sacmac/Downloads/ne_10m_land/", layer = 'ne_10m_land')
  # 
  #     df <- fortify(land)
  #     ggplot(df, aes(long, lat, group=group)) + 
  #       geom_polygon()
  # 
  #     x <- na.omit(x)
  #     coordinates(x) <- ~longitude+latitude
  #     proj4string(x) <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
  # 
  #     over(x, land)
}