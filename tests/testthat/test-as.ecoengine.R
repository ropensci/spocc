test_that("as.ecoengine", {
  vcr::use_cassette("as_ecoengine_prep", {
    spnames <- c('Accipiter striatus', 'Spinus tristis')
    out <- occ(query=spnames, from='ecoengine', limit=2)
  }, preserve_exact_body_bytes = TRUE)

  vcr::use_cassette("as_ecoengine", {
    tt <- as.ecoengine(out)
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(tt, "list")
  expect_length(tt, 4)
  expect_match(names(tt), "[A-Za-z]+:[A-Za-z]+:[0-9]+")
  expect_is(tt[[1]], "ecoenginekey")
  expect_is(unclass(tt[[1]]), "list")
  expect_is(tt[[1]]$geometry, "list")
  expect_equal(tt[[1]]$geometry$type, "Point")
  expect_is(tt[[1]]$geometry$coordinates, "numeric")
})
