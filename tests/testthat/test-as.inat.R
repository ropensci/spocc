skip_on_cran()

test_that("as.inat", {
  vcr::use_cassette("as_inat_prep", {
    out <- occ(query='Accipiter striatus', from='inat', limit=1)
  }, preserve_exact_body_bytes = TRUE)

  vcr::use_cassette("as_inat", {
    tt <- as.inat(out)
  }, preserve_exact_body_bytes = TRUE)
  
  expect_is(tt, "list")
  expect_length(tt, 1)
  expect_match(names(tt), "[0-9]+")
  expect_is(tt[[1]], "inatkey")
  expect_is(unclass(tt[[1]]), "list")
  expect_equal(tt[[1]]$total_results, 1)
  expect_equal(tt[[1]]$page, 1)
  expect_equal(tt[[1]]$per_page, 1)
  expect_is(tt[[1]]$results, "data.frame")
  expect_is(tt[[1]]$results$taxon, "data.frame")
  expect_equal(tt[[1]]$results$taxon$name, "Accipiter striatus")
})
