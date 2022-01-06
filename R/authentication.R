library(shiny)
library(shinyjs)
library(shinythemes)
library(tidyverse)


## create user base
## TODO: access from config
user_base_basic <- tibble(user_name = "daniel", password = "heimgartner")


# ui ----------------------------------------------------------------------
ui <- fluidPage(
  ## Register shinyjs
  useShinyjs(),
  
  ## Basic user form
  div(
    id = "login-basic", ## to be hidden with help of shinyjs!
    style = "width: 500px; max-width: 100%; margin: 0 auto;",
    
    div(
      class = "well",
      h4(class = "text-center", "Please login"),
      p(class = "text-center",
        tags$small("First approach login form")
      ),
      
      textInput("ti_user_name_basic",
                tagList(icon("user"),
                        "User Name"),
                placeholder = "Enter user name"),
      
      passwordInput("ti_password_basic",
                    tagList(icon("unlock-alt"),
                            "Password"),
                    placeholder = "Enter password"),
      
      div(
        class = "text-center",
        actionButton("ab_login_button_basic",
                     "Log in",
                     class = "btn-primary")
      )
    )
  ),
  
  ## Main app after access granted
  uiOutput("display_content_basic")
)



# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  ## validate reactive
  validate_password_basic <- eventReactive(input$ab_login_button_basic, {
    validate <- FALSE
    
    if (input$ti_user_name_basic %in% user_base_basic$user_name &&
        input$ti_password_basic == user_base_basic[user_base_basic$user_name == input$ti_user_name_basic, "password"]) {
      validate <- TRUE
    }
  })
  
  
  ## hide form
  observeEvent(validate_password_basic(), {
    shinyjs::hide(id = "login-basic") ## see comment in ui
  })
  
  
  ## show app ~ basically ui stuff...
  output$display_content_basic <- renderUI({
    req(validate_password_basic())
    
    div(
      class = "bg-success",
      id = "success_basic",
      h4("Access confirmed!"),
      p("Welcome to your basically-secured application")
    )
  })
}



# app ---------------------------------------------------------------------
shinyApp(ui, server)
