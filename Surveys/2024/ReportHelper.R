library(ggplot2)
library(dplyr)
library(forcats) # For fct_reorder and fct_rev
library(tidyr)
library(ggwordcloud)
library(tidytext)
library(syuzhet)
library(maps)

# Helper function for parameter validation
validate_parameters <- function(df, columns) {
  for (column in columns) {
    if (!column %in% names(df)) {
      stop(paste(column, "not found in dataframe."))
    }
  }
}

# Helper function for reordering factor levels based on values
reorder_factor_levels <- function(df, column, value_column) {
  df[[column]] <- reorder(df[[column]], df[[value_column]])
  return(df)
}

# Helper function for creating a bar chart
create_bar_chart <- function(df, x_column, y_column, title) {
  
  # Regular bar chart with categories ordered by value_column
  p <- ggplot(df, aes(x = .data[[x_column]], y = .data[[y_column]])) +
    geom_bar(stat = "identity", position = "dodge") +
    coord_flip() +
    theme_minimal() +
    labs(x = x_column, y = y_column, title = title) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_brewer(palette = "Pastel1")
  
  return(p)
}

# Helper function for creating a stacked bar chart
create_stacked_bar_chart <- function(df, x_column, y_column, fill_column, title) {
  
  # Calculate total percentages for each concern
  total_percents <- df %>%
    group_by(.data[[x_column]]) %>%
    summarise(TotalPercentage = sum(.data[[y_column]], na.rm = TRUE)) %>%
    arrange(desc(TotalPercentage)) %>%
    ungroup()
  
  level_order <- c("Third Concern","Second Concern","First Concern")
  
  # Reorder the concern column based on total percentages and reverse for y-axis display
  df[[x_column]] <- factor(df[[x_column]], levels = rev(total_percents[[x_column]]))
  df[[fill_column]] <- factor(df[[fill_column]], levels = level_order)
  
  # Plot
  p <- ggplot(df, aes(x = .data[[x_column]], y = .data[[y_column]], fill = .data[[fill_column]])) +
    geom_bar(stat = "identity", position = "stack") +
    coord_flip() +
    theme_minimal() +
    labs(x = x_column, y = y_column, title = title) +
    theme(axis.text.y = element_text(angle = 0, hjust = 1)) +
    scale_fill_viridis_d(limits = rev(level_order))
    # scale_fill_discrete(limits = rev(level_order)) +
    # scale_fill_brewer(palette = "Pastel1")
    
  
  return(p)
}

# Helper function for creating a word cloud
create_wordcloud <- function(df, sentence_column) {
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
  
  # Filter to improve visualization; i.e. include only interesting words
  stdDev_count <- round(sd(words_df$n, na.rm = TRUE))
  stdDev_sentiment <- sd(words_df$avg_sentiment, na.rm = TRUE)
  words_df <- words_df %>%
    filter(abs(n) > stdDev_count | abs(avg_sentiment) >= stdDev_sentiment)
  
  wordcloud_plot <- ggplot(words_df, aes(label = word, size = n, color = color_score)) +
    geom_text_wordcloud(show.legend = TRUE) +
    scale_size_area(max_size = 15) +
    scale_color_gradient2(low = "red", high = "blue", midpoint = 0.5, mid = "grey90") +
    theme_minimal() +
    theme(legend.position = "right", legend.title = element_text(size = 12), legend.text = element_text(size = 10)) +
    labs(color = "Sentiment", size = "Frequency")
  
  return(wordcloud_plot)
}

# Helper function for creating a map plot
create_map_plot <- function(df, region_column, value_column) {
  df[[region_column]] <- tolower(df[[region_column]])
  
  # Extract the value for 'Unspecified' before merging
  unspecified_value <- df %>% filter(.[[region_column]] == "unspecified") %>% pull(value_column)
  # Remove 'Unspecified' from df to avoid issues in merging
  df <- df %>% filter(.[[region_column]] != "unspecified")
  
  us_map <- map_data("state")
  us_map$region <- tolower(us_map$region)
  
  merged_data <- merge(us_map, df, by.x = "region", by.y = region_column, all.x = TRUE)
  merged_data <- merged_data[order(merged_data$order),]
  
  p <- ggplot() +
    geom_polygon(data = merged_data, aes(x = long, y = lat, group = group, fill = get(value_column)), color = "grey50") +
    scale_fill_gradient(low = "lightblue", high = "red", na.value = "grey90", name = "Percent") +
    labs(title = "Respondents by State", x = "", y = "") +
    theme_minimal() +
    theme(axis.text = element_blank(), axis.title = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank())

  # If there's a value for 'Unspecified', add an annotation
  if (!is.na(unspecified_value) && length(unspecified_value) > 0) {
    p <- p + annotate("text", x = Inf, y = Inf, label = paste("Unspecified:", unspecified_value, "%"), hjust = 1.1, vjust = 2, size = 5, color = "red")
  }
    
  return(p)
}

# Helper function for creating a histogram plot
create_histogram_plot <- function(df, value_column, count_column) {
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
  
  return(p)
}

# Helper function for creating a categorical plot
create_categorical_plot <- function(df, value_column, count_column) {
  # Define the desired order of categories
  desired_order <- c("0", "1", "2", "3", "4", "5", "10+","Increased", "Improved", "Expanded", "Expanding", "Increase", "Decreased", "Worsened", "Reduced", "Reducing", "Decrease", "Remained Stable", "Maintaining", "Remain the same", "1 to 2", "1 to 3", "3 to 5", "1 to 5", "4 to 8", "6 to 8", "8+", "9 to 13", "13+", "6 to 15", "16 to 30", "31 to 50", "51 to 75", "76 to 100", "100+", "101 to 140", "200 to 300", "More Optimistic", "About the Same", "More Pessimistic", "Don't Know", "Unspecified")

  # Convert the value column to a factor and specify the levels explicitly based on desired order
  df[[value_column]] <- factor(df[[value_column]], levels = desired_order)
  
  # Generate the bar plot
  p <- ggplot(df, aes(x = .data[[value_column]], y = .data[[count_column]])) +
    geom_bar(stat = "identity", color = "black") + # Use identity to use count values directly
    theme_minimal() +
    labs(x = value_column, y = "Count", title = paste("Count of", value_column)) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Uncommented for label readability

  
  return(p)
}

# Function to generate a bar chart
generate_bar_chart <- function(df, category_column, value_column) {
  validate_parameters(df, c(category_column, value_column))
  
  df <- reorder_factor_levels(df, category_column, value_column)
  
  p <- create_bar_chart(df, category_column, value_column, "Bar Chart")

  print(p)
}

# Function to generate a stacked bar chart
generate_stacked_bar_chart <- function(df, x_value_column, y_value_column, fill_column) {
  validate_parameters(df, c(x_value_column, y_value_column, fill_column))
  
  df <- reorder_factor_levels(df, x_value_column, y_value_column)
  
  # Ensure all categories have all ranks, fill missing values with 0
  df <- df %>%
    tidyr::complete(Response, Rank, fill = list(Metric = 0))
  
  p <- create_stacked_bar_chart(df, x_value_column, y_value_column, fill_column, "Stacked Bar Chart")
  
  print(p)
}

# Function to generate a word cloud
generate_wordcloud <- function(df, sentence_column) {
  validate_parameters(df, sentence_column)
  
  wordcloud_plot <- create_wordcloud(df, sentence_column)
  
  print(wordcloud_plot)
}

# Function to generate a map plot
generate_map_plot <- function(df, region_column, value_column) {
  validate_parameters(df, c(region_column, value_column))
  
  map_plot <- create_map_plot(df, region_column, value_column)
  
  print(map_plot)
}

# Function to generate a histogram plot
generate_histogram_plot <- function(df, value_column, count_column) {
  validate_parameters(df, c(value_column, count_column))
  
  histogram_plot <- create_histogram_plot(df, value_column, count_column)
  
  print(histogram_plot)
}

# Function to generate a categorical plot
generate_categorical_plot <- function(df, value_column, count_column) {
  validate_parameters(df, c(value_column, count_column))
  
  categorical_plot <- create_categorical_plot(df, value_column, count_column)
  
  print(categorical_plot)
}
