context("wkt_vis works")

skip_on_cran()

test_that("wkt_vis works with browse=FALSE", {
  skip_on_cran()
  
  poly <- 'POLYGON((-111.06 38.84, -110.80 39.37, -110.20 39.17, -110.20 38.90,
  -110.63 38.67, -111.06 38.84))'
  aa <- wkt_vis(poly, browse = FALSE)
  
  expect_is(aa, "character")
  expect_match(aa, ".html")
  expect_match(aa, "spocc")
  
  aa_html <- paste0(readLines(aa), collapse = "\n")
  expect_is(aa_html, "character")
  expect_true(grepl("DOCTYPE", aa_html))
  expect_true(grepl("L.mapbox", aa_html))
})

test_that("wkt_vis works with multiple polygons", {
  skip_on_cran()
  
  x <- "POLYGON((-125 38.4, -121.8 38.4, -121.8 40.9, -125 40.9, -125 38.4), 
   (-115 22.4, -111.8 22.4, -111.8 30.9, -115 30.9, -115 22.4))"
  aa <- wkt_vis(x, browse = FALSE)
  
  expect_is(aa, "character")
  expect_match(aa, ".html")
  expect_match(aa, "spocc")
  
  aa_html <- paste0(readLines(aa), collapse = "\n")
  expect_is(aa_html, "character")
  expect_true(grepl("DOCTYPE", aa_html))
  expect_true(grepl("L.mapbox", aa_html))
})
