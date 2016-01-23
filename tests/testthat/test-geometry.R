context("Testing geometry searches")

test_that("geometry searches work", {
  skip_on_cran()
  
  # no results
  geo1 <- occ(query='Accipiter', from='gbif', limit = 30,
              geometry='POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))')
  geo11 <- occ(query='Accipiter striatus', from='gbif', limit = 30,
               geometry=
                 'POLYGON((-120.7 46.8,-103.1 46.4,-88.0 36.9,-109.5 32.6,-123.9 42.3,-120.7 46.8))')
  
  geo2 <- occ(query='Accipiter striatus', from='gbif', geometry=c(-125.0,38.4,-121.8,40.9), limit = 30)
  geo3 <- occ(query='Accipiter striatus', from='ecoengine', limit=10, geometry=c(-125.0,38.4,-121.8,40.9))
  bounds <- c(-125.0,38.4,-121.8,40.9)
  geo4 <- occ(query = 'Danaus plexippus', from="inat", geometry=bounds, limit = 30)
  geo5 <- occ(query = 'Danaus plexippus', from=c("inat","gbif","ecoengine"), geometry=bounds, limit = 30)
  
  expect_is(geo1, "occdat")
  expect_is(geo2, "occdat")
  expect_is(geo3, "occdat")
  expect_is(geo4, "occdat")
  expect_is(geo5, "occdat")
  expect_match(names(geo2$gbif$data), 'Accipiter_striatus')
})

test_that("occ works for geometry (single) - query (none)", {
  skip_on_cran()
  
  bounds <- c(-120, 40, -100, 45)
  aa <- occ(from = "idigbio", geometry = bounds, limit = 10)
  
  expect_is(aa, "occdat")
  expect_is(aa$idigbio, "occdatind")
  expect_is(aa$idigbio$meta$type, "character")
  expect_equal(aa$idigbio$meta$type, "geometry")
  expect_named(aa$idigbio$meta$opts$rq, "geopoint")
})

test_that("occ works for geometry (many) - query (none)", {
  skip_on_cran()
  
  bounds <- list(c(165,-53,180,-29), c(-180,-53,-175,-29))
  aa <- occ(from = "gbif", geometry = bounds, limit = 10)
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "geometry")
  expect_null(aa$gbif$meta$opts$scientifcName)
})

test_that("occ works for geometry (single) - query (single)", {
  skip_on_cran()
  
  bounds <- c(-120, 40, -100, 45)
  aa <- occ(query = "Accipiter striatus", from = "gbif", geometry = bounds, limit = 10)
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "sci")
  expect_match(aa$gbif$meta$opts$geometry, "POLYGON")
  expect_match(aa$gbif$meta$opts$scientificName, "striatus")
})

test_that("occ works for geometry (many) - query (single)", {
  skip_on_cran()
  
  bounds <- list(c(165,-53,180,-29), c(-180,-53,-175,-29))
  aa <- occ(query = "Poa annua", from = "gbif", geometry = bounds, limit = 10)
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "sci")
  expect_match(aa$gbif$meta$opts$geometry, "POLYGON")
  expect_match(aa$gbif$meta$opts$scientificName, "annua")
})

test_that("occ works for geometry (single) - query (many)", {
  skip_on_cran()
  
  bounds <- c(-120, 40, -100, 45)
  aa <- occ(query = c("Poa", "Quercus"), from = "gbif", geometry = bounds, limit = 10)
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "sci")
  expect_match(aa$gbif$meta$opts$geometry, "POLYGON")
  expect_equal(length(aa$gbif$meta$opts$scientificName), 2)
  # should be only of length 2, one for each queried term
  expect_equal(length(aa$gbif$data), 2)
})

test_that("occ works for geometry (many) - query (many)", {
  skip_on_cran()
  
  bounds <- list(c(165,-53,180,-29), c(-180,-53,-175,-29))
  aa <- occ(query = c("Poa", "Quercus"), from = "gbif", geometry = bounds, limit = 10)
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "sci")
  expect_match(aa$gbif$meta$opts$geometry, "POLYGON")
  expect_equal(length(aa$gbif$meta$opts$scientificName), 2)
  # should be only of length 2, one for each queried term
  expect_equal(length(aa$gbif$data), 2)
})

## there was at one point a problem with ecoengine queries, testing for that
test_that("occ works for geometry for ecoengine", {
  skip_on_cran()
  
  x <- "POLYGON((-113.527516 20.929036 ,-113.357516 20.929036 ,-113.357516 21.099036 ,-113.527516 21.099036 ,-113.527516 20.929036))"
  aa <- suppressWarnings(occ(geometry = x, from = "ecoengine", limit = 10))
  expect_warning(occ(geometry = x, from = "ecoengine", limit = 10))
  expect_is(aa, "occdat")
  expect_equal(NROW(aa$ecoengine$data[[1]]), 0)
  
  y <- "POLYGON((-110.527516 20.929036, -120.357516 20.929036, -120.357516 31.099036, -110.527516 31.099036, -110.527516 20.929036))"
  aa <- suppressWarnings(occ(geometry = y, from = "ecoengine", limit = 10))
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_gt(NROW(aa$ecoengine$data[[1]]), 0)
  expect_equal(aa$ecoengine$meta$opts$bbox, "-120.357516,20.929036,-110.527516,31.099036")
})

