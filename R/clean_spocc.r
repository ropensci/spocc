#' Clean spocc data
#' 
#' @import assertthat rgdal sp
#' @export
#' @param input An object of class occdat
#' @param country (logical) Attempt to clean based on country
#' @param habitat (logical) Attempt to clean based on habitat
#' @examples \dontrun{
#' res <- occ(query = c('Ursus','Accipiter','Rubus'), from = 'bison', limit=120)
#' res_cleaned <- clean_spocc(input=res)
#' class(res_cleaned) # now with classes occdat and occclean
#' 
#' # Country cleaning
# res <- occ(query = 'Ursus americanus', from = 'gbif', limit=500, gbifopts = list(hasCoordinate=TRUE, fields='all'))
# res$gbif
# plot(res)
# 
# res <- occ(query = 'Ursus americanus', from = 'gbif', limit=1200, gbifopts = list(hasCoordinate=TRUE))
# plot(res)
# res2 <- clean_spocc(res, country = "Mexico")
# plot(res2)
#' }

clean_spocc <- function(input, country=NULL, country_which='include', habitat=NULL)
{
  assert_that(is(input, "occdat") | is(input, "data.frame"))
  
  clean <- function(x){
    if(all(sapply(x$data, nrow) < 1)){
      x
    } else {   
      clean_eachsp <- function(y, what){
        dat <- replacelatlongcols(y, what)
        
        # Make lat/long data numeric
        dat$latitude <- as.numeric(as.character(dat$latitude))
        dat$longitude <- as.numeric(as.character(dat$longitude))
        
        # Remove points that are not physically possible
        notcomplete <- dat[!complete.cases(dat$latitude, dat$longitude), ]
        dat <- dat[complete.cases(dat$latitude, dat$longitude), ]
        notpossible <- dat[!abs(dat$latitude) <= 90 | !abs(dat$longitude) <= 180, ]
        dat <- dat[abs(dat$latitude) <= 90, ]
        dat <- dat[abs(dat$longitude) <= 180, ]
        
        # Remove points at lat 0 & long 0, these are very likely wrong
        dat <- dat[ !dat$latitude == 0 & !dat$longitude == 0, ]
        
        if(!is.null(habitat)){
          #     clean_habitat()
          # get polygons for terrestrial vs. marine vs. freshwater
          # calculate whether polygon encompasses points
          # remove points not in polygon
        }
        
        if(!is.null(country)){
          dat <- clean_country(data=dat, country=country, which=country_which)
        }
        
        dat <- replacelatlongcols(dat, what, reverse = TRUE)
        
        list(nc = notcomplete, np = notpossible, d = dat)
      }
      
      dat_eachsp <- lapply(x$data, clean_eachsp, what=x$meta$source)
      
      nc <- lapply(dat_eachsp, function(x) ifnone(x$nc))
      np <- lapply(dat_eachsp, function(x) ifnone(x$np))
      datdat <- lapply(dat_eachsp, "[[", "d")
      
      # assign to a class and assign attributes
      x$meta <- c(x$meta, removed_incomplete_cases = list(nc), removed_impossible = list(np))
      x$data <- datdat
      x
    }
  }
  
  output <- lapply(input, clean)
  class(output) <- c("occdat","occclean")
  return( output )
}

ifnone <- function(x) if(nrow(x)==0){ NA } else { x }

replacelatlongcols <- function(w, z, reverse=FALSE){
  cols <- switch(z,
                 gbif = c('decimalLatitude','decimalLongitude'),
                 bison = c('decimalLongitude','decimalLatitude'), 
                 inat = c('Longitude','Latitude'), 
                 ebird = c('lng','lat'), 
                 ecoengine = c('longitude','latitude'), 
                 antweb = c('decimal_longitude','decimal_latitude'))
  if(reverse)
    names(w)[ names(w) %in% c('latitude','longitude') ] <- cols
  else  
    names(w)[ names(w) %in% cols ] <- c('latitude','longitude')
  
  return( w )
}

clean_country <- function(data, country=NULL, which='include', 
  shppath="~/github/ropensci/shapefiles/ne_10m_admin_0_countries/")
{
  shppath <- path.expand(shppath)
  layer <- ogrListLayers(shppath)
  shp <- readOGR(shppath, layer = layer)
  country_shp <- switch(which, 
    include = shp[shp@data$name %in% country,],
    exclude = shp[!shp@data$name %in% country,]
  )
  
  coordinates(data) <- ~longitude+latitude
  proj4string(data) <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
  
  ss <- over(data, country_shp)
  tmp <- data[!apply(ss, 1, function(b) is.na(b['scalerank'])), ]
  tmp <- as(tmp, "data.frame")
  return( tmp )
}

clean_habitat <- function(x){
  library(maptools)
  res <- map_data("world")
  #     ogrListLayers("/Users/sacmac/Downloads/ne_110m_land")
  #     land <- readOGR("/Users/sacmac/Downloads/ne_110m_land/", layer = 'ne_110m_land')
  land <- readOGR("/Users/sacmac/Downloads/ne_10m_land/", layer = 'ne_10m_land')
  
  df <- fortify(land)
  ggplot(df, aes(long, lat, group=group)) + 
    geom_polygon()
  
  x <- na.omit(x)
  coordinates(x) <- ~longitude+latitude
  proj4string(x) <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
  
  over(x, land)
}
