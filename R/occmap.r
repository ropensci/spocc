#' Make a map of species occurrence data.
#' 
#' @examples \dontrun{
#' # Point map, using output from occurrencelist, example 1
#' out <- occ('Accipiter erythronemius', from = c('rgbif','bison'), maxresults = 100)
#' occmap(out)
#' }
#' @export
occmap <- function(input = NULL, mapdatabase = "world", region = ".", 
                     geom = geom_point, jitter = NULL, customize = NULL)
{
  # CODE BELOW FROM RGBIF PACKAGE, CHANGE AS NEEDED...
  
  long = NULL
  lat = NULL
  group = NULL
  decimalLongitude = NULL
  decimalLatitude = NULL
  taxonName = NULL
  
  if(!is.gbiflist(input))
    stop("Input is not of class gbiflist")
  
  input <- data.frame(input)
  input$decimalLatitude <- as.numeric(input$decimalLatitude)
  input$decimalLongitude <- as.numeric(input$decimalLongitude)
  
  tomap <- input[complete.cases(input$decimalLatitude, input$decimalLatitude), ]
  tomap <- input[-(which(tomap$decimalLatitude <=90 || tomap$decimalLongitude <=180)), ]
  tomap$taxonName <- as.factor(capwords(tomap$taxonName, onlyfirst=TRUE))
  
  if(length(unique(tomap$taxonName))==1){ theme2 <- theme(legend.position="none") } else 
  { theme2 <- NULL }
  
  world <- map_data(map=mapdatabase, region=region) # get world map data
  message(paste("Rendering map...plotting ", nrow(tomap), " points", sep=""))
  
  ggplot(world, aes(long, lat)) + # make the plot
    geom_polygon(aes(group=group), fill="white", color="gray40", size=0.2) +
    geom(data=tomap, aes(decimalLongitude, decimalLatitude, colour=taxonName), 
         alpha=0.4, size=3, position=jitter) +
    scale_color_brewer("", type="qual", palette=6) +
    labs(x="", y="") +
    theme_bw(base_size=14) +
    theme(legend.position = "bottom", legend.key = element_blank()) +
    guides(col = guide_legend(nrow=2)) +
    blanktheme() +
    theme2 + 
    customize
}