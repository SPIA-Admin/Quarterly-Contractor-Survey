library(readxl)
library(arrow)
library(dplyr)
library(tidyr)


# Load survey_categories
source(".\\Surveys\\2024\\Q1 2024 SectionsAndColumns.R")

# Replace with the path to your Excel file
file_path_excel <- ".\\Surveys\\2024\\Q1 2024 Contractor Survey (Responses).xlsx"
arrowFilePath_Responses <- ".\\Surveys\\2024\\Q1 2024 Contractor Survey (Responses).parquet"
arrowFilePath_DemographicsServices <- ".\\Surveys\\2024\\Q1 2024 Contractor Survey (DemographicsServices).parquet"
arrowFilePath_ResponsesJunctionDemographicsServices <- ".\\Surveys\\2024\\Q1 2024 Contractor Survey (ResponsesJunctionDemographicsServices).parquet"

column_name <- survey_categories$Demographics$Services

# Read the Excel file
responses_data <- read_excel(file_path_excel)

# Add a unique identifier column 
responses_data <- responses_data %>% mutate(response_id = row_number())

demographicsServices_data <- responses_data %>% 
  select(column_name) %>%
  separate_rows(column_name, sep = ", ") %>%
  distinct()

# Assign unique identifier to each value in demographicsServices_data
demographicsServices_data <- demographicsServices_data %>% mutate(value_id = row_number())

# Create junction_table
responsesJunctionDemographicsServices_data <- responses_data %>% 
  select(response_id, column_name) %>%
  separate_rows(column_name, sep = ", ") %>%
  left_join(demographicsServices_data, by = column_name) %>%
  select(response_id, value_id)
  

# Remove the 'column_name' column from responses_data
responses_data <- responses_data %>% select(-column_name)

# Create Arrow tables
responses_arrow <- as_arrow_table(responses_data)
demographicsServices_arrow <- as_arrow_table(demographicsServices_data)
responsesJunctionDemographicsServices_arrow <- as_arrow_table(responsesJunctionDemographicsServices_data)


# Write to Parquet files
write_parquet(responses_arrow, arrowFilePath_Responses)
write_parquet(demographicsServices_arrow, arrowFilePath_DemographicsServices)
write_parquet(responsesJunctionDemographicsServices_arrow, arrowFilePath_ResponsesJunctionDemographicsServices)

