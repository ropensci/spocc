context("Occurrence data is correctly retrieved")

test_that("occ works", {
x2 <- occ(query = 'Accipiter striatus', from = 'gbif')
x2 <- occ(query = 'Accipiter striatus', from = 'ecoengine')
x3 <- occ(query = 'Danaus plexippus', from = 'inat')
# Make sure they are all occdats
x4 <- occ(query = 'Bison bison', from = 'bison')
x5 <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'))
x6 <- occ(query = 'Spinus tristis', from = 'ebird', ebirdopts = list(method = 'ebirdgeo', lat = 42, lng = -76, dist = 50))	

expect_is(x3, "occdat")
# expect_is(x4, "occdat")
expect_is(x5, "occdat")
expect_is(x6, "occdat")
# Testing x1
# expect_is(x1, "occdat")
# expect_is(x1$gbif, "list")
# expect_is(x1$gbif$data[[1]], "data.frame")
# temp_df <- x1$gbif$data[[1]]
# expect_equal(unique(temp_df$prov), "gbif")
# Testing x2
expect_is(x2, "occdat")
expect_is(x2$ecoengine, "list")
expect_is(x2$ecoengine$data[[1]], "data.frame")
temp_df2 <- x2$ecoengine$data[[1]]
expect_equal(unique(temp_df2$prov), "ecoengine")
# Testing x3
expect_is(x3, "occdat")
expect_is(x3$inat, "list")
expect_is(x3$inat$data[[1]], "data.frame")
temp_df3 <- x3$inat$data[[1]]
expect_equal(unique(temp_df3$prov), "inat")
# Testing x5
expect_is(x5, "occdat")
expect_is(x5$ebird, "list")
expect_is(x5$ebird$data[[1]], "data.frame")
temp_df4 <- x5$ebird$data[[1]]
expect_equal(unique(temp_df4$prov), "ebird")
# Testing x6
expect_is(x6, "occdat")
expect_is(x6$ebird, "list")
expect_is(x6$ebird$data[[1]], "data.frame")
temp_df6 <- x6$ebird$data[[1]]
expect_equal(unique(temp_df6$prov), "ebird")

# Adding tests for Antweb
by_species <- occ(query = "acanthognathus brevicornis", from = "antweb")
by_genus <- occ(query = "acanthognathus", from = "antweb")
expect_is(by_species, "occdat")
expect_is(by_species$antweb, "list")
expect_is(by_species$antweb$data[[1]], "data.frame")
temp_df7 <- by_species$antweb$data[[1]]
expect_equal(unique(temp_df7$prov), "antweb")

expect_is(by_genus, "occdat")
expect_is(by_genus$antweb, "list")
expect_is(by_genus$antweb$data[[1]], "data.frame")
temp_df8 <- by_genus$antweb$data[[1]]
expect_equal(unique(temp_df8$prov), "antweb")


})

context("Testing geometry searches")

test_that("geometry searches work", {
geo1 <- occ(query='Accipiter striatus', from='gbif', 
    geometry='POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))')
geo2 <- occ(query='Accipiter striatus', from='gbif', geometry=c(-125.0,38.4,-121.8,40.9))
geo3 <- occ(query='Accipiter striatus', from='ecoengine', limit=10, geometry=c(-125.0,38.4,-121.8,40.9))
bounds <- c(-125.0,38.4,-121.8,40.9)
geo4 <- occ(query = 'Danaus plexippus', from="inat", geometry=bounds)
geo5 <- occ(query = 'Danaus plexippus', from=c("inat","gbif","ecoengine"), geometry=bounds)

expect_is(geo1, "occdat")
expect_is(geo2, "occdat")
expect_is(geo3, "occdat")
expect_is(geo4, "occdat")
expect_is(geo5, "occdat")
expect_equal(nrow(geo1$gbif$data[[1]]), 1)
expect_match(names(geo2$gbif$data), 'Accipiter_striatus')
expect_equal(nrow(geo4$gbif$data[[1]]), 0)
expect_equal(ncol(occ2df(geo5)), 4)
})


context("Testing by taxon identifier searches")
library(taxize)

test_that("Taxon identifier searches work", {
  ids <- get_ids(names=c("Chironomus riparius","Pinus contorta"), db = c('itis','gbif'))
  byid1 <- occ(ids = ids[[1]], from='bison')
  byid2 <- occ(ids = ids, from=c('bison','gbif'))
  
  ids <- get_ids(names="Chironomus riparius", db = 'gbif')
  byid3 <- occ(ids = ids, from='gbif')
  
  ids <- get_gbifid("Chironomus riparius")
  byid4 <- occ(ids = ids, from='gbif', limit=5)
  
  ids <- get_tsn('Accipiter striatus')
  byid5 <- occ(ids = ids, from='bison')
  
  expect_is(byid1, "occdat")
  expect_is(byid2, "occdat")
  expect_is(byid3, "occdat")
  expect_is(byid4, "occdat")
  expect_is(byid5, "occdat")
  expect_equal(byid1$bison$meta$source, "bison")
  expect_equal(nrow(byid4$gbif$data[[1]]), 5)
})