##install.packages("RODBC")
###install.packages("odbc")
##library(RODBC)
library(odbc)
library(tidyverse)
library(data.table)

year <- 2019

months <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")

month_file <- c("Variables.mdb",
                "Variables.mdb",
                "Variables.csv",
                "Variables.csv",
                "Variables.csv",
                "Variables.csv",
                "Variables.csv",
                "Variables.csv",
                "Variables.csv",
                "Variables.csv",
                "Variables.csv",
                "variables.csv")

base_path <- "./wage rigidity/_data/_IRCMO"




dir_path <- file.path(base_path, as.character(year))


number_of_moths <- 1:12

stacked_df <- data.frame()

for (month_index in number_of_moths) {
  
  iteration_file_path <- file.path(dir_path, months[month_index], month_file[month_index])
  extension <- substr(iteration_file_path, nchar(iteration_file_path) - 2, nchar(iteration_file_path))
  month <- months[month_index]
  
  if (extension == "mdb") {
    print("aa")
  }
  
  else if (extension == "csv"){
    dir_path <- file.path(base_path, as.character(year), month)
    print(dir_path)
    
    variables <- fread(file.path(dir_path, "Variables.csv"), encoding = "Latin-1")
    ponderadores <- fread(file.path(dir_path, "Ponderadores.csv"), encoding = "Latin-1")
    
    colnames(variables) <- tolower(colnames(variables))
    colnames(ponderadores) <- tolower(colnames(ponderadores))
    
    variables_colnames <- colnames(variables)
    ponderadores_colnames <- colnames(ponderadores)
    
    if ("tama¤o" %in% variables_colnames) {
      variables_colnames <- variables_colnames %>%
        rename_with(~ gsub("tama¤o", "tamaño", .x), .cols = "tama¤o")
    }
    
    if ("a¤o" %in% variables_colnames) {
      variables_colnames <- variables_colnames %>%
        rename_with(~ gsub("a¤o", "año", .x), .cols = "a¤o")
    }
    
    if ("categor¡a" %in% variables_colnames) {
      variables_colnames <- variables_colnames %>%
        rename_with(~ gsub("categor¡a", "categoría", .x), .cols = "categor¡a")
    }
    
    if ("tama¤o" %in% ponderadores_colnames) {
      ponderadores_colnames <- ponderadores_colnames %>%
        rename_with(~ gsub("tama¤o", "tamaño", .x), .cols = "tama¤o")
    }
    
    if ("a¤o" %in% ponderadores_colnames) {
      ponderadores_colnames <- ponderadores_colnames %>%
        rename_with(~ gsub("a¤o", "año", .x), .cols = "a¤o")
    }
    
    if ("categor¡a" %in% ponderadores_colnames) {
      ponderadores_colnames <- ponderadores_colnames %>%
        rename_with(~ gsub("categor¡a", "categoría", .x), .cols = "categor¡a")
    }
    
    colnames(variables) <- variables_colnames
    colnames(ponderadores) <- ponderadores_colnames
    
    join_cols <- c("tamaño", "categoría", "sexo", "grupo")
    
    
    result <- inner_join(variables, ponderadores, by = join_cols)
    colnames(result) <- tolower(colnames(result))
    # previous_vars <- c("año", "id_empresa", "tamaño", "categoría", "división")
    # new_var_names <- c("anio", "id", "tamano", "categoria", "div")
    # print(colnames(result))
    # result <- result %>% rename_with(~ new_var_names, all_of(previous_vars))
    # result <- result %>% mutate(mes = month)  # Add the month column
    # 
    # # Convert relevant columns to double
    # result <- result %>% 
    #   mutate(across(c("ro", "ho", "c", "ht"), as.double))
    # 
    # result <- result[, c("anio", "mes", "id", "tamano", "categoria", "sexo", "grupo", "div", "ro", "ho", "c", "ht")]
    # 
    # write.table(result, file = file.path(base_path, as.character(year), sprintf("agrouped_%s.csv", month)), row.names = FALSE, quote = FALSE, sep = ";")
    # 
    # stacked_df <- bind_rows(stacked_df, result)
  }
  
  else
    print("Problems on path reading")
  # DataBase <- file.path(dir_path, months[month_index], month_file[month_index])
  # 
  # print(DataBase)
  # 
  # 
  # connection <- dbConnect(odbc::odbc(), Driver = "Microsoft Access Driver (*.mdb, *.accdb)",
  #                         DBQ = DataBase)
  # 
  # year_str <- as.character(year)
  # 
  # consult_instruction <- "
  #   SELECT Variables.*,
  #          Ponderadores.IR_Wtam,
  #          Ponderadores.IR_Wcat,
  #          Ponderadores.IR_Wsex,
  #          Ponderadores.IR_Wgru,
  #          Ponderadores.IR_Wi,
  #          Ponderadores.ICMO_Wtam,
  #          Ponderadores.ICMO_Wcat,
  #          Ponderadores.ICMO_Wsex,
  #          Ponderadores.ICMO_Wgru,
  #          Ponderadores.ICMO_Wi
  #   FROM Variables
  #   INNER JOIN Ponderadores ON Variables.Tamaño = Ponderadores.Tamaño
  #                           AND Variables.Categoría = Ponderadores.Categoría
  #                           AND Variables.Sexo = Ponderadores.Sexo
  #                           AND Variables.Grupo = Ponderadores.Grupo;
  # "
  # 
  # df <- dbGetQuery(connection, consult_instruction)
  # 
  # colnames(df) <- tolower(colnames(df))
  # print(colnames(df))
  # 
  # cols_to_drop = c("ro_t_1", "ho_t_1", "c_t_1", "ht_t_1")
  # 
  # df <- df[, !names(df) %in% cols_to_drop]
  # 
  # 
  # previous_vars <- c("año","id_empresa" ,"tamaño", "categoría", "división","ro", "ho", "ht", "c")
  # new_var_names <- c("anio", "id" ,"tamano", "categoria", "div", "ro", "ho", "ht", "c")
  # 
  # df <- df %>% rename_with(~new_var_names, all_of(previous_vars))
  # df <- df[, c("anio", "mes", "id", "tamano", "categoria", "sexo", "grupo", "div", "ro", "ho", "c", "ht")]
  # 
  # write.csv(df, file = file.path(dir_path, paste0(sprintf("2018_%s", months[month_index]), "_combined_r.csv")), row.names = FALSE, quote = FALSE)
  # dbDisconnect(connection)

}

# write.table(stacked_df, file = file.path(base_path, as.character(year), "2019_combined.csv"), row.names = FALSE, quote = FALSE, sep = ";")

