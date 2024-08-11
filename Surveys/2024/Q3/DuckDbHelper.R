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

# Function to append or create&load data from Parquet into DuckDB
load_or_append_from_parquet <- function(con, table_name, file_path) {
  if (check_exists(con, table_name)) {
    # If the table exists, append the data from the Parquet file
    append_sql <- sprintf("INSERT INTO %s SELECT * FROM read_parquet('%s')", table_name, file_path)
    dbExecute(con, append_sql)
  } else {
    # If the table does not exist, create it and load data
    create_and_load_sql <- sprintf("CREATE TABLE %s AS SELECT * FROM read_parquet('%s')", table_name, file_path)
    dbExecute(con, create_and_load_sql)
  }
}