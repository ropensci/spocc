skip_on_cran()

test_that("as.ala", {
  vcr::use_cassette("as_ala_prep", {
    spnames <- c('Barnardius zonarius', 'Grus rubicunda', 'Cracticus tibicen')
    out <- suppressWarnings(occ(query=spnames, from='ala', limit=2))
  }, preserve_exact_body_bytes = TRUE)

  vcr::use_cassette("as_ala", {
    tt <- as.ala(out)
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(tt, "list")
  expect_length(tt, 2)
  expect_match(names(tt),
    "[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+")
  expect_named(tt[[1]], c("raw", "processed", "systemAssertions",
    "userAssertions"))
  expect_is(tt[[1]]$systemAssertions, "list")
  expect_is(tt[[1]]$systemAssertions$passed, "data.frame")
  expect_is(tt[[1]]$raw$occurrence, "list")
  expect_is(tt[[1]]$raw$classification, "list")
  expect_equal(tt[[1]]$raw$classification$scientificName,
    "Barnardius zonarius")
})
