context("Testing global common parameters")

skip_on_cran()

test_that("limit", {
  vcr::use_cassette("occ_limit_param", {
    limit_1 <- occ(query = "Accipiter", from = "gbif", limit = 3)
    limit_2 <- occ(query = "Accipiter striatus", from = "gbif", limit = 5)
  })

  expect_is(limit_1, "occdat")
  expect_is(limit_2, "occdat")

  expect_lt(
    NROW(limit_1$gbif$data$Accipiter),
    NROW(limit_2$gbif$data$Accipiter)
  )
})

test_that("geometry", {
  # a full set of tests for this, so just briefly here
  bounds1 <- c(-120, 40, -100, 45)
  bounds2 <- c(-120, 40, -115, 42)

  vcr::use_cassette("occ_geometry_param", {
    geom_1 <- occ(from = "gbif", geometry = bounds1, limit = 5)
    geom_2 <- occ(from = "gbif", geometry = bounds2, limit = 5)
  })

  expect_is(geom_1, "occdat")
  expect_is(geom_2, "occdat")
  expect_lt(geom_2$gbif$meta$found, geom_1$gbif$meta$found)
})
