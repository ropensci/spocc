#' "occdat" class
#' 
#' @name occdat-class
#' @aliases occdat
#' @family occdat
#' 
#' @exportClass occdat
setClass("occdat", slots=list(meta="list", data="list"))

#' "occdf" class
#' 
#' @name occdf-class
#' @aliases occdf
#' @family occdf
#' 
#' @exportClass occdf
setClass("occdf", slots=list(meta="list", data="data.frame"))

#' "occdfmany" class
#' 
#' @name occdfmany-class
#' @aliases occdfmany
#' @family occdfmany
#' 
#' @exportClass occdfmany
setClass("occdfmany", slots=list(meta="list", data="data.frame"))

#' Coerce to sp object
#' 
#' @import sp
#' @name occdat-class
#' @family occdat-class
#' @examples \dontrun{
#' dat <- occ(query='Accipiter striatus', from='gbif')
#' spdat <- as(dat, "SpatialPointsDataFrame")
#' summary(spdat)
#' bbox(spdat)
#' plot(spdat)
#' bubble(obj=spdat, zcol="name", key.space="bottom")
#' spplot(spdat, names.attr=spdat@data$name)
#' 
#' library(RColorBrewer)
#' palette(brewer.pal(6, "YlOrRd"))
#' spplot(obj=spdat, zcol="name", key.space="right", )
#' }
setAs("occdat", "SpatialPointsDataFrame", function(from){
  if(length(from@data)==1){ 
    dat <- from@data[[1]]
    dat <- na.omit(dat)
  } else
  { 
    dat <- occ_todf(from)
    dat <- na.omit(dat@data)
  }
  coordinates(dat) <- c("latitude","longitude")
  dat
})

#' Coerce to sp object
#' 
#' @import sp
#' @name occdf-class
#' @family occdf
setAs("occdf", "SpatialPointsDataFrame", function(from){
  dat <- na.omit(from@data)
  coordinates(dat) <- c("latitude","longitude")
  dat
})

#' Coerce to sp object
#' 
#' @import sp
#' @name occdfmany-class
#' @family occdfmany-class
#' @examples \dontrun{
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
#' dat <- lapply(spp, function(x) occ(query=x, from='gbif', gbifopts=list(georeferenced=TRUE)))
#' dfmany <- occmany_todf(dat)
#' spdat <- as(dfmany, "SpatialPointsDataFrame")
#' spdat@data$var <- rnorm(nrow(spdat@data)) # add a randomly generated data variable
#' bbox(spdat) # get bounding box data
#' plot(spdat) # plot points, bare bones
#' bubble(obj=spdat, zcol="var", key.space="bottom") # plot points w/ points of various sizes
#' spplot(obj=spdat, zcol="var", key.space="bottom")
#' }
setAs("occdfmany", "SpatialPointsDataFrame", function(from){
  dat <- na.omit(from@data)
  coordinates(dat) <- c("latitude","longitude")
  dat
})