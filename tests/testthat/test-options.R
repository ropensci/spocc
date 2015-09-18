context("Occ options work")

test_that("passing in options to occ works", {
  skip_on_cran()
  
  opts1 <- occ(query = 'Accipiter striatus', from = 'gbif', gbifopts = list(hasCoordinate = TRUE), limit = 5)
  opts2 <- occ(query = 'Accipiter striatus', from = 'ecoengine', ecoengineopts = list(county="Sonoma"), limit = 5)
  opts3 <- occ(query = 'Danaus plexippus', from = 'inat', inatopts = list(year=2014), limit = 5)
  opts5 <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'), limit = 5)
  
  expect_is(opts1, "occdat")
  expect_is(opts2, "occdat")
  expect_is(opts3, "occdat")
  expect_is(opts5, "occdat")
  
  expect_false(all(is.na(opts1$gbif$data$Accipiter_striatus$longitude)))
  expect_is(opts5$ebird$data$Setophaga_caerulescens$comName, "character")
})
