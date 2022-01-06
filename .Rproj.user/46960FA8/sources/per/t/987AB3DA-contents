# library(DBI)
# library(RPostgres)

# https://shiny.rstudio.com/articles/overview.html


#### Removed..........
## Added postgreSQL
## User: shiny
## sudo -i -u shiny
## psql

## created shiny_survey table

## SELECT * FROM shiny_survey;
#### ................

#' write response to database
#'
#' @param credentials to connect to db (preferably from config.yml)
#' @param db_table table name in postgres database
#' @param response data to write (data.frame)
#'
#' @return
#' @export
response_to_db <- function(credentials = NULL, db_table = "shiny_survey", response) {
  
  ## establish connection (pass credentials to dbConnect)
  con <- DBI::dbConnect(RPostgres::Postgres())
  
  ## check if table exists
  if (!(db_table %in% DBI::dbListTables(con))) stop("Table does not exist!")
  
  ## write to db
  DBI::dbAppendTable(con, db_table, response)
  
  ## stop connection
  DBI::dbDisconnect(con)
  
}
