MONTHS <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")


base_path <- "./wage rigidity/_data/_IRCMO/2019"

for (month in MONTHS) {
  
  dir_path <- file.path(base_path, month)
  print(sprintf("Folders and files of %s:", month))
  file_list <- list.files(dir_path, full.names = TRUE)
  
  for (file in file_list) {
    print(file)
  }
  cat("\n")
}