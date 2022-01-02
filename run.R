library(plumber)

port <- Sys.getenv('PORT')

r <- plumb("./Recommendation.R")
r$run(port = port)
