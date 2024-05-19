library(tidyverse)
library(data.table)

years <- 2010:2015

# Base path for data
base_path <- "./wage rigidity/_data/_IRCMO"


df_2009_path <- paste(base_path, "/2009/2009_combined_r.csv", sep = "")

combined <- fread(df_2009_path, sep = ";")
str(combined)

for (year in years) {
  df_2_path_prev <- sprintf("/%d/%d_combined_r.csv", year, year)
  df_2_path <- paste(base_path, df_2_path_prev, sep = "")
  df_to_add <- fread(df_2_path, sep = ";")
  combined <- rbind(combined, df_to_add)
}

write.table(combined, file = file.path(base_path, "Base_Anual_2009/combined_2009.csv"), row.names = FALSE, quote = FALSE, sep = ";")
