context("Testing by taxon identifier searches")

test_that("Taxon identifier searches work", {
  suppressPackageStartupMessages(require("taxize"))
  load("ids.rda")
  load("ids2.rda")
  load("ids3.rda")
  load("ids4.rda")

  vcr::use_cassette("identifier_based_searches", {
    byid1 <- occ(ids = ids[[1]], from = "bison", limit = 5)
    byid2 <- occ(ids = ids, from = c("bison", "gbif"), limit = 5)
    byid3 <- occ(ids = ids2, from = "gbif", limit = 5)
    byid4 <- occ(ids = ids3, from = "gbif", limit = 5)
    byid5 <- occ(ids = ids4, from = "bison", limit = 5)
  }, preserve_exact_body_bytes = TRUE)

  expect_is(byid1, "occdat")
  expect_is(byid2, "occdat")
  expect_is(byid3, "occdat")
  expect_is(byid4, "occdat")
  expect_is(byid5, "occdat")
  expect_equal(byid1$bison$meta$source, "bison")
})
