context("Testing the Leaflet maps")

test_that("Leaflet maps and geoJSON work", {
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta','Puma concolor', 'Ursus americanus','Gymnogyps californianus')
dat <- occ(query = spp, from = 'gbif', gbifopts = list(hasCoordinate = TRUE))
data <- occ2df(dat, 'data')
mapleaflet(data, map_provider = 'toner', dest = ".")
expect_true(file.exists("map"))
expect_true(file.exists("data.geojson"))
unlink("data.geojson")
unlink("map/", recursive = TRUE)
})
