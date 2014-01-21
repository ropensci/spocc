\name{mapggplot}
\alias{mapggplot}
\title{ggplot2 visualization of species occurences}
\usage{
mapggplot(df, zoom = 5)
}
\arguments{
  \item{df}{Input \code{data.frame}}
}
\description{
ggplot2 visualization of species occurences
}
\examples{
\dontrun{
ecoengine_data <- occ(query = "Lynx rufus californicus", from = "ecoengine")
mapggplot(ecoengine_data)
gbif_data <- occ(query = 'Accipiter striatus', from = 'gbif')
mapggplot(gbif_data)
}
}

