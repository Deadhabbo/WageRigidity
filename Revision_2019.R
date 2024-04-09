# MONTHS <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
# 
# 
# base_path <- "./wage rigidity/_data/_IRCMO/2019"
# 
# for (month in MONTHS) {
#   
#   dir_path <- file.path(base_path, month)
#   print(sprintf("Folders and files of %s:", month))
#   file_list <- list.files(dir_path, full.names = TRUE)
#   
#   for (file in file_list) {
#     print(file)
#   }
#   cat("\n")
# }

MONTHS <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")

base_path <- "./wage rigidity/_data/_IRCMO/2019"

for (month in MONTHS) {
  
  dir_path <- file.path(base_path, month)
  sub_dirs <- list.dirs(dir_path, recursive = TRUE)
  
  cat("Directorio:", dir_path, "\n")
  
  for (sub_dir in sub_dirs) {
    file_list <- list.files(sub_dir, full.names = TRUE)
    cat("Subdirectorio:", sub_dir, "\n")
    cat("Archivos:", "\n")
    cat(file_list, "\n")
    cat("\n")
  }
}