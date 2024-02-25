library(duckdb)
library(arrow)
library(ggplot2)
library(dplyr)
library(stringr)

# Initialize DuckDB connection
con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb", read_only = FALSE)

# List all Parquet files in the directory
parquet_files <- list.files(".\\Data\\", pattern = "\\.parquet$", full.names = TRUE)

# Function to create a table name from the file name
create_table_name <- function(file_path) {
  file_name <- basename(file_path)
  gsub("[^A-Za-z0-9]+", "_", tools::file_path_sans_ext(file_name))
}

# Check if a table or view already exists in DuckDB
check_exists <- function(con, name, type = "table") {
  exists_query <- sprintf("SELECT count(*) > 0 as exists FROM information_schema.tables WHERE table_name = '%s' AND table_type = '%s'", name, toupper(type))
  dbGetQuery(con, exists_query)$exists[1]
}

# Phase 1: Load each Parquet file into DuckDB as a table, if not already loaded
for (file_path in parquet_files) {
  table_name <- create_table_name(file_path)
  
  if (!check_exists(con, table_name)) {
    arrow_table <- arrow::open_dataset(file_path)
    duckdb::duckdb_register_arrow(con, table_name, arrow_table)
  }
}


# Ensure all tables are registered before proceeding to view creation
# dbDisconnect(con) # Close and reopen the connection to commit all changes
# con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb", read_only = FALSE)

#Phase 2: Automatically create views for "Junction" tables
# for (file_path in parquet_files) {
#   file_name <- basename(file_path)
#   if (str_detect(file_name, "Junction")) {
#     pattern <- "(.*)-Junction-(.*).parquet$"
#     matches <- str_match(file_name, pattern)
#     table1 <- matches[, 2]
#     table2 <- matches[, 3]
# 
#     table1_name <- create_table_name(table1)
#     table2_name <- create_table_name(table2)
#     junction_table_name <- create_table_name(file_name)
#     view_name <- paste0("view_", table1_name, "_to_", table2_name)
# 
#     if (!check_exists(con, view_name, "view")) {
#       sql_create_view <- sprintf(
#         "CREATE VIEW %s AS SELECT * FROM %s JOIN %s ON %s.response_id = %s.response_id AND %s.value_id = %s.value_id",
#         view_name,
#         table1_name,
#         junction_table_name,
#         table1_name,
#         junction_table_name,
#         junction_table_name,
#         table2_name
#       )
#       dbExecute(con, sql_create_view)
#     }
#   }
# }

# Close the connection when done
dbDisconnect(con)
