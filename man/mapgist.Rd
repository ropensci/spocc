\name{mapgist}
\alias{mapgist}
\title{Make an interactive map to view in the browser as a Github gist}
\usage{
  mapgist(data, description = "", file = "gistmap",
    dir = NULL, ...)
}
\arguments{
  \item{data}{A data.frame, with any number of columns, but
  with at least the following: name (the taxonomic name),
  latitude (in dec. deg.), longitude (in dec. deg.)}

  \item{description}{Description for the Github gist, or
  leave to default (=no description)}

  \item{file}{File name (without file extension) for your
  geojson file. Default is "gistmap".}

  \item{dir}{Directory for storing file and reading it back
  in to create gist.  If none is given, this function gets
  your working directory and uses that.}

  \item{...}{Further arguments passed on to
  \code{spocc_stylegeojson}}
}
\value{
  Creates a gist on your Github account, and prints out
  where the geojson file was written on your machinee, the
  url for the gist, and an embed script in the console.
}
\description{
  You will be asked ot enter you Github credentials
  (username, password) during each session, but only once
  for each session. Alternatively, you could enter your
  credentials into your .Rprofile file with the entries

  \itemize{ \item options(github.username =
  "your_github_username") \item options(github.password =
  "your_github_password") }

  then \code{mapgist} will simply read those options.

  \code{mapgist} has modified code from the rCharts package
  by Ramnath Vaidyanathan
}
\examples{
\dontrun{
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- lapply(spp, function(x) occ(query=x, from='gbif', gbifopts=list(georeferenced=TRUE)))
dat <- do.call(rbind, lapply(dat, function(x) x
}
\seealso{
  \code{spocc_gist}, \code{spocc_stylegeojson},
  \code{spocc_togeojson}
}

