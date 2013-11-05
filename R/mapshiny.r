#' Shiny visualization of species occurrences
#' 
#' @export
#' @return Opens a shiny app in your default browser
#' @examples \dontrun{
#' mapshiny()
#' }
mapshiny <- function()
{
#   runApp("~/github/ropensci/spocc/inst/shinyrcharts/")
  message('Hit <escape> to stop')
  require(shiny)
  shiny::runApp(system.file('shiny', package='spocc'))
}