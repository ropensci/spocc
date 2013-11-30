#' Coerce elements of output from a single occ() call to a single data.frame
#' 
#' @importFrom plyr rbind.fill
#' @param x An object of class occdat
#' @return An object of class occdf, including metadata from input occdat object, 
#' and a combined data.frame from different sources. If a single data sources was 
#' called in the \code{occ} call, the same data.frame is returned.
occ_todf <- function(x)
{
  if(!is(x,"occdat"))
    stop("Input object must be of class occdat")
  
  parse <- function(y){
    if(y$prov[1]=="gbif"){
      data.frame(name=y$name,longitude=y$longitude,latitude=y$latitude,prov=y$prov)
    } else
      if(y$prov[1]=="bison"){
        data.frame(name=y$name,longitude=y$longitude,latitude=y$latitude,prov=y$prov)
      } else
        if(y$prov[1]=="inat"){
          data.frame(name=y$Scientific.name,latitude=y$Latitude,longitude=y$Longitude,prov=y$prov)
        } else
          if(y$prov[1]=="npn"){
            data.frame(name=y$sciname,latitude=y$latitude,longitude=y$longitude,prov=y$prov)
          }
  }
  tmp <- do.call(rbind.fill, lapply(x@data, parse))
  row.names(tmp) <- NULL
  new("occdf", meta=x@meta, data=tmp)
}

#' Coerce elements of output from many occ() calls to a single data.frame
#' 
#' @importFrom plyr rbind.fill
#' @param ... A list of objects, or any number of objects separated by commas, all 
#' of class occdat.
#' @return An object of class occdfmany, with a metadata (meta) slot and a data slot. 
#' Includes metadata from all input occdat objects as a list in the meta slot, and 
#' a combined data.frame from all inputs.
#' @examples \dontrun{
#' # Pass in a list of occdat objects
#' spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
#' dat <- lapply(spp, function(x) occ(query=x, from='gbif'))
#' occmany_todf(dat) # data with compiled metadata
#' occmany_todf(dat)@data # just data
#' 
#' # Pass in a series of occdat objects separated by commas
#' dat1 <- occ('Danaus plexippus', from='gbif')
#' dat2 <- occ('Accipiter striatus', from='gbif')
#' dat3 <- occ('Pinus contorta', from='gbif')
#' occmany_todf(dat1, dat2, dat3)
#' }
#' @export
occmany_todf <- function(...)
{
  x <- list(...)
  if(is(x, "list"))
    x <- x[[1]]
  if( !all(sapply(x, function(y) is(y,"occdat"))) )
    stop("Input objects must all be of class occdat")
  
  out <- lapply(x, function(z) occ_todf(z)@data)
  tmp <- do.call(rbind.fill, out)
  row.names(tmp) <- NULL
  new("occdfmany", meta=lapply(x, function(x) x@meta), data=tmp)
}