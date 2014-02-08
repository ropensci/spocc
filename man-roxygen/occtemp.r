#' @param query (character) One to many names. Either a scientific name or a common name.  
#' Specify whether a scientific or common name in the type parameter.
#' Only scientific names supported right now.
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' inat, ebird, and/or ecoengine
#' @param limit (numeric) Number of records to return. This is passed across all sources.
#' To specify different limits for each source, use the options for each source.
#' @param geometry (character) Searches for occurrences inside a polygon described in 
#' Well Known Text (WKT) format. A WKT shape written as 
#' 'POLYGON((30.1 10.1, 20, 20 40, 40 40, 30.1 10.1))' would be queried as is, 
#' i.e. http://bit.ly/HwUSif. See Details for more examples of WKT objects.
#' @param rank (character) Taxonomic rank. Not used right now.
#' @param type (character) Type of name, sci (scientific) or com (common name, vernacular).
#' Not used right now.		
#' @param gbifopts (list) List of options to pass on to rgbif
#' @param bisonopts (list) List of options to pass on to rbison
#' @param inatopts (list) List of options to pass on to rinat
#' @param ebirdopts (list) List of options to pass on to ebird
#' @param ecoengineopts (list) List of options to pass on to ecoengine
#' @details The \code{occ} function is an opinionated wrapper
#' around the rgbif, rbison, rinat, rebird, and ecoengine packages to allow data 
#' access from a single access point. We take care of making sure you get useful 
#' objects out at the cost of flexibility/options - although you can still set 
#' options for each of the packages via the gbifopts, bisonopts, inatopts, 
#' ebirdopts, and ecoengineopts parameters.
#' 
#' WKT objects are strings of pairs of lat/long coordinates that define a shape. Many classes
#' of shapes are supported, including POLYGON, POINT, and XXXX. Within each defined shape
#' define all vertices of the shape with a coordinate like 30.1 10.1, the first of which is the 
#' latitude, the second the longitude.
#' 
#' Examples of valid WKT objects:
#' \itemize{
#'  \item 'POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))'
#'  \item 'POINT((30.1 10.1))'
#'  \item 'LINESTRING(3 4,10 50,20 25)'
#'  \item 'MULTIPOINT((3.5 5.6),(4.8 10.5))")'
#'  \item 'MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))'
#'  \item 'MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2)),((6 3,9 2,9 4,6 3)))'
#'  \item 'GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))'
#' }