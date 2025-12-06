# Extracted from test-has_coords.R:19

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "spocc", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
context("Limit to records with coordinates via has_coords")
skip_on_cran()

# test -------------------------------------------------------------------------
vcr::use_cassette("has_coords_gbif", {
    hc_1 <- occ(query = 'Accipiter', from = 'gbif', limit = 5, 
      has_coords = TRUE)
    hc_2 <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 5, 
      has_coords = FALSE)
  })
expect_is(hc_1, "occdat")
expect_is(hc_2, "occdat")
expect_true(hc_1$gbif$meta$opts$hasCoordinate)
expect_false(hc_2$gbif$meta$opts$hasCoordinate)
expect_lt(hc_2$gbif$meta$found, hc_1$gbif$meta$found)
