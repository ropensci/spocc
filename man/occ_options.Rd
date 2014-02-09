\name{occ_options}
\alias{occ_options}
\title{Look up options for parameters passed to each source}
\usage{
occ_options(from = "gbif")
}
\arguments{
  \item{from}{(character) Data source to get data from, any
  combination of gbif, bison, inat, ebird, and/or
  ecoengine}
}
\value{
Opens up the documentation for the function that is used
internally within the occ function for each source. Any of
the parameters passed to e.g. occ_search() from the rgbif
package can be passed in the associated gbifopts list in
occ()
}
\description{
Look up options for parameters passed to each source
}
\examples{
occ_options()
occ_options('ecoengine')
}

