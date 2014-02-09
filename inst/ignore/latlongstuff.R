### Calculate a polygon around a point with a given distance radius
#### make sure to convert this to UTM first with WGS84 datum

library(rgeos)
foo <- function(lat, lon, write=FALSE, ...)
{
  latlon <- paste(lon, lat)
  #   poly <- readWKT(sprintf("POLYGON((%s,%s,%s,%s))", latlon,latlon,latlon,latlon))
  poly <- readWKT(sprintf("POLYGON((%s,%s,%s,%s))", latlon,latlon,latlon,latlon))
  g <- gBuffer(poly, ...)
  if(write)
    writeWKT(g)
  else
    g
}

(p <- foo(lat=33.95, lon=-118.40, width=0.4))
plot(p)

# this was Barry's solution

require(sp)
require(rgeos)
require(rgdal)
d <- data.frame(lat=c(33.95,34.95,34.70), lon=c(-118.40,-118.22,-118.43),ID=1:3)
coordinates(d)=~lon+lat
proj4string(d)=CRS("+init=epsg:4326")

buf <- gBuffer(d,width=0.2)
writeWKT(buf[1])
plot(buf)

# Bounding box to WKT

#' Converts a bounding box to a Well Known Text polygon
#' 
#' @param minx Minimum x value, or the most western longitude
#' @param miny Minimum y value, or the most southern latitude
#' @param maxx Maximum x value, or the most eastern longitude 
#' @param maxy Maximum y value, or the most northern latitude
#' @param all A vector of length 4, with the elements: minx, miny, maxx, maxy
#' @return An object of class charactere, a Well Known Text string of the form
#' 'POLYGON((minx miny, maxx miny, maxx maxy, minx maxy, minx miny))'
#' @examples
#' # Pass in a vector of length 4 with all values
#' mm <- bbox2wkt(bbox=c(38.4,-125.0,40.9,-121.8))
#' plot(readWKT(mm))
#' 
#' # Or pass in each vdalue separately
#' mm <- bbox2wkt(minx=38.4, miny=-125.0, maxx=40.9, maxy=-121.8)
#' plot(readWKT(mm))

bbox2wkt <- function(minx=NA, miny=NA, maxx=NA, maxy=NA, bbox=NULL){
  if(is.null(bbox))
    bbox <- c(minx, miny, maxx, maxy)
  
  assert_that(length(bbox)==4) #check for 4 digits
  assert_that(noNA(bbox)) #check for NAs
  assert_that(is.numeric(as.numeric(bbox))) #check for numeric-ness
  paste('POLYGON((', 
        sprintf('%s %s',bbox[1],bbox[2]), ',', sprintf('%s %s',bbox[3],bbox[2]), ',', 
        sprintf('%s %s',bbox[3],bbox[4]), ',', sprintf('%s %s',bbox[1],bbox[4]), ',', 
        sprintf('%s %s',bbox[1],bbox[2]), 
        '))', sep="")
}

# assert_that(length(c(minx, miny, maxx, maxy))==4) #check for 4 digits
# assert_that(noNA(c(minx, miny, maxx, maxy))) #check for NAs
# assert_that(is.numeric(as.numeric(all))) #check for numeric-ness
# paste('POLYGON((', 
#       sprintf('%s %s',minx,miny), ',', sprintf('%s %s',maxx,miny), ',', 
#       sprintf('%s %s',maxx,maxy), ',', sprintf('%s %s',minx,maxy), ',', 
#       sprintf('%s %s',minx,miny), 
#       '))', sep="")


wkt="POLYGON((38.4 -125,40.9 -125,40.9 -121.8,38.4 -121.8,38.4 -125))"
wkt2bbox <- function(wkt=NULL){
  assert_that(!is.null(wkt))
  tmp <- bbox(readWKT(wkt))
  as.vector(tmp)
}


#####
# d <- cbind(c(33.95,34.95,34.70), c(-118.40,-118.22,-118.43))
# coordinates(d)=~lon+lat
# spTransform(d, CRS("+proj=utm +zone=11 +datum=WGS84"))
# project(d, "+proj=utm +zone=11 +datum=WGS84")

# library(rgdal) 
# xy <- cbind(c(118, 119), c(10, 50)) 
# project(xy, "+proj=utm +zone=24 ellps=WGS84") 
# spTransform(xy, CRS("+proj=utm +zone=51 ellps=WGS84"))

### Get UTM zone for a set of lat/long coordinates
#### for western hemisphere only 
long2UTM <- function(long) {
  (floor((long + 180)/6) %% 60) + 1
}
long2UTM(4)

#### for globe
long2utm <- function(lon, lat) {
  if(56 <= lat & lat < 64){
    if(0 <= lon & lon < 3){ 31 } else 
      if(3 <= lon & lon < 12) { 32 } else { NULL }
  } else 
  if(72 <= lat) {
    if(0 <= lon & lon < 9){ 31 } else 
      if(9 <= lon & lon < 21) { 33 } else 
        if(21 <= lon & lon < 33) { 35 } else 
          if(33 <= lon & lon < 42) { 37 } else { NULL }
  }
  (floor((lon + 180)/6) %% 60) + 1
}
long2utm(-60, 65)
#


# library(rgdal)

## Create an example SpatialPoints object
# pts <- SpatialPoints(cbind(-120:-121, 39:40), 
#                      proj4string = CRS("+proj=longlat +datum=NAD27"))

## Construct a proper proj4string
# UTM11N <- "+proj=utm +zone=11 +datum=NAD83 +units=m +no_defs"
# UTM11N <- paste(UTM11N, "+ellps=GRS80 +towgs84=0,0,0")
# UTM11N <-  CRS(UTM11N)

## Project your points
# ptsUTM <- spTransform(pts, UTM11N)


### Convert data.frame from spocc of lat/long coord's to UTM coords

library(spocc)
dat <- occ(query='Accipiter striatus', from='gbif')
dat <- na.omit(dat@gbif@data)
coordinates(dat)=~longitude+latitude
proj4string(dat) = CRS("+init=epsg:4326")
spTransform(dat, CRS("+proj=utm +zone=11 +datum=WGS84 +units=m +no_defs +towgs84=0,0,0"))