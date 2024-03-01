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
  Demographics = list(
    Provider = list(
      question = "Which company is your Service Provider agreement contracted with?",
      viz_type = "bar",
      data_prep = "count",
      sql_query = "SELECT provider AS category, COUNT(*) AS count FROM survey_responses GROUP BY provider"
    ),
    Services = list(
      question = "What is/are the service(s) you are contracted for?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT service AS word, COUNT(*) AS frequency FROM survey_responses GROUP BY service"
    ),
    Location = list(
      question = "In which state/territory/province is your contract based?",
      viz_type = "map",
      data_prep = "distribution",
      sql_query = "SELECT location AS area, COUNT(*) AS count FROM survey_responses GROUP BY location"
    ),
    Territory = list(
      question = "What best describes the primary territories of your routes?",
      viz_type = "bar",
      data_prep = "count",
      sql_query = "SELECT territory AS category, COUNT(*) AS count FROM survey_responses GROUP BY territory"
    ),
    DeliveryType = list(
      question = "What percentage of your deliveries are to residential addresses versus business addresses?",
      viz_type = "stacked_bar",
      data_prep = "percentage",
      sql_query = "SELECT delivery_type AS category, COUNT(*) / (SELECT COUNT(*) FROM survey_responses) * 100 AS percentage FROM survey_responses GROUP BY delivery_type"
    ),
    AdditionalAgreements = list(
      question = "How many additional Service Provider agreements does your company have?",
      viz_type = "histogram",
      data_prep = "distribution",
      sql_query = "SELECT additional_agreements AS agreements, COUNT(*) AS count FROM survey_responses GROUP BY additional_agreements"
    ),
    OperationStart = list(
      question = "When did your company begin operations under a Service Provider agreement?",
      viz_type = "timeline",
      data_prep = "time_series",
      sql_query = "SELECT YEAR(operation_start) AS year, COUNT(*) AS count FROM survey_responses GROUP BY YEAR(operation_start)"
    )
  ),
  Financials = list(
    RevenuePercentage = list(
      question = "Approximately what percentage of your revenues comes directly from your Service Provider contract.",
      viz_type = "bar",
      data_prep = "percentage",
      sql_query = "SELECT revenue_percentage AS category, COUNT(*) AS count FROM survey_responses GROUP BY revenue_percentage"
    ),
    FinancialHealth = list(
      question = "On a scale of 1-5, how would you rate your company's financial health over the past year?",
      viz_type = "bar",
      data_prep = "scale",
      sql_query = "SELECT financial_health AS rating, COUNT(*) AS count FROM survey_responses GROUP BY financial_health"
    ),
    YearOverYearRevenue = list(
      question = "Over the past year, have your year-over-year revenues:",
      viz_type = "line",
      data_prep = "trend",
      sql_query = "SELECT year, revenue_change AS change FROM financial_data WHERE company_id = ?"  # Placeholder for dynamic filtering
    ),
    YearOverYearProfit = list(
      question = "Over the past year, have your year-over-year profit margins:",
      viz_type = "line",
      data_prep = "trend",
      sql_query = "SELECT year, profit_margin_change AS change FROM financial_data WHERE company_id = ?"  # Placeholder for dynamic filtering
    ),
    FinancialChallenges = list(
      question = "What are the major financial challenges you face?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT challenge, COUNT(*) AS frequency FROM survey_responses GROUP BY challenge"
    )
  ),
  Operations = list(
    OperationalConstancy = list(
      question = "On a scale of 1-5, how would you rate your company's operational constancy over the past year?",
      viz_type = "bar",
      data_prep = "scale",
      sql_query = "SELECT operational_constancy AS rating, COUNT(*) AS count FROM survey_responses GROUP BY operational_constancy"
    ),
    OperationalEfficiencyChange = list(
      question = "Over the past year, has your year-over-year operational efficiency:",
      viz_type = "bar",
      data_prep = "comparison",
      sql_query = "SELECT efficiency_change AS change, COUNT(*) AS count FROM survey_responses GROUP BY efficiency_change"
    ),
    CurrentOperationalEfficiency = list(
      question = "On a scale of 1-5, how would you rate your company's current operational efficiency?",
      viz_type = "bar",
      data_prep = "scale",
      sql_query = "SELECT current_efficiency AS rating, COUNT(*) AS count FROM survey_responses GROUP BY current_efficiency"
    ),
    OperationalChallenges = list(
      question = "What are the major operational challenges you face?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT challenge, COUNT(*) AS frequency FROM survey_responses GROUP BY challenge"
    ),
    RoutesPerWeek = list(
      question = "How many routes in an average week are dispatched to service your contract?",
      viz_type = "histogram",
      data_prep = "distribution",
      sql_query = "SELECT routes_per_week AS routes, COUNT(*) AS count FROM survey_responses GROUP BY routes_per_week"
    ),
    RoutesExpansion = list(
      question = "Have you expanded or reduced your routes in the past year?",
      viz_type = "bar",
      data_prep = "count",
      sql_query = "SELECT routes_expansion AS expansion_status, COUNT(*) AS count FROM survey_responses GROUP BY routes_expansion"
    ),
    DriversPerWeek = list(
      question = "How many drivers are used to support your contract in an average week?",
      viz_type = "histogram",
      data_prep = "distribution",
      sql_query = "SELECT drivers_per_week AS drivers, COUNT(*) AS count FROM survey_responses GROUP BY drivers_per_week"
    ),
    HelpersPerWeek = list(
      question = "How many helper/jumpers are used to support your contract in an average week?",
      viz_type = "histogram",
      data_prep = "distribution",
      sql_query = "SELECT helpers_per_week AS helpers, COUNT(*) AS count FROM survey_responses GROUP BY helpers_per_week"
    ),
    ManagersPerWeek = list(
      question = "How many managers are used to support your contract in an average week?",
      viz_type = "histogram",
      data_prep = "distribution",
      sql_query = "SELECT managers_per_week AS managers, COUNT(*) AS count FROM survey_responses GROUP BY managers_per_week"
    ),
    AdminPositions = list(
      question = "How many administrative & executive (non-operations) positions does your company employ?",
      viz_type = "histogram",
      data_prep = "distribution",
      sql_query = "SELECT admin_positions AS positions, COUNT(*) AS count FROM survey_responses GROUP BY admin_positions"
    )
  ),
  SentimentAndOutlook = list(
    BusinessHealthPast = list(
      question = "How would you rate the overall health of your business one year ago?",
      viz_type = "bar",
      data_prep = "scale",
      sql_query = "SELECT business_health_past AS rating, COUNT(*) AS count FROM survey_responses GROUP BY business_health_past"
    ),
    BusinessHealthPresent = list(
      question = "How would you currently rate the overall health of your business?",
      viz_type = "bar",
      data_prep = "scale",
      sql_query = "SELECT business_health_present AS rating, COUNT(*) AS count FROM survey_responses GROUP BY business_health_present"
    ),
    BusinessHealthFuture = list(
      question = "How would you rate your prediction for the overall health of your business one year from now?",
      viz_type = "bar",
      data_prep = "scale",
      sql_query = "SELECT business_health_future AS rating, COUNT(*) AS count FROM survey_responses GROUP BY business_health_future"
    ),
    BusinessGrowthSentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of business growth?",
      viz_type = "bar",
      data_prep = "sentiment",
      sql_query = "SELECT growth_sentiment AS sentiment, COUNT(*) AS count FROM survey_responses GROUP BY growth_sentiment"
    ),
    OperationalChallengeSentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?",
      viz_type = "bar",
      data_prep = "sentiment",
      sql_query = "SELECT operational_challenge_sentiment AS sentiment, COUNT(*) AS count FROM survey_responses GROUP BY operational_challenge_sentiment"
    ),
    ProfitabilitySentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of profitability?",
      viz_type = "bar",
      data_prep = "sentiment",
      sql_query = "SELECT profitability_sentiment AS sentiment, COUNT(*) AS count FROM survey_responses GROUP BY profitability_sentiment"
    ),
    ContractStabilityConfidence = list(
      question = "How confident are you in the stability of your contract in the coming year?",
      viz_type = "bar",
      data_prep = "confidence",
      sql_query = "SELECT contract_stability_confidence AS confidence, COUNT(*) AS count FROM survey_responses GROUP BY contract_stability_confidence"
    ),
    CompanyStabilityConfidence = list(
      question = "How confident are you in the stability of the company you contracted with in the coming year?",
      viz_type = "bar",
      data_prep = "confidence",
      sql_query = "SELECT company_stability_confidence AS confidence, COUNT(*) AS count FROM survey_responses GROUP BY company_stability_confidence"
    ),
    TopConcerns = list(
      question = "What are your top three concerns for the future of your business?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT concern, COUNT(*) AS frequency FROM survey_responses_unpivoted_concerns GROUP BY concern"
      # // Note: This assumes a transformation of the data to a single 'concern' column in a separate process.
    ),
    RoutePlans = list(
      question = "Are you considering expanding, maintaining, or reducing your routes in the upcoming year?",
      viz_type = "bar",
      data_prep = "count",
      sql_query = "SELECT route_plans AS plan, COUNT(*) AS count FROM survey_responses GROUP BY route_plans"
    ),
    DemandPrediction = list(
      question = "Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?",
      viz_type = "bar",
      data_prep = "prediction",
      sql_query = "SELECT demand_prediction AS prediction, COUNT(*) AS count FROM survey_responses GROUP BY demand_prediction"
    )
  ),
  AnecdotalInsights = list(
    SpecificChallenge = list(
      question = "Can you share a specific challenge you've faced in the past year and how you addressed it?",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis",
      sql_query = "SELECT specific_challenge AS challenge FROM survey_responses"
      # // This assumes a direct extraction for qualitative analysis, potentially summarized or highlighted in a report.
    ),
    SuccessStory = list(
      question = "Describe a recent success story or a significant milestone your company achieved.",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis",
      sql_query = "SELECT success_story AS story FROM survey_responses"
      # // Similar to SpecificChallenge, direct extraction for narrative display or report inclusion.
    ),
    SuggestionForImprovement = list(
      question = "If you could suggest one change to improve contractor relations, what would it be?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT suggestion, COUNT(*) AS frequency FROM survey_responses GROUP BY suggestion"
      # // Assumes aggregation of suggestions for a word cloud visualization.
    ),
    IndustryChangeImpact = list(
      question = "Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT industry_change_impact AS impact, COUNT(*) AS frequency FROM survey_responses GROUP BY industry_change_impact"
    ),
    RelationshipWithCompany = list(
      question = "Share an experience that exemplifies your relationship with the company your contract is with.",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis",
      sql_query = "SELECT relationship_with_company AS experience FROM survey_responses"
    ),
    ChallengesAndRewards = list(
      question = "What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT challenges_and_rewards AS insights, COUNT(*) AS frequency FROM survey_responses GROUP BY challenges_and_rewards"
    )
  ),
  SurveyFeedback = list(
    Feedback = list(
      question = "Please provide any feedback you have regarding this survey.",
      viz_type = "wordcloud",
      data_prep = "frequencies",
      sql_query = "SELECT feedback, COUNT(*) AS frequency FROM survey_responses GROUP BY feedback"
    )
  )
)
