library(duckdb)
library(ggplot2)
library(dplyr)
library(stringr)

# Initialize DuckDB connection
con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb", read_only = FALSE)

# List all Parquet files in the directory
parquet_files <- list.files(".\\Data\\", pattern = "\\.parquet$", full.names = TRUE)

# Function to create a table name from the file name, filtering out the year and quarter stamp
create_table_name <- function(file_path) {
  file_name <- basename(file_path)
  # Remove the year and quarter stamp from the file name
  file_name_no_stamp <- gsub("_\\d{4}Q[1-4]", "", file_name)
  # Replace non-alphanumeric characters with underscores
  clean_name <- gsub("[^A-Za-z0-9]+", "_", tools::file_path_sans_ext(file_name_no_stamp))
  return(clean_name)
}


# Check if a table or view already exists in DuckDB
check_exists <- function(con, name, type = "table") {
  exists_query <- sprintf("SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = '%s') AS exists", name)
  result <- dbGetQuery(con, exists_query)
  # Ensure result is interpreted as logical
  return(as.logical(result$exists))
}

# Phase 1: Conditionally load each Parquet file into DuckDB as a table
for (file_path in parquet_files) {
  table_name <- create_table_name(file_path)
  
  # Use the updated check_exists function
  if (!check_exists(con, table_name)) {
    # If table does not exist, create it from the Parquet file
    read_parquet_sql <- sprintf("CREATE TABLE %s AS SELECT * FROM read_parquet('%s')", table_name, file_path)
    dbExecute(con, read_parquet_sql)
  }
}


# Ensure all tables are registered before proceeding to view creation
dbDisconnect(con) # Close and reopen the connection to commit all changes
rm(con) # Remove the connection object
gc() # Force garbage collection to free up resources
