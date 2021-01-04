skip_on_cran()

test_that("as.ecoengine", {
  expect_error(as.ecoengine(), "defunct")
})
