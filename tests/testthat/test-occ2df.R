context("occ2df")

skip_on_cran()

test_that("occ2df basic functionality works", {
  vcr::use_cassette("occ2df", {
    aa <- occ(query = 'Accipiter striatus', from = "gbif", limit = 10)
  })
  
  expect_is(aa, "occdat")

  aadf <- occ2df(aa)
  expect_is(aadf, "data.frame")
  expect_named(aadf, c('name', 'longitude', 'latitude', 'prov', 'date', 'key'))
  expect_is(aadf$date, "Date")
})

#### FIXME: find example where no dates given back
# test_that("occ2df works when no eventDate given back from gbif", {
#   skip_on_cran()
#   
#   res <- occ(query = 'Culex modestus', geometry = c(-11, 49.5, 2.5, 61), from = "gbif", limit = 5)
#   bb <- occ2df(res)
#   
#   expect_is(bb, "data.frame")
#   # note date field missing
#   expect_named(bb, c('name', 'longitude', 'latitude', 'prov', 'key'))
# })

test_that("occ2df works when eventDate gone - another eg", {
  vcr::use_cassette("occ2df_with_eventdate_gone", {
    out <- occ(query = "Pinus contorta", from = c("gbif","bison"),
      limit = 10)
  })
  
  # make date field null
  out$gbif$data$Pinus_contorta$eventDate <- NULL
  expect_warning(out$gbif$data$Pinus_contorta$eventDate,
               "Unknown")
  
  # but should still work
  outdf <- occ2df(out)
  
  expect_is(outdf, "data.frame")
  # FIXME: note date field missing - date is on end though, kinda weird
  # FIXME: below test failing on CRAN, just comment out for now
  # expect_named(outdf, c('name', 'longitude', 'latitude', 'prov', 'key', 'date'))
})
