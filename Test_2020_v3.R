library(tidyverse)
library(data.table)

year <- 2020
months <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
base_path <- "./wage rigidity/_data/_IRCMO"
join_cols <- c("Tamano", "Categoria", "Sexo", "Grupo")

stacked_df <- data.frame()

for (month in months) {
  dir_path <- file.path(base_path, as.character(year), month)
  print(dir_path)
  
  variables <- fread(file.path(dir_path, "Variables.csv"))
  ponderadores <- fread(file.path(dir_path, "Ponderadores.csv"))
  
  result <- inner_join(variables, ponderadores, by = join_cols)
  colnames(result) <- tolower(colnames(result))
  previous_vars <- c("ano", "id_empresa", "tamano", "categoria", "division")
  new_var_names <- c("anio", "id", "tamano", "categoria", "div")
  
  result <- result %>% rename_with(~ new_var_names, all_of(previous_vars))
  result <- result %>% mutate(mes = month)  # Add the month column
  
  # Convert relevant columns to double
  result <- result %>% 
    mutate(across(c("ro", "ho", "c", "ht"), as.double))
  
  result <- result[, c("anio", "mes", "id", "tamano", "categoria", "sexo", "grupo", "div", "ro", "ho", "c", "ht")]
  
  write.table(result, file = file.path(base_path, as.character(year), sprintf("agrouped_%s.csv", month)), row.names = FALSE, quote = FALSE, sep = ";")
  
  stacked_df <- bind_rows(stacked_df, result)
}

# Optionally, write the final stacked dataframe to a file
write.table(stacked_df, file = file.path(base_path, as.character(year), "2020_combined.csv"), row.names = FALSE, quote = FALSE, sep = ";")

# Check the final stacked dataframe
print(head(stacked_df))
