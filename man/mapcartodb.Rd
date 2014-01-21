\name{mapcartodb}
\alias{mapcartodb}
\title{Make an interactive map to view on CartoDB}
\usage{
mapcartodb(data, tablename, columns, username = NULL, key = NULL)
}
\arguments{
  \item{data}{A data.frame with your data}

  \item{tablename}{Table name in CartoDB to push data to}

  \item{columns}{Columns in your data object to post to
  your table}

  \item{username}{User name for CartoDB}

  \item{key}{API key for CartoDB}
}
\description{
Make an interactive map to view on CartoDB
}
\examples{
\dontrun{
# Create an interactive map on CartoDB
## Install CartoDB library
install_github('cartodb-r', 'Vizzuality', subdir='CartoDB')
library(CartoDB)

## Get data for Puma concolor, the *hello, world* for biodiversity data
tmp <- occ(query='Puma concolor', from='gbif', gbifopts=list(limit=500,
   georeferenced=TRUE, country='US'))
data <- occ2df(tmp, 'data')

## Push data up to CartoDB
### I frist crated a table in my CartoDB account named `pumamap`. Then, I need to
### initialize the connection with CartoDB with my account name and API key. Note that
### I am pulling up my key from my .Rprofile file on my machine for ease and so it's
### not revealed to you :)

### Now we need to push data to our `pumamap` table using the function \\code{mapcartodb}
mapcartodb(data, 'pumamap', c('name','longitude','latitude'), 'recology')
}
}

