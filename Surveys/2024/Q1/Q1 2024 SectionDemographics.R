# 
# # Function to create ggplots for two columns
# create_plots <- function() {
# # Create bar plots for categorical data
# # Plot for Service Provider
#   plot1 <- ggplot(survey_data, aes(x = .data[[survey_categories$Demographics$Provider]])) +
#   geom_bar() +
#   theme_minimal() +
#   labs(title = "Distribution of Service Providers", x = "Service Provider", y = "Count")
# 
# # Plot for Services Contracted For
#   plot2 <- ggplot(survey_data, aes(x = .data[[survey_categories$Demographics$Services]])) +
#   geom_bar() +
#   theme_minimal() +
#   labs(title = "Distribution of Services Contracted For", x = "Services", y = "Count")
# 
# return(list(Plot1 = plot1, Plot2 = plot2))
# }
viridis_option <- "D"
SPIA_theme <- theme_economist()

# Function to create demographic visualizations
create_demographic_visualizations <- function(data) {
  # Bar Chart for Provider
  provider_plot <- ggplot(data) +
    aes(x = .data[[survey_categories$Demographics$Provider]],fill = .data[[survey_categories$Demographics$Provider]]) +
    geom_bar() +
    scale_fill_viridis(option = viridis_option, direction = 1, discrete = TRUE) +
    SPIA_theme +
    theme(legend.position = "bottom")+
    labs(title = "Distribution of Service Providers", x = "Service Provider", y = "Count") 
  
  # Bar Chart for Services Contracted For
  services_plot <- ggplot(data)+
    aes(x = .data[[survey_categories$Demographics$Services]],fill =.data[[survey_categories$Demographics$Services]]) +
    geom_bar() +
    scale_fill_viridis(option = viridis_option, direction = 1, discrete = TRUE) +
    SPIA_theme +
    theme(legend.position = "bottom")+
    labs(title = "Services Contracted For", x = "Services", y = "Count")
  
  # Bar Chart for Primary Territories
  territory_plot <- ggplot(data)+
    aes(x = .data[[survey_categories$Demographics$Territory]], fill = .data[[survey_categories$Demographics$Territory]]) +
    geom_bar() +
    scale_fill_viridis(option = viridis_option, direction = 1, discrete = TRUE) +
    SPIA_theme +
    theme(legend.position = "bottom")+
    labs(title = "Primary Territories of Routes", x = "Territories", y = "Count")
  
  # Pie Chart for Delivery Type (Residential vs Business)
  delivery_type_counts <- table(data[[survey_categories$Demographics$DeliveryType]])
  # delivery_type_plot <- ggplot(as.data.frame(delivery_type_counts), aes(x = "", y = Freq, fill = Var1)) +
  #   geom_bar(width = 1, stat = "identity") +
  #   coord_polar("y", start = 0) +
  #   scale_fill_viridis(discrete = TRUE, option=viridis_option) +
  #   labs(title = "Delivery Type Proportions", fill = "Delivery Type")
  delivery_type_plot <- ggplot(as.data.frame(delivery_type_counts))+
    aes(x = "", y = Freq, fill = Var1) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar("y", start = 0) +
    scale_fill_viridis(option = viridis_option, direction = 1, discrete = TRUE) +
    SPIA_theme +
    theme(legend.position = "bottom")+
    labs(title = "Delivery Type Proportions", fill = "Delivery Type")

  
  return(list(ProviderPlot = provider_plot, ServicesPlot = services_plot, TerritoryPlot = territory_plot, DeliveryTypePlot = delivery_type_plot))
}