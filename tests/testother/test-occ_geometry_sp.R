devtools::load_all("../../")
library(testthat)
library(sp)

context("Testing handle_sp")
test_that("handle_sp", {
  # A single polygons in a SpatialPolygons class
  one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
  spone = Polygons(list(one), "s1")
  sppoly = SpatialPolygons(list(spone), as.integer(1))
  aa <- handle_sp(spobj = sppoly)

  expect_is(aa, "character")
  expect_match(aa, "POLYGON\\(\\(91 30,90 30,90 32,91 30\\)\\)")

  # Two polygons in a SpatialPolygons class
  one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
  two <- Polygon(cbind(c(94,92,92,94), c(40,40,42,40)))
  spone = Polygons(list(one), "s1")
  sptwo = Polygons(list(two), "s2")
  sppoly = SpatialPolygons(list(spone, sptwo), as.integer(1:2))
  bb <- handle_sp(spobj = sppoly)

  expect_is(bb, "character")
  expect_match(bb, "MULTIPOLYGON\\(\\(\\(91 30,90 30,90 32,91 30\\)\\),\\(\\(94 40,92 40,92 42,94 40\\)\\)\\)")

  # Another example
  one <- Polygon(cbind(c(-121.0,-117.9,-121.0,-121.0), c(39.4, 37.1, 35.1, 
    39.4)))
  two <- Polygon(cbind(c(-123.0,-121.2,-122.3,-124.5,-123.5,-124.1,-123.0),
                       c(44.8,42.9,41.9,42.6,43.3,44.3,44.8)))
  spone = Polygons(list(one), "s1")
  sptwo = Polygons(list(two), "s2")
  sppoly = SpatialPolygons(list(spone, sptwo), 1:2)
  cc <- handle_sp(spobj=sppoly)

  expect_is(cc, "character")
  expect_match(cc, "MULTIPOLYGON")
})

context("Testing geometry searches w/ `sp` inputs")
test_that("occ works for geometry sp inputs", {
  library("sp")
  
  ## Single polygon in SpatialPolygons class
  one <- Polygon(cbind(c(91,90,90,91), c(30,30,32,30)))
  spone = Polygons(list(one), "s1")
  sppoly = SpatialPolygons(list(spone), as.integer(1))

  aa <- occ(geometry = sppoly, limit = 10)

  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "geometry")
  expect_match(aa$gbif$meta$opts$geometry,
    "POLYGON\\(\\(91 30,90 30,90 32,91 30\\)\\)")
})

