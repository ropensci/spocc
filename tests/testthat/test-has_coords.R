context("Limit to records with coordinates via has_coords")

test_that("has_coords works as expected", {
  skip_on_cran()

  hc_1 <- occ(query = 'Accipiter', from = 'gbif', limit = 5, has_coords = TRUE)
  hc_2 <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 5, has_coords = FALSE)

  expect_is(hc_1, "occdat")
  expect_is(hc_2, "occdat")

  expect_true(hc_1$gbif$meta$opts$hasCoordinate)
  expect_false(hc_2$gbif$meta$opts$hasCoordinate)

  expect_lt(hc_2$gbif$meta$found, hc_1$gbif$meta$found)
})

test_that("has_coords works with all data sources as planned", {
  skip_on_cran()

  aa <- occ('Accipiter striatus', from = 'gbif', limit = 5, has_coords = TRUE)
  bb <- occ('Accipiter striatus', from = 'ecoengine', limit = 5, has_coords = TRUE)
  dd <- occ('Accipiter striatus', from = 'inat', limit = 5, has_coords = TRUE)
  ee <- occ('Accipiter striatus', from = 'idigbio', limit = 5, has_coords = TRUE)
  ff <- occ('Accipiter striatus', from = 'vertnet', limit = 5, has_coords = TRUE)

  # gg <- occ('Accipiter striatus', from = 'ebird', limit = 5, has_coords = TRUE)
  hh <- occ('Accipiter striatus', from = 'bison', limit = 5, has_coords = TRUE)

  expect_is(aa, "occdat")
  expect_is(bb, "occdat")
  # expect_is(cc, "occdat")
  expect_is(dd, "occdat")
  expect_is(ee, "occdat")
  expect_is(ff, "occdat")
  # expect_is(gg, "occdat")
  expect_is(hh, "occdat")

  expect_false(anyNA(aa$gbif$data[[1]]$longitude))
  expect_false(anyNA(aa$gbif$data[[1]]$latitude))

  expect_false(anyNA(bb$ecoengine$data[[1]]$longitude))
  expect_false(anyNA(bb$ecoengine$data[[1]]$latitude))

  expect_false(anyNA(dd$inat$data[[1]]$longitude))
  expect_false(anyNA(dd$inat$data[[1]]$latitude))

  expect_false(anyNA(ee$idigbio$data[[1]]$longitude))
  expect_false(anyNA(ee$idigbio$data[[1]]$latitude))

  expect_false(anyNA(ff$vertnet$data[[1]]$longitude))
  expect_false(anyNA(ff$vertnet$data[[1]]$latitude))

  expect_true(aa$gbif$meta$opts$hasCoordinate)
  expect_true(bb$ecoengine$meta$opts$georeferenced)
  expect_true(dd$inat$meta$opts$geo)
  expect_equal(ee$idigbio$meta$opts$rq$geopoint$type, "exists")
  expect_true(ff$vertnet$meta$opts$mappable)
})
