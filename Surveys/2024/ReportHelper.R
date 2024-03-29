# Function to generate a bar chart
# df: The dataframe containing the data
# category_column: The column representing the categories to be plotted on the y-axis
# value_column: The column representing the values to be plotted on the x-axis
# fill_column: Optional column for stacked bar charts (default is NULL)
generate_bar_chart <- function(df, category_column, value_column, fill_column=NULL) {
  library(ggplot2)
  library(dplyr)
  
  # Validate parameters
  if (!category_column %in% names(df) || !value_column %in% names(df)) {
    stop("category_column or value_column not found in dataframe.")
  }
  
  if (!is.null(fill_column) && !fill_column %in% names(df)) {
    stop("fill_column not found in dataframe.")
  }
  
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

# Function to generate a grouped bar chart
# df: The dataframe containing the data
# concern_column: The column representing the concerns to be plotted on the x-axis
# rank_column: The column representing the rank of concerns
# y_value_column: The column representing the y-axis values
generate_grouped_bar_chart <- function(df, concern_column, rank_column, y_value_column) {
  library(ggplot2)
  library(dplyr)
  library(forcats) # For fct_reorder
  
  # Validate parameters
  if (!concern_column %in% names(df) || !rank_column %in% names(df) || !y_value_column %in% names(df)) {
    stop("concern_column, rank_column, or y_value_column not found in dataframe.")
  }
  
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

# Function to generate a stacked bar chart
# df: The dataframe containing the data
# concern_column: The column representing the concerns to be plotted on the y-axis
# rank_column: The column representing the rank of concerns
# y_value_column: The column representing the y-axis values
generate_stacked_bar_chart <- function(df, concern_column, rank_column, y_value_column) {
  library(ggplot2)
  library(dplyr)
  library(forcats) # For fct_reorder and fct_rev
  
  # Validate parameters
  if (!concern_column %in% names(df) || !rank_column %in% names(df) || !y_value_column %in% names(df)) {
    stop("concern_column, rank_column, or y_value_column not found in dataframe.")
  }
  
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

# Function to generate a word cloud
# df: The dataframe containing the data
# sentence_column: The column containing sentences or text data
generate_wordcloud <- function(df, sentence_column) {
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(ggwordcloud)
  library(tidytext)
  library(syuzhet)
  
  # Validate parameters
  if (!sentence_column %in% names(df)) {
    stop("sentence_column not found in dataframe.")
  }
  
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
  
  # Normalize sentiment scores for coloring
  max_abs_sentiment <- max(abs(sentiments$avg_sentiment), na.rm = TRUE)
  
  words_df <- merge(words_df, sentiments, by = "word", all.x = TRUE) %>%
    mutate(color_score = scales::rescale(avg_sentiment, to = c(0, 1), from = c(-max_abs_sentiment, max_abs_sentiment)))
  
  # Filter to improve visualization
  stdDev <- sd(words_df$avg_sentiment, na.rm = TRUE)
  words_df <- words_df %>%
    filter(n > 1 | abs(avg_sentiment) >= stdDev)
  
  # Generate the word cloud with ggwordcloud
  wordcloud_plot <- ggplot(words_df, aes(label = word, size = n, color = color_score)) +
    geom_text_wordcloud(show.legend = TRUE) +
    scale_size_area(max_size = 15) +
    scale_color_gradient2(low = "red", high = "blue", midpoint = 0.5, mid = "grey90") +
    theme_minimal() +
    theme(legend.position = "right", legend.title = element_text(size = 12), legend.text = element_text(size = 10)) +
    labs(color = "Sentiment", size = "Frequency")
  
  print(wordcloud_plot)
}

# Function to generate a map plot
# df: The dataframe containing the data
# region_column: The column representing the regions (e.g., state names)
# value_column: The column representing the values to be plotted on the map
generate_map_plot <- function(df, region_column, value_column) {
  library(ggplot2)
  library(maps)
  library(dplyr)
  
  # Validate parameters
  if (!region_column %in% names(df) || !value_column %in% names(df)) {
    stop("region_column or value_column not found in dataframe.")
  }
  
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

# Function to generate a histogram plot
# df: The dataframe containing the data
# value_column: The column representing the values to be plotted
# count_column: The column representing the count of each value
generate_histogram_plot <- function(df, value_column, count_column) {
  library(ggplot2)
  library(dplyr)
  
  # Validate parameters
  if (!value_column %in% names(df) || !count_column %in% names(df)) {
    stop("value_column or count_column not found in dataframe.")
  }
  
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

# Function to generate a categorical plot
# df: The dataframe containing the data
# value_column: The column representing the categorical values to be plotted
# count_column: The column representing the count of each categorical value
generate_categorical_plot <- function(df, value_column, count_column) {
  library(ggplot2)
  
  # Validate parameters
  if (!value_column %in% names(df) || !count_column %in% names(df)) {
    stop("value_column or count_column not found in dataframe.")
  }
  
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