library(shiny)
library(shinyjs)
library(shinythemes)
library(tidyverse)

rm(list = ls())


## create user base
## TODO: access from config
user_base_module <- tibble(user_name = "daniel", password = "heimgartner")


# ui ----------------------------------------------------------------------
loginUI <- function(id, title) {
  
  ## Simplifies
  ns <- NS(id)
  
  ## module user form
  div(
    id = ns("login-hide"), ## to be hidden with help of shinyjs!
    style = "width: 500px; max-width: 100%; margin: 0 auto;",
    
    div(
      class = "well",
      h4(class = "text-center", title), ## function param!
      p(class = "text-center",
        tags$small("second approach login form")
      ),
      
      textInput(ns("ti_user_name_module"),
                tagList(icon("user"),
                        "User Name"),
                placeholder = "Enter user name"),
      
      passwordInput(ns("ti_password_module"),
                    tagList(icon("unlock-alt"),
                            "Password"),
                    placeholder = "Enter password"),
      
      div(
        class = "text-center",
        actionButton(ns("ab_login_button_module"),
                     "Log in",
                     class = "btn-primary")
      )
    )
  )
}


# server ------------------------------------------------------------------
loginServer <- function(id, user_base_module) {
  moduleServer(id, function(input, output, session) {
    
    ## validate reactive
    validate_password_module <- eventReactive(input$ab_login_button_module, {
      validate <- FALSE
      
      if (input$ti_user_name_module %in% user_base_module$user_name &&
          input$ti_password_module == user_base_module[user_base_module$user_name == input$ti_user_name_module, "password"]) {
        validate <- TRUE
      }
    })
    
    ## hide form
    observeEvent(validate_password_module(), {
      shinyjs::hide(id = "login-hide") ## see comment in ui
    })
    
    ## return
    reactive(validate_password_module())
    
  })
}


# app ---------------------------------------------------------------------
loginApp <- function() {
  ui <- fluidPage(
    ## register shinyjs here (not in module)
    useShinyjs(),
    
    loginUI("login", title = "Please log in"),
    
    ## Main app after access granted
    uiOutput("display_content_module")
  )
  
  server <- function(input, output, session) {
    access_granted <- loginServer("login", user_base_module)
    
    ## show app ~ basically ui stuff...
    output$display_content_module <- renderUI({
      
      req(access_granted())
      
      div(
        class = "bg-success",
        id = "success_module",
        h4("Access confirmed!"),
        p("Welcome to your secured application")
      )
    })
  }
  
  shinyApp(ui, server)
}


