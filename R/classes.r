#' "occResult" class
#' 
#' @name occResult-class
#' @aliases occResult
#' @family occResult
#' 
#' @exportClass occResult
setClass("occResult", 
         slots=list(meta="list", data="data.frame"))

#' "occResultList" class
#' 
#' @name occResultList-class
#' @aliases occResultList
#' @family occResultList
#' 
#' @exportClass occResultList
setClass("occResultList", 
         slots=list(meta="list", data="list"))

#' "occDat" class
#' 
#' @name occDat-class
#' @aliases occDat
#' @family occDat
#' 
#' @exportClass occDat
setClass("occDat", 
         slots=list(gbif = "occResult", bison = "occResult", inat = "occResult", npn = "occResult", ebird = "occResult"))


#' "occDatSpp" class
#' 
#' @name occDatSpp-class
#' @aliases occDatSpp
#' @family occDatSpp
#' 
#' @exportClass occDatSpp
setClass("occDatSpp", 
         slots=list(gbif = "occResultList", bison = "occResultList", inat = "occResultList", npn = "occResultList", ebird = "occResultList"))





setGeneric("occtodf", function(x, what='all')
  standardGeneric("occtodf"))
#' Generic method for coercing class occDat to occDf
#' @exportMethod occtodf
setMethod("occtodf",
  signature = c("occDat"),
  definition = function(x, what){
    what <- match.arg(what, choices=c('all','data'))
    aa <- x@gbif@data
    bb <- x@bison@data
    cc <- x@inat@data
    dd <- x@npn@data
    ee <- x@ebird@data
    tmp <- data.frame(rbindlist(list(
      data.frame(name=aa$name,longitude=aa$longitude,latitude=aa$latitude,prov=aa$prov),
      data.frame(name=bb$name,longitude=bb$longitude,latitude=bb$latitude,prov=bb$prov),
      data.frame(name=cc$Scientific.name,latitude=cc$Latitude,longitude=cc$Longitude,prov=cc$prov),
      data.frame(name=dd$sciname,latitude=dd$latitude,longitude=dd$longitude,prov=dd$prov),
      data.frame(name=ee$sciName,latitude=ee$lat,longitude=ee$lng,prov=ee$prov)
    )))
    tmpout <- new("occDf", 
                  meta=list(x@gbif@meta,x@bison@meta,x@inat@meta,x@npn@meta,x@ebird@meta), 
                  data=tmp)
    if(what %in% 'data')
      tmpout@data
    else 
      tmpout
  }
)

setGeneric("occtodfspp", function(x, what='all')
  standardGeneric("occtodfspp"))
#' Generic method for coercing class occDat to occDf
#' @exportMethod occtodfspp
setMethod("occtodfspp",
          signature = c("occDatSpp"),
          definition = function(x, what){
            what <- match.arg(what, choices=c('all','data'))
            aa <- rbindlist(x@gbif@data)
            bb <- rbindlist(x@bison@data)
            cc <- rbindlist(x@inat@data)
            dd <- rbindlist(x@npn@data)
            ee <- rbindlist(x@ebird@data)
            tmp <- data.frame(rbindlist(list(
              data.frame(name=aa$name,longitude=aa$longitude,latitude=aa$latitude,prov=aa$prov),
              data.frame(name=bb$name,longitude=bb$longitude,latitude=bb$latitude,prov=bb$prov),
              data.frame(name=cc$Scientific.name,latitude=cc$Latitude,longitude=cc$Longitude,prov=cc$prov),
              data.frame(name=dd$sciname,latitude=dd$latitude,longitude=dd$longitude,prov=dd$prov),
              data.frame(name=ee$sciName,latitude=ee$lat,longitude=ee$lng,prov=ee$prov)
            )))
            tmpout <- new("occDf",
                          meta=list(x@gbif@meta,x@bison@meta,x@inat@meta,x@npn@meta,x@ebird@meta),
                          data=tmp)
            if(what %in% 'data')
              tmpout@data
            else 
              tmpout
          }
)


setGeneric("occmanytodf", function(x, what='all')
  standardGeneric("occmanytodf"))
#' Generic method for coercing a list of elements of class occDat to occDf
#' @exportMethod occmanytodf
setMethod("occmanytodf",
          signature = c("list"),
          definition = function(x, what='all'){
            if( !all(sapply(x, function(y) is(y,"occDat"))) )
              stop("Input objects must all be of class occDat")
            
            out <- lapply(x, function(z) occtodf(z, 'data'))
            tmp <- do.call(rbind.fill, out)
            row.names(tmp) <- NULL
            allmeta <- lapply(dat, function(x) 
              list(x@gbif@meta, x@bison@meta, x@inat@meta, x@npn@meta, x@ebird@meta))
            tmpout <- new("occDfMany", 
                meta=allmeta, 
                data=tmp)
            if(what %in% 'data')
              tmpout@data
            else 
              tmpout
  }
)


#' "occDf" class
#' 
#' @name occDf-class
#' @aliases occDf
#' @family occDf
#' 
#' @exportClass occDf
setClass("occDf", slots=list(meta="list", data="data.frame"))

#' "occDfMany" class
#' 
#' @name occDfMany-class
#' @aliases occDfMany
#' @family occDfMany
#' 
#' @exportClass occDfMany
setClass("occDfMany", slots=list(meta="list", data="data.frame"))

#' Coerce to sp object
#' 
#' @import sp
#' @name occDat-class
#' @family occDat-class
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
setAs("occDat", "SpatialPointsDataFrame", function(from){
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
setAs("occDf", "SpatialPointsDataFrame", function(from){
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
#' dfmany <- occmanytodf(dat)
#' spdat <- as(dfmany, "SpatialPointsDataFrame")
#' spdat@data$var <- rnorm(nrow(spdat@data)) # add a randomly generated data variable
#' bbox(spdat) # get bounding box data
#' plot(spdat) # plot points, bare bones
#' bubble(obj=spdat, zcol="var", key.space="bottom") # plot points w/ points of various sizes
#' spplot(obj=spdat, zcol="var", key.space="bottom")
#' }
setAs("occDfMany", "SpatialPointsDataFrame", function(from){
  dat <- na.omit(from@data)
  coordinates(dat) <- c("latitude","longitude")
  dat
})