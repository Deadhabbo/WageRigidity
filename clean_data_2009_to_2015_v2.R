library(tidyverse)
library(rio)

# Define the years, months, and the variable names of interest
years <- 2009:2015
MONTHS <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
VARS_OF_INTEREST <- c("ro", "ho", "re", "he", "c", "nt")
MONTHS_DICT <- setNames(sprintf("%02d", 1:12), tolower(MONTHS)) 


# Base path for data
base_path <- "./wage rigidity/_data/_IRCMO"

# Function to rename columns
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
  
  # Take the csv with de matching name: "*name*_xxxx.csv"
  dir_path <- file.path(base_path, as.character(yy))
  csv_file <- list.files(dir_path, pattern = paste0("\\d{4}\\.csv"), full.names = TRUE)
  
  if (!is_empty(csv_file)) {
    df <- import(csv_file, decimal.mark = ",")
    
    # Renaming columns to var_monthnum
    df <- rename_month_columns(df)
    colnames(df) <- tolower(colnames(df))
    
    ## Change col names for consistency
    if (yy <= 2013) {
      old_names <- c("empresa_generica", "tt", "id_division")
    } else {
      old_names <- c("empresa_generica", "tt", "division")
    }
    new_names <- c("id", "tamano", "div")
    df <- df %>% rename_with(~new_names, all_of(old_names))
    
    # Initialize an empty dataframe for the stacked data
    stacked_df <- data.frame()
    
    for (month in MONTHS) {
      month_num <- MONTHS_DICT[tolower(month)]
      print(paste("Processing month:", month_num))
      
      # Filter the columns for the current month
      month_vars <- paste(VARS_OF_INTEREST, month_num, sep = "_")
      print(month_vars)
      stable_col = c("id", "tamano", "categoria", "sexo", "grupo", "div")
      month_df <- df %>% select(stable_col, all_of(month_vars)) 

      if (ncol(month_df) > 0) {
        month_df$mes <- as.integer(month_num)
        month_df$ano <- yy
        # Rename the month-specific columns to generic names without the month number
        month_df <- month_df %>% rename_with(~VARS_OF_INTEREST, all_of(month_vars))
        # # Stack or concatenate this month's dataframe with the accumulated dataframe
        stacked_df <- rbind(stacked_df, month_df)
      }
      
    }

    stacked_df <- subset(stacked_df, select = -c( re, he))
    stacked_df <- stacked_df[, c("ano", "mes", "id", "tamano", "categoria", "sexo", "grupo", "div", "ro", "ho", "c", "nt")]
    
    # Write the combined dataframe to a new CSV file
    write.table(stacked_df, file = file.path(dir_path, paste0(yy, "_combined_r.csv")), row.names = FALSE, quote = FALSE, sep = ";")
  } else {
    print(paste("File not found for year", yy))
  }
}

