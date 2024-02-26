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
  return(full_key %in% names(columns_to_normalize))
}

# Adjusted Function to Perform Query and Visualize Data
query_and_visualize <- function(con, category, column_key, question) {
  full_key <- paste(category, column_key, sep="$")
  
  # Initialize the SQL variable outside the conditionals for scope
  sql <- ""
  
  if (full_key == "SentimentAndOutlook$TopConcerns") {
    # Handling for the special case of "TopConcerns"
    concerns <- c(
      "What are your top three concerns for the future of your business? [First concern]",
      "What are your top three concerns for the future of your business? [Second concern]",
      "What are your top three concerns for the future of your business? [Third concern]"
    )
    sql <- sprintf(
      "SELECT concern, COUNT(*) as count FROM (
                SELECT \"%s\" as concern FROM responses
                UNION ALL
                SELECT \"%s\" as concern FROM responses
                UNION ALL
                SELECT \"%s\" as concern FROM responses
            ) as unified_concerns
            WHERE concern IS NOT NULL AND concern != ''
            GROUP BY concern",
      concerns[1], concerns[2], concerns[3]
    )
  } else if (needs_normalization(category, column_key)) {
    # Normalized data handling (omitted for brevity)
  } else {
    # Direct query for non-normalized data
    trimmed_question <- trimws(question)
    sql <- sprintf("SELECT \"%s\" as value, COUNT(*) as count FROM responses GROUP BY \"%s\"",
                   trimmed_question, trimmed_question)
  }
  
  # Ensure SQL is executed as a string
  if (sql != "") {
    df <- tryCatch({
      dbGetQuery(con, sql)
    }, error = function(e) {
      message("Error executing query: ", e$message)
      return(NULL)  # Return NULL if there's an error executing the query
    })
    
    # Proceed to visualization if the dataframe is not NULL
    if (!is.null(df)) {
      ggplot(df, aes(x = value, y = count, fill = value)) +
        geom_bar(stat = "identity") +
        theme_minimal() +
        labs(title = question, x = "", y = "Count") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    }
  }
}

# Iterate through survey categories and their respective questions
for (category in names(survey_categories)) {
  for (column_key in names(survey_categories[[category]])) {
    question_text <- survey_categories[[category]][[column_key]]
    query_and_visualize(con, category, column_key, question_text)
  }
}

# Ensure all actions are completed and cleanup
dbDisconnect(con)
