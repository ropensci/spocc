context("print and summary methods")

skip_on_cran()

vcr::use_cassette("print_methods", {
  res <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 3)
}, preserve_exact_body_bytes = TRUE)

test_that("print.occdat", {
  expect_output(print(res), "Searched: gbif")
  expect_output(print(res), "Occurrences - Found:")
  expect_output(print(res), "Search type: Scientific")
  expect_output(print(res), "gbif: Accipiter striatus \\(3\\)")
})

test_that("print.occdatind", {
  expect_output(print(res$gbif), "Species \\[Accipiter striatus \\(3\\)\\]")
  expect_output(print(res$gbif), "First 10 rows of \\[Accipiter_striatus\\]")
  expect_output(print(res$gbif), "A tibble")
  expect_output(print(res$gbif), "name")
  expect_output(print(res$gbif), "longitude")

  # empty results
  expect_output(print(res$obis), "First 10 rows of \\[Accipiter_striatus\\]")
  expect_output(print(res$obis), "A tibble: 0 x 0")
})

test_that("summary.occdat", {
  expect_output(print(summary(res)), "<source> gbif")
  expect_output(print(summary(res)), "<time>")
  expect_output(print(summary(res)), "<found> 1092647")
  expect_output(print(summary(res)), "<returned> 3")
  expect_output(print(summary(res)), "<query options>")
  expect_output(print(summary(res)), "<source> inat")
  expect_output(print(summary(res)), "<source> ebird")
  expect_output(print(summary(res)), "<source> ecoengine")
  expect_output(print(summary(res)), "<source> vertnet")
  expect_output(print(summary(res)), "<source> idigbio")
  expect_output(print(summary(res)), "<source> obis")
  expect_output(print(summary(res)), "<source> ala")
})

test_that("summary.occdatind", {
  expect_output(print(summary(res$gbif)), "<source> gbif")
  expect_output(print(summary(res$gbif)), "<time>")
  expect_output(print(summary(res$gbif)), "<found> 1092647")
  expect_output(print(summary(res$gbif)), "<returned> 3")
  expect_output(print(summary(res$gbif)), "<query options>")
  expect_output(print(summary(res$gbif)), "skip_validate: TRUE")
  expect_output(print(summary(res$gbif)), "scientificName: Accipiter striatus")
  expect_output(print(summary(res$gbif)), "limit: 3")
})
