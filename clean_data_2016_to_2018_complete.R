##install.packages("RODBC")
###install.packages("odbc")
##library(RODBC)
library(odbc)
library(tidyverse)



years <- 2016:2018
base_path <- "./wage rigidity/_data/_IRCMO"

dir_path <- file.path(base_path, as.character(2016))

DataBase <- list.files(dir_path, pattern = "Rectificada.MDB", full.names = TRUE)

print(DataBase)



connection <- dbConnect(odbc::odbc(), Driver = "Microsoft Access Driver (*.mdb, *.accdb)",
                        DBQ = DataBase)


for (yy in years) {
  
  
  year_str <- as.character(yy)
  consult_instruction <-sprintf("SELECT Año_%s.*, 
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
FROM Año_%s
INNER JOIN Ponderadores ON Año_%s.Tamaño = Ponderadores.Tamaño
                      AND Año_%s.Categoría = Ponderadores.Categoría
                      AND Año_%s.Sexo = Ponderadores.Sexo
                      AND Año_%s.Grupo = Ponderadores.Grupo;", year_str, year_str, year_str, year_str, year_str, year_str)
  
  df <- dbGetQuery(connection, consult_instruction)
  
  colnames(df) <- tolower(colnames(df))


  cols_to_drop = c("ro_t_1", "ho_t_1", "c_t_1", "ht_t_1")

  df <- df[, !names(df) %in% cols_to_drop]


  previous_vars <- c("año","id_empresa" ,"tamaño", "categoría", "división","ro_t", "ho_t", "ht_t", "c_t")
  new_var_names <- c("anio", "id" ,"tamano", "categoria", "div", "ro", "ho", "ht", "c")

  df <- df %>% rename_with(~new_var_names, all_of(previous_vars))
  df <- df[, c("anio", "mes", "id", "tamano", "categoria", "sexo", "grupo", "div", "ro", "ho", "c", "ht")]

  write.csv(df, file = file.path(dir_path, paste0(yy, "_combined_r.csv")), row.names = FALSE, quote = FALSE)

}

dbDisconnect(connection)