R CMD CHECK passed on my local OS X install with R 3.1.2 and R development version, Ubuntu running on Travis-CI, and Win builder.

This version includes a fix requested by CRAN:
- CRAN reported some examples were not passing in R development version that
were wrapped in \donttest. All examples are now in \dontrun because all work
with web APIs and I can't be sure that the web API is up all the time. 

Thanks! Scott Chamberlain
