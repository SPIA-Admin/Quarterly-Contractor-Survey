library(ggplot2)
library(dplyr)
library(forcats) 
library(tidyr)
library(ggwordcloud)
library(tidytext)
library(syuzhet)
library(maps)
library(viridis)
library(extrafont)
library(extrafontdb)
library(systemfonts)

#https://www.cararthompson.com/posts/2024-01-12-using-fonts-in-r-for-dataviz/2024-01-12_getting-fonts-to-work
#https://isabella-b.com/blog/ggplot2-theme-elements-reference/ggplot2-theme-elements-reference-v2_hu8994090e1960a0a71878a3756da20076_580819_2000x2000_fit_lanczos_2.png

viridis_Palette <- "viridis"

# Define the infographic theme with the viridis color palette
infographic_theme <- function(){ 
  font <- "Verdana"   #assign font family up front
  theme_minimal() %+replace%    #replace elements we want to change
    theme(
      #grid elements
       panel.grid.major = element_blank(),    #strip major gridlines
       #panel.grid.minor = element_blank(),    #strip minor gridlines
       #axis.ticks = element_blank(),          #strip axis ticks

       plot.background = element_rect(fill = "#FFFFF4", colour = "black"),
       
       # panel.grid.minor = element_line(color = "#8E5BA8"),

      #since theme_minimal() already strips axis lines,
      #we don't need to do that again


      #text elements
      plot.title = element_text(             #title
        family = font,            #set font family
        face = 'bold',            #bold typeface
        colour = "#374151",
        size = 20,                #set font size
        hjust = 0,                #left align
        vjust = 1                #raise slightly
        ),
      plot.title.position = "plot",

      plot.subtitle = element_text(
        family = font,
        size = 14,
        hjust = 0,
        vjust = 1),

      
      plot.caption = element_text(
        family = font,
        size = 9,
        hjust = 1),
      plot.caption.position = "plot",

      axis.title = element_text(
        family = font,
        size = 10,
        colour = "#374151",
        face = "bold"),

      axis.text = element_text(
        family = font,
        size = 9,
        colour = "#374151",
        face = "bold",),

      axis.text.x = element_text(            #margin for axis text
        margin=margin(5, b = 10)),

      #since the legend often requires manual tweaking
      #based on plot content, don't define it here


    # strip.text = element_text(family = "Impact", colour = "white"),
     strip.background = element_rect(fill = "#8E5BA8")
  )
}

# Define a function to create a viridis color scale
create_viridis_scale <- function(direction = 1, continuous = TRUE, limits = NULL) {
  if (continuous) {
    scale_fill_viridis_c(option = viridis_Palette, direction = direction, limits = limits)  # Continuous color scale
  } else {
    scale_fill_viridis_d(option = viridis_Palette, direction = direction, limits = limits)  # Discrete color scale
  }
}

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
create_bar_chart <- function(df, x_column, y_column, title, subtitle) {
  p <- ggplot(df, aes(x = .data[[x_column]], y = .data[[y_column]], fill = "#374151" )) +
    geom_bar(stat = "identity", position = "dodge") +  # Use identity to use count values directly
    coord_flip() +
    infographic_theme() +
    labs(x = "", y = "% of Respondents", title = title, subtitle = subtitle) +
    theme(legend.position = "none") +
    create_viridis_scale(continuous = FALSE) 
  
  return(p)
}

# Helper function for creating a stacked bar chart
create_stacked_bar_chart <- function(df, x_column, y_column, fill_column, title, subtitle) {
  
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
    infographic_theme() +
    labs(x = "", y = "% of Respondents", title = title, subtitle = subtitle) +
    #theme(axis.text.y = element_text(angle = 0, hjust = 1)) +
    create_viridis_scale(continuous = FALSE, limits = rev(level_order))  # Apply viridis color scale

  return(p)
}

# Helper function for creating a word cloud
create_wordcloud <- function(df, sentence_column, title, subtitle) {
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
    scale_color_viridis_c(option = viridis_Palette) +  # Use viridis color scale
    infographic_theme() +
    labs(color = "Sentiment", size = "Frequency", title = title, subtitle = subtitle)
    


  return(wordcloud_plot)
}

# Helper function for creating a map plot
create_map_plot <- function(df, region_column, value_column, title, subtitle) {
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
    geom_polygon(data = merged_data, aes(x = long, y = lat, group = group, fill = get(value_column))) +
    scale_fill_viridis_c(option = viridis_Palette, name = "Percent") +  # Use viridis color scale
    labs(title = title, subtitle = subtitle, x = "", y = "") +
    infographic_theme()+
    theme(axis.text.x = element_blank(), axis.text.y = element_blank())

  
  # If there's a value for 'Unspecified', add an annotation
  if (!is.na(unspecified_value) && length(unspecified_value) > 0) {
    p <- p + annotate("text", x = Inf, y = Inf, label = paste("Unspecified:", unspecified_value, "%"), hjust = 1, vjust = 2, size = 4, color = "#374151")
  }
    
  return(p)
}

# Helper function for creating a histogram plot
create_histogram_plot <- function(df, value_column, count_column, title, subtitle) {
  # Convert value_column where possible and create a numeric version of count_column
  # df <- df %>%
  #   mutate(numeric_value = as.numeric(as.character(.data[[value_column]])),
  #          numeric_count = as.numeric(as.character(.data[[count_column]])))
  df <- df %>%
    mutate(numeric_value = as.character(.data[[value_column]]),
           numeric_count = as.numeric(as.character(.data[[count_column]])))
  
  # # Expand the dataframe for numeric values
  # df_expanded <- df %>%
  #   rowwise() %>%
  #   do(data.frame(numeric_value = rep(.$numeric_value, .$numeric_count))) %>%
  #   ungroup()
  # 
  # # Remove rows with NA in numeric_value (including 'Unspecified' if not numeric)
  # df_expanded <- df_expanded %>% filter(!is.na(numeric_value))
  
  # Generate the histogram for numeric values
 # p <- ggplot(df, aes(x = .data[[value_column]], y = .data[[count_column]], fill="#374151")) +
 #   geom_histogram(stat = "identity", position = "dodge") +
 #       infographic_theme() +
 #    labs(x = "", y = "% of Respondents", title = title, subtitle = subtitle) +
 #    theme(legend.position = "none") +
 #    create_viridis_scale(continuous = FALSE)
 
 p <- ggplot(df, aes(x = .data[[value_column]], y = .data[[count_column]], fill="#374151")) +
   geom_bar(stat = "identity", position = "dodge") +
   infographic_theme() +
   labs(x = "", y = "% of Respondents", title = title, subtitle = subtitle) +
   theme(legend.position = "none") +
   create_viridis_scale(continuous = FALSE)
    
  # Extract counts for 'Unspecified'
  #special_counts <- df %>% filter(.data[[value_column]] == "Unspecified") %>% summarise(TotalUnspecified = sum(numeric_count, na.rm = TRUE))
  
  return(p)
}

# Helper function for creating a categorical plot
create_categorical_plot <- function(df, value_column, count_column, title, subtitle) {
  # Define the desired order of categories
  desired_order <- c("0", "1", "2", "3", "4", "5", "10+","Increased", "Improved", "Expanded", "Expanding", "Increase", "Decreased", "Worsened", "Reduced", "Reducing", "Decrease", "Remained Stable", "Maintaining", "Remain the same", "1 to 2", "1 to 3", "3 to 5", "1 to 5", "4 to 8", "6 to 8", "8+", "9 to 13", "13+", "6 to 15", "16 to 30", "31 to 50", "51 to 75", "76 to 100", "100+", "101 to 140", "200 to 300", "More Optimistic", "About the Same", "More Pessimistic", "Don't Know", "Unspecified")

  # Convert the value column to a factor and specify the levels explicitly based on desired order
  df[[value_column]] <- factor(df[[value_column]], levels = desired_order)
  
  # Generate the bar plot
  p <- ggplot(df, aes(x = .data[[value_column]], y = .data[[count_column]], fill="#374151")) +
    geom_bar(stat = "identity", position = "dodge") + # Use identity to use count values directly
    infographic_theme() +
    labs(x = "", y = "% of Respondents", title = title, subtitle = subtitle) +
    theme(legend.position = "none") +
    create_viridis_scale(continuous = FALSE)

  return(p)
}

# Function to generate a bar chart
generate_bar_chart <- function(df, category_column, value_column, title, subtitle) {
  validate_parameters(df, c(category_column, value_column))
  
  df <- reorder_factor_levels(df, category_column, value_column)
  
  p <- create_bar_chart(df, category_column, value_column, title, subtitle)

  #print(p)
  return(p)
}

# Function to generate a stacked bar chart
generate_stacked_bar_chart <- function(df, x_value_column, y_value_column, fill_column, title, subtitle) {
  validate_parameters(df, c(x_value_column, y_value_column, fill_column))
  
  df <- reorder_factor_levels(df, x_value_column, y_value_column)
  
  # Ensure all categories have all ranks, fill missing values with 0
  df <- df %>%
    tidyr::complete(Response, Rank, fill = list(Metric = 0))
  
  p <- create_stacked_bar_chart(df, x_value_column, y_value_column, fill_column, title, subtitle)
  
  #print(p)
  return(p)
}

# Function to generate a word cloud
generate_wordcloud <- function(df, sentence_column, title, subtitle) {
  validate_parameters(df, sentence_column)
  
  wordcloud_plot <- create_wordcloud(df, sentence_column, title, subtitle)
  
  #print(wordcloud_plot)
  return(wordcloud_plot)
}

# Function to generate a map plot
generate_map_plot <- function(df, region_column, value_column, title, subtitle) {
  validate_parameters(df, c(region_column, value_column))
  
  map_plot <- create_map_plot(df, region_column, value_column, title, subtitle)
  
  #print(map_plot)
  return(map_plot)
}

# Function to generate a histogram plot
generate_histogram_plot <- function(df, value_column, count_column, title, subtitle) {
  validate_parameters(df, c(value_column, count_column))
  
  histogram_plot <- create_histogram_plot(df, value_column, count_column, title, subtitle)
  
  #print(histogram_plot)
  return(histogram_plot)
}

# Function to generate a categorical plot
generate_categorical_plot <- function(df, value_column, count_column, title, subtitle) {
  validate_parameters(df, c(value_column, count_column))
  
  categorical_plot <- create_categorical_plot(df, value_column, count_column, title, subtitle)
  
  #print(categorical_plot)
  return(categorical_plot)
}
