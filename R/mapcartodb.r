#' Make an interactive map to view on CartoDB
#' 
#' @param data A data.frame with your data
#' @param tablename Table name in CartoDB to push data to
#' @param columns Columns in your data object to post to your table
#' @param username User name for CartoDB
#' @param key API key for CartoDB
#' @export
#' @examples \dontrun{
#' # Create an interactive map on CartoDB
#' ## Install CartoDB library
#' install_github('cartodb-r', 'Vizzuality', subdir='CartoDB')
#' library(CartoDB)
#' 
#' ## Get data for Puma concolor, the *hello, world* for biodiversity data
#' tmp <- occ(query='Puma concolor', from='gbif', gbifopts=list(limit=500, 
#'    georeferenced=TRUE, country='US'))
#' data <- occtodf(tmp, 'data')
#' 
#' ## Push data up to CartoDB 
#' ### I frist crated a table in my CartoDB account named `pumamap`. Then, I need to 
#' ### initialize the connection with CartoDB with my account name and API key. Note that 
#' ### I am pulling up my key from my .Rprofile file on my machine for ease and so it's 
#' ### not revealed to you :)
#' 
#' ### Now we need to push data to our `pumamap` table using the function \code{mapcartodb}
#' mapcartodb(data, 'pumamap', c('name','longitude','latitude'), 'recology')
#' }
mapcartodb <- function(data, tablename, columns, username = NULL, key = NULL) {
    if (is.null(username)) 
        stop("you must provide your username")
    if (is.null(key)) 
        key <- getOption("mycartodbkey", stop("no key provided"))
    cartodb(account.name = username, api.key = key)  # initialize connection
    rows <- apply(data, 1, as.list)
    lapply(rows, function(x) cartodb.row.insert(name = tablename, columns = columns, 
        values = x))
    message("huzzah! Rows written to your CartoDB table :)")
} 
