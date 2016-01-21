context("Occurrence data is correctly retrieved")

test_that("occ works for each data source", {
  skip_on_cran()

  x1 <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 30)
  x2 <- occ(query = 'Accipiter striatus', from = 'ecoengine', limit = 30)
  x3 <- occ(query = 'Danaus plexippus', from = 'inat', limit = 30)
  # Make sure they are all occdats
  x4 <- occ(query = 'Bison bison', from = 'bison', limit = 30)
  x5 <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'), limit = 30)
  x6 <- occ(query = 'Spinus tristis', from = 'ebird', ebirdopts = list(method = 'ebirdgeo', lat = 42, lng = -76, dist = 50), limit = 30)
  x7 <- occ(query = 'Spinus tristis', from = 'idigbio', limit = 30)

  expect_is(x3, "occdat")
  expect_is(x4, "occdat")
  expect_is(x5, "occdat")
  expect_is(x6, "occdat")
  expect_is(x7, "occdat")
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

  # Testing x7
  expect_is(x7, "occdat")
  expect_is(x7$idigbio, "occdatind")
  expect_is(x7$idigbio$data[[1]], "data.frame")
  temp_df7 <- x7$idigbio$data[[1]]
  expect_equal(unique(temp_df7$prov), "idigbio")

  # Adding tests for Antweb
  by_species <- suppressWarnings(
    tryCatch(suppressMessages(
      occ(query = "linepithema humile", from = "antweb", limit = 10)), error=function(e) e))
  by_genus <- suppressWarnings(
    tryCatch(suppressMessages(
      occ(query = "acanthognathus", from = "antweb", limit = 10)), error=function(e) e))

  if (!"error" %in% class(by_species)) {
    expect_is(by_species, "occdat")
    expect_is(by_species$antweb, "occdatind")
    expect_is(by_species$antweb$data[[1]], "data.frame")
    temp_df7 <- by_species$antweb$data[[1]]
    expect_equal(unique(temp_df7$prov), "antweb")
  }

  if (!"error" %in% class(by_genus)) {
    expect_is(by_genus, "occdat")
    expect_is(by_genus$antweb, "occdatind")
    expect_is(by_genus$antweb$data[[1]], "data.frame")
    temp_df8 <- by_genus$antweb$data[[1]]
    expect_equal(unique(temp_df8$prov), "antweb")
  }
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


######## paging

test_that("occ paging works", {
  skip_on_cran()

  one <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 5)
  two <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 5, start = 5)
  one$gbif
  two$gbif

  expect_is(one, "occdat")
  expect_is(one$gbif, "occdatind")

  expect_is(two, "occdat")
  expect_is(two$gbif, "occdatind")

  expect_null(one$gbif$meta$opts$start)
  expect_false(is.null(two$gbif$meta$opts$start))
})
