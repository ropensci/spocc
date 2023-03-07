#' @title Interface to many species occurrence data sources
#' 
#' @description A programmatic interface to many species occurrence data 
#' sources, including GBIF, iNaturalist, Berkeley Ecoinformatics 
#' Engine, eBird, iDigBio, VertNet, OBIS, and ALA. Includes 
#' functionality for retrieving species occurrence data, and 
#' combining that data.
#' 
#' @section Package API:
#' 
#' The main function to use is [occ()] - a single interface to 
#' many species occurrence databases (see below for a list). 
#' 
#' Other functions include:
#' 
#' - [occ2df()] - Combine results from `occ` into a 
#'  data.frame
#' - [wkt_vis()] - Visualize WKT strings (used to define 
#'  geometry based searches for some data sources) in an interactive map
#' 
#' @section Currently supported species occurrence data sources:
#'
#' \tabular{ll}{
#' Provider \tab Web \cr
#' GBIF \tab <https://www.gbif.org/> \cr
#' eBird \tab <http://ebird.org/content/ebird/> \cr
#' iNaturalist \tab <https://www.inaturalist.org/> \cr
#' VertNet \tab <http://vertnet.org/> \cr
#' iDigBio \tab <https://www.idigbio.org/> \cr
#' OBIS \tab <https://www.iobis.org/> \cr
#' ALA \tab <https://www.ala.org.au/>
#' }
#' 
#' @section Duplicates:
#' 
#' See [spocc_duplicates()] for more.
#' 
#' @section Clean data:
#' 
#' All data cleaning functionality is in as archived package: `scrubr` 
#' (<https://github.com/ropensci-archive/scrubr>).
#' On CRAN: <https://cran.r-project.org/src/contrib/Archive/scrubr/>. 
#' See also package 
#' <https://cran.r-project.org/package=CoordinateCleaner>
#' 
#' @section Make maps:
#' 
#' All mapping functionality is now in a separate package: `mapr``
#' (<https://github.com/ropensci/mapr>) (formerly known as `spoccutils`).
#' On CRAN: <https://cran.r-project.org/package=mapr>
#'
#' @importFrom jsonlite toJSON
#' @importFrom utils browseURL head read.csv data setTxtProgressBar 
#' txtProgressBar
#' @importFrom data.table rbindlist setDF
#' @importFrom tibble tibble as_tibble
#' @importFrom lubridate now ymd_hms ymd_hm ydm_hm ymd as_date
#' @importFrom rgbif occ_data occ_get name_lookup
#' @importFrom rebird ebirdregion ebirdgeo
#' @importFrom rvertnet vertsearch
#' @importFrom ridigbio idig_search_records idig_view_records
#' @importFrom whisker whisker.render
#' @name spocc-package
#' @aliases spocc
#' @docType package
#' @author Scott Chamberlain
#' @keywords package
NULL
