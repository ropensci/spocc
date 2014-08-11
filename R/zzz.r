#' Capitalize the first letter of a character string.
#'
#' @param s A character string
#' @param strict Should the algorithm be strict about capitalizing. Defaults to FALSE.
#' @param onlyfirst Capitalize only first word, lowercase all others. Useful for
#' taxonomic names.
#' @examples  \dontrun{
#' capwords(c('using AIC for model selection'))
#' capwords(c('using AIC for model selection'), strict=TRUE)
#' }
#' @export
#' @keywords internal
spocc_capwords <- function(s, strict = FALSE, onlyfirst = FALSE) {
    cap <- function(s) paste(toupper(substring(s, 1, 1)), {
        s <- substring(s, 2)
        if (strict)
            tolower(s) else s
    }, sep = "", collapse = " ")
    if (!onlyfirst) {
        vapply(strsplit(s, split = " "), cap, "", USE.NAMES = !is.null(names(s)))
    } else {
        vapply(s, function(x) paste(toupper(substring(x, 1, 1)), tolower(substring(x,
            2)), sep = "", collapse = " "), "", USE.NAMES = F)
    }
}
#' Code based on the `gbifxmlToDataFrame` function from dismo package
#' (http://cran.r-project.org/web/packages/dismo/index.html),
#' by Robert Hijmans, 2012-05-31, License: GPL v3
#' @import XML
#' @param doc A parsed XML document.
#' @param format Format to use.
#' @export
#' @keywords internal
spocc_gbifxmlToDataFrame <- function(doc, format) {
    nodes <- getNodeSet(doc, "//to:TaxonOccurrence")
    if (length(nodes) == 0)
        return(data.frame())
    if (!is.null(format) & format == "darwin") {
        varNames <- c("occurrenceID", "country", "stateProvince", "county", "locality",
            "decimalLatitude", "decimalLongitude", "coordinateUncertaintyInMeters",
            "maximumElevationInMeters", "minimumElevationInMeters", "maximumDepthInMeters",
            "minimumDepthInMeters", "institutionCode", "collectionCode", "catalogNumber",
            "basisOfRecordString", "collector", "earliestDateCollected", "latestDateCollected",
            "gbifNotes")
    } else {
        varNames <- c("occurrenceID", "country", "decimalLatitude", "decimalLongitude",
            "catalogNumber", "earliestDateCollected", "latestDateCollected")
    }
    dims <- c(length(nodes), length(varNames))
    ans <- as.data.frame(replicate(dims[2], rep(as.character(NA), dims[1]), simplify = FALSE),
        stringsAsFactors = FALSE)
    names(ans) <- varNames
    for (i in seq(length = dims[1])) {
        ans[i, 1] <- xmlAttrs(nodes[[i]])[["gbifKey"]]
        ans[i, -1] <- xmlSApply(nodes[[i]], xmlValue)[varNames[-1]]
    }
    nodes <- getNodeSet(doc, "//to:Identification")
    varNames <- c("taxonName")
    dims <- c(length(nodes), length(varNames))
    tax <- as.data.frame(replicate(dims[2], rep(as.character(NA), dims[1]), simplify = FALSE),
        stringsAsFactors = FALSE)
    names(tax) <- varNames
    for (i in seq(length = dims[1])) {
        tax[i, ] <- xmlSApply(nodes[[i]], xmlValue)[varNames]
    }
    cbind(tax, ans)
}
#' Coerces data.frame columns to the specified classes
#'
#' @param d A data.frame.
#' @param colClasses A vector of column attributes, one of:
#'    numeric, factor, character, etc.
#' @examples  \dontrun{
#' dat <- data.frame(xvar = seq(1:10), yvar = rep(c('a','b'),5)) # make a data.frame
#' str(dat)
#' str(colClasses(dat, c('factor','factor')))
#' }
#' @export
#' @keywords internal
spocc_colClasses <- function(d, colClasses) {
    colClasses <- rep(colClasses, len = length(d))
    d[] <- lapply(seq_along(d), function(i) switch(colClasses[i], numeric = as.numeric(d[[i]]),
        character = as.character(d[[i]]), Date = as.Date(d[[i]], origin = "1970-01-01"),
        POSIXct = as.POSIXct(d[[i]], origin = "1970-01-01"), factor = as.factor(d[[i]]),
        as(d[[i]], colClasses[i])))
    d
}
#' Convert commas to periods in lat/long data
#'
#' @param dataframe A data.frame
#' @export
#' @keywords internal
spocc_commas_to_periods <- function(dataframe) {
    dataframe$decimalLatitude <- gsub("\\,", ".", dataframe$decimalLatitude)
    dataframe$decimalLongitude <- gsub("\\,", ".", dataframe$decimalLongitude)
    return(dataframe)
}
#' Parse results from call to occurrencelist endpoint
#'
#' @param x A list
#' @param ... Further args passed on to gbifxmlToDataFrame
#' @param removeZeros remove zeros or not
#' @export
#' @keywords internal
spocc_parseresults <- function(x, ..., removeZeros = removeZeros) {
    df <- gbifxmlToDataFrame(x, ...)
    if (nrow(df[!is.na(df$decimalLatitude), ]) == 0) {
        return(df)
    } else {
        df <- commas_to_periods(df)
        df_num <- df[!is.na(df$decimalLatitude), ]
        df_nas <- df[is.na(df$decimalLatitude), ]
        df_num$decimalLongitude <- as.numeric(df_num$decimalLongitude)
        df_num$decimalLatitude <- as.numeric(df_num$decimalLatitude)
        i <- df_num$decimalLongitude == 0 & df_num$decimalLatitude == 0
        if (removeZeros) {
            df_num <- df_num[!i, ]
        } else {
            df_num[i, "decimalLatitude"] <- NA
            df_num[i, "decimalLongitude"] <- NA
        }
        temp <- rbind(df_num, df_nas)
        return(temp)
    }
}
#' Custom ggplot2 theme
#' @import ggplot2 grid
#' @export
#' @keywords internal
spocc_blanktheme <- function() {
    theme(axis.line = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank(),
        axis.ticks = element_blank(), axis.title.x = element_blank(), axis.title.y = element_blank(),
        panel.background = element_blank(), panel.border = element_blank(), panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), plot.background = element_blank(), plot.margin = rep(unit(0,
            "null"), 4))
}
#' Combine results from occ calls to a single data.frame
#' @param obj Input from occ
#' @param what One of data (default) or all (with metadata)
#' @export
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE))
#' occ2df(out)
#' }
occ2df <- function(obj, what = "data") {
    what <- match.arg(what, choices = c("all", "data"))
    foolist <- function(x) data.frame(rbindlist(x$data), stringsAsFactors = FALSE)
    aa <- foolist(obj$gbif)
    bb <- foolist(obj$bison)
    cc <- foolist(obj$inat)
    dd <- foolist(obj$ebird)
    ee <- foolist(obj$ecoengine)
    aw <- foolist(obj$antweb)
    tmp <- data.frame(rbindlist(list(
      data.frame(name = aa$name, longitude = aa$decimalLongitude, latitude = aa$decimalLatitude, prov = aa$prov),
      data.frame(name = bb$name, longitude = bb$decimalLongitude, latitude = bb$decimalLatitude, prov = bb$prov),
      data.frame(name = cc$name, longitude = cc$Longitude, latitude = cc$Latitude, prov = cc$prov),
      data.frame(name = dd$name, longitude = dd$lng, latitude = dd$lat, prov = dd$prov),
      data.frame(name = ee$name, longitude = ee$longitude, latitude = ee$latitude, prov = ee$prov),
      data.frame(name = aw$name, longitude = aw$decimal_longitude, latitude = aw$decimal_latitude, prov = aw$prov))))
    tmpout <- list(meta = list(obj$gbif$meta, obj$bison$meta, obj$inat$meta, obj$ebird$meta,
        obj$ecoengine$meta, obj$aw$meta), data = tmp)
    if (what %in% "data")
        tmpout$data else tmpout
}
#' Occ output or data.frame to sp SpatialPointsDataFrame class
#'
#' @import sp assertthat
#' @param input Output from \code{\link{occ}} or a data.frame
#' @details Note that you must have a column named latitude and a column named
#' longitude - any additional columns are fine, but those two columns must exist.
#' If you are using \code{\link{occ}} this will be done for you as you pass in the
#' output of occ as an occdat class, but if you pass in a data.frame you should check
#' this.
#' @export
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE))
#'
#' # pass in output of occ directly to occ2sp
#' occ2sp(out)
#'
#' # or make a data.frame first, then pass in
#' mydf <- occ2df(out)
#' occ2sp(mydf)
#' }
occ2sp <- function(input) {
    # check class
    assert_that(is(input, "occdat") | is(input, "data.frame"))
    dat <- switch(class(input), occdat = occ2df(input), data.frame = input)
    # check column names
    assert_that(all(c("latitude", "longitude") %in% names(dat)))
    # convert to SpatialPointsDataFrame object
    coordinates(dat) <- c("latitude", "longitude")
    return(dat)
}

#' Convert a bounding box to a Well Known Text polygon, and a WKT to a bounding box
#'
#' @import rgeos
#' @param minx Minimum x value, or the most western longitude
#' @param miny Minimum y value, or the most southern latitude
#' @param maxx Maximum x value, or the most eastern longitude
#' @param maxy Maximum y value, or the most northern latitude
#' @param bbox A vector of length 4, with the elements: minx, miny, maxx, maxy
#' @return bbox2wkt returns an object of class charactere, a Well Known Text string
#' of the form 'POLYGON((minx miny, maxx miny, maxx maxy, minx maxy, minx miny))'.
#'
#' wkt2bbox returns a numeric vector of length 4, like c(minx, miny, maxx, maxy).
#' @export
#' @examples \dontrun{
#' # Convert a bounding box to a WKT
#'
#' ## Pass in a vector of length 4 with all values
#' mm <- bbox2wkt(bbox=c(38.4,-125.0,40.9,-121.8))
#' plot(e)
#'
#' ## Or pass in each value separately
#' mm <- bbox2wkt(minx=38.4, miny=-125.0, maxx=40.9, maxy=-121.8)
#' plot(readWKT(mm))
#'
#' ========================================
#'
#' # Convert a WKT object to a bounding box
#' wkt <- "POLYGON((38.4 -125,40.9 -125,40.9 -121.8,38.4 -121.8,38.4 -125))"
#' wkt2bbox(wkt)
#' }

bbox2wkt <- function(minx=NA, miny=NA, maxx=NA, maxy=NA, bbox=NULL){
  if(is.null(bbox)) bbox <- c(minx, miny, maxx, maxy)

  assert_that(length(bbox)==4) #check for 4 digits
  assert_that(noNA(bbox)) #check for NAs
  assert_that(is.numeric(as.numeric(bbox))) #check for numeric-ness
  paste('POLYGON((',
        sprintf('%s %s',bbox[1],bbox[2]), ',', sprintf(' %s %s',bbox[3],bbox[2]), ',',
        sprintf(' %s %s',bbox[3],bbox[4]), ',', sprintf(' %s %s',bbox[1],bbox[4]), ',',
        sprintf(' %s %s',bbox[1],bbox[2]),
        '))', sep="")
}

#' @param wkt A Well Known Text object.
#' @export
#' @rdname bbox2wkt

wkt2bbox <- function(wkt=NULL){
  assert_that(!is.null(wkt))
  tmp <- bbox(readWKT(wkt))
  as.vector(tmp)
}

spocc_trunc_mat <- function(x, n = NULL){
  rows <- nrow(x)
  if (!is.na(rows) && rows == 0)
    return()
  if (is.null(n)) {
    if (is.na(rows) || rows > 100) { n <- 10 }
    else { n <- rows }
  }
  df <- as.data.frame(head(x, n))
  if (nrow(df) == 0)
    return()
#   is_list <- vapply(df, is.list, logical(1))
#   df[is_list] <- lapply(df[is_list], function(x) vapply(x, spocc_obj_type, character(1)))
  mat <- format(df, justify = "left")
  width <- getOption("width")
  values <- c(format(rownames(mat))[[1]], unlist(mat[1, ]))
  names <- c("", colnames(mat))
  w <- pmax(nchar(values), nchar(names))
  cumw <- cumsum(w + 1)
  too_wide <- cumw[-1] > width
  if (all(too_wide)) {
    too_wide[1] <- FALSE
    df[[1]] <- substr(df[[1]], 1, width)
  }
  shrunk <- format(df[, !too_wide, drop = FALSE])
  needs_dots <- is.na(rows) || rows > n
  if (needs_dots) {
    dot_width <- pmin(w[-1][!too_wide], 3)
    dots <- vapply(dot_width, function(i) paste(rep(".", i), collapse = ""), FUN.VALUE = character(1))
    shrunk <- rbind(shrunk, .. = dots)
  }
  print(shrunk)
  if (any(too_wide)) {
    vars <- colnames(mat)[too_wide]
    types <- vapply(df[too_wide], spocc_type_sum, character(1))
    var_types <- paste0(vars, " (", types, ")", collapse = ", ")
    cat(spocc_wrap("Variables not shown: ", var_types), "\n", sep = "")
  }
}

spocc_wrap <- function (..., indent = 0, width = getOption("width")){
  x <- paste0(..., collapse = "")
  wrapped <- strwrap(x, indent = indent, exdent = indent + 5, width = width)
  paste0(wrapped, collapse = "\n")
}

#' Type summary
#' @export
#' @keywords internal
spocc_type_sum <- function (x) UseMethod("spocc_type_sum")

#' @method spocc_type_sum default
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.default <- function (x) unname(abbreviate(class(x)[1], 4))

#' @method spocc_type_sum character
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.character <- function (x) "chr"

#' @method spocc_type_sum Date
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.Date <- function (x) "date"

#' @method spocc_type_sum factor
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.factor <- function (x) "fctr"

#' @method spocc_type_sum integer
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.integer <- function (x) "int"

#' @method spocc_type_sum logical
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.logical <- function (x) "lgl"

#' @method spocc_type_sum array
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.array <- function (x){
  paste0(NextMethod(), "[", paste0(dim(x), collapse = ","),
         "]")
}

#' @method spocc_type_sum matrix
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.matrix <- function (x){
  paste0(NextMethod(), "[", paste0(dim(x), collapse = ","),
         "]")
}

#' @method spocc_type_sum numeric
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.numeric <- function (x) "dbl"

#' @method spocc_type_sum POSIXt
#' @export
#' @rdname spocc_type_sum
spocc_type_sum.POSIXt <- function (x) "time"

spocc_obj_type <- function (x)
{
  if (!is.object(x)) {
    paste0("<", spocc_type_sum(x), if (!is.array(x))
      paste0("[", length(x), "]"), ">")
  }
  else if (!isS4(x)) {
    paste0("<S3:", paste0(class(x), collapse = ", "), ">")
  }
  else {
    paste0("<S4:", paste0(is(x), collapse = ", "), ">")
  }
}
