library("vcr")
invisible(vcr::vcr_configure(
  dir = "../fixtures",
  filter_sensitive_data = list(
    "<<ebird_api_key>>" = Sys.getenv("EBIRD_KEY")
  )
))
