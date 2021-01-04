skip_on_cran()

test_that("as.bison", {
  skip_on_os("windows")
  vcr::use_cassette("as_bison_prep", {
    spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
    out <- occ(query=spnames, from='bison', limit=2)
  }, preserve_exact_body_bytes = TRUE)

  vcr::use_cassette("as_bison", {
    tt <- as.bison(out)
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(tt, "list")
  expect_length(tt, 6)
  expect_match(names(tt), "[0-9]+")
  expect_is(tt[[1]], "bisonkey")
  expect_is(unclass(tt[[1]]), "list")
  expect_named(tt[[1]], c("num_found", "points", "highlight",
    "facets"))
  expect_is(tt[[1]]$points, "data.frame")
  expect_is(tt[[1]]$points$providedScientificName, "character")
})
