## TODO:
# config
# adjust app
# commit
# update heroku
# test


#' Init psql table from data.frame
#'
#' @param credentials from config
#' @param db_table psql table name
#' @param df df (serves as template)
#'
#' @return
#' @export
#'
#' @examples
#' \donotrun{
#' init_table_from_df(credentials = config$get()$credentials, name = "shiny_survey", df = df_db)
#' }
init_table_from_df <- function(credentials, db_table, df) {
  
  con <- DBI::dbConnect(RPostgres::Postgres(),
                        dbname = credentials$dbname,
                        host = credentials$host,
                        user = credentials$user,
                        port = credentials$port,
                        password = credentials$password,
  )
  
  DBI::dbCreateTable(conn = con, name = db_table, fields = df)
  
  ## check
  if (!(db_table %in% DBI::dbListTables(con))) stop("Table does not exist!")
  
  ## stop connection
  DBI::dbDisconnect(con)
  
  cat("Table ", db_table, " initialized\n")
  
}
