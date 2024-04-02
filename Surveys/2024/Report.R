library(duckdb)
library(dplyr)
library(ggplot2)
library(grid)
library(extrafont)
library(extrafontdb)

#loadfonts()

# Ensure the directory for plots exists
plots_dir <- "./plots"
if (!dir.exists(plots_dir)) {
  dir.create(plots_dir)
}

source(".\\Surveys\\2024\\ReportHelper.R")

# Load survey_categories and columns_to_normalize
source(".\\Surveys\\2024\\Q1 2024 SectionsAndColumns.R")
# Load duckdb helper functions like check_exists
source(".\\Surveys\\2024\\DuckDbHelper.R")


query_and_visualize <- function(con, category, question_details) {
  vis_title <- question_details$title
  vis_subTitle <- question_details$subtitle
  sql_query <- question_details$sql_query
  df <- dbGetQuery(con, sql_query)
  
  if (nrow(df) == 0) {
    message("No data available for ", category, " - ", question_details$question)
    return()
  }
  
  switch(question_details$viz_type,
         bar = {
            p <- generate_bar_chart(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         StackedBar = {
           p <-generate_stacked_bar_chart(df, "Response", "Metric", "Rank", vis_title, vis_subTitle)
         },         
         wordcloud = {
           p <-generate_wordcloud(df, "Response", vis_title, vis_subTitle)
         },
         map = {
           p <-generate_map_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         histogram = {
           p <-generate_histogram_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         categorical = {
           p <-generate_categorical_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         {
           message("Visualization type not recognized.")
         }
  )
  
  return(p)
}

# Open connection to the existing DuckDB database
con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb")

# Function to check if a column (based on survey question) needs normalization
needs_normalization <- function(category, column_key) {
  full_key <- paste(category, column_key, sep="$")
  return(full_key %in% names(columns_to_normalize))
}

#Iterate through survey categories and their respective questions
# for (category_name in names(survey_categorie_caharts)) {
#   category_questions <- survey_categorie_caharts[[category_name]]
#   for (question_key in names(category_questions)) {
#     question_details <- category_questions[[question_key]]
#     print(query_and_visualize(con, category_name, question_details))
#   }
# }

#cairo_pdf("demographics_report.pdf", width = 10, height = 20, family = "Verdana") # Adjust 'width' and 'height' as needed


vplayout <- function(x,y){
  viewport(layout.pos.row = x, layout.pos.col = y)
}
grid.newpage()

vp <- viewport(layout = grid.layout(4,3))
pushViewport(vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.95, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Brought to you by the Service Provider Insight Alliance (SPIA)", vjust = 0, y = unit(0.9175, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))

p1 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$Provider) 
p2 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$Services)
p3 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$Location)
p4 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$Territory)
p5 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$DeliveryType)
p6 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$AdditionalAgreements)
p7 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$OperationStart)

print(p1, vp = vplayout(1,1))
print(p2, vp = vplayout(2,1))
print(p3, vp = vplayout(1,2))
print(p4, vp = vplayout(2,2))



# vp <- viewport(width=0.5, height=0.5)
# pushViewport(vp)
# grid.rect(gp=gpar(col="blue"))
# grid.text("Quarter of the device",
#           y=unit(1, "npc") - unit(1, "lines"), gp=gpar(col="blue"))
# pushViewport(vp)
# grid.rect(gp=gpar(col="red"))
# grid.text("Quarter of the parent viewport",
#           y=unit(1, "npc") - unit(1, "lines"), gp=gpar(col="red"))
# popViewport(2)




############################################
############################################
# Ensure all actions are completed and cleanup
dbDisconnect(con) # Close the connection to commit all changes
rm(con) # Remove the connection object
gc() # Force garbage collection to free up resources





