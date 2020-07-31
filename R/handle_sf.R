# modified from code donated by Michael Sumner
matrix_tuple <- function(x) { # nocov start
  paste(unlist(lapply(split(t(x), rep(seq_len(dim(x)[1L]), each = dim(x)[2L])),
    paste0, collapse = " ")),
  collapse = ", ")
}
paren <- function(x) sprintf("(%s)", x)
declare <- function(x, DECLARATION) sprintf("%s %s", DECLARATION, x)
pstc <- function(x) paste(x, collapse = ", ")
sf2wkt_coords <- function(x) paren(matrix_tuple(x))
sf2wkt_polygon <- function(x) {
  paren(pstc(unlist(lapply(unclass(x), function(m) sf2wkt_coords(m)))))
}
shps <- c("POINT", "MULTIPOINT", "LINESTRING",
  "MULTILINESTRING", "POLYGON", "MULTIPOLYGON")
handle_geoms <- function(x) {
  clz <- shps[which(shps %in% class(x))]
  class(x) <- clz
  handle_geom(x)
}
handle_geom <- function(x, ...) {
  UseMethod("handle_geom")
}
handle_geom.POINT <- function(x, ...) {
  if (!is.matrix(x)) x<- matrix(x, nrow = 1L)
  declare(sf2wkt_coords(x), "POINT")
}
handle_geom.MULTIPOINT <- function(x, ...) {
  declare(sf2wkt_coords(x), "MULTIPOINT")
}
handle_geom.LINESTRING <- function(x, ...) {
 declare(sf2wkt_coords(x), "LINESTRING")
}
handle_geom.MULTILINESTRING <- function(x, ...) {
  declare(sf2wkt_polygon(x), "MULTILINESTRING")
}
handle_geom.POLYGON <- function(x, ...) {
  declare(sf2wkt_polygon(x), "POLYGON")
}
handle_geom.MULTIPOLYGON <- function(x, ...) {
  declare(paren(paste0(unlist(lapply(unclass(x), sf2wkt_polygon)),
    collapse = ", ")),
  "MULTIPOLYGON")
}
handle_sf <- function(x) {
  if (inherits(x, "sfg")) {
    handle_geoms(x)
  } else if (inherits(x, "sfc")) {
    tmp <- unlist(lapply(unclass(x), handle_geoms))
    if (all(grepl("^POLYGON", tmp)) && length(tmp) > 1) {
      return(declare(paren(pstc(strtrim(gsub("POLYGON", "", tmp)))),
        "MULTIPOLYGON"))
    }
    return(tmp)
  } else if (inherits(x, "sf")) {
    handle_sf(x[[attr(x, "sf_column")]])
  }
} # nocov end
