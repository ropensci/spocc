#' Shiny visualization of species occurrences
#' 
#' @import shiny
#' @export
#' @return Opens a shiny app in your default browser
#' @examples \dontrun{
#' mapshiny()
#' }
mapshiny <- function() {
    message("Hit <escape> to stop")
    runApp(system.file("shiny", package = "spocc"))
} 
