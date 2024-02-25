library(readxl)
#library(dplyr)
library(ggplot2)
#library(viridisLite)
library(viridis)
library(ggthemes)

# Replace with the path to your Excel file
file_path <- ".\\Surveys\\2024\\Q1 2024 Contractor Survey (Responses).xlsx"

# Read the Excel file
survey_data <- read_excel(file_path)

# Load survey_categories
source(".\\Surveys\\2024\\Q1 2024 SectionsAndColumns.R")
source(".\\Surveys\\2024\\Q1 2024 SectionDemographics.R")

# Open a PDF device
#pdf("demographics_report.pdf", width = 8, height = 11) # Adjust 'width' and 'height' as needed


# Create visualizations
demographic_plots <- create_demographic_visualizations(survey_data)

print(demographic_plots$ProviderPlot)

print(demographic_plots$ServicesPlot)

print(demographic_plots$TerritoryPlot)

print(demographic_plots$DeliveryTypePlot)


# Close the PDF device
#dev.off()