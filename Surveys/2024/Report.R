library(duckdb)
library(dplyr)
library(ggplot2)
library(grid)
library(gridExtra)
library(extrafont)
library(extrafontdb)
library(lattice)
library(png)

# Ensure the directory for plots exists
plots_dir <- "./plots"
if (!dir.exists(plots_dir)) {
  dir.create(plots_dir)
}

source(".\\Surveys\\2024\\ReportHelper.R")
source(".\\Surveys\\2024\\Q1 2024 SectionsAndColumns.R")
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
           p <- generate_stacked_bar_chart(df, "Response", "Metric", "Rank", vis_title, vis_subTitle)
         },         
         wordcloud = {
           p <- generate_wordcloud(df, "Response", vis_title, vis_subTitle)
         },
         map = {
           p <- generate_map_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         histogram = {
           p <- generate_histogram_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         categorical = {
           p <- generate_categorical_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         {
           message("Visualization type not recognized.")
         }
  )
  
  return(p)
}

con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb")

needs_normalization <- function(category, column_key) {
  full_key <- paste(category, column_key, sep="$")
  return(full_key %in% names(columns_to_normalize))
}

cairo_pdf("demographics_report.pdf", width = 11, height = 17, family = "Verdana")
#https://bookdown.org/rdpeng/RProgDA/the-grid-package.html#viewports
vplayout <- function(x,y){
  viewport(layout.pos.row = x, layout.pos.col = y)
}
grid.newpage()
#grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

#vp <- viewport(layout = grid.layout(4,3))
header_vp <- viewport(x = 0, y = 0.9, 
                      width = 1, height = 0.1,
                      just = c("left", "bottom"))

pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
#grid.text("Service Provider Demographics", vjust = 0, y = unit(0.01, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
popViewport(1)

body_vp <- viewport(x = 0, y = 0.025, 
                    width = 1, height = 0.875,
                    just = c("left", "bottom"))

pushViewport(body_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Body Section
p1 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$Provider) 
p2 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$Services)
p3 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$Location)
p4 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$Territory)
p5 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$DeliveryType)
p6 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$AdditionalAgreements)
p7 <- query_and_visualize(con, survey_categorie_caharts$Demographics, survey_categorie_caharts$Demographics$OperationStart)

#https://bookdown.org/rdpeng/RProgDA/the-grid-package.html#the-gridextra-package
#https://cran.r-project.org/web/packages/gridExtra/vignettes/arrangeGrob.html
lay <- rbind(c(1,1,5,5,2,2,2),
             c(4,4,4,3,3,3,3),
             c(4,4,4,6,6,6,6),
             c(7,7,7,7,7,7,7))

# grid.arrange(p1,p2,p3,p4,p5,p6,p7, layout_matrix = lay)
body_grob = arrangeGrob(p1,p2,p3,p4,p5,p6,p7, layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

footer_vp <- viewport(x = 0, y = 0, 
                      width = 1, height = 0.025,
                      just = c("left", "bottom"))

pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
# Footer Section
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)



dev.off()

# Cleanup
dbDisconnect(con)
rm(con)
gc()
