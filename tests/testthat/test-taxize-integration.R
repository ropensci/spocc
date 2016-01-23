context("taxize integration")

library("taxize")

test_that("taxize based searches works with > 1 get_ids, but indexed to 1 input", {
  skip_on_cran()

	ids <- get_ids(names=c("Chironomus riparius","Pinus contorta"), db = c('itis','gbif'), verbose = FALSE)
	aa <- occ(ids = ids[[1]], from='bison', limit=20)
	expect_is(ids, "ids")
	expect_is(aa, "occdat")
	expect_is(aa$bison, "occdatind")
	expect_equal(length(aa$bison$data), 2)
	expect_equal(length(aa$ecoengine$data), 0)
	expect_named(aa$bison$data, c("129313", "183327"))
})

test_that("taxize based searches works with > 1 get_ids input", {
  skip_on_cran()

  ids <- get_ids(names=c("Chironomus riparius","Pinus contorta"), db = c('itis','gbif'), verbose = FALSE)
	bb <- occ(ids = ids, from=c('bison','gbif'), limit=20)
	expect_is(bb, "occdat")
	expect_is(bb$gbif, "occdatind")
	expect_is(bb$bison, "occdatind")
	expect_equal(length(bb$gbif$data), 2)
	expect_equal(length(bb$bison$data), 2)
	expect_equal(length(bb$vertnet$data), 0)
	expect_named(bb$gbif$data, c("1448237", "5285750"))
	expect_named(bb$bison$data, c("129313", "183327"))
})

test_that("taxize based searches works with single get_ids input", {
  skip_on_cran()

	ids <- get_ids(names="Chironomus riparius", db = 'gbif', verbose = FALSE)
	cc <- occ(ids = ids, from='gbif', limit=20)
	expect_is(cc, "occdat")
	expect_is(cc$gbif, "occdatind")
	expect_equal(length(cc$gbif$data), 1)
	expect_equal(length(cc$bison$data), 0)
	expect_named(cc$gbif$data, "1448237")
})

test_that("taxize based searches works with get_gbifid input", {
  skip_on_cran()

  ids <- get_gbifid("Chironomus riparius", verbose = FALSE)
  dd <- occ(ids = ids, from='gbif', limit=20)
  expect_is(dd, "occdat")
  expect_is(dd$gbif, "occdatind")
  expect_equal(length(dd$gbif$data), 1)
  expect_equal(length(dd$bison$data), 0)
  expect_named(dd$gbif$data, "1448237")
})

test_that("taxize based searches works with get_tsn input", {
  skip_on_cran()
  ids <- get_tsn('Accipiter striatus', verbose = FALSE)
  ee <- occ(ids = ids, from='bison', limit=20)
  expect_is(ee, "occdat")
  expect_is(ee$bison, "occdatind")
  expect_equal(length(ee$bison$data), 1)
  expect_equal(length(ee$gbif$data), 0)
  expect_named(ee$bison$data, "175304")
})
