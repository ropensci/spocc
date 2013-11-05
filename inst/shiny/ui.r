require(shiny)
require(rCharts)
library(spocc)

shinyUI(pageWithSidebar(
  
  headerPanel(title=HTML("spocc explorer"), windowTitle="Species occurrence data explorer"),
  
  sidebarPanel(
    
    HTML('<style type="text/css">
         .row-fluid .span4{width: 26%;}
         .leaflet {height: 600px; width: 830px;}
         </style>'),
    HTML('
         <style type="text/css">
         .btn-submit {float: left;}
         </style>'),
    includeHTML('egsmodal.html'),
    HTML('<button style="float: left;" type="submit" class="btn btn-primary">Submit</button><br><br>'),
    
#     HTML('<textarea id="spec" rows="3" cols="50">Carpobrotus,Rosmarinus,Ageratina</textarea>'),
    
    HTML('<textarea id="spec" rows="3" cols="50">Accipiter striatus,Bison bison,Pinus contorta</textarea>'),
    
    # Map options 
    h5(strong("Map options:")),
    # data source
    selectInput(inputId="datasource", label="Select data source", choices=c("GBIF","BISON","INATURALIST"), selected="BISON"),
    # number of occurrences for map
    sliderInput(inputId="numocc", label="Select max. number of occurrences to search for per species", min=0, max=500, value=50),
    # color palette for map
    selectInput(inputId="palette", label="Select color palette", 
                choices=c("Blues","BlueGreen","BluePurple","GreenBlue","Greens","Greys","Oranges","OrangeRed","PurpleBlue","PurpleBlueGreen","PurpleRed","Purples","RedPurple","Reds","YellowGreen","YellowGreenBlue","YlOrBr","YellowOrangeRed",
                          "BrownToGreen","PinkToGreen","PurpleToGreen","PurpleToOrange","RedToBlue","RedToGrey","RedYellowBlue","RedYellowGreen","Spectral"), selected="Blues"),
    selectInput('provider', 'Select map provider for interactive map', 
                choices = c("OpenStreetMap.Mapnik","OpenStreetMap.BlackAndWhite","OpenStreetMap.DE","OpenCycleMap","Thunderforest.OpenCycleMap","Thunderforest.Transport","Thunderforest.Landscape","MapQuestOpen.OSM","MapQuestOpen.Aerial","Stamen.Toner","Stamen.TonerBackground","Stamen.TonerHybrid","Stamen.TonerLines","Stamen.TonerLabels","Stamen.TonerLite","Stamen.Terrain","Stamen.Watercolor","Esri.WorldStreetMap","Esri.DeLorme","Esri.WorldTopoMap","Esri.WorldImagery","Esri.WorldTerrain","Esri.WorldShadedRelief","Esri.WorldPhysical","Esri.OceanBasemap","Esri.NatGeoWorldMap","Esri.WorldGrayCanvas","Acetate.all","Acetate.basemap","Acetate.terrain","Acetate.foreground","Acetate.roads","Acetate.labels","Acetate.hillshading"),
                selected = 'MapQuestOpen.OSM'
    )
  ),
  
  mainPanel(
    mapOutput('map_rcharts')
  )
))