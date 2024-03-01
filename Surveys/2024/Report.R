library(duckdb)
library(dplyr)
library(ggplot2)

# Ensure the directory for plots exists
plots_dir <- "./plots"
if (!dir.exists(plots_dir)) {
  dir.create(plots_dir)
}

# Load survey_categories and columns_to_normalize
source(".\\Surveys\\2024\\Q1 2024 SectionsAndColumns.R")
# Load duckdb helper functions like check_exists
source(".\\Surveys\\2024\\DuckDbHelper.R")

# Open connection to the existing DuckDB database
con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb")

# Function to check if a column (based on survey question) needs normalization
needs_normalization <- function(category, column_key) {
  full_key <- paste(category, column_key, sep="$")
  return(full_key %in% names(columns_to_normalize))
}

generate_bar_chart <- function(df, category_column, value_column, fill_column=NULL) {
  library(ggplot2)
  
  if (is.null(fill_column)) {
    # Regular bar chart
    p <- ggplot(df, aes_string(x=category_column, y=value_column)) +
      geom_bar(stat="identity") +
      theme_minimal()
  } else {
    # Stacked bar chart
    p <- ggplot(df, aes_string(x=category_column, y=value_column, fill=fill_column)) +
      geom_bar(stat="identity", position="stack") +
      theme_minimal()
  }
  
  print(p)
}

generate_wordcloud <- function(df, word_column, freq_column) {
  library(wordcloud)
  # Ensure words are ordered by frequency for better visualization
  df <- df[order(-df[[freq_column]]), ]
  words <- df[[word_column]]
  freqs <- df[[freq_column]]
  
  # Generate the word cloud
  wordcloud(words = words, freq = freqs, min.freq = 1,
            max.words = 200, random.order = FALSE, rot.per = 0.35, 
            colors = brewer.pal(8, "Dark2"))
}

generate_map <- function(df, region_column, value_column) {
  library(ggplot2)
  library(maps)
  
  # Assume 'df' includes region names that match the map data and a value to fill
  map_data <- map_data("world") # Change to relevant map; 'state', 'county' etc.
  df <- merge(map_data, df, by.x = "region", by.y = region_column)
  
  ggplot() +
    geom_polygon(data = df, aes(x = long, y = lat, group = group, fill = value_column)) +
    borders("world", colour = "gray50", fill = NA) + # Adjust based on map choice
    theme_minimal() +
    labs(fill = "Value")
}

# This function requires 'df' to have specific columns for matching and values.
# Adapt the 'merge' and 'aes' parameters based on your actual data structure.

generate_histogram <- function(df, value_column) {
  library(ggplot2)
  
  # Generate the histogram
  p <- ggplot(df, aes_string(x=value_column)) +
    geom_histogram(binwidth = 1, fill="blue", color="white") + # Adjust binwidth as necessary
    theme_minimal() +
    labs(x=value_column, y="Frequency", title=paste("Histogram of", value_column))
  
  print(p)
}

generate_timeline <- function(df, date_column, value_column) {
  library(ggplot2)
  
  # Ensure the date column is in Date format
  df[[date_column]] <- as.Date(df[[date_column]])
  
  # Generate the timeline
  p <- ggplot(df, aes_string(x=date_column, y=value_column)) +
    geom_line() + # Use geom_point() if you want dots instead of lines
    geom_point() +
    theme_minimal() +
    labs(x="Date", y=value_column, title=paste("Timeline of", value_column))
  
  print(p)
}

generate_line_chart <- function(df, x_column, y_column) {
  library(ggplot2)
  
  # Generate the line chart
  p <- ggplot(df, aes_string(x=x_column, y=y_column)) +
    geom_line(color="blue") + # You can change the line color
    geom_point() + # Add points on each data point
    theme_minimal() +
    labs(x=x_column, y=y_column, title=paste("Line Chart of", y_column, "over", x_column))
  
  print(p)
}

generate_text_summary <- function(text_data) {
  # Assuming text_data is a vector of strings
  # Here you might apply text summarization, extraction of key phrases, or simply aggregate responses
  
  # For demonstration, just printing the first few responses
  if (length(text_data) > 5) {
    print(paste(head(text_data, 5), collapse="\n"))
    print(sprintf("...and %s more responses", length(text_data) - 5))
  } else {
    print(paste(text_data, collapse="\n"))
  }
}


query_and_visualize <- function(con, category, question_details) {
  sql_query <- question_details$sql_query
  df <- dbGetQuery(con, sql_query)
  
  if (nrow(df) == 0) {
    message("No data available for ", category, " - ", question_details$question)
    return()
  }
  
  switch(question_details$viz_type,
         bar = {
           generate_bar_chart(df, "category", "count")
         },
         wordcloud = {
           generate_wordcloud(df, "word", "frequency")
         },
         map = {
           generate_map(df, "area", "count")
         },
         stacked_bar = {
           generate_stacked_bar_chart(df, "category", "percentage")
         },
         histogram = {
           generate_histogram(df, "value")
         },
         timeline = {
           generate_timeline(df, "date", "event")
         },
         line = {
           generate_line_chart(df, "time", "value")
         },
         text_summary = {
           generate_text_summary(df, "text")
         },
         {
           message("Visualization type not recognized.")
         }
  )
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
