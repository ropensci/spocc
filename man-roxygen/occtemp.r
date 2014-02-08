#' @param query One to many names. Either a scientific name or a common name.  
#' 	  Specify whether a scientific or common name in the type parameter.
#' Only scientific names supported right now.
#' @param from Data source to get data from, any combination of gbif, bison,
#'    inat, ebird, and/or ecoengine
#' @param limit Number of records to return. This is passed across all sources.
#' 	  To specify different limits for each source, use the options for each source.
#' @param geometry Searches for occurrences inside a polygon described in Well Known Text (WKT) format. A WKT shape written as POLYGON ((30.1 10.1, 20, 20 40, 40 40, 30.1 10.1)) would be queried as is, i.e. http://bit.ly/HwUSif
#' @param rank Taxonomic rank. Not used right now.
#' @param type Type of name, sci (scientific) or com (common name, vernacular).
#' 	  Not used right now.		
#' @param gbifopts List of options to pass on to rgbif
#' @param bisonopts List of options to pass on to rbison
#' @param inatopts List of options to pass on to rinat
#' @param ebirdopts List of options to pass on to ebird
#' @param ecoengineopts List of options to pass on to ecoengine
#' @details The \code{occ} function is an opinionated wrapper
#' around the rgbif, rbison, rinat, rebird, and ecoengine packages to allow data 
#' access from a single access point. We take care of making sure you get useful 
#' objects out at the cost of flexibility/options - although you can still set 
#' options for each of the packages via the gbifopts, bisonopts, inatopts, 
#' ebirdopts, and ecoengineopts parameters.