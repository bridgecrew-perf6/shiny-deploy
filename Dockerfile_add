FROM schnick/shiny_test_base:latest

## potentially replace some files...

# cd into package root
WORKDIR ./app

# for testing
ENV PORT=3838

# run app on container start (dynamic port allocation!)
CMD ["R", "-e", "shiny::runApp('run_app.R', host = '0.0.0.0', port = as.numeric(Sys.getenv('PORT')))"]