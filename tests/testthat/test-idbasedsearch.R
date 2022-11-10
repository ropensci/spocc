context("Testing by taxon identifier searches")

skip_on_cran()

test_that("Taxon identifier searches work", {
  suppressPackageStartupMessages(require("taxize"))
  load("ids.rda")
  load("ids2.rda")
  load("ids3.rda")
  load("ids4.rda")

  vcr::use_cassette("identifier_based_searches", {
    byid3 <- occ(ids = ids2, from = "gbif", limit = 5)
    byid4 <- occ(ids = ids3, from = "gbif", limit = 5)
  }, preserve_exact_body_bytes = TRUE)

  expect_is(byid3, "occdat")
  expect_is(byid4, "occdat")
})
