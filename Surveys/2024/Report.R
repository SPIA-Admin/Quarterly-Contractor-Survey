library(duckdb)
library(dplyr)
library(ggplot2)

# Load survey_categories and columns_to_normalize
source(".\\Surveys\\2024\\Q1 2024 SectionsAndColumns.R")
# Load duckdb helper functions like check_exists
source(".\\Surveys\\2024\\DuckDbHelper.R")

# Open connection to the existing DuckDB database
con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb")

# Function to check if a column (based on survey question) needs normalization
# Now includes 'category' to construct the full key as used in columns_to_normalize
needs_normalization <- function(category, column_key) {
  # Construct the full key as it appears in columns_to_normalize
  full_key <- paste(category, column_key, sep="$")
  
  print(sprintf("Checking normalization for: %s", full_key))
  print(sprintf("Available keys for normalization: %s", toString(names(columns_to_normalize))))
  
  result <- full_key %in% names(columns_to_normalize)
  print(sprintf("Needs normalization: %s", result))
  
  return(result)
}

# Adjusted Function to Perform Query and Visualize Data
query_and_visualize <- function(con, category, column_key, question) {
  full_key <- paste(category, column_key, sep="$")
  
  if (needs_normalization(category, column_key)) {
    # Table name from full_key for the junction table
    junction_table_name <- sprintf("Responses_Junction_%s", gsub("\\$", "_", full_key))
    
    # Correctly construct the table name for the value table using paste0
    value_table_name <- paste0(gsub("\\$", "_", category), "_", gsub("[^A-Za-z0-9]", "_", column_key))
    
    # Construct the SQL query for normalized data
    sql <- sprintf(
      "SELECT v.\"%s\" as value, COUNT(*) as count FROM responses 
       JOIN %s j ON responses.response_id = j.response_id 
       JOIN %s v ON j.value_id = v.value_id 
       GROUP BY v.\"%s\"",
      question,  # Assuming question texts are used as column names in value table
      junction_table_name,
      value_table_name,
      question
    )
  } else {
    # This branch might be adjusted or removed based on your schema if all columns are normalized
    sql <- sprintf("SELECT [\"%s\"] as value, COUNT(*) as count FROM responses GROUP BY [\"%s\"]",
                   question, question)
  }
  
  df <- tryCatch({
    dbGetQuery(con, sql)
  }, error = function(e) {
    message("Error executing query: ", e$message)
    return(NULL)  # Return NULL if there's an error executing the query
  })
  
  if (!is.null(df)) {
    ggplot(df, aes(x = value, y = count, fill = value)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      labs(title = question, x = "", y = "Count") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  }
}

# Iterate through survey categories and their respective questions
# And pass category and column_key to needs_normalization
for (category in names(survey_categories)) {
  for (column_key in names(survey_categories[[category]])) {
    question_text <- survey_categories[[category]][[column_key]]
    # Adjusted to pass both category and column_key
    query_and_visualize(con, category, column_key, question_text)
  }
}


# Ensure all actions are completed and cleanup
dbDisconnect(con) # Close the connection to commit all changes
rm(con) # Remove the connection object
gc() # Force garbage collection to free up resources
