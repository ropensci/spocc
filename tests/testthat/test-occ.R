context("Occurrence data is correctly retrieved")

test_that("occ works", {
  skip_on_cran()
  
  x1 <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 30)
  x2 <- occ(query = 'Accipiter striatus', from = 'ecoengine', limit = 30)
  x3 <- occ(query = 'Danaus plexippus', from = 'inat', limit = 30)
  # Make sure they are all occdats
  x4 <- occ(query = 'Bison bison', from = 'bison', limit = 30)
  x5 <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'), limit = 30)
  x6 <- occ(query = 'Spinus tristis', from = 'ebird', ebirdopts = list(method = 'ebirdgeo', lat = 42, lng = -76, dist = 50), limit = 30)

  expect_is(x3, "occdat")
  expect_is(x4, "occdat")
  expect_is(x5, "occdat")
  expect_is(x6, "occdat")
  # Testing x1
  expect_is(x1, "occdat")
  expect_is(x1$gbif, "occdatind")
  expect_is(x1$gbif$data[[1]], "data.frame")
  temp_df <- x1$gbif$data[[1]]
  expect_equal(unique(temp_df$prov), "gbif")
  # Testing x2
  expect_is(x2, "occdat")
  expect_is(x2$ecoengine, "occdatind")
  expect_is(x2$ecoengine$data[[1]], "data.frame")
  temp_df2 <- x2$ecoengine$data[[1]]
  expect_equal(unique(temp_df2$prov), "ecoengine")
  # Testing x3
  expect_is(x3, "occdat")
  expect_is(x3$inat, "occdatind")
  expect_is(x3$inat$data[[1]], "data.frame")
  temp_df3 <- x3$inat$data[[1]]
  expect_equal(unique(temp_df3$prov), "inat")
  # Testing x5
  expect_is(x5, "occdat")
  expect_is(x5$ebird, "occdatind")
  expect_is(x5$ebird$data[[1]], "data.frame")
  temp_df4 <- x5$ebird$data[[1]]
  expect_equal(unique(temp_df4$prov), "ebird")
  # Testing x6
  expect_is(x6, "occdat")
  expect_is(x6$ebird, "occdatind")
  expect_is(x6$ebird$data[[1]], "data.frame")
  temp_df6 <- x6$ebird$data[[1]]
  expect_equal(unique(temp_df6$prov), "ebird")

  # Adding tests for Antweb
  # by_species <- suppressWarnings(tryCatch(occ(query = "acanthognathus brevicornis", from = "antweb"), error=function(e) e))
  # by_genus <- suppressWarnings(tryCatch(occ(query = "acanthognathus", from = "antweb"), error=function(e) e))
  #
  # if(!"error" %in% class(by_species)){
  #   expect_is(by_species, "occdat")
  #   expect_is(by_species$antweb, "list")
  #   expect_is(by_species$antweb$data[[1]], "data.frame")
  #   temp_df7 <- by_species$antweb$data[[1]]
  #   expect_equal(unique(temp_df7$prov), "antweb")
  # }
  #
  # if(!"error" %in% class(by_genus)){
  #   expect_is(by_genus, "occdat")
  #   expect_is(by_genus$antweb, "list")
  #   expect_is(by_genus$antweb$data[[1]], "data.frame")
  #   temp_df8 <- by_genus$antweb$data[[1]]
  #   expect_equal(unique(temp_df8$prov), "antweb")
  # }

})

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


context("Testing by taxon identifier searches")

test_that("Taxon identifier searches work", {
  skip_on_cran()
  
  suppressPackageStartupMessages(require("taxize"))
  ids <- suppressMessages(get_ids(names=c("Chironomus riparius","Pinus contorta"), db = c('itis','gbif')))
  byid1 <- occ(ids = ids[[1]], from='bison', limit = 5)
  byid2 <- occ(ids = ids, from=c('bison','gbif'), limit = 5)

  ids <- suppressMessages(get_ids(names="Chironomus riparius", db = 'gbif'))
  byid3 <- occ(ids = ids, from='gbif', limit = 5)

  ids <- get_gbifid("Chironomus riparius", verbose = FALSE)
  byid4 <- occ(ids = ids, from='gbif', limit=5)

  ids <- get_tsn('Accipiter striatus', verbose = FALSE)
  byid5 <- occ(ids = ids, from='bison', limit = 5)

  expect_is(byid1, "occdat")
  expect_is(byid2, "occdat")
  expect_is(byid3, "occdat")
  expect_is(byid4, "occdat")
  expect_is(byid5, "occdat")
  expect_equal(byid1$bison$meta$source, "bison")
})


test_that("passing in options to occ works", {
  skip_on_cran()
  
  opts1 <- occ(query = 'Accipiter striatus', from = 'gbif', gbifopts = list(hasCoordinate = TRUE), limit = 5)
  opts2 <- occ(query = 'Accipiter striatus', from = 'ecoengine', ecoengineopts = list(county="Sonoma"), limit = 5)
  opts3 <- occ(query = 'Danaus plexippus', from = 'inat', inatopts = list(year=2014), limit = 5)
  opts5 <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'), limit = 5)
  opts6 <- occ(query = 'Spinus tristis', from = 'vertnet', vertnetopts = list(state = "california"), limit = 5)
  
  expect_is(opts1, "occdat")
  expect_is(opts2, "occdat")
  expect_is(opts3, "occdat")
  expect_is(opts5, "occdat")
  expect_is(opts6, "occdat")
  
  expect_false(all(is.na(opts1$gbif$data$Accipiter_striatus$longitude)))
  expect_match(opts3$inat$data$Danaus_plexippus$observed_on[1], "2014")
  expect_match(opts6$vertnet$data$Spinus_tristis$stateprovince[1], "California")
})
