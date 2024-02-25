library(duckdb)
library(fs)

# Connect to DuckDB
conn <- dbConnect(duckdb::duckdb())

# Directory containing Parquet files
dir_path <- "./Surveys/2024/data/"

# List all Parquet files
parquet_files <- fs::dir_ls(dir_path, regexp = "\\.parquet$")

# Loop through files and load each into DuckDB
for (file_path in parquet_files) {
  table_name <- fs::path_ext_remove(path_file(file_path))  # Correctly removes extension for the table name
  
  # Use the read_parquet function to load directly into DuckDB
  query <- sprintf("CREATE TABLE \"%s\" AS SELECT * FROM read_parquet('%s');", table_name, file_path)
  dbExecute(conn, query)
}

# Execute a query to list all tables
queryResult <- dbGetQuery(conn, "SHOW TABLES")
print(queryResult)

queryResult <- dbGetQuery(conn, "SELECT * FROM Responses")
print(queryResult)