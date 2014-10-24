#' Automatically generate coverages for a spocc search
#' 
#' @description This function will automatically generate metadata for spocc queries that can then be converted to other standards.
#' @param occObj an search object returned by occ
#' @param coverage a vector of coverage types to generate.  These include 'temporal','spatial','taxa', or just 'all'.
#' @keywords internal

occ_coverage <- function(occObj,coverage = 'all'){
  coverage <- match.arg(coverage,choices = c("temporal","spatial","taxa","all"))
  cov <- list()
  if("spatial" %in% coverage){
    out <- occ2df(occObj)
    cov$spatial$polygon <- "Bounding box"
    coord <- rbind(apply(out[,2:3],2,min),apply(out[,2:3],2,max))
    cov$spatial$coord$UR <- coord[2,]
    cov$spatial$coord$LL  <- coord[1,]
    cov$spatial$coord$UL   <-  c(coord[1,1],coord[2,2])
    cov$spatial$coord$LR <- c(coord[2,1],coord[1,2])
  }
  
}
