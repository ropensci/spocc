#' Style a data.frame prior to converting to geojson.
#'
#' @param input A data.frame
#' @param var A single variable to map colors, symbols, and/or sizes to.
#' @param var_col The variable to map colors to.
#' @param var_sym The variable to map symbols to.
#' @param var_size The variable to map size to.
#' @param color Valid RGB hex color
#' @param symbol An icon ID from the Maki project \url{http://www.mapbox.com/maki/} or
#'    a single alphanumeric character (a-z or 0-9).
#' @param size One of 'small', 'medium', or 'large'
#' @export
#' @seealso \code{\link{spocc_togeojson}}
spocc_stylegeojson <- function(input, var = NULL, var_col = NULL, var_sym = NULL,
    var_size = NULL, color = NULL, symbol = NULL, size = NULL) {
    if (!inherits(input, "data.frame"))
        stop("Your input object needs to be a data.frame")
    if (nrow(input) == 0)
        stop("Your data.frame has no rows...")
    if (is.null(var_col) & is.null(var_sym) & is.null(var_size))
        var_col <- var_sym <- var_size <- var
    if (!is.null(color)) {
        if (length(color) == 1) {
            color_vec <- rep(color, nrow(input))
        } else {
            mapping <- data.frame(var = unique(input[[var_col]]), col2 = color)
            stuff <- input[[var_col]]
            color_vec <- with(mapping, col2[match(stuff, var)])
        }
    } else {
        color_vec <- NULL
    }
    if (!is.null(symbol)) {
        if (length(symbol) == 1) {
            symbol_vec <- rep(symbol, nrow(input))
        } else {
            mapping <- data.frame(var = unique(input[[var_sym]]), symb = symbol)
            stuff <- input[[var_sym]]
            symbol_vec <- with(mapping, symb[match(stuff, var)])
        }
    } else {
        symbol_vec <- NULL
    }
    if (!is.null(size)) {
        if (length(size) == 1) {
            size_vec <- rep(size, nrow(input))
        } else {
            mapping <- data.frame(var = unique(input[[var_size]]), sz = size)
            stuff <- input[[var_size]]
            size_vec <- with(mapping, sz[match(stuff, var)])
        }
    } else {
        size_vec <- NULL
    }
    output <- do.call(cbind, sc(list(input, `marker-color` = color_vec, `marker-symbol` = symbol_vec,
        `marker-size` = size_vec)))
    return(output)
}


#' Convert spatial data files to GeoJSON from various formats.
#'
#' @export
#' @importFrom httr POST stop_for_status content upload_file
#' @param input The file being uploaded, path to the file on your machine.
#' @param destpath Destination for output geojson file. Defaults to your root
#'    directory ('~/').
#' @param outfilename The output file name, without file extension.
#' @description
#' We use the Ogre web API. Ogre currently has an output size limit of 15MB.
#' See here \url{http://ogre.adc4gis.com/} for info on the Ogre web API.
#'
#' Note that for Shapefiles, GML, MapInfo, and VRT, you need to send zip files
#' to Ogre. For other file types (.bna, .csv, .dgn, .dxf, .gxt, .txt, .json,
#' .geojson, .rss, .georss, .xml, .gmt, .kml, .kmz) you send the actual file with
#' that file extension.
#'
#' If you're having trouble rendering geoJSON files, ensure you have a valid
#' geoJSON file by running it through a geoJSON linter \url{http://geojsonlint.com/}.
#' @seealso \code{spocc_stylegeojson}
#' @examples \dontrun{
#' file <- '/Users/scottmac2/Downloads/taxon-placemarks-2441176.kml'
#'
#' # KML type file
#' spocc_togeojson(file, outfilename='kml_web')
#'
#' # Shp type file input is a zipped shp bundle
#' file <- '~/github/sac/bison.zip'
#' spocc_togeojson(file, outfilename='shp_web')
#'
#' # Get data and save map data
#' splist <- c('Accipiter erythronemius', 'Junco hyemalis', 'Aix sponsa')
#' keys <- sapply(splist, function(x) gbif_lookup(name=x, kingdom='plants')$speciesKey,
#'    USE.NAMES=FALSE)
#' out <- occ_search(keys, hasCoordinate=TRUE, limit=50, return='data')
#' dat <- ldply(out)
#' datgeojson <- spocc_stylegeojson(input=dat, var='name',
#'    color=c('#976AAE','#6B944D','#BD5945'), size=c('small','medium','large'))
#'
#' # Put into a github repo to view on the web
#' write.csv(datgeojson, '~/github/sac/mygeojson/rgbif_data.csv')
#' file <- '~/github/sac/mygeojson/rgbif_data.csv'
#' spocc_togeojson(file, destpath='~/github/sac/mygeojson/',
#'    outfilename='rgbif_data')
#'
#' # Using rCharts' function spocc_create_gist
#' write.csv(datgeojson, '~/my.csv')
#' file <- '~/my.csv'
#' spocc_togeojson(input=file, outfilename='my')
#' spocc_create_gist('~/my.geojson', description = 'Map of three bird species occurrences')
#' }
spocc_togeojson <- function(input, destpath = "~/", outfilename = "myfile") {
  url <- "http://ogre.adc4gis.com/convert"
  tt <- POST(url, body = list(upload = upload_file(input)))
  stop_for_status(tt)
  out <- content(tt, as = "text")
  fileConn <- file(paste0(destpath, outfilename, ".geojson"))
  writeLines(out, fileConn)
  close(fileConn)
  message(paste0("Success! File is at ", destpath, outfilename, ".geojson"))
}
