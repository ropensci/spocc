\name{occ}
\alias{occ}
\title{Make a map of species occurrence data.}
\usage{
  occ(query = NULL,
    from = c("gbif", "bison", "vertnet", "inat"),
    type = "sci", gbifopts = NULL, bisonopts = NULL,
    inatopts = NULL, vertnetopts = NULL)
}
\arguments{
  \item{query}{Query term. Either a scientific name or a
  common name. Specify whether a scientific or common name
  in the type parameter.}

  \item{from}{Data source to get data from, any combination
  of gbif, bison, vertnet, inat}

  \item{type}{Type of name, sci (scientific) or com (common
  name, vernacular)}

  \item{gbifopts}{List of options to pass on to rgbif}

  \item{bisonopts}{List of options to pass on to rbison}

  \item{inatopts}{List of options to pass on to rinat}

  \item{vertnetopts}{List of options to pass on to
  rvertnet}
}
\description{
  Make a map of species occurrence data.
}
\details{
  The \code{occ} function is an opinionated wrapper around
  the rgbif, rbison, rvertnet, and rinat packages to allow
  data access from a single access point. We take care of
  making sure you get useful objects out at the cost of
  flexibility/options - if you need options you can use the
  functions inside each of those packages.
}
\examples{
\dontrun{
# Single data sources
out <- occ(query='Accipiter striatus', from='gbif')
occ('Ursus americanus', from='inat')
occ('Danaus plexippus', from='bison')
occ('Danaus plexippus', from='vertnet')

# Many data sources
out <- occ(query='Accipiter striatus', from = c('gbif','bison'))
out
occ_todf(out) # coerce to combined data.frame
}
}

