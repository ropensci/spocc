context("Testing global common parameters")

test_that("limit", {
  skip_on_cran()
  
  limit_1 <- occ(query = 'Accipiter', from = 'gbif', limit = 3)
  limit_2 <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 5)
  
  expect_is(limit_1, "occdat")
  expect_is(limit_2, "occdat")
  
  expect_less_than(NROW(limit_1$gbif$data$Accipiter), NROW(limit_2$gbif$data$Accipiter))
})

test_that("geometry", {
  skip_on_cran()
  
  # a full set of tests for this, so just briefly here
  bounds1 <- c(-120, 40, -100, 45)
  bounds2 <- c(-120, 40, -115, 42)
  geom_1 <- occ(from = "gbif", geometry = bounds1, limit = 5)
  geom_2 <- occ(from = "gbif", geometry = bounds2, limit = 5)
  
  expect_is(geom_1, "occdat")
  expect_is(geom_2, "occdat")
  
  expect_less_than(geom_2$gbif$meta$found, geom_1$gbif$meta$found)  
})
