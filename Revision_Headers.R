library(tidyverse)
library(rio)
# Define the years, months, and the variable names of interest
years <- 2009:2015
MONTHS <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
VARS_OF_INTEREST <- c("ro", "ho", "re", "he", "c", "nt")
MONTHS_DICT <- setNames(sprintf("%02d", 1:12), tolower(MONTHS)) ## Previous %02d
##print(months_dict)
# Base path for your data
base_path <- "./wage rigidity/_data/_IRCMO"

# # Function to rename columns
rename_month_columns <- function(data_frame) {
  # Create a vector to map month names to numbers
  months <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
  
  # Get the names of the dataframe columns
  column_names <- names(data_frame)
  
  # Iterate over column names
  for (col_name in column_names) {
    # Check if the column name contains a month in parentheses
    if (grepl("\\(.*\\)", col_name)) {
      # Extract the month name inside parentheses
      month <- gsub(".*\\((.*)\\).*", "\\1", col_name)
      # Get the corresponding month number
      num_month <- match(tolower(month), tolower(months))
      # Format the month number with leading zero if it's less than 10
      formatted_month <- sprintf("%02d", num_month)
      # Rename the column, removing spaces before adding the month number
      new_name <- gsub("\\s+", "", gsub("\\(.*\\)", paste0("_", formatted_month), col_name))
      names(data_frame)[names(data_frame) == col_name] <- new_name
    }
  }
  return(data_frame)
}


for (yy in years) {
  print(paste("Processing year:", yy))
  
  # Assuming there's only one CSV file per folder, dynamically get the file name
  dir_path <- file.path(base_path, as.character(yy))
  
  csv_file <- list.files(dir_path, pattern = paste0("\\d{4}\\.csv"), full.names = TRUE)
  
  if (!is_empty(csv_file)) {
    df <- import(csv_file)
    # Renaming columns to var_monthnum
    df <- rename_month_columns(df)
    colnames(df) <- tolower(colnames(df))
    ## Change col names
    if (yy <= 2013) {
      old_names <- c("empresa_generica", "tt", "id_division")
    } else {
      old_names <- c("empresa_generica", "tt", "division")
    }
    new_names <- c("id", "tamano", "div")
    df <- df %>% rename_with(~new_names, all_of(old_names))
    print(colnames(select(df, 1:9)))
  }
    
}

