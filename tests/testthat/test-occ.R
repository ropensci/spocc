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
