context("taxize integration")

skip_on_cran()

library("taxize")

test_that("taxize based searches works with > 1 get_ids input", {
  skip_on_os("windows")
  
  # ids6 <- get_ids(c("Chironomus riparius","Pinus contorta"),
  #                db = c('itis',"gbif"), verbose = FALSE, rows = 1)
  # save(ids6, file = "tests/testthat/ids6.rda")
  load("ids6.rda")
	
  vcr::use_cassette("taxize_integration_morethan1id", {
    bb <- suppressWarnings(occ(ids = ids6, from=c("gbif"), limit=20))
  }, preserve_exact_body_bytes = TRUE)

	expect_is(bb, "occdat")
	expect_is(bb$gbif, "occdatind")
	expect_equal(length(bb$gbif$data), 2)
	expect_equal(length(bb$vertnet$data), 0)
  # FIXME: this test is broken
	# expect_named(bb$gbif$data, c("1448237", "5285750"))
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
  expect_named(dd$gbif$data, "1448237")
})
