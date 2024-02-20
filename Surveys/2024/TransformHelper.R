# Function to create demographic visualizations
splitDelimitedDataColumn <- function(data, column) {
  # Generate unique identifiers if not already present
  if (!"response_id" %in% names(data)) {
    data <- data %>% mutate(response_id = row_number())
  }
  
  # Remove text between parentheses before normalizing the values
  data[[column]] <- str_remove_all(data[[column]], "\\(.*?\\)")
  
  # Replace "Federal, State, or Local Taxes" with "Federal State or Local Taxes"
  data[[column]] <- str_replace_all(data[[column]], "Federal, State, or Local Taxes", "Federal State or Local Taxes")
  
  # Normalize the values in the specified column
  column_data <- data %>%
    select(column) %>%
    separate_rows(column_name, sep = ", ") %>%
    distinct()
  
  # Assign unique identifier to each value
  column_data <- column_data %>% mutate(value_id = row_number())
  
  # Create the junction table
  dataJunctionColumn <- data %>%
    select(response_id, column) %>%
    separate_rows(column, sep = ", ") %>%
    left_join(column_data, by = column) %>%
    select(response_id, value_id)
  
  # Remove the original column from the data
  data <- data %>% select(-!!sym(column))
  
  # Return the modified data, column_data, and dataJunctionColumn as a list
  return(list(modified_data = data, normalized_data = column_data, junction_table = dataJunctionColumn))
}

sanitizeFileName <- function(name) {
  # Replace reserved characters with an underscore (or other character)
  sanitized_name <- gsub("[/\\\\:*?\"<>|]", "_", name)
  return(sanitized_name)
}