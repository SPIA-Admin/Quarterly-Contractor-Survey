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


# generate_map <- function(df, region_column, value_column) {
#   library(ggplot2)
#   library(maps)
#   library(dplyr)
# 
#   # Ensure the region names in df match the format in map_data
#   df[[region_column]] <- tolower(df[[region_column]])
# 
#   # Get map data
#   us_map <- map_data("state")
#   us_map$region <- tolower(us_map$region)
# 
#   # Merge your data with the map data
#   merged_data <- merge(us_map, df, by.x = "region", by.y = region_column, all.x = TRUE)
# 
#   # Sort merged_data by the 'order' column to ensure correct plotting sequence
#   merged_data <- merged_data[order(merged_data$order),]
# 
#   # Create the plot
#   p <- ggplot() +
#     geom_polygon(data = merged_data, aes(x = long, y = lat, group = group, fill = get(value_column)), color = "grey50") +
#     scale_fill_gradient(low = "lightblue", high = "red", na.value = "grey75", name = "Percent") +
#     labs(title = "Heatmap of State Percent", x = "", y = "") +
#     theme_minimal() +
#     theme(axis.text = element_blank(), axis.title = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())
# 
#    print(p)
# }
generate_map <- function(df, region_column, value_column) {
  library(ggplot2)
  library(maps)
  library(dplyr)
  
  # Ensure the region names in df match the format in map_data
  df[[region_column]] <- tolower(df[[region_column]])
  
  # Extract the value for 'Unspecified' before merging
  unspecified_value <- df %>% filter(.[[region_column]] == "unspecified") %>% pull(value_column)
  # Remove 'Unspecified' from df to avoid issues in merging
  df <- df %>% filter(.[[region_column]] != "unspecified")
  
  # Get map data
  us_map <- map_data("state")
  us_map$region <- tolower(us_map$region)
  
  # Merge your data with the map data
  merged_data <- merge(us_map, df, by.x = "region", by.y = region_column, all.x = TRUE)
  
  # Sort merged_data by the 'order' column to ensure correct plotting sequence
  merged_data <- merged_data[order(merged_data$order),]
  
  # Create the plot
  p <- ggplot() +
    geom_polygon(data = merged_data, aes(x = long, y = lat, group = group, fill = get(value_column)), color = "grey50") +
    scale_fill_gradient(low = "lightblue", high = "red", na.value = "grey75", name = "Percent") +
    labs(title = "Respondents by State", x = "", y = "") +
    theme_minimal() +
    theme(axis.text = element_blank(), axis.title = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())
  
  # If there's a value for 'Unspecified', add an annotation
  if (!is.na(unspecified_value) && length(unspecified_value) > 0) {
    p <- p + annotate("text", x = Inf, y = Inf, label = paste("Unspecified:", unspecified_value, "%"), hjust = 1.1, vjust = 2, size = 5, color = "red")
  }
  
  print(p)
}



# This function requires 'df' to have specific columns for matching and values.
# Adapt the 'merge' and 'aes' parameters based on your actual data structure.

# generate_histogram <- function(df, value_column) {
#   library(ggplot2)
#   
#   # Generate the histogram
#   p <- ggplot(df, aes_string(x=value_column)) +
#     geom_histogram(binwidth = 1, fill="blue", color="white") + # Adjust binwidth as necessary
#     theme_minimal() +
#     labs(x=value_column, y="Frequency", title=paste("Histogram of", value_column))
#   
#   print(p)
# }
# generate_histogram <- function(df, value_column, count_column) {
#   library(ggplot2)
#   library(dplyr)
#   
#   # Filter out '10+' and 'Unspecified' for the histogram
#   df_filtered <- df %>% 
#     filter(!(.[[value_column]] %in% c("10+", "Unspecified"))) %>%
#     mutate(across(all_of(value_column), ~as.numeric(as.character(.)), .names = "numeric_value"))
#   
#   # Expand the dataframe for numeric values
#   df_expanded <- df_filtered[rep(row.names(df_filtered), df_filtered[[count_column]]), ]
#   
#   # Generate the histogram for numeric values
#   p <- ggplot(df_expanded, aes(x = .data[["numeric_value"]])) +
#     geom_histogram(binwidth = 1, fill = "blue", color = "white", na.rm = TRUE) +
#     theme_minimal() +
#     labs(x = value_column, y = "Frequency", title = paste("Histogram of", value_column))
#   
#   # Extract counts for '10+' and 'Unspecified'
#   special_counts <- df %>% 
#     filter(.[[value_column]] %in% c("10+", "Unspecified")) %>%
#     select(all_of(value_column), all_of(count_column))
#   
#   # Manually set the position for annotations to avoid overlap, adjust as needed
#   x_position <- max(df_expanded$numeric_value, na.rm = TRUE) + 1  # Position after the last bar
#   y_position <- max(table(df_expanded$numeric_value))  # At the height of the most frequent value
#   
#   # Add annotations for '10+' and 'Unspecified'
#   for(i in 1:nrow(special_counts)) {
#     label_text <- paste(special_counts[[i, value_column]], ":", special_counts[[i, count_column]])
#     p <- p + annotate("text", x = x_position, y = y_position - i*2, label = label_text, hjust = 0, size = 4, color = "red")
#   }
#   
#   print(p)
# }


generate_categorical_plot <- function(df, value_column, count_column) {
  library(ggplot2)

  # Convert the value column to a factor to ensure it's treated as categorical
  df[[value_column]] <- factor(df[[value_column]], levels = unique(df[[value_column]]))

  # Generate the bar plot
  p <- ggplot(df, aes_string(x = value_column, y = count_column, fill = value_column)) +
    geom_bar(stat = "identity", color = "black") + # Use identity to use count values directly
    theme_minimal() +
    labs(x = value_column, y = "Count", title = paste("Count of", value_column)) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Improve label readability

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
           generate_bar_chart(df, "Answer", "Percentage")
         },
         wordcloud = {
           generate_wordcloud(df, "Answer", "Percentage")
         },
         map = {
           generate_map(df, "Answer", "Percentage")
         },
         stacked_bar = {
           generate_stacked_bar_chart(df, "Answer", "Percentage")
         },
         histogram = {
           #generate_histogram(df, "Answer", "Count")
           generate_categorical_plot(df, "Answer", "Count")
         },
         timeline = {
           generate_timeline(df, "date", "event")
         },
         line = {
           generate_line_chart(df, "Answer", "Percentage")
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
