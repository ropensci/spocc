context("Occ options work")

test_that("passing in options to occ works", {
  skip_on_cran()
  
  opts1 <- occ(query = 'Accipiter striatus', from = 'gbif', 
               gbifopts = list(hasCoordinate = TRUE), limit = 5)
  opts2 <- occ(query = 'Accipiter', from = 'ecoengine', 
               ecoengineopts = list(county = "Sonoma"), limit = 5)
  opts3 <- occ(query = 'Danaus plexippus', from = 'inat',
               inatopts = list(year=2014), limit = 5)
  opts4 <- suppressMessages(occ(query = "linepithema humile", from = 'antweb', 
               antwebopts = list(country='Australia'), limit = 5))
  opts5 <- occ(query = 'Setophaga caerulescens', from = 'ebird', 
               ebirdopts = list(region='US'), limit = 5)
  opts6 <- occ("mustela", from = 'vertnet', 
               vertnetopts = list(specificepithet = "(nivalis OR erminea)"), limit = 5)
  opts7 <- occ(query = "Helianthus annuus", from = 'bison', 
               bisonopts = list(year = 2003), limit = 5)
  opts8 <- occ("Acer", from = 'idigbio', 
               idigbioopts = list(rq = list(hasImage = "true")), limit = 5)
  
  expect_is(opts1, "occdat")
  expect_is(opts2, "occdat")
  expect_is(opts3, "occdat")
  expect_is(opts5, "occdat")
  
  expect_false(anyNA(opts1$gbif$data$Accipiter_striatus$longitude))
  
  expect_equal(strsplit(as.character(opts3$inat$data$Danaus_plexippus$observed_on[1]), "-")[[1]][1], 
               "2014")
  
  expect_is(opts4$antweb$data$linepithema_humile$country[1], "character")
  expect_equal(opts4$antweb$data$linepithema_humile$country[1], "Australia")
  
  expect_is(opts5$ebird$data$Setophaga_caerulescens$comName, "character")
  expect_equal(opts5$ebird$data$Setophaga_caerulescens$comName[1], "Black-throated Blue Warbler")
  
  expect_true(any(vapply(opts6$vertnet$data$mustela$name, function(z) grepl("erminea", z), logical(1))))
  expect_true(any(vapply(opts6$vertnet$data$mustela$name, function(z) grepl("nivalis", z), logical(1))))
  
  expect_equal(opts7$bison$data$Helianthus_annuus$year[1], 2003)
  expect_is(opts7$bison$data$Helianthus_annuus$year[1], "integer")
  
  expect_true(all(opts8$idigbio$data$Acer$hasImage))
})
