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
})


context("ggmap works correctly")

library(ggplot2)

test_that("ggmaps work as expected", {
	ecoengine_data <- occ(query = "Lynx rufus californicus", from = "ecoengine")
    map1 <- mapggplot(ecoengine_data)
 	gbif_data <- occ(query = 'Accipiter striatus', from = 'gbif')
	map2 <- mapggplot(gbif_data)
	expect_is(ecoengine_data, "occdat")
	expect_is(gbif_data, "occdat")
	expect_is(map1, "ggplot")
	expect_is(map2, "ggplot")
	unlink("ggmapTemp.png")
})


context("Testing the Leaflet maps")

test_that("Leaflet maps and geoJSON work", {
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta','Puma concolor', 'Ursus americanus','Gymnogyps californianus')
dat <- occ(query = spp, from = 'gbif', gbifopts = list(georeferenced = TRUE))
data <- occ2df(dat, 'data')
mapleaflet(data, map_provider = 'cm', dest = ".")
expect_true(file.exists("map"))
expect_true(file.exists("data.geojson"))
unlink("data.geojson")
unlink("map/", recursive = TRUE)
})


