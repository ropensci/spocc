test_that("as.vertnet", {
  vcr::use_cassette("as_vertnet_prep", {
    spnames <- c('Accipiter striatus', 'Setophaga caerulescens',
      'Spinus tristis')
    out <- suppressWarnings(occ(query=spnames, from='vertnet', limit=2))
  }, preserve_exact_body_bytes = TRUE)

  vcr::use_cassette("as_vertnet", {
    tt <- suppressMessages(as.vertnet(out))
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(tt, "list")
  expect_length(tt, 4)
  expect_match(names(tt), "http://.+")
  expect_is(tt[[1]], "vertnetkey")
  expect_is(unclass(tt[[1]]), "list")
  expect_is(tt[[1]]$meta, "list")
  expect_is(tt[[1]]$data, "data.frame")
  expect_equal(tt[[1]]$data$scientificname,
    "Setophaga caerulescens caerulescens")
})
