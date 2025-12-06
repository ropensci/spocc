# Extracted from test-as.vertnet.R:11

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "spocc", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
skip_on_cran()

# test -------------------------------------------------------------------------
vcr::use_cassette("as_vertnet_prep", {
    spnames <- c('Accipiter striatus', 'Setophaga caerulescens',
      'Spinus tristis')
    out <- suppressWarnings(occ(query=spnames, from='vertnet', limit=2))
  }, preserve_exact_body_bytes = TRUE)
vcr::use_cassette("as_vertnet", {
    tt <- suppressMessages(as.vertnet(out))
  }, preserve_exact_body_bytes = TRUE)
