library("vcr")
invisible(vcr::vcr_configure(
  dir = "../fixtures",
  filter_sensitive_data = list(
    "<<ebird_api_key>>" = Sys.getenv("EBIRD_KEY")
  )
))

sw <- suppressWarnings

has_internet <- function() {
  requireNamespace("crul")
  crul::ok("https://search.idigbio.org/v2/search/records")
}
has_idigbio <- function() {
  z <- try(sw(readLines("https://www.google.com", n = 1)),
    silent = TRUE)
  !inherits(z, "try-error")
}
skip_if_ <- function(fun) {
  function() {
    if (eval(fun)()) return()
    testthat::skip("no internet")
  }
}
skip_if_net_down <- skip_if_(has_internet)
skip_if_idigbio_down <- skip_if_(has_idigbio)
