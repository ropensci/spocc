context("Testing by taxon identifier searches")

test_that("Taxon identifier searches work", {
  skip_on_cran()
  
  suppressPackageStartupMessages(require("taxize"))
  ids <- suppressMessages(get_ids(names=c("Chironomus riparius","Pinus contorta"), db = c('itis','gbif'), rows = 1))
  byid1 <- occ(ids = ids[[1]], from='bison', limit = 5)
  byid2 <- occ(ids = ids, from=c('bison','gbif'), limit = 5)
  
  ids <- suppressMessages(get_ids(names="Chironomus riparius", db = 'gbif', rows = 1))
  byid3 <- occ(ids = ids, from='gbif', limit = 5)
  
  ids <- get_gbifid("Chironomus riparius", verbose = FALSE, rows = 1)
  byid4 <- occ(ids = ids, from='gbif', limit=5)
  
  ids <- get_tsn('Accipiter striatus', verbose = FALSE)
  byid5 <- occ(ids = ids, from='bison', limit = 5)
  
  expect_is(byid1, "occdat")
  expect_is(byid2, "occdat")
  expect_is(byid3, "occdat")
  expect_is(byid4, "occdat")
  expect_is(byid5, "occdat")
  expect_equal(byid1$bison$meta$source, "bison")
})
