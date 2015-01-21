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
