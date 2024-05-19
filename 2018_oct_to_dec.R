##install.packages("RODBC")
###install.packages("odbc")
##library(RODBC)
library(odbc)
library(tidyverse)


year <- 2018

months <- c("oct", "nov", "dic")
 
month_file <- c("Septiembre 2018 rectificado-octubre 2018 provisorio.mdb", "Variables.mdb", "Variables.mdb")

base_path <- "./wage rigidity/_data/_IRCMO"




dir_path <- file.path(base_path, as.character(year))


number_of_moths <- 1:3

for (month_index in number_of_moths) {
  
  
  DataBase <- file.path(dir_path, months[month_index], month_file[month_index])
  
  print(DataBase)
  

  connection <- dbConnect(odbc::odbc(), Driver = "Microsoft Access Driver (*.mdb, *.accdb)",
                          DBQ = DataBase)

  year_str <- as.character(year)
  
  consult_instruction <- "
    SELECT Variables.*,
           Ponderadores.IR_Wtam,
           Ponderadores.IR_Wcat,
           Ponderadores.IR_Wsex,
           Ponderadores.IR_Wgru,
           Ponderadores.IR_Wi,
           Ponderadores.ICMO_Wtam,
           Ponderadores.ICMO_Wcat,
           Ponderadores.ICMO_Wsex,
           Ponderadores.ICMO_Wgru,
           Ponderadores.ICMO_Wi
    FROM Variables
    INNER JOIN Ponderadores ON Variables.Tamaño = Ponderadores.Tamaño
                            AND Variables.Categoría = Ponderadores.Categoría
                            AND Variables.Sexo = Ponderadores.Sexo
                            AND Variables.Grupo = Ponderadores.Grupo;
  "

  df <- dbGetQuery(connection, consult_instruction)

  colnames(df) <- tolower(colnames(df))
  print(colnames(df))

  cols_to_drop = c("ro_t_1", "ho_t_1", "c_t_1", "ht_t_1")

  df <- df[, !names(df) %in% cols_to_drop]


  previous_vars <- c("año","id_empresa" ,"tamaño", "categoría", "división","ro", "ho", "ht", "c")
  new_var_names <- c("anio", "id" ,"tamano", "categoria", "div", "ro", "ho", "ht", "c")

  df <- df %>% rename_with(~new_var_names, all_of(previous_vars))
  df <- df[, c("anio", "mes", "id", "tamano", "categoria", "sexo", "grupo", "div", "ro", "ho", "c", "ht")]
  
  write.csv(df, file = file.path(dir_path, paste0(sprintf("2018_%s", months[month_index]), "_combined_r.csv")), row.names = FALSE, quote = FALSE)
  dbDisconnect(connection)

}

