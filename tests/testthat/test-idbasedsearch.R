context("Testing by taxon identifier searches")

test_that("Taxon identifier searches work", {
  skip_on_cran()

  suppressPackageStartupMessages(require("taxize"))
  # ids <- suppressMessages(get_ids(names=c("Bison","Pinus contorta"), db = c('itis','gbif'), rows = 1))
  load("ids.rda")
  byid1 <- occ(ids = ids[[1]], from='bison', limit = 5)
  byid2 <- occ(ids = ids, from=c('bison','gbif'), limit = 5)

  # ids2 <- suppressMessages(get_ids(names="Chironomus riparius", db = 'gbif', rows = 1))
  load("ids2.rda")
  byid3 <- occ(ids = ids2, from='gbif', limit = 5)

  # ids3 <- get_gbifid("Chironomus riparius", verbose = FALSE, rows = 1)
  load("ids3.rda")
  byid4 <- occ(ids = ids3, from='gbif', limit=5)

  # ids4 <- suppressWarnings(get_tsn('Accipiter striatus', verbose = FALSE, rows = 1))
  load("ids4.rda")
  byid5 <- occ(ids = ids4, from='bison', limit = 5)

  expect_is(byid1, "occdat")
  expect_is(byid2, "occdat")
  expect_is(byid3, "occdat")
  expect_is(byid4, "occdat")
  expect_is(byid5, "occdat")
  expect_equal(byid1$bison$meta$source, "bison")
})
