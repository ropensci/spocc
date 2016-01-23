context("occ paging works")

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
