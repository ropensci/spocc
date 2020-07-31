test_that("as.gbif", {
  vcr::use_cassette("as_gbif_prep", {
    spnames <- c('Accipiter striatus', 'Setophaga caerulescens',
      'Spinus tristis')
    out <- occ(query=spnames, from=c('gbif'), 
      gbifopts=list(hasCoordinate=TRUE), limit=2)
  }, preserve_exact_body_bytes = TRUE)

  vcr::use_cassette("as_gbif", {
    tt <- as.gbif(out)
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(tt, "list")
  expect_length(tt, 6)
  expect_match(names(tt), "[0-9]+")
  expect_is(tt[[1]], "gbifkey")
  expect_is(unclass(tt[[1]]), "list")
  expect_is(tt[[1]][[1]]$hierarchy, "data.frame")
  expect_is(tt[[1]][[1]]$media, "list")
  expect_is(tt[[1]][[1]]$data, "data.frame")
  expect_is(tt[[1]][[1]]$data$scientificName, "character")
})
