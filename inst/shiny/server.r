require(shiny)
require(rCharts)
library(taxize)
library(spocc)

shinyServer(function(input, output){
  
  # factor out code common to all functions.
  species2 <- reactive({
    strsplit(input$spec, ",")[[1]]
  })
  
  occur_data <- reactive({
    rcharts_prep1(sppchar = input$spec, occurrs = input$numocc, datasource = input$datasource)
  })
  
  rcharts_data <- reactive({
    rcharts_prep2(occur_data(), palette_name = get_palette(input$palette), popup = TRUE)
  })
  
  output$map_rcharts <- renderMap({  
    imap = gbifmap2(input = rcharts_data(), input$provider)
    imap$legend(
      position = 'bottomright',
      colors = get_colors(species2(), get_palette(input$palette)),
      labels = species2()
    )
    imap
  })
  
})