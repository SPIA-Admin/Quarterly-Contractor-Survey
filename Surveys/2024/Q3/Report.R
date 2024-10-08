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

source(".\\Surveys\\2024\\Q3\\ReportHelper.R")
source(".\\Surveys\\2024\\Q3\\SectionsAndColumns.R")
source(".\\Surveys\\2024\\Q3\\DuckDbHelper.R")

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
           a <- paste(question_details$quote_of_intrest, question_details$response_summary)
           count_threshold <- question_details$count_threshold
           sentiment_threshold <- question_details$sentiment_threshold
           p <- generate_wordcloud(df, "Response", vis_title, vis_subTitle, a, count_threshold, sentiment_threshold)
         },
         map = {
           p <- generate_map_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         histogram = {
           options <- question_details$options
           options_vector <- unlist(strsplit(options, ","))          
           if (length(options_vector) > 0) {
             all_options_df <- data.frame(Response = options_vector, Metric = rep(0, length(options_vector)))
             merged_df <- merge(all_options_df, df, by = "Response", all = TRUE, suffixes = c(NA, ""))
             merged_df$Metric[is.na(merged_df$Metric)] <- 0
             df <- subset(merged_df, select = c(Response, Metric))
           }
           
           p <- generate_histogram_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         categorical = {
           # options <- question_details$options
           # options_vector <- unlist(strsplit(options, ","))          
           # if (length(options_vector) > 0) {
           #   all_options_df <- data.frame(Response = options_vector, Metric = rep(0, length(options_vector)))
           #   merged_df <- merge(all_options_df, df, by = "Response", all = TRUE, suffixes = c(NA, ""))
           #   merged_df$Metric[is.na(merged_df$Metric)] <- 0
           #   df <- subset(merged_df, select = c(Response, Metric))
           # }
           
           p <- generate_categorical_plot(df, "Response", "Metric", vis_title, vis_subTitle)
         },
         {
           message("Visualization type not recognized.")
         }
  )
  
  return(p)
}



con <- dbConnect(duckdb::duckdb(), dbdir = ".\\Data\\duckdb_database.duckdb")
spia_logo <- as.raster(readPNG("~/Quarterly-Contractor-Survey/SPIA_Logo.png"))
cat_just <- c("left","bottom")

needs_normalization <- function(category, column_key) {
  full_key <- paste(category, column_key, sep="$")
  return(full_key %in% names(columns_to_normalize))
}

cairo_pdf("Quarterly_Contractor_Survey_2024_Q3.pdf", width = 11, height = 17, family = "Verdana", onefile = TRUE)
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
grid.text("2024 - Q3", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Demographics", just = cat_just, x = unit(.01, "npc"), y = unit(.1, "npc"), gp = gpar(fontfamily = "Impact", col = "black", cex = 4))
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
grid.raster(spia_logo, x = .75, y = .25, default.units = "npc", interpolate = FALSE)

#############Financials################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q3", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Financials", just = cat_just, x = unit(.01, "npc"), y = unit(.1, "npc"), gp = gpar(fontfamily = "Impact", col = "black", cex = 4))
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
grid.raster(spia_logo, x = .75, y = .25, default.units = "npc", interpolate = FALSE)

#############Operations################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q3", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Operations", just = cat_just, x = unit(.01, "npc"), y = unit(.1, "npc"), gp = gpar(fontfamily = "Impact", col = "black", cex = 4))
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
grid.raster(spia_logo, x = .75, y = .25, default.units = "npc", interpolate = FALSE)

#############Operations2################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q3", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Operations", just = cat_just, x = unit(.01, "npc"), y = unit(.1, "npc"), gp = gpar(fontfamily = "Impact", col = "black", cex = 4))
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
grid.raster(spia_logo, x = .75, y = .25, default.units = "npc", interpolate = FALSE)

#############SentimentAndOutlook################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q3", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Sentiment and Outlook", just = cat_just, x = unit(.01, "npc"), y = unit(.1, "npc"), gp = gpar(fontfamily = "Impact", col = "black", cex = 4))
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
grid.raster(spia_logo, x = .75, y = .25, default.units = "npc", interpolate = FALSE)

#############SentimentAndOutlook2################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q3", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Sentiment and Outlook", just = cat_just, x = unit(.01, "npc"), y = unit(.1, "npc"), gp = gpar(fontfamily = "Impact", col = "black", cex = 4))
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
grid.raster(spia_logo, x = .75, y = .25, default.units = "npc", interpolate = FALSE)

#############AnecdotalInsights################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q3", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Anecdotal Insights", just = cat_just, x = unit(.01, "npc"), y = unit(.1, "npc"), gp = gpar(fontfamily = "Impact", col = "black", cex = 4))
popViewport(1)

# Body Section
pushViewport(body_vp)

p1 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$SpecificChallenge)

p2 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$SuccessStory)

p3 <- query_and_visualize(con, survey_categorie_caharts$AnecdotalInsights, survey_categorie_caharts$AnecdotalInsights$SuggestionForImprovement)

grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))

lay <- rbind(c(1,1,1,1,1,1,1),
             c(2,2,2,2,2,2,2),
             c(3,3,3,3,3,3,3))

#body_grob = arrangeGrob(p1,p2,p3, layout_matrix = lay)
body_grob = arrangeGrob(p1,p2,p3, nrow=3)
grid.draw(body_grob)
#popViewport(1)
popViewport()

# Footer Section
pushViewport(footer_vp)
grid.rect(gp = gpar(fill = "#374151", col = "#374151"))
grid.text("© 2024 Service Provider Insight Alliance", vjust = 0, y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#FFFFF4", cex = 0.8))
popViewport(1)
grid.raster(spia_logo, x = .75, y = .25, default.units = "npc", interpolate = FALSE)

#############AnecdotalInsights2################
grid.newpage()
pushViewport(header_vp)
grid.rect(gp = gpar(fill = "#FFFFF4", col = "#FFFFF4"))
# Header Section
grid.text("Contractor Survey", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 8.5, alpha = 0.3))
grid.text("2024 - Q3", y = unit(0.4, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
grid.text("Anecdotal Insights", just = cat_just, x = unit(.01, "npc"), y = unit(.1, "npc"), gp = gpar(fontfamily = "Impact", col = "black", cex = 4))
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
grid.raster(spia_logo, x = .75, y = .25, default.units = "npc", interpolate = FALSE)

dev.off()

# Cleanup
dbDisconnect(con)
rm(con)
gc()
