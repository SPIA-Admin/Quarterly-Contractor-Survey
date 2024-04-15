library(duckdb)
library(dplyr)
library(ggplot2)
library(grid)
library(gridExtra)
library(gridtext)
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

cairo_pdf("Quarterly_Contractor_Survey_2024_Q1.pdf", width = 11, height = 17, family = "Verdana", onefile = TRUE)
#https://bookdown.org/rdpeng/RProgDA/the-grid-package.html#viewports
vplayout <- function(x,y){
  viewport(layout.pos.row = x, layout.pos.col = y)
}

#########Demographics#######################
# Header Section
grid.newpage()
header_vp <- viewport(x = 0, y = 0.9, 
                      width = 1, height = 0.1,
                      just = c("left", "bottom"))

pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
popViewport(1)

# Body Section
body_vp <- viewport(x = 0, y = 0.025, 
                    width = 1, height = 0.875,
                    just = c("left", "bottom"))
pushViewport(body_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

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

body_grob = arrangeGrob(p1,p2,p3,p4,p5,p6,p7, layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

# Footer Section
footer_vp <- viewport(x = 0, y = 0, 
                      width = 1, height = 0.025,
                      just = c("left", "bottom"))

pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))

grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)

#############Financials################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
popViewport(1)

# Body Section
pushViewport(body_vp)

p1 <- query_and_visualize(con, survey_categorie_caharts$Financials, survey_categorie_caharts$Financials$RevenuePercentage)
p2 <- query_and_visualize(con, survey_categorie_caharts$Financials, survey_categorie_caharts$Financials$FinancialHealth)
p3 <- query_and_visualize(con, survey_categorie_caharts$Financials, survey_categorie_caharts$Financials$YearOverYearRevenue)
p4 <- query_and_visualize(con, survey_categorie_caharts$Financials, survey_categorie_caharts$Financials$YearOverYearProfit)
p5 <- query_and_visualize(con, survey_categorie_caharts$Financials, survey_categorie_caharts$Financials$FinancialChallenges)

grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

lay <- rbind(c(2,2,2,2,2),
             c(2,2,2,2,2),
             c(1,1,3,3,3),
             c(1,1,3,3,3),
             c(1,1,4,4,4),
             c(1,1,4,4,4),
             c(5,5,5,5,5),
             c(5,5,5,5,5),
             c(5,5,5,5,5))

body_grob = arrangeGrob(p1,p2,p3,p4,p5, layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

# Footer Section
pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)

#############Operations################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
popViewport(1)

# Body Section
pushViewport(body_vp)

p1 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$OperationalConstancy)
p2 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$OperationalEfficiencyChange)
p3 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$CurrentOperationalEfficiency)
p4 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$OperationalChallenges)
p5 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$RoutesPerWeek)
p6 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$RoutesExpansion)
p7 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$DriversPerWeek)
p8 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$HelpersPerWeek)
p9 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$ManagersPerWeek)
p10 <- query_and_visualize(con, survey_categorie_caharts$Operations, survey_categorie_caharts$Operations$AdminPositions)

grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

lay <- rbind(c(2,2,2,2,2,2),
             c(2,2,2,2,2,2),
             c(3,3,3,3,3,3),
             c(3,3,3,3,3,3),
             c(5,5,5,5,5,5),
             c(5,5,5,5,5,5),
             c(7,7,7,8,8,8),
             c(7,7,7,8,8,8),
             c(9,9,9,10,10,10),
             c(9,9,9,10,10,10))




body_grob = arrangeGrob(p2,p3,p5,p7,p8,p9,p10,  layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

# Footer Section
pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)
#############Operations2################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
popViewport(1)

# Body Section
pushViewport(body_vp)

grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

#1,4,6
lay <- rbind(c(1,1,6,6),
             c(1,1,6,6),
             c(4,4,4,4),
             c(4,4,4,4),
             c(4,4,4,4),
             c(4,4,4,4))




body_grob = arrangeGrob(p1,p4,p6,  layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

# Footer Section
pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)

#############SentimentAndOutlook################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
popViewport(1)

# Body Section
pushViewport(body_vp)

p1 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$BusinessHealthPast)
p2 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$BusinessHealthPresent)
p3 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$BusinessHealthFuture)
p4 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$BusinessGrowthSentiment)
p5 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$OperationalChallengeSentiment)
p6 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$ProfitabilitySentiment)

grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

lay <- rbind(c(1,2,3),
             c(1,2,3),
             c(4,4,4),
             c(5,5,5),
             c(6,6,6))

body_grob = arrangeGrob(p1,p2,p3,p4,p5,p6, layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

# Footer Section
pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)

#############SentimentAndOutlook2################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
popViewport(1)

# Body Section
pushViewport(body_vp)

p1 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$ContractStabilityConfidence)
p2 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$CompanyStabilityConfidence)
p3 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$TopConcerns)
p4 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$RoutePlans)
p5 <- query_and_visualize(con, survey_categorie_caharts$SentimentAndOutlook, survey_categorie_caharts$SentimentAndOutlook$DemandPrediction)

grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

lay <- rbind(c(3,3,3,3,1,1,1),
             c(3,3,3,3,1,1,1),
             c(3,3,3,3,2,2,2),
             c(3,3,3,3,2,2,2),
             c(5,5,5,5,4,4,4),
             c(5,5,5,5,4,4,4))

body_grob = arrangeGrob(p1,p2,p3,p4,p5, layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

# Footer Section
pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)

#############AnecdotalInsights################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
popViewport(1)

# Body Section
pushViewport(body_vp)

p1 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$SpecificChallenge)
p1s <- textbox_grob(survey_categorie_caharts$AnecdotalInsights$SpecificChallenge$response_summary, x = unit(0.5, "npc"), y = unit(0.5, "npc"), gp = gpar(col = "black", cex = 1))
p1q <- textbox_grob(survey_categorie_caharts$AnecdotalInsights$SpecificChallenge$quote_of_intrest, x = unit(0.5, "npc"), y = unit(0.5, "npc"), gp = gpar(col = "black", cex = 1))

p2 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$SuccessStory)
p2s <- textbox_grob(survey_categorie_caharts$AnecdotalInsights$SuccessStory$response_summary, x = unit(0.5, "npc"), y = unit(0.5, "npc"), gp = gpar(fontsize = 10))
p2q <- textbox_grob(survey_categorie_caharts$AnecdotalInsights$SuccessStory$quote_of_intrest, x = unit(0.5, "npc"), y = unit(0.5, "npc"), gp = gpar(fontsize = 12))

p3 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$SuggestionForImprovement)
p3s <- textbox_grob(survey_categorie_caharts$AnecdotalInsights$SuggestionForImprovement$response_summary, x = unit(0.5, "npc"), y = unit(0.5, "npc"), gp = gpar(fontsize = 10))
p3q <- textbox_grob(survey_categorie_caharts$AnecdotalInsights$SuggestionForImprovement$quote_of_intrest, x = unit(0.5, "npc"), y = unit(0.5, "npc"), gp = gpar(fontsize = 12))

grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

lay <- rbind(c(1,1,1,3,3,3,3),
             c(2,2,2,3,3,3,3),
             c(2,2,2,3,3,3,3),
             
             c(5,5,5,5,4,4,4),
             c(5,5,5,5,6,6,6),
             c(5,5,5,5,6,6,6),
             
             c(7,7,7,9,9,9,9),
             c(8,8,8,9,9,9,9),
             c(8,8,8,9,9,9,9))

body_grob = arrangeGrob(p1q,p1s,p1,p2q,p2,p2s,p3q,p3s,p3, layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

# Footer Section
pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)

#############AnecdotalInsights2################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q1", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
popViewport(1)

# Body Section
pushViewport(body_vp)

p1 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$IndustryChangeImpact)
p2 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$RelationshipWithCompany)
p3 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$ChallengesAndRewards)

grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

lay <- rbind(c(1,1,1,1,1,1,1),
             c(2,2,2,2,2,2,2),
             c(3,3,3,3,3,3,3))

body_grob = arrangeGrob(p1,p2,p3, layout_matrix = lay)
grid.draw(body_grob)
popViewport(1)

# Footer Section
pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)

dev.off()

# Cleanup
dbDisconnect(con)
rm(con)
gc()
