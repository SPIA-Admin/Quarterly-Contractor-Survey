# Organizing column names into lists based on categories
survey_categories <- list(
  Demographics = list(
    Provider = "Which company is your Service Provider agreement contracted with?",
    Services = "What is/are the service(s) you are contracted for?",
    Location = "In which state/territory/province is your contract based?",
    Territory = "What best describes the primary territories of your routes?",
    DeliveryType = "What percentage of your deliveries are to residential addresses versus business addresses?",
    AdditionalAgreements = "How many additional Service Provider agreements does your company have?",
    OperationStart = "When did your company begin operations under a Service Provider agreement?"
  ),
  Financials = list(
    RevenuePercentage = "Approximately what  percentage of your revenues comes directly from your Service Provider contract.",
    FinancialHealth = "On a scale of 1-5, how would you rate your company's financial health over the past year?",
    YearOverYearRevenue = "Over the past year, have your year-over-year revenues:",
    YearOverYearProfit = "Over the past year, have your year-over-year profit margins:",
    FinancialChallenges = "What are the major finical challenges you face?"
  ),
  Operations = list(
    OperationalConstancy = "On a scale of 1-5, how would you rate your company's operational constancy over the past year?",
    OperationalEfficiencyChange = "Over the past year, has your year-over-year operational efficiency:",
    CurrentOperationalEfficiency = "On a scale of 1-5, how would you rate your company's current operational efficiency?",
    OperationalChallenges = "What are the major operational challenges you face?",
    RoutesPerWeek = "How many routes in an average week are dispatch to service your contract?",
    RoutesExpansion = "Have you expanded or reduced your routes in the past year?",
    DriversPerWeek = "How many drivers are used to support your contract in an average week?",
    HelpersPerWeek = "How many helper/jumpers are used to support your contract in an average week?",
    ManagersPerWeek = "How many managers are used to support your contract in an average week?",
    AdminPositions = "How many administrative & executive (non-operations) positions does your company employ?"
  ),
  SentimentAndOutlook = list(
    BusinessHealthPast = "How would you rate the overall health of your business one year ago?",
    BusinessHealthPresent = "How would you currently rate the overall health of your business?",
    BusinessHealthFuture = "How would you rate your prediction for the overall health of your business one year from now?",
    BusinessGrowthSentiment = "Compared to the past year, how do you feel about the upcoming year in terms of business growth?",
    OperationalChallengeSentiment = "Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?",
    ProfitabilitySentiment = "Compared to the past year, how do you feel about the upcoming year in terms of profitability?",
    ContractStabilityConfidence = "How confident are you in the stability of your contract in the coming year?",
    CompanyStabilityConfidence = "How confident are you in the stability of the company you contracted with in the coming year?",
    TopConcerns = "What are your top three concerns for the future of your business?",
    RoutePlans = "Are you considering expanding, maintaining, or reducing your routes in the upcoming year?",
    DemandPrediction = "Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?"
  ),
  AnecdotalInsights = list(
    SpecificChallenge = "Can you share a specific challenge you've faced in the past year and how you addressed it?",
    SuccessStory = "Describe a recent success story or a significant milestone your company achieved.",
    SuggestionForImprovement = "If you could suggest one change to improve contractor relations, what would it be?",
    IndustryChangeImpact = "Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?",
    RelationshipWithCompany = "Share an experience that exemplifies your relationship with the company your contract is with.",
    ChallengesAndRewards = "What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?"
  ),
  SurveyFeedback = list(
    Feedback = "Please provide any feedback you have regarding this survey."
  )
)

# List of columns to be normalized
columns_to_normalize <- c(
  "Demographics$Services" = survey_categories$Demographics$Services,
  "Demographics$Territory" = survey_categories$Demographics$Territory,
  "Financials$FinancialChallenges" = survey_categories$Financials$FinancialChallenges,
  "Operations$OperationalChallenges" = survey_categories$Operations$OperationalChallenges
)





# bar
# wordcloud
# map
# stacked_bar
# histogram
# timeline
# line
# text_summary


survey_categorie_caharts <- list(
  # Demographics = list(
  #   Provider = list(
  #     question = "Which company is your Service Provider agreement contracted with?",
  #     viz_type = "bar",
  #     data_prep = "count",
  #     sql_query = "SELECT 
  #         COALESCE(\"Which company is your Service Provider agreement contracted with?\", 'Unspecified') AS Answer, 
  #         ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage 
  #         FROM Responses 
  #         GROUP BY \"Which company is your Service Provider agreement contracted with?\" 
  #         ORDER BY Percentage DESC"
  #   ),
  #   Services = list(
  #     question = "What is/are the service(s) you are contracted for?",
  #     viz_type = "bar",
  #     data_prep = "count",
  #     sql_query = "SELECT COALESCE(val.\"What is/are the service(s) you are contracted for?\", 'Unspecified') AS Answer, 
  #         COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses_Junction_Demographics_Services) AS Percentage 
  #         FROM Responses AS R 
  #         JOIN Responses_Junction_Demographics_Services AS jun 
  #         ON R.response_id = jun.response_id 
  #         JOIN Demographics_Services AS val 
  #         ON jun.value_id = val.value_id 
  #         GROUP BY val.\"What is/are the service(s) you are contracted for?\" 
  #         ORDER BY Percentage DESC"
  #   ),
  #   Location = list(
  #     question = "In which state/territory/province is your contract based?",
  #     viz_type = "map",
  #     data_prep = "distribution",
  #     sql_query = "SELECT LOWER(COALESCE(\"In which state/territory/province is your contract based?\", 'Unspecified')) AS Answer, 
  #         ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage 
  #         FROM Responses 
  #         GROUP BY \"In which state/territory/province is your contract based?\" 
  #         ORDER BY Percentage DESC"
  #   ),
  #   Territory = list(
  #     question = "What best describes the primary territories of your routes?",
  #     viz_type = "bar",
  #     data_prep = "count",
  #     sql_query = "SELECT COALESCE(val.\"What best describes the primary territories of your routes?\", 'Unspecified') AS Answer, 
  #         COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses_Junction_Demographics_Territory) AS Percentage 
  #         FROM Responses AS R 
  #         JOIN Responses_Junction_Demographics_Territory AS jun 
  #         ON R.response_id = jun.response_id 
  #         JOIN Demographics_Territory AS val 
  #         ON jun.value_id = val.value_id 
  #         GROUP BY val.\"What best describes the primary territories of your routes?\" 
  #         ORDER BY Percentage DESC"
  #   ),
  #   DeliveryType = list(
  #     question = "What percentage of your deliveries are to residential addresses versus business addresses?",
  #     viz_type = "bar",
  #     data_prep = "percentage",
  #     sql_query = "SELECT COALESCE(\"What percentage of your deliveries are to residential addresses versus business addresses?\", 'Unspecified') AS Answer, 
  #       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage 
  #       FROM Responses 
  #       GROUP BY \"What percentage of your deliveries are to residential addresses versus business addresses?\" 
  #       ORDER BY Percentage DESC"
  #   ),
  #   AdditionalAgreements = list(
  #     question = "How many additional Service Provider agreements does your company have?",
  #     viz_type = "categorical",
  #     data_prep = "distribution",
  #     sql_query = "SELECT 
  #       COALESCE(\"How many additional Service Provider agreements does your company have?\", 'Unspecified') AS Answer, 
  #       COUNT(*) AS Count 
  #       FROM Responses 
  #       GROUP BY \"How many additional Service Provider agreements does your company have?\" 
  #       ORDER BY Answer"
  #   )#,
  #   # OperationStart = list(
  #   #   question = "When did your company begin operations under a Service Provider agreement?",
  #   #   viz_type = "timeline",
  #   #   data_prep = "time_series",
  #   #   sql_query = paste("SELECT ",
  #   #     "2024 - EXTRACT(YEAR FROM CAST(\"When did your company begin operations under a Service Provider agreement?\" AS DATE)) AS CompanyAge, ",
  #   #     "COUNT(*) AS NumberOfCompanies ",
  #   #     "FROM duckdb_database.main.Responses ",
  #   #     "GROUP BY CompanyAge ",
  #   #     "ORDER BY CompanyAge ")
  #   # )
  # ),
  # Financials = list(
  #   RevenuePercentage = list(
  #     question = "Approximately what percentage of your revenues comes directly from your Service Provider contract.",
  #     viz_type = "bar",
  #     data_prep = "percentage",
  #     sql_query = "SELECT  COALESCE(\"Approximately what  percentage of your revenues comes directly from your Service Provider contract.\", 'Unspecified') AS Answer,
  #         ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage
  #         FROM Responses 
  #         Group By Answer
  #         Order By Percentage desc"
  #   ),
  #   FinancialHealth = list(
  #     question = "On a scale of 1-5, how would you rate your company's financial health over the past year?",
  #     viz_type = "histogram",
  #     data_prep = "distribution",
  #     sql_query = "SELECT 
  #         COALESCE(\"On a scale of 1-5, how would you rate your company's financial health over the past year?\"::string, 'Unspecified') AS Answer, 
  #         COUNT(*)  AS Count 
  #         FROM Responses 
  #         GROUP BY Answer
  #         ORDER BY Answer ASC"
  #   ),
  #   YearOverYearRevenue = list(
  #     question = "Over the past year, have your year-over-year revenues:",
  #     viz_type = "categorical",
  #     data_prep = "trend",
  #     sql_query = "SELECT 
  #       COALESCE(\"Over the past year, have your year-over-year revenues:\", 'Unspecified') AS Answer, 
  #       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Count DESC"
  #   ),
  #   YearOverYearProfit = list(
  #     question = "Over the past year, have your year-over-year profit margins:",
  #     viz_type = "categorical",
  #     data_prep = "trend",
  #     sql_query = "SELECT 
  #       COALESCE(\"Over the past year, have your year-over-year profit margins:\", 'Unspecified') AS Answer, 
  #       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Count DESC"
  #   ),
  #   FinancialChallenges = list(
  #     question = "What are the major financial challenges you face?",
  #     viz_type = "bar",
  #     data_prep = "frequencies",
  #     sql_query = "SELECT COALESCE(FC.\"What are the major finical challenges you face?\", 'Unspecified') AS Answer, 
  #       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses_Junction_Financials_FinancialChallenges) AS Percentage 
  #       FROM Responses AS R 
  #       JOIN Responses_Junction_Financials_FinancialChallenges AS RJFC 
  #       ON R.response_id = RJFC.response_id 
  #       JOIN Financials_FinancialChallenges AS FC 
  #       ON RJFC.value_id = FC.value_id 
  #       GROUP BY Answer
  #       ORDER BY Percentage DESC"
  #   )
  # ),
  # Operations = list(
  #   OperationalConstancy = list(
  #     question = "On a scale of 1-5, how would you rate your company's operational constancy over the past year?",
  #     viz_type = "histogram",
  #     data_prep = "scale",
  #     sql_query = "SELECT 
  #       COALESCE(\"On a scale of 1-5, how would you rate your company's operational constancy over the past year?\"::string, 'Unspecified') AS Answer, 
  #       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Answer Asc"
  #   ),
  #   OperationalEfficiencyChange = list(
  #     question = "Over the past year, has your year-over-year operational efficiency:",
  #     viz_type = "categorical",
  #     data_prep = "comparison",
  #     sql_query = "SELECT 
  #       COALESCE(\"Over the past year, has your year-over-year operational efficiency:\"::string, 'Unspecified') AS Answer, 
  #       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Count DESC"
  #   ),
  #   CurrentOperationalEfficiency = list(
  #     question = "On a scale of 1-5, how would you rate your company's current operational efficiency?",
  #     viz_type = "histogram",
  #     data_prep = "scale",
  #     sql_query = "SELECT 
  #       COALESCE(\"On a scale of 1-5, how would you rate your company's current operational efficiency?\"::string, 'Unspecified') AS Answer, 
  #       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Answer Asc"
  #   ),
  #   OperationalChallenges = list(
  #     question = "What are the major operational challenges you face?",
  #     viz_type = "bar",
  #     data_prep = "frequencies",
  #     sql_query = "SELECT COALESCE(OC.\"What are the major operational challenges you face?\"::string, 'Unspecified') AS Answer, 
  #       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses_Junction_Operations_OperationalChallenges) AS Percentage 
  #       FROM Responses AS R 
  #       JOIN Responses_Junction_Operations_OperationalChallenges AS RJOC 
  #       ON R.response_id = RJOC.response_id 
  #       JOIN Operations_OperationalChallenges AS OC 
  #       ON RJOC.value_id = OC.value_id 
  #       GROUP BY Answer
  #       ORDER BY Percentage DESC"
  #   ),
  #   RoutesPerWeek = list(
  #     question = "How many routes in an average week are dispatched to service your contract?",
  #     viz_type = "categorical",
  #     data_prep = "distribution",
  #     sql_query = "SELECT \"How many routes in an average week are dispatch to service your contract?\" AS Answer, 
  #       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Answer ASC"
  #   ),
  #   RoutesExpansion = list(
  #     question = "Have you expanded or reduced your routes in the past year?",
  #     viz_type = "categorical",
  #     data_prep = "count",
  #     sql_query = "SELECT 
  #       COALESCE(\"Have you expanded or reduced your routes in the past year?\", 'Unspecified') AS Answer, 
  #       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Count DESC"
  #   ),
  #   DriversPerWeek = list(
  #     question = "How many drivers are used to support your contract in an average week?",
  #     viz_type = "categorical",
  #     data_prep = "distribution",
  #     sql_query = "SELECT COALESCE(\"How many drivers are used to support your contract in an average week?\",'Unspecified') AS Answer, 
  #       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Answer DESC"
  #   ),
  #   HelpersPerWeek = list(
  #     question = "How many helper/jumpers are used to support your contract in an average week?",
  #     viz_type = "categorical",
  #     data_prep = "distribution",
  #     sql_query = "SELECT COALESCE(\"How many helper/jumpers are used to support your contract in an average week?\", 'Unspecfied') AS Answer, 
  #       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Count DESC"
  #   ),
  #   ManagersPerWeek = list(
  #     question = "How many managers are used to support your contract in an average week?",
  #     viz_type = "categorical",
  #     data_prep = "distribution",
  #     sql_query = "SELECT COALESCE(\"How many managers are used to support your contract in an average week?\", 'Unspecfied') AS Answer, 
  #       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Count DESC"
  #   ),
  #   AdminPositions = list(
  #     question = "How many administrative & executive (non-operations) positions does your company employ?",
  #     viz_type = "categorical",
  #     data_prep = "distribution",
  #     sql_query = "SELECT \"How many administrative & executive (non-operations) positions does your company employ?\" AS Answer, 
  #       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses ) AS Count 
  #       FROM Responses 
  #       GROUP BY Answer
  #       ORDER BY Count DESC"
  #   )
  # ),
  SentimentAndOutlook = list(
    # BusinessHealthPast = list(
    #   question = "How would you rate the overall health of your business one year ago?",
    #   viz_type = "histogram",
    #   data_prep = "scale",
    #   sql_query = "SELECT 
    #     COALESCE(\"How would you rate the overall health of your business one year ago?\"::string, 'Unspecified') AS Answer, 
    #     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
    #     FROM Responses 
    #     GROUP BY Answer 
    #     ORDER BY Answer ASC"
    # ),
    # BusinessHealthPresent = list(
    #   question = "How would you currently rate the overall health of your business?",
    #   viz_type = "histogram",
    #   data_prep = "scale",
    #   sql_query = "SELECT 
    #     COALESCE(\"How would you currently rate the overall health of your business?\"::string, 'Unspecified') AS Answer, 
    #     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
    #     FROM Responses 
    #     GROUP BY Answer
    #     ORDER BY Answer ASC"
    # ),
    # BusinessHealthFuture = list(
    #   question = "How would you rate your prediction for the overall health of your business one year from now?",
    #   viz_type = "histogram",
    #   data_prep = "scale",
    #   sql_query = "SELECT 
    #     COALESCE(\"How would you rate your prediction for the overall health of your business one year from now?\"::string, 'Unspecified') AS Answer, 
    #     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
    #     FROM Responses 
    #     GROUP BY Answer
    #     ORDER BY Answer ASC"
    # ),
    # BusinessGrowthSentiment = list(
    #   question = "Compared to the past year, how do you feel about the upcoming year in terms of business growth?",
    #   viz_type = "categorical",
    #   data_prep = "sentiment",
    #   sql_query = "SELECT 
    #     COALESCE(\"Compared to the past year, how do you feel about the upcoming year in terms of business growth?\", 'Unspecified') AS Answer, 
    #     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
    #     FROM Responses 
    #     GROUP BY Answer
    #     ORDER BY Answer DESC"
    # ),
    # OperationalChallengeSentiment = list(
    #   question = "Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?",
    #   viz_type = "categorical",
    #   data_prep = "sentiment",
    #   sql_query = "SELECT 
    #     COALESCE(\"Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?\", 'Unspecified') AS Answer, 
    #     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
    #     FROM Responses 
    #     GROUP BY Answer
    #     ORDER BY Answer DESC"
    # ),
    # ProfitabilitySentiment = list(
    #   question = "Compared to the past year, how do you feel about the upcoming year in terms of profitability?",
    #   viz_type = "categorical",
    #   data_prep = "sentiment",
    #   sql_query = "SELECT 
    #     COALESCE(\"Compared to the past year, how do you feel about the upcoming year in terms of profitability?\", 'Unspecified') AS Answer, 
    #     ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
    #     FROM Responses 
    #     GROUP BY Answer
    #     ORDER BY Answer DESC"
    # ),
    ContractStabilityConfidence = list(
      question = "How confident are you in the stability of your contract in the coming year?",
      viz_type = "histogram",
      data_prep = "confidence",
      sql_query = "SELECT
        COALESCE(\"How confident are you in the stability of your contract in the coming year?\"::string, 'Unspecified') AS Answer,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count
        FROM Responses
        GROUP BY Answer
        ORDER BY Answer ASC"
    ),
    CompanyStabilityConfidence = list(
      question = "How confident are you in the stability of the company you contracted with in the coming year?",
      viz_type = "histogram",
      data_prep = "confidence",
      sql_query = "SELECT 
        COALESCE(\"How confident are you in the stability of the company you contracted with in the coming year?\"::string, 'Unspecified') AS Answer, 
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Count 
        FROM Responses 
        GROUP BY Answer
        ORDER BY Answer ASC"
    ),
    TopConcerns = list(
      question = "What are your top three concerns for the future of your business?",
      viz_type = "bar",
      data_prep = "frequencies",
      sql_query = paste("WITH UnpivotedConcerns AS ( ",
        "SELECT \"What are your top three concerns for the future of your business? [First concern]\" AS Concern, 'First Concern' AS Rank ",
        "FROM Responses ",
          "UNION ALL ",
          "SELECT \"What are your top three concerns for the future of your business? [Second concern]\", 'Second Concern' ",
          "FROM Responses ",
          "UNION ALL ",
          "SELECT \"What are your top three concerns for the future of your business? [Third concern]\", 'Third Concern' ",
          "FROM Responses), ",
        "RankedConcerns AS (",
            "SELECT Concern, Rank, COUNT(*) AS Count ",
            "FROM UnpivotedConcerns ",
            "WHERE Concern IS NOT NULL AND Concern <> '' -- This filters out any empty or null responses ",
            "GROUP BY Concern, Rank), ",
        "TotalConcerns AS ( ",
            "SELECT COUNT(*) AS Total ",
            "FROM UnpivotedConcerns ",
            "WHERE Concern IS NOT NULL AND Concern <> '') ",
        "SELECT RC.Concern, RC.Rank, RC.Count, (RC.Count * 100.0) / TC.Total AS Percentage ",
        "FROM RankedConcerns RC, TotalConcerns TC ",
        "ORDER BY RC.Concern, CASE RC.Rank WHEN 'First Concern' THEN 1 WHEN 'Second Concern' THEN 2 WHEN 'Third Concern' THEN 3 END")
    ),
    RoutePlans = list(
      question = "Are you considering expanding, maintaining, or reducing your routes in the upcoming year?",
      viz_type = "bar",
      data_prep = "count",
      sql_query = paste("SELECT ",
        "COALESCE('Are you considering expanding, maintaining, or reducing your routes in the upcoming year?', 'Unspecified') AS Company, ",
        "ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage ",
        "FROM Responses ",
        "GROUP BY 'Are you considering expanding, maintaining, or reducing your routes in the upcoming year?' ",
        "ORDER BY Percentage DESC")
    ),
    DemandPrediction = list(
      question = "Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?",
      viz_type = "bar",
      data_prep = "prediction",
      sql_query = paste("SELECT ",
        "COALESCE('Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?', 'Unspecified') AS Company, ",
        "ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Percentage ",
        "FROM Responses ",
        "GROUP BY 'Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?' ",
        "ORDER BY Percentage DESC")
    )
  ),
  AnecdotalInsights = list(
    SpecificChallenge = list(
      question = "Can you share a specific challenge you've faced in the past year and how you addressed it?",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis",
      sql_query = "SELECT \"Can you share a specific challenge you've faced in the past year and how you addressed it?\" AS challenge FROM responses"
    ),
    SuccessStory = list(
      question = "Describe a recent success story or a significant milestone your company achieved.",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis",
      sql_query = paste("SELECT \"Can you share a specific challenge you've faced in the past year and how you addressed it?\" AS story FROM responses")
    ),
    SuggestionForImprovement = list(
      question = "If you could suggest one change to improve contractor relations, what would it be?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT \"Can you share a specific challenge you've faced in the past year and how you addressed it?\" as suggestion, COUNT(*) AS frequency FROM responses GROUP BY suggestion"
    ),
    IndustryChangeImpact = list(
      question = "Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT \"Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?\" AS impact, COUNT(*) AS frequency FROM responses GROUP BY industry_change_impact"
    ),
    RelationshipWithCompany = list(
      question = "Share an experience that exemplifies your relationship with the company your contract is with.",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis",
      sql_query = "SELECT \"Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?\" AS experience FROM responses"
    ),
    ChallengesAndRewards = list(
      question = "What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT \"What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?\" AS insights, COUNT(*) AS frequency FROM responses GROUP BY challenges_and_rewards"
    )
  ),
  SurveyFeedback = list(
    Feedback = list(
      question = "Please provide any feedback you have regarding this survey.",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT \"Please provide any feedback you have regarding this survey.\" as feedback, COUNT(*) AS frequency FROM responses GROUP BY feedback"
    )
  )
)
