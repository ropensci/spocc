test_that("as.idigbio", {
  vcr::use_cassette("as_idigbio_prep", {
    spnames <- c('Accipiter striatus', 'Setophaga caerulescens',
      'Spinus tristis')
    out <- occ(query=spnames, from='idigbio', limit=2)
  }, preserve_exact_body_bytes = TRUE)

  vcr::use_cassette("as_idigbio", {
    tt <- as.idigbio(out)
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(tt, "list")
  expect_length(tt, 6)
  expect_match(names(tt),
    "[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+-[0-9A-Za-z]+")
  expect_is(tt[[1]], "idigbiokey")
  expect_is(unclass(tt[[1]]), "list")
  expect_is(tt[[1]]$data, "list")
  expect_is(tt[[1]]$data$`dwc:scientificName`, "character")
})
