test_that("as.obis", {
  vcr::use_cassette("as_obis_prep", {
    spnames <- c('Mola mola', 'Loligo vulgaris')
    out <- occ(query=spnames, from='obis', limit=2)
  }, preserve_exact_body_bytes = TRUE)

  vcr::use_cassette("as_obis", {
    tt <- as.obis(out)
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(tt, "list")
  expect_length(tt, 4)
  expect_match(names(tt),
    "[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+")
  expect_is(tt[[1]], "obiskey")
  expect_is(unclass(tt[[1]]), "list")
  expect_equal(tt[[1]]$total, 1)
  expect_is(tt[[1]]$results, "data.frame")
  expect_equal(tt[[1]]$results$scientificName, "Mola mola")
})
