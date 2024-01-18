library(readxl)
library(dplyr)
library(ggplot2)

# Replace with the path to your Excel file
file_path <- ".\\Surveys\\2024\\Q1 2024 Contractor Survey (Responses).xlsx"

# Read the Excel file
survey_data <- read_excel(file_path)

# View the first few rows of the data
head(survey_data)

# Load survey_categories
source(".\\Surveys\\2024\\Q1 2024 SectionsAndColumns.R")
source(".\\Surveys\\2024\\Q1 2024 SectionDemographics.R")

plots <- create_plots()

# Now you can display or use the plots
#print(plots$Plot1)
#print(plots$Plot2)

# Open a PDF device
pdf("demographics_report.pdf", width = 8, height = 11) # Adjust 'width' and 'height' as needed


# Create visualizations
demographic_plots <- create_demographic_visualizations(survey_data)

# Print plots
# Page 1: Provider Plot
plot.new()
title("Demographics Analysis - Service Providers")
print(demographic_plots$ProviderPlot)
mtext("This bar chart shows the distribution of service providers contracted with by the survey respondents.", side = 1, line = 4, adj = 0)

# Page 2: Services Plot
plot.new()
title("Demographics Analysis - Services Contracted For")
print(demographic_plots$ServicesPlot)
mtext("This bar chart represents the types of services that respondents are contracted for.", side = 1, line = 4, adj = 0)

# Page 3: Territory Plot
plot.new()
title("Demographics Analysis - Primary Territories of Routes")
print(demographic_plots$TerritoryPlot)
mtext("The chart illustrates the primary territories of the respondents' routes, such as urban, suburban, and rural areas.", side = 1, line = 4, adj = 0)

# Page 4: Delivery Type Plot
plot.new()
title("Demographics Analysis - Delivery Type Proportions")
print(demographic_plots$DeliveryTypePlot)
mtext("This pie chart compares the percentage of deliveries made to residential addresses versus business addresses.", side = 1, line = 4, adj = 0)



# Close the PDF device
dev.off()