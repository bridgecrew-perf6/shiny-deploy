# library(shiny)
# library(shinysurveys)
# library(shinyjs)
# library(shinyauthr)
# library(bslib)
# library(dplyr)
# library(config)
# 
# 
# rm(list = ls())


#### Proceed ####
# Understand shinyjs
# Save to database with custom_id = login credentials
# Host app (docker -> see golem) and test
# Clone individual functions: https://github.com/jdtrat/shinysurveys/blob/main/R/func_survey-output.R



## javascript can be found here: ~/R/x86_64-pc-linux-gnu-library/3.6/shinysurveys
# shinysurveys::demo_survey_multipage()


## Neat: you can use shinyjs::hide() and other functions such as declaring mandatory fields
help(package = "shinyjs")

#' shiny test app
#'
#' @param ... not used as of now
#'
#' @return
#' @export
#'
#' @import shiny
surveyApp <- function(...) {
  ## Load config
  conf <- config::get()
  user_base <- dplyr::tibble(user = as.character(unlist(conf$user)), ## otherwise \n
                             password = as.character(unlist(conf$password)))
  
  
  ?shinysurveys::teaching_r_questions
  ## page col can be added for multipage survey
  ## matrix questions (item batteries) are also available
  questions <- shinysurveys::teaching_r_questions 
  
  
  # ui ----------------------------------------------------------------------
  ui <- shiny::fluidPage(
    # theme = bslib::bs_theme(bootswatch = "darkly"),
    
    shinyauthr::loginUI("login"),
    
    uiOutput("survey")
  )
  
  
  # server ------------------------------------------------------------------
  server <- function(input, output, session) {
    
    credentials <- shinyauthr::loginServer(id = "login",
                                           data = user_base,
                                           user_col = "user",
                                           pwd_col = "password")
    
    output$survey <- renderUI({
      if (credentials()$user_auth) {
        shinysurveys::surveyOutput(df = questions,
                                   survey_title = NULL,
                                   survey_description = NULL,
                                   theme = "white")
      }
    })
    
    observeEvent(credentials(), {
      if (credentials()$user_auth) shinysurveys::renderSurvey()
    })
    
    ## getSurveyData
    observeEvent(input$submit, {
      # browser()
      df_db <<- shinysurveys::getSurveyData(custom_id = credentials()$info[["user"]])
      ?shinysurveys::getSurveyData
      ## write to database here
      ## TODO: implement credentials in response_to_db()
      response <- df_db %>% dplyr::mutate(across(everything(), as.character))
      # response_to_db(response = response)
      message("Writing to database:\n---\n", paste0(capture.output(response), collapse = "\n"))
      
      showModal(modalDialog(
        title = "Thanks for your participation",
        "You can now close the browser!"
      ))
    })
  }
  
  
  # app ---------------------------------------------------------------------
  shiny::shinyApp(ui = ui, server = server)
  
}

