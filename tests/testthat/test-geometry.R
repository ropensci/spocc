context("Testing geometry searches")

skip_on_cran()

test_that("geometry searches work", {
  vcr::use_cassette("occ_geometry_searches", {
    geo1 <- occ(query="Accipiter", from="gbif", limit = 3,
      geometry='POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))')
    geo11 <- occ(query="Accipiter striatus", from="gbif", limit = 3,
      geometry='POLYGON((-120.7 46.8,-103.1 46.4,-88.0 36.9,-109.5 32.6,-123.9 42.3,-120.7 46.8))')
  
    geo2 <- occ(query="Accipiter striatus", from="gbif", 
      geometry=c(-125.0,38.4,-121.8,40.9), limit = 3)
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(geo1, "occdat")
  expect_is(geo2, "occdat")
  expect_match(names(geo2$gbif$data), "Accipiter_striatus")
})

test_that("occ works for geometry (single) - query (none)", {
  skip_on_cran()

  bounds <- c(-120, 40, -100, 45)
  aa <- occ(from = "idigbio", geometry = bounds, limit = 2)

  expect_is(aa, "occdat")
  expect_is(aa$idigbio, "occdatind")
  expect_is(aa$idigbio$meta$type, "character")
  expect_equal(aa$idigbio$meta$type, "geometry")
  expect_named(aa$idigbio$meta$opts$rq, "geopoint")
})

test_that("occ works for geometry (many) - query (none)", {
  bounds <- list(c(165,-53,180,-29), c(-180,-53,-175,-29))
  vcr::use_cassette("occ_geometry_many_query_none", {
    aa <- occ(from = "gbif", geometry = bounds, limit = 2)
  })
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "geometry")
  expect_null(aa$gbif$meta$opts$scientifcName)
})

test_that("occ works for geometry (single) - query (single)", {
  bounds <- c(-120, 40, -100, 45)
  vcr::use_cassette("occ_geometry_single_query_single", {
    aa <- occ(query = "Accipiter striatus", from = "gbif", 
      geometry = bounds, limit = 2)
  })
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "sci")
  expect_match(aa$gbif$meta$opts$geometry, "POLYGON")
  expect_match(aa$gbif$meta$opts$scientificName, "striatus")
})

test_that("occ works for geometry (many) - query (single)", {
  bounds <- list(c(165,-53,180,-29), c(-180,-53,-175,-29))
  vcr::use_cassette("occ_geometry_many_query_single", {
    aa <- occ(query = "Poa annua", from = "gbif", 
      geometry = bounds, limit = 2)
  })
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "sci")
  expect_match(aa$gbif$meta$opts$geometry, "POLYGON")
  expect_match(aa$gbif$meta$opts$scientificName, "annua")
})

test_that("occ works for geometry (single) - query (many)", {
  bounds <- c(-120, 40, -100, 45)
  vcr::use_cassette("occ_geometry_single_query_many", {
    aa <- occ(query = c("Poa", "Quercus"), from = "gbif", 
      geometry = bounds, limit = 2)
  })
  
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
  bounds <- list(c(165,-53,180,-29), c(-180,-53,-175,-29))
  vcr::use_cassette("occ_geometry_many_query_many", {
    aa <- occ(query = c("Poa", "Quercus"), from = "gbif", 
      geometry = bounds, limit = 2)
  })
  
  expect_is(aa, "occdat")
  expect_is(aa$gbif, "occdatind")
  expect_is(aa$gbif$meta$type, "character")
  expect_equal(aa$gbif$meta$type, "sci")
  expect_match(aa$gbif$meta$opts$geometry, "POLYGON")
  expect_equal(length(aa$gbif$meta$opts$scientificName), 2)
  # should be only of length 2, one for each queried term
  expect_equal(length(aa$gbif$data), 2)
})
