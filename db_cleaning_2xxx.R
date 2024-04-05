##install.packages('here')
##install.packages("tidyverse")
##install.packages("rio")
##install.packages("dplyr")

##library(here)
library(rio)

base_path <- "./wage rigidity/_data/_IRCMO/2007"

data <- import(paste(base_path, "/EERCMO2007.csv", sep = ""), dec=",")

for (column in names(data)) {
  if (column != "Factor_Expansion_Tamano"){
    data[[column]] <- gsub("\\.", "", data[[column]])
    }
  
}

colnames(data)[1:7] <- c("id", "seccion", "div", "tamano", "factor_expansion", "grupo", "sexo")
names(data) <- trimws(tolower(names(data)))

data$ro <- as.double(data$ro)
data$ro <- ifelse(is.na(data$ro), 0, data$ro)

numerator <- as.double(data$ro * data$factor_expansion)
print(typeof(numerator[4]))
denominator <- sum(numerator)

data$pondw <- numerator / denominator

col_to_exclude <- c("ro", "re", "c", "ho", "he", "ht", "nt")

final_data <- data[, colnames(data)[!colnames(data) %in% col_to_exclude]]


str(data)
str(final_data)

write.csv(final_data, paste(base_path, "/2007_ponderadores_r.csv", sep = ""), row.names = TRUE, quote = FALSE)