context("occ paging works")

skip_on_cran()

test_that("occ paging works", {
  vcr::use_cassette("occ_pagination", {
    one <- occ(query = "Accipiter striatus", from = "gbif", limit = 5)
    two <- occ(query = "Accipiter striatus", from = "gbif", limit = 5,
      start = 5)
  })

  expect_is(one, "occdat")
  expect_is(one$gbif, "occdatind")

  expect_is(two, "occdat")
  expect_is(two$gbif, "occdatind")

  expect_null(one$gbif$meta$opts$start)
  expect_false(is.null(two$gbif$meta$opts$start))
})
