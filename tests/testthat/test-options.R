context("Occ options work")

skip_on_cran()

test_that("passing in options to occ works", {
  skip_on_cran()
  
  vcr::use_cassette("occ_options_gbif", {
    opts1 <- occ(query = "Accipiter striatus", from = "gbif",
                 gbifopts = list(hasCoordinate = TRUE), limit = 5)
  }, preserve_exact_body_bytes = TRUE)
  # vcr::use_cassette("occ_options_inat", { 
  #   opts3 <- occ(query = "Danaus plexippus", from = "inat",
  #                inatopts = list(year = 2014), limit = 5)
  # }, preserve_exact_body_bytes = TRUE)
  vcr::use_cassette("occ_options_ebird", {
    opts5 <- occ(query = "Setophaga caerulescens", from = "ebird",
                 ebirdopts = list(hotspot = TRUE), limit = 5)
  }, preserve_exact_body_bytes = TRUE)
  # opts6 <- occ(query = "Mustela", from = "vertnet",
  #              vertnetopts = list(year = 2010), limit = 5)

  expect_is(opts1, "occdat")
  # expect_is(opts3, "occdat")
  expect_is(opts5, "occdat")
  # expect_is(opts6, "occdat")

  expect_false(anyNA(opts1$gbif$data$Accipiter_striatus$longitude))

  # expect_equal(
  #   strsplit(
  #     as.character(opts3$inat$data$Danaus_plexippus$observed_on[1]),
  #     "-")[[1]][1],
  #   "2014"
  # )

  if (!is.null(opts5$ebird$data$Setophaga_caerulescens$comName[1])) {
    expect_is(opts5$ebird$data$Setophaga_caerulescens$comName,
      "character")
    expect_equal(opts5$ebird$data$Setophaga_caerulescens$comName[1],
      "Black-throated Blue Warbler")
  }

  # expect_true(all(as.numeric(opts6$vertnet$data$Mustela$year) == 2010))
})

test_that("passing in options to occ works: idigbio", {
  skip_on_cran()
  opts8 <- occ("Acer", from = 'idigbio',
               idigbioopts = list(rq = list(hasImage = "true")), limit = 5)
  expect_is(opts8, "occdat")
  expect_true(all(opts8$idigbio$data$Acer$hasImage))
})
