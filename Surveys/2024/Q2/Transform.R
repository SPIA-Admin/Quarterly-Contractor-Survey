library(arrow)
library(dplyr)
library(tidyr)
library(stringr)

# Load survey_categories
source(".\\Surveys\\2024\\Q2\\Q2 2024 SectionsAndColumns.R")

# Load Helper functions
source(".\\Surveys\\2024\\Q2\\TransformHelper.R")

# Replace with the path to your Excel file
file_path_csv <- ".\\Surveys\\2024\\Q2\\Q2 2024 Contractor Survey.csv"
survey_instance <- "2024Q2"
arrowFilePath_Responses <- ".\\Data\\Responses_2024Q2.parquet"
arrowFileNameAndPath <- ".\\Data\\%_2024Q2.parquet"

# Read the CSV file
responses_data <- read.csv(file_path_csv, header=TRUE, check.names = FALSE)

# Add a unique identifier column 
responses_data <- responses_data %>% mutate(response_id = row_number())

for (column_path in names(columns_to_normalize)) {
  column_name <- columns_to_normalize[[column_path]] # Access the actual column name
  
  result <- splitDelimitedDataColumn(responses_data, column_name)
  
  # Sanitize file names
  normalized_file_name <- sanitizeFileName(column_path)
  normalized_file_path <- gsub("%", normalized_file_name, arrowFileNameAndPath)
  junction_file_path <- gsub("%", paste("Responses-Junction-", normalized_file_name, sep=""), arrowFileNameAndPath)
  
  # Write to Parquet files
  responses_data <- result$modified_data
  write_parquet(as_arrow_table(result$normalized_data), normalized_file_path)
  write_parquet(as_arrow_table(result$junction_table), junction_file_path)
}

write_parquet(as_arrow_table(responses_data), arrowFilePath_Responses)

