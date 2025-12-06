# Extracted from test-as.idigbio.R:7

# setup ------------------------------------------------------------------------
library(testthat)
test_env <- simulate_test_env(package = "spocc", path = "..")
attach(test_env, warn.conflicts = FALSE)

# prequel ----------------------------------------------------------------------
skip_on_cran()

# test -------------------------------------------------------------------------
vcr::use_cassette("as_idigbio_prep", {
    spnames <- c('Accipiter striatus', 'Setophaga caerulescens',
      'Spinus tristis')
    out <- occ(query=spnames, from='idigbio', limit=2)
  }, preserve_exact_body_bytes = TRUE)
