context("ggmap works correctly")

library("ggplot2")

test_that("ggmaps work as expected", {
	ecoengine_data <- occ(query = "Lynx rufus californicus", from = "ecoengine")
  map1 <- suppressMessages(mapggplot(ecoengine_data))
 	gbif_data <- occ(query = 'Accipiter striatus', from = 'gbif')
	map2 <- suppressMessages(mapggplot(gbif_data))
	expect_is(ecoengine_data, "occdat")
	expect_is(gbif_data, "occdat")
	expect_is(map1, "ggplot")
	expect_is(map2, "ggplot")
	unlink("ggmapTemp.png")
})
