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
