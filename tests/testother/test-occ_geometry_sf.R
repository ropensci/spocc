# devtools::load_all("../../")
library(spocc)
library(testthat)
library(sp)
library(sf)
library(silicate) ## just for data examples

context("Testing handle_sf")
test_that("handle_sf", {
  # A single polygons in a SpatialPolygons class
  # to: a polygon
  one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
  spone = Polygons(list(one), "s1")
  sppoly = SpatialPolygons(list(spone), as.integer(1))
  poly <- sf::st_as_sf(sppoly)
  ## class: sf
  single_sf <- spocc:::handle_sf(poly)
  ## class: sfc/sfc_POLYGON
  single_sfc <- spocc:::handle_sf(poly[[1]])
  ## class: sfg/POLYGON
  single_polygon <- spocc:::handle_sf(unclass(poly[[1]])[[1]])

  poly_str <- "POLYGON \\(\\(91 30, 90 30, 90 32, 91 30\\)\\)"
  expect_is(single_sf, "character")
  expect_match(single_sf, poly_str)
  expect_is(single_sfc, "character")
  expect_match(single_sfc, poly_str)
  expect_is(single_polygon, "character")
  expect_match(single_polygon, poly_str)


  # Two polygons in a SpatialPolygons class
  # to: a multipolygon
  one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
  two <- Polygon(cbind(c(94,92,92,94), c(40,40,42,40)))
  spone = Polygons(list(one), "s1")
  sptwo = Polygons(list(two), "s2")
  sppoly = SpatialPolygons(list(spone, sptwo), as.integer(1:2))
  sppoly <- sf::st_as_sf(sppoly)
  ## class: sf
  two_sf <- spocc:::handle_sf(sppoly)
  ## class: sfc/sfc_POLYGON
  two_sfc <- spocc:::handle_sf(sppoly[[1]])
  ## class: sfg/POLYGON
  two_polygon <- spocc:::handle_sf(unclass(sppoly[[1]])[[1]])

  mpoly_str <- "MULTIPOLYGON \\(\\(\\(91 30, 90 30, 90 32, 91 30\\)\\), \\(\\(94 40, 92 40, 92 42, 94 40\\)\\)\\)"
  expect_is(two_sf, "character")
  expect_match(two_sf, mpoly_str)
  expect_is(two_sfc, "character")
  expect_match(two_sfc, mpoly_str)
  expect_is(two_polygon, "character")
  expect_match(two_polygon, poly_str)


  # Two polygons, aka one polygon with a hole
  # Sr1 = Polygon(cbind(c(2,4,4,1,2),c(2,3,5,4,2)), hole = FALSE)
  # Sr2 = Polygon(cbind(c(5,4,2,5),c(2,3,2,2)), hole = FALSE)
  # Sr3 = Polygon(cbind(c(4,4,5,10,4),c(5,3,2,5,5)), hole = FALSE)
  # Sr4 = Polygon(cbind(c(5,6,6,5,5),c(4,4,3,3,4)), hole = TRUE)
  # Srs1 = Polygons(list(Sr3), "s1")
  # Srs3 = Polygons(list(Sr4), "s4")
  # sps = SpatialPolygons(list(Srs1, Srs3), 1:2)
  # sps_sf <- sf::st_as_sf(sps)
  # aa <- spocc:::handle_sf(sps_sf)

  # multipolygon
  # class(sfzoo$multipolygon)
  # plot(sfzoo$multipolygon)
  bb <- spocc:::handle_sf(sfzoo$multipolygon)
  expect_is(bb, "character")
  expect_match(bb, "MULTIPOLYGON")
})

context("Testing geometry searches w/ `sf` inputs")
test_that("occ works for geometry sf inputs", {
  ## Single polygon in SpatialPolygons class
  one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
  spone = Polygons(list(one), "s1")
  sppoly = SpatialPolygons(list(spone), as.integer(1))
  x <- st_as_sf(sppoly)

  aa <- occ(geometry = x, limit = 10)

  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "geometry")
  expect_match(aa$gbif$meta$opts$geometry,
    "POLYGON \\(\\(91 30, 90 30, 90 32, 91 30\\)\\)")
})
