library(duckdb)
library(dplyr)
library(ggplot2)

# Ensure the directory for plots exists
plots_dir <- "./plots"
if (!dir.exists(plots_dir)) {
  dir.create(plots_dir)
}

source(".\\Surveys\\2024\\ReportHelper.R")

# Load survey_categories and columns_to_normalize
source(".\\Surveys\\2024\\Q1 2024 SectionsAndColumns.R")
# Load duckdb helper functions like check_exists
source(".\\Surveys\\2024\\DuckDbHelper.R")

query_and_visualize <- function(con, category, question_details) {
  sql_query <- question_details$sql_query
  df <- dbGetQuery(con, sql_query)
  
  if (nrow(df) == 0) {
    message("No data available for ", category, " - ", question_details$question)
    return()
  }
  
  switch(question_details$viz_type,
         bar = {
           generate_bar_chart(df, "Response", "Metric")
         },
         GroupedBar= {
           generate_grouped_bar_chart(df, "Response", "Rank", "Metric")
         },
         StackedBar = {
           generate_stacked_bar_chart(df, "Response", "Rank", "Metric")
         },         
         wordcloud = {
           generate_sentiment_wordcloud(df, "Response")
         },
         map = {
           generate_map(df, "Response", "Metric")
         },
         histogram = {
           generate_histogram(df, "Response", "Metric")
         },
         categorical = {
           generate_categorical_plot(df, "Response", "Metric")
         },
         timeline = {
           generate_timeline(df, "date", "event")
         },
         line = {
           generate_line_chart(df, "Response", "Metric")
         },
         {
           message("Visualization type not recognized.")
         }
  )
}

# Open connection to the existing DuckDB database
con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb")

# Function to check if a column (based on survey question) needs normalization
needs_normalization <- function(category, column_key) {
  full_key <- paste(category, column_key, sep="$")
  return(full_key %in% names(columns_to_normalize))
}

# Iterate through survey categories and their respective questions
for (category_name in names(survey_categorie_caharts)) {
  category_questions <- survey_categorie_caharts[[category_name]]
  for (question_key in names(category_questions)) {
    question_details <- category_questions[[question_key]]
    query_and_visualize(con, category_name, question_details)
  }
}

# Ensure all actions are completed and cleanup
dbDisconnect(con) # Close the connection to commit all changes
rm(con) # Remove the connection object
gc() # Force garbage collection to free up resources





