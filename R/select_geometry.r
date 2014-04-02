select_geometry <- function(x, iter.max = 10,
                            algorithm = c("Hartigan-Wong", "Lloyd", "Forgy",
                                          "MacQueen")) {
  if (!require("shiny"))
    stop("Please install the shiny package and try again")
  
  if (ncol(x) != 2)
    stop("ikmeans only works on 2-dimensional data")
  
  shiny::runApp(list(
    ui = basicPage(
      plotOutput("plot", clickId = "newCenter"),
      actionButton("ok", "Accept"),
      actionButton("undo", "Undo"),
      actionButton("cancel", "Cancel")
    ),
    server = function(input, output, session) {
      values <- reactiveValues(centers = matrix(numeric(), 0, 2))
      
      retvalues <- reactive({
        values$centers
      })
      
      clusters <- reactive({
        if (nrow(values$centers) < 2)
          return(NULL)
        kmeans(x, values$centers)
      })
      
      output$plot <- renderPlot({
        colors <- if(is.null(clusters()))
          1
        else
          clusters()$cluster
        
        plot(x, col = colors)
        points(clusters()$centers, col = 1:nrow(values$centers), pch = 8)
        points(values$centers, col = 1:nrow(values$centers), pch = 9)
      })
      
      observe({
        if (is.null(input$newCenter))
          return()
        isolate({
          newCenter <- matrix(c(input$newCenter[['x']], input$newCenter[['y']]),
                              1, 2)
          values$centers <- rbind(values$centers, newCenter)
        })
      })
      
      observe({
        if (input$ok == 0)
          return()
        stopApp(retvalues())
      })
      
      observe({
        if (input$cancel == 0)
          return()
        stopApp(NULL)
      })
      
      observe({
        if (input$undo == 0)
          return()
        isolate({
          if (nrow(values$centers) > 2)
            values$centers <- values$centers[-nrow(values$centers),]
          else if (nrow(values$centers) == 2)
            values$centers <- matrix(values$centers[1,], 1, 2)
          else if (nrow(values$centers) == 1)
            values$centers <- matrix(numeric(), 0, 2)
        })
      })
    }
  ))
}