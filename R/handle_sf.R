# library("sf")
# library("sp")
# library("silicate") ## just for data examples

# # A single polygons in a SpatialPolygons class
# # to: a polygon
# one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
# spone = Polygons(list(one), "s1")
# sppoly = SpatialPolygons(list(spone), as.integer(1))
# poly <- sf::st_as_sf(sppoly)
# class(poly)
# # plot(poly)
# handle_sf(poly)
# handle_sf(poly[[1]])
# handle_sf(unclass(poly[[1]])[[1]])

# # Two polygons in a SpatialPolygons class
# # to: a multipolygon
# one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
# two <- Polygon(cbind(c(94,92,92,94), c(40,40,42,40)))
# spone = Polygons(list(one), "s1")
# sptwo = Polygons(list(two), "s2")
# sppoly = SpatialPolygons(list(spone, sptwo), as.integer(1:2))
# sppoly <- sf::st_as_sf(sppoly)
# class(sppoly)
# # plot(sppoly)
# handle_sf(sppoly)

# # Two polygons, aka one polygon with a hole
# # RIGHT NOW: converting multipolygon
# # NOT SUPPORTED, so maybe error when users pass these?
# # check that all data sources don't suppor this or not?
# Sr1 = Polygon(cbind(c(2,4,4,1,2),c(2,3,5,4,2)), hole = FALSE)
# Sr2 = Polygon(cbind(c(5,4,2,5),c(2,3,2,2)), hole = FALSE)
# Sr3 = Polygon(cbind(c(4,4,5,10,4),c(5,3,2,5,5)), hole = FALSE)
# Sr4 = Polygon(cbind(c(5,6,6,5,5),c(4,4,3,3,4)), hole = TRUE)
# Srs1 = Polygons(list(Sr3), "s1")
# Srs3 = Polygons(list(Sr4), "s4")
# sp = SpatialPolygons(list(Srs1, Srs3), 1:2)
# sp <- sf::st_as_sf(sp)
# class(sp)
# # plot(sp)
# handle_sf(sp)
#
# # multipolygon
# class(sfzoo$multipolygon)
# handle_sf(sfzoo$multipolygon)
matrix_tuple <- function(x) {
  paste(unlist(lapply(split(t(x), rep(seq_len(dim(x)[1L]), each = dim(x)[2L])),
    paste0, collapse = " ")), 
  collapse = ", ")
}
paren <- function(x) sprintf("(%s)", x)
declare <- function(x, DECLARATION) sprintf("%s %s", DECLARATION, x)
pstc <- function(x) paste(x, collapse = ", ")
handle_sf <- function(x, ...) {
  UseMethod("handle_sf")
}
sf2wkt_coords <- function(x) paren(matrix_tuple(x))
sf2wkt_polygon <- function(x) {
  paren(pstc(unlist(lapply(unclass(x), function(m) sf2wkt_coords(m)))))
}
handle_sf.POINT <- function(x, ...) {
  if (!is.matrix(x)) x<- matrix(x, nrow = 1L)
  declare(sf2wkt_coords(x), "POINT") 
}
handle_sf.MULTIPOINT <- function(x, ...) {
  declare(sf2wkt_coords(x), "MULTIPOINT") 
}
handle_sf.LINESTRING <- function(x, ...) {
 declare(sf2wkt_coords(x), "LINESTRING") 
}
handle_sf.MULTILINESTRING <- function(x, ...) {
  declare(sf2wkt_polygon(x), "MULTILINESTRING")
}
handle_sf.POLYGON <- function(x, ...) {
  declare(sf2wkt_polygon(x), "POLYGON")
}
handle_sf.sfc <- function(x, ...) {
  tmp <- unlist(lapply(unclass(x), handle_sf))
  if (all(grepl("^POLYGON", tmp)) && length(tmp) > 1) {
    return(declare(paren(pstc(strtrim(gsub("POLYGON", "", tmp)))),
      "MULTIPOLYGON"))
  }
  return(tmp)
}
handle_sf.sf <- function(x, ...) {
  handle_sf(x[[attr(x, "sf_column")]])
}
handle_sf.MULTIPOLYGON <- function(x, ...) {
  declare(paren(paste0(unlist(lapply(unclass(x), sf2wkt_polygon)),
    collapse = ", ")),
  "MULTIPOLYGON")
}
