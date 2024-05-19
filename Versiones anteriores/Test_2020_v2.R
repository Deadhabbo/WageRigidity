library(tidyverse)
library(data.table)



year <- 2020

months <- c("ene", "feb", "mar","abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")

base_path <- "./wage rigidity/_data/_IRCMO"

join_cols <- c("Tamano", "Categoria", "Sexo", "Grupo")

for (month in months) {
  
  dir_path <- file.path(base_path, as.character(year), month)
  print(dir_path)
  
  variables <- fread(file.path(dir_path, "Variables.csv"))
  ponderadores <- fread(file.path(dir_path, "Ponderadores.csv"))
  
  result <- inner_join(variables, ponderadores , by = join_cols)
  colnames(result) <- tolower(colnames(result))
  previous_vars <- c("ano","id_empresa" ,"tamano", "categoria", "division")
  new_var_names <- c("anio", "id" ,"tamano", "categoria", "div" )
  
  result <- result %>% rename_with(~new_var_names, all_of(previous_vars))
  result <- result[, c("anio", "mes", "id", "tamano", "categoria", "sexo", "grupo", "div", "ro", "ho", "c", "ht")]
  
  write.table(result, file = file.path(base_path, as.character(year), sprintf("agrouped_%s.csv", month)), row.names = FALSE, quote = FALSE, sep = ";")
}


stacked_df <- data.frame()
for (month in months) {
  temp_path <- file.path(base_path, as.character(year), sprintf("agrouped_%s.csv", month))
  print(temp_path)
  temp_df <- fread(temp_path, sep = ";", colClasses = c("integer", "integer", "integer", "integer", "character", rep("double", 7)))
  
  stacked_df <- bind_rows(stacked_df, temp_df)
}


