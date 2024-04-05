library(rio)

base_path <- "./wage rigidity/_data/_IRCMO/2009"

data <- import(paste(base_path, "/base-de-datos-enero-a-diciembre-de-2009.csv", sep = ""), dec=",")