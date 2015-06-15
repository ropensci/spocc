#' @importFrom V8 new_context
terr <- NULL
cent <- NULL
.onLoad <- function(libname, pkgname){
  terr <<- V8::new_context();
  terr$source(system.file("js/terraformer-wkt-parser.js", package = pkgname))
  
  cent <<- V8::new_context();
  cent$source(system.file("js/turf-centroid.js", package = pkgname))
}
