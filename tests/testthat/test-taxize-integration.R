context("taxize integration")

skip_on_cran()

library("taxize")

test_that("taxize based searches works with > 1 get_ids,
          but indexed to 1 input", {
  skip_on_os("windows")

  # ids5 <- get_ids(c("Chironomus riparius","Pinus contorta"),
  #                db = c('itis',"gbif"), verbose = FALSE, rows = 1)
  # save(ids5, file = "tests/testthat/ids5.rda")
  load("ids5.rda")

  vcr::use_cassette("taxize_integration_morethan1id_indexed1", {
    aa <- occ(ids = ids5[[1]], from = "bison", limit = 20)
  })
	
  expect_is(ids5, "ids")
	expect_is(aa, "occdat")
	expect_is(aa$bison, "occdatind")
	expect_equal(length(aa$bison$data), 2)
	expect_named(aa$bison$data, c("129313", "183327"))
})

test_that("taxize based searches works with > 1 get_ids input", {
  skip_on_os("windows")
  
  # ids6 <- get_ids(c("Chironomus riparius","Pinus contorta"),
  #                db = c('itis',"gbif"), verbose = FALSE, rows = 1)
  # save(ids6, file = "tests/testthat/ids6.rda")
  load("ids6.rda")
	
  vcr::use_cassette("taxize_integration_morethan1id", {
    bb <- occ(ids = ids6, from=c("bison", "gbif"), limit=20)
  }, preserve_exact_body_bytes = TRUE)

	expect_is(bb, "occdat")
	expect_is(bb$gbif, "occdatind")
	expect_is(bb$bison, "occdatind")
	expect_equal(length(bb$gbif$data), 2)
	expect_equal(length(bb$bison$data), 2)
	expect_equal(length(bb$vertnet$data), 0)
  # FIXME: this test is broken
	# expect_named(bb$gbif$data, c("1448237", "5285750"))
	expect_named(bb$bison$data, c("129313", "183327"))
})

test_that("taxize based searches works with single get_ids input", {
	# ids7 <- get_ids("Chironomus riparius", db = "gbif", verbose = FALSE)
  # save(ids7, file = "tests/testthat/ids7.rda")
  load("ids7.rda")
	
  vcr::use_cassette("taxize_integration_1id", {
    cc <- occ(ids = ids7, from = "gbif", limit = 20)
  }, preserve_exact_body_bytes = TRUE)

	expect_is(cc, "occdat")
	expect_is(cc$gbif, "occdatind")
	expect_equal(length(cc$gbif$data), 1)
	expect_equal(length(cc$bison$data), 0)
	expect_named(cc$gbif$data, "1448237")
})

test_that("taxize based searches works with get_gbifid input", {
  # ids8 <- get_gbifid("Chironomus riparius", verbose = FALSE)
  # save(ids8, file = "tests/testthat/ids8.rda")
  load("ids8.rda")
  
  vcr::use_cassette("taxize_integration_get_gbifid", {
    dd <- occ(ids = ids8, from = "gbif", limit = 20)
  }, preserve_exact_body_bytes = TRUE)

  expect_is(dd, "occdat")
  expect_is(dd$gbif, "occdatind")
  expect_equal(length(dd$gbif$data), 1)
  expect_equal(length(dd$bison$data), 0)
  expect_named(dd$gbif$data, "1448237")
})

test_that("taxize based searches works with get_tsn input", {
  skip_on_os("windows")

  # ids9 <- get_tsn('Accipiter striatus', verbose = FALSE, rows = 1)
  # save(ids9, file = "tests/testthat/ids9.rda")
  load("ids9.rda")

  vcr::use_cassette("taxize_integration_get_tsn", {
    ee <- occ(ids = ids9, from = "bison", limit = 20)
  }, preserve_exact_body_bytes = TRUE)

  expect_is(ee, "occdat")
  expect_is(ee$bison, "occdatind")
  expect_equal(length(ee$bison$data), 1)
  expect_equal(length(ee$gbif$data), 0)
  expect_named(ee$bison$data, "175304")
})
