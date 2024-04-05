library(tidyverse)

# Define the years, months, and the variable names of interest
years <- 2009:2015
MONTHS <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
VARS_OF_INTEREST <- c("ro", "ho", "re", "he", "c", "nt")
MONTHS_DICT <- setNames(sprintf("%2d", 1:12), tolower(MONTHS)) ## Previous %02d
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
      # Rename the column, removing spaces before adding the month number
      new_name <- gsub("\\s+", "", gsub("\\(.*\\)", paste0("_", num_month), col_name))
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
    str(df)
    # Renaming columns to var_monthnum
    df <- rename_month_columns(df)
    colnames(df) <- tolower(colnames(df))
    str(df)
    
    # Initialize an empty dataframe for the stacked data
    stacked_df <- data.frame()

    for (month in MONTHS) {
      month_num <- MONTHS_DICT[tolower(month)]
      print(paste("Processing month:", month_num))
  
      # Filter the columns for the current month
      month_vars <- paste(VARS_OF_INTEREST, month_num, sep = "_")
      print(month_vars)
      print(typeof(month_vars))
      month_vars <- df[, month_vars]
      
      if (length(month_vars) > 0) {
        temp_df <- df[, c(1:8, month_vars)]
        temp_df$mes <- as.integer(month_num)
        temp_df$ano <- yy

        # Rename the month-specific columns to generic names without the month number
        new_names <- sub(sprintf("_%s$", month_num), "", month_vars)
        names(temp_df)[names(temp_df) %in% month_vars] <- new_names

        # Stack or concatenate this month's dataframe with the accumulated dataframe
        if (month_num == "1") {
          stacked_df <- rbind(stacked_df, temp_df)
        } else {
          if (yy != 2015) {
            temp_df <- temp_df[, !names(temp_df) %in% c("ro_01")]
          }
          stacked_df <- rbind(stacked_df, temp_df)
        }
      }
    }

    if (yy <= 2013) {
      old_names <- c("empresa_generica", "tt", "id_division")
    } else {
      old_names <- c("empresa_generica", "tt", "division")
    }
    new_names <- c("id", "tamano", "div")
    names(stacked_df)[names(stacked_df) %in% old_names] <- new_names

    stacked_df <- subset(stacked_df, select = -c(tamano_empresa, re, he))
    stacked_df <- stacked_df[, c("ano", "mes", "id", "tamano", "categoria", "sexo", "grupo", "div", "ro", "ho", "c", "nt")]

    # Write the combined dataframe to a new CSV file
    write.csv(stacked_df, file = file.path(dir_path, paste0(yy, "_combined.csv",sep = "")), row.names = FALSE)
  } else {
    print(paste("File not found for year", yy))
  }
  break
}