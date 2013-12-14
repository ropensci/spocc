#' @param rank Taxonomic rank.
#' @param from Data source to get data from, any combination of gbif, bison, or
#'    inat
#' @param type Type of name, sci (scientific) or com (common name, vernacular)
#' @param gbifopts List of options to pass on to rgbif
#' @param bisonopts List of options to pass on to rbison
#' @param inatopts List of options to pass on to rinat
#' @param ebirdopts List of options to pass on to ebird
#' @details The \code{occ} and \code{occlist} functions are opinionated wrappers 
#' around the rgbif, rbison, rinat, and rebird packages to allow data access from 
#' a single access point. We take care of making sure you get useful objects out 
#' at the cost of flexibility/options - if you need options you can use the functions
#' inside each of those packages.