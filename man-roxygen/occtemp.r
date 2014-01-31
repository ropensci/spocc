#' @param rank Taxonomic rank.
#' @param from Data source to get data from, any combination of gbif, bison,
#'    inat, ebird, and/or ecoengine
#' @param type Type of name, sci (scientific) or com (common name, vernacular)
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