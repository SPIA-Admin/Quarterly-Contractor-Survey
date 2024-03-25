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

# generate_bar_chart <- function(df, category_column, value_column, fill_column=NULL) {
#   library(ggplot2)
# 
#   if (is.null(fill_column)) {
#     # Regular bar chart
#     p <- ggplot(df, aes_string(x=value_column, y=category_column)) +
#       geom_bar(stat="identity") +
#       theme_minimal()
#   } else {
#     # Stacked bar chart
#     p <- ggplot(df, aes_string(x=category_column, y=value_column, fill=fill_column)) +
#       geom_bar(stat="identity", position="stack") +
#       theme_minimal()
#   }
# 
#   print(p)
# }
generate_bar_chart <- function(df, category_column, value_column, fill_column=NULL) {
  library(ggplot2)
  library(dplyr)
  
  # Reorder the category_column based on the value_column
  df <- df %>%
    mutate(ordered_category = reorder(.data[[category_column]], .data[[value_column]]))
  
  if (is.null(fill_column)) {
    # Regular bar chart with categories ordered by value_column
    p <- ggplot(df, aes(y = ordered_category, x = .data[[value_column]])) +
      geom_bar(stat="identity") +
      theme_minimal()
  } else {
    # Stacked bar chart with categories ordered by value_column
    p <- ggplot(df, aes(y = ordered_category, x = .data[[value_column]], fill = .data[[fill_column]])) +
      geom_bar(stat="identity", position="stack") +
      theme_minimal()
  }
  
  print(p)
}

generate_grouped_bar_chart <- function(df, concern_column, rank_column, y_value_column) {
  library(ggplot2)
  library(dplyr)
  library(forcats) # For fct_reorder
  
  # Step 1: Calculate a priority score for ordering
  # This assumes higher y_value_column values are more significant
  # You might need to adjust this logic based on how you define "highest" in your context
  df <- df %>%
    group_by(.data[[concern_column]]) %>%
    mutate(priority = case_when(
      .data[[rank_column]] == "First Concern" ~ max(.data[[y_value_column]]) * 3,
      .data[[rank_column]] == "Second Concern" ~ max(.data[[y_value_column]]) * 2,
      .data[[rank_column]] == "Third Concern" ~ max(.data[[y_value_column]]),
      TRUE ~ 0
    )) %>%
    ungroup() %>%
    arrange(desc(priority))
  
  # Step 2: Reorder the concern column based on the priority
  df[[concern_column]] <- fct_inorder(df[[concern_column]])
  
  # Plot
  p <- ggplot(df, aes(x = .data[[concern_column]], y = .data[[y_value_column]], fill = .data[[rank_column]])) +
    geom_bar(stat = "identity", position = "dodge") +
    theme_minimal() +
    labs(x = concern_column, y = y_value_column, title = paste("Concerns by", rank_column, "and", y_value_column)) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_brewer(palette = "Pastel1")
  
  print(p)
}

generate_stacked_bar_chart <- function(df, concern_column, rank_column, y_value_column) {
  library(ggplot2)
  library(dplyr)
  library(forcats) # For fct_reorder and fct_rev
  
  # Calculate total percentages for each concern
  total_percents <- df %>%
    group_by(.data[[concern_column]]) %>%
    summarise(TotalPercentage = sum(.data[[y_value_column]], na.rm = TRUE)) %>%
    arrange(desc(TotalPercentage)) %>%
    ungroup()
  
  # Reorder the concern column based on total percentages and reverse for y-axis display
  df[[concern_column]] <- factor(df[[concern_column]],
                                 levels = rev(total_percents[[concern_column]]))
  
  # Plot
  p <- ggplot(df, aes(x = .data[[concern_column]], y = .data[[y_value_column]], fill = .data[[rank_column]])) +
    geom_bar(stat = "identity", position = "stack") +
    coord_flip() + # Optionally use coord_flip() to swap x and y axes, or keep as is for y-axis categories
    theme_minimal() +
    labs(x = concern_column, y = y_value_column, title = paste("Stacked Concerns by", rank_column, "and", y_value_column)) +
    theme(axis.text.y = element_text(angle = 0, hjust = 1)) +
    scale_fill_brewer(palette = "Pastel1")
  
  print(p)
}


generate_sentiment_wordcloud <- function(df, sentence_column) {
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(ggwordcloud)
  library(tidytext)
  library(syuzhet)
  
  # Ensure the sentence column exists
  if (!sentence_column %in% names(df)) {
    stop("The specified sentence column does not exist in the dataframe.")
  }
  
  # Prepare the data
  words_df <- df %>%
    unnest_tokens(word, !!rlang::sym(sentence_column)) %>%
    anti_join(stop_words, by = "word") %>%
    count(word, sort = TRUE)
  
  # Calculate sentiment for each word
      sentiments <- df %>%
        mutate(sentiment = get_sentiment(!!rlang::sym(sentence_column))) %>%
        unnest_tokens(word, !!rlang::sym(sentence_column)) %>%
        anti_join(stop_words, by = "word") %>%
        group_by(word) %>%
        summarise(avg_sentiment = mean(sentiment, na.rm = TRUE), .groups = 'drop')
      
      #   # Normalize sentiment scores for coloring
  max_abs_sentiment <- max(abs(sentiments$avg_sentiment), na.rm = TRUE)

  
   words_df <- merge(words_df, sentiments, by = "word", all.x = TRUE) %>%
    mutate(color_score = scales::rescale(avg_sentiment, to = c(0, 1), from = c(-max_abs_sentiment, max_abs_sentiment)))
  
  
  # Filter to improve visualization
  stdDev <- sd(words_df$avg_sentiment, na.rm = TRUE)
  words_df <- words_df %>%
    filter(n > 1 | abs(avg_sentiment) >= stdDev)
  
  # Generate the word cloud with ggwordcloud
  wordcloud_plot <- ggplot(words_df, aes(label = word, size = n, color = color_score)) +
    geom_text_wordcloud() +
    scale_size_area(max_size = 15) +
    scale_color_gradient2(low = "red", high = "blue", midpoint = 0.5, mid = "black") +
    theme_minimal() +
    theme(legend.position = "right", legend.title = element_text(size = 12), legend.text = element_text(size = 10)) +
    labs(color = "Sentiment Score")
  
  print(wordcloud_plot)
}



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


generate_histogram <- function(df, value_column, count_column) {
  library(ggplot2)
  library(dplyr)
  
  # Convert value_column where possible and create a numeric version of count_column
  df <- df %>%
    mutate(numeric_value = as.numeric(as.character(.data[[value_column]])),
           numeric_count = as.numeric(as.character(.data[[count_column]])))
  
  # Expand the dataframe for numeric values
  df_expanded <- df %>%
    rowwise() %>%
    do(data.frame(numeric_value = rep(.$numeric_value, .$numeric_count))) %>%
    ungroup()
  
  # Remove rows with NA in numeric_value (including 'Unspecified' if not numeric)
  df_expanded <- df_expanded %>% filter(!is.na(numeric_value))
  
  # Generate the histogram for numeric values
  p <- ggplot(df_expanded, aes(x = numeric_value)) +
    geom_histogram(binwidth = 1, color = "white", na.rm = TRUE) +
    theme_minimal() +
    labs(x = value_column, y = "Frequency", title = paste("Histogram of", value_column))
  
  # Extract counts for 'Unspecified'
  special_counts <- df %>% filter(.data[[value_column]] == "Unspecified") %>% summarise(TotalUnspecified = sum(numeric_count, na.rm = TRUE))
  
  # Only add annotations if 'Unspecified' exists and its count is greater than 0
  if (!is.na(special_counts$TotalUnspecified) && special_counts$TotalUnspecified > 0) {
    x_position <- max(df_expanded$numeric_value, na.rm = TRUE) + 1  # Position after the last bar
    y_position <- max(table(df_expanded$numeric_value))  # At the height of the most frequent value
    label_text <- paste("Unspecified:", special_counts$TotalUnspecified)
    p <- p + annotate("text", x = x_position, y = y_position, label = label_text, hjust = 0, size = 5, color = "red")
  }
  
  print(p)
}


generate_categorical_plot <- function(df, value_column, count_column) {
  library(ggplot2)
  
  # Define the desired order of categories
  desired_order <- c("0.0", "1.0", "2.0", "3.0", "4.0", "5.0", "10+","Increased", "Improved", "Expanded", "Expanding", "Increase", "Decreased", "Worsened", "Reduced", "Reducing", "Decrease", "Remained Stable", "Maintaining", "Remain the same", "1 to 2", "1 to 3", "3 to 5", "1 to 5", "4 to 8", "6 to 8", "8+", "9 to 13", "13+", "6 to 15", "16 to 30", "31 to 50", "51 to 75", "76 to 100", "100+", "101 to 140", "200 to 300", "More Optimistic", "About the Same", "More Pessimistic", "Don't Know", "Unspecified")
  
  # Convert the value column to a factor and specify the levels explicitly based on desired order
  df[[value_column]] <- factor(df[[value_column]], levels = desired_order)
  
  # Generate the bar plot
  p <- ggplot(df, aes(x = .data[[value_column]], y = .data[[count_column]])) +
    geom_bar(stat = "identity", color = "black") + # Use identity to use count values directly
    theme_minimal() +
    labs(x = value_column, y = "Count", title = paste("Count of", value_column)) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Uncommented for label readability
  
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
         GroupedBar= {
           generate_grouped_bar_chart(df, "Concern", "Rank", "Percentage")
         },
         StackedBar = {
           generate_stacked_bar_chart(df, "Concern", "Rank", "Percentage")
         },         
         wordcloud = {
           generate_sentiment_wordcloud(df, "Answer")
         },
         map = {
           generate_map(df, "Answer", "Percentage")
         },
         histogram = {
           generate_histogram(df, "Answer", "Count")
         },
         categorical = {
           generate_categorical_plot(df, "Answer", "Count")
         },
         timeline = {
           generate_timeline(df, "date", "event")
         },
         line = {
           generate_line_chart(df, "Answer", "Percentage")
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
