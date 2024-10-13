library(duckdb)
library(ggplot2)
library(dplyr)
library(stringr)

# Load Helper functions
source(".\\Surveys\\2024\\Q3\\DuckDbHelper.R")

# Initialize DuckDB connection
con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb", read_only = FALSE)

# List all Parquet files in the directory
parquet_files <- list.files(".\\Data\\", pattern = "_2024Q3.parquet", full.names = TRUE)

# Phase 1: Conditionally load or append each Parquet file into DuckDB as a table
for (file_path in parquet_files) {
  table_name <- create_table_name(file_path)
  load_or_append_from_parquet(con, table_name, file_path)
}

# Ensure all actions are completed and cleanup
dbDisconnect(con) # Close the connection to commit all changes
rm(con) # Remove the connection object
gc() # Force garbage collection to free up resources
