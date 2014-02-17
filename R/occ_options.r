#' Look up options for parameters passed to each source
#' 
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' inat, ebird, AntWeb, and/or ecoengine
#' @return Opens up the documentation for the function that is used internally within 
#' the occ function for each source. Any of the parameters passed to e.g. occ_search()
#' from the rgbif package can be passed in the associated gbifopts list in occ()
#' @export
#' @examples
#' occ_options()
#' occ_options('ecoengine')

occ_options <- function(from = 'gbif'){
  switch(from, 
         gbif = help('occ_search', package = "rgbif"),
         bison = help('bison', package = "rbison"),
         inat = help('get_inat_obs', package = "rinat"),
         ebird = help('ebirdregion', package = "rebird"),
         ecoengine = help('ee_observations', package = "ecoengine"))
         antweb = help('aw_data', package = "AntWeb")
}

# getauthors <- function(package){
#   db <- tools::Rd_db(package)
# #   authors <- 
# # tags <- tools:::RdTags(names(db)[grep("occ_search", names(db))])
# bb <- db[grep("occ_search", names(db))]
# if("\\arguments" %in% bb){
#   # return a crazy list of results
#   #out <- x[which(tmp=="\\author")]
#   # return something a little cleaner
#   out <- paste(unlist(x[which(tags=="\\arguments")]),collapse="")
# }
# else
#   out <- NULL
# invisible(out)
# #   gsub("\n","",unlist(authors)) # further cleanup
# # }
# 
# getauthors(package='rgbif')