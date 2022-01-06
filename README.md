# Hosting Shiny on Heroku using Docker

blobb

Some personal (non-conclusive) learning notes... Google is your friend!

**Keep calm and dockerize it** or something like that. My personal take-away (from this simple experiment) was that once the app runs in a container on your local machine it is straight forward to publish the app! I guess that's the beauty of containers - once they run, they run. I mean isn't that the point?


## Prerequisites

- Basic understanding for shiny framework (read https://mastering-shiny.org/)
- Docker installed
- Postgres installed
- Heroku CLI installed


## Some Resources

**Read the docs!** They usually know best what they are doing...

- Shiny:
  - Mastering Shiny: https://mastering-shiny.org/
  - Shiny extensions: https://github.com/nanxstats/awesome-shiny-extensions
- Docker:
  - Rscript in Docker container: https://www.youtube.com/watch?v=ARd5IldVFUs&t=3s&ab_channel=AndrewCouch
  - Shiny app in Docker container: https://www.statworx.com/blog/running-your-r-script-in-docker/
  - Short intro video (pointing to resources above): https://www.statworx.com/en/blog/how-to-dockerize-shinyapps/
- Heroku:
  - Really neat official documentation (try to do it from the CLI!)


## R Specifics

In the sense of "Things and packages you want to keep in mind when setting up a public shiny app...". Mainly a list of packages and some random remarks why they are useful.

**Build the shiny app as a Package!** And preferably write some tests! Leverage `usethis` and `devtools` (and...?) to set up the files (respectively the repo structure).


### authr

- Super easy user authentication - basic login form with few lines of code.
- I simply check the users against a list (hidden, i.e. contained in the `config.yml`) as my purpose is to invite people to survey. Could probably be easily extended with sign in form and stuff...


### config

- Allows you to manage paths and stuff you want to manage centrally (and hidden) in a `config.yml` which then can be imported in R with `config::config::get()`.
- **Don't share this with others!** I.e. include it in the `.gitignore` (don't track with git and don't push) and `.Rbuildignore` (don't embody in package)!

> However, does heroku push only include the files tracked by git??
> Obviously, your `config.yml` needs to be pushed to heroku too...
> See f.ex. here: https://stackoverflow.com/questions/50942102/using-gitignore-on-heroku
> Or: https://www.r-bloggers.com/2020/11/deploying-an-r-shiny-app-on-heroku-free-tier/


### renv

- `renv::init()` sets up blank library and keeps track when you install stuff with `install.packages()`.
- Makes it then easy to set up the dependency from within the `Dockerfile` (see Dockerfile for specifics).


### DBI and RPostgres

- `RPostgres` contains the driver (?) which you leverage in the `DBI` package (f.ex. by passing the `RPostgres` specific arguments in `dbConnect()`)
- Once the connection is established, I think you mainly use the `DBI` functionality (usually passing the connection as the first argument)...


### shinyjs

- Making the UI dynamic is probably a hustle without this...
- Can be used to **hide** stuff, etc.
- There exist other resources to improve user experience (see shiny extensions above)...


### Further Remarks

- You might want to consider packages for multipage UIs, e.g. the `brochure` package.
- Curated list of shiny extensions: https://github.com/nanxstats/awesome-shiny-extensions


## Pay Attention

- Docker sudo -> usergroup: When I tried to push the app to heroku I got a complain along the lines of "permission denied - login to Docker" or something like that. I've then added `$USER` to the docker group which now allows me to run docker commands without `sudo`. The error disappeared also but might have because of the next issue:
- `FROM in Dockerfile`: Having not yet understood the precise structure of Docker on your system I just realized, that locally I could build on top of a (private) image by specifying `FROM private-image`. However, when trying to push to heroku, this was no longer possible (as I think heroku tried to grab it from the Docker hub instead of my local image repo...).
- `.gitignore` `.Rbuildignore`: Don't push sensitive stuff to public (and don't include it in the script).
- unix tools in Dockerfile: When your image results in a running container on your local machine but during the build on remote an error results, it is most likely that the you need to add stuff to the unix environment (in `Dockerfile`, see first lines there). **Read the error message** (printed to your terminal)!
- Port specification (incl. heroku env variable): There's a difference between `RUN` and `CMD` in your Dockerfile! Use `shiny::runApp()` in your Dockerfile (you can also call a script calling a function calling `shiny::shinyApp()`)... Also you might have to set the `WORKDIR` appropriately! Now to the main point: When the container runs you can map (via the `-p` flag in `docker run`) the exposed port to your local port (or something like that). And you then can access the App via this local port in your browser. However, heroku sets this exposed port dynamically and publishes the port as an ENV variable. See `Dockerfile` for how to handle that!
- Heroku register psql and container: First, include a `heroku.yml` config in your root. Then (via the CLI) after project initialization you can somehow (google it) register that you are using a containerized solution. Also register your app using a postgres hobby plan.
- Navigate to your projects root when working with heroku: It is somehow magically linked to it without leaving traces in your repo?? However, it obviously requires internet connection to work with heroku CLI, right?


## Some Useful Commands

**`help` is usually the most usefull command!** If you don't know what's going on try `help` or `man` or append `--help` to your commands - it helps...

- R:
  - `usethis` and `devtools` stuff!
  - You can also add some badges and stuff with some package (forgot the name...)
  - etc.
- Docker:
  - navigate to the project dir first!
  - might have to run with sudo
  - `docker build -t <TAGNAME> .` (point!)
  - `docker run -d --rm -p -v <TAGNAME>` (flags!)
  - `docker container ls -a` (docker container id is also printed when run)
  - `docker stats`
  - `docker images`
  - `docker rmi <IMAGE>` (id or tag(?))
  - `docker logs <CONTAINER-ID` of running container.
  - etc.
- Heroku:
  - navigate to the project dir first!
  - git init, git add ., git commit -m "blobb"
  - `heroku create` (--stack=container)
  - `heroku stack:set container` (or with flag above)
  - `git push heroku master` (or whatever branchname you want to push)
  - `heroku addons:create heroku-postgresql:<PLAN_NAME>`
  - `heroku pg:info`
  - `heroku pg:credentials:url DATABASE` (primary database...)
  - `heroku pg:psql`
  - `heroku open`
  - etc.
- Postgres:
  - Get db creds
  - `\d` list tables
  - normal querying possible directly after `heroku pg:psql`!
  - etc.
  

## Further Remarks

- Setting up the Postgres db on heroku, I realized, that the actual DB is hosted on AWS. Having figured out the credentials (see above) it was actually easy to init the table (after having gone though the heroku specific app:addon thingy) from within R with the `DBI` package.
