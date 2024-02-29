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

survey_categories2 <- list(
  Demographics = list(
    Provider = list(
      question = "Which company is your Service Provider agreement contracted with?",
      viz_type = "bar",
      data_prep = "count"
    ),
    Services = list(
      question = "What is/are the service(s) you are contracted for?",
      viz_type = "wordcloud",
      data_prep = "frequencies"
    ),
    Location = list(
      question = "In which state/territory/province is your contract based?",
      viz_type = "map",
      data_prep = "distribution"
    ),
    Territory = list(
      question = "What best describes the primary territories of your routes?",
      viz_type = "bar",
      data_prep = "count"
    ),
    DeliveryType = list(
      question = "What percentage of your deliveries are to residential addresses versus business addresses?",
      viz_type = "stacked_bar",
      data_prep = "percentage"
    ),
    AdditionalAgreements = list(
      question = "How many additional Service Provider agreements does your company have?",
      viz_type = "histogram",
      data_prep = "distribution"
    ),
    OperationStart = list(
      question = "When did your company begin operations under a Service Provider agreement?",
      viz_type = "timeline",
      data_prep = "time_series"
    )
  ),
  Financials = list(
    RevenuePercentage = list(
      question = "Approximately what percentage of your revenues comes directly from your Service Provider contract.",
      viz_type = "bar",
      data_prep = "percentage"
    ),
    FinancialHealth = list(
      question = "On a scale of 1-5, how would you rate your company's financial health over the past year?",
      viz_type = "bar",
      data_prep = "scale"
    ),
    YearOverYearRevenue = list(
      question = "Over the past year, have your year-over-year revenues:",
      viz_type = "line",
      data_prep = "trend"
    ),
    YearOverYearProfit = list(
      question = "Over the past year, have your year-over-year profit margins:",
      viz_type = "line",
      data_prep = "trend"
    ),
    FinancialChallenges = list(
      question = "What are the major financial challenges you face?",
      viz_type = "wordcloud",
      data_prep = "frequencies"
    )
  ),
  Operations = list(
    OperationalConstancy = list(
      question = "On a scale of 1-5, how would you rate your company's operational constancy over the past year?",
      viz_type = "bar",
      data_prep = "scale"
    ),
    OperationalEfficiencyChange = list(
      question = "Over the past year, has your year-over-year operational efficiency:",
      viz_type = "bar",
      data_prep = "comparison"
    ),
    CurrentOperationalEfficiency = list(
      question = "On a scale of 1-5, how would you rate your company's current operational efficiency?",
      viz_type = "bar",
      data_prep = "scale"
    ),
    OperationalChallenges = list(
      question = "What are the major operational challenges you face?",
      viz_type = "wordcloud",
      data_prep = "frequencies"
    ),
    RoutesPerWeek = list(
      question = "How many routes in an average week are dispatched to service your contract?",
      viz_type = "histogram",
      data_prep = "distribution"
    ),
    RoutesExpansion = list(
      question = "Have you expanded or reduced your routes in the past year?",
      viz_type = "bar",
      data_prep = "count"
    ),
    DriversPerWeek = list(
      question = "How many drivers are used to support your contract in an average week?",
      viz_type = "histogram",
      data_prep = "distribution"
    ),
    HelpersPerWeek = list(
      question = "How many helper/jumpers are used to support your contract in an average week?",
      viz_type = "histogram",
      data_prep = "distribution"
    ),
    ManagersPerWeek = list(
      question = "How many managers are used to support your contract in an average week?",
      viz_type = "histogram",
      data_prep = "distribution"
    ),
    AdminPositions = list(
      question = "How many administrative & executive (non-operations) positions does your company employ?",
      viz_type = "histogram",
      data_prep = "distribution"
    )
  ),
  SentimentAndOutlook = list(
    BusinessHealthPast = list(
      question = "How would you rate the overall health of your business one year ago?",
      viz_type = "bar",
      data_prep = "scale"
    ),
    BusinessHealthPresent = list(
      question = "How would you currently rate the overall health of your business?",
      viz_type = "bar",
      data_prep = "scale"
    ),
    BusinessHealthFuture = list(
      question = "How would you rate your prediction for the overall health of your business one year from now?",
      viz_type = "bar",
      data_prep = "scale"
    ),
    BusinessGrowthSentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of business growth?",
      viz_type = "bar",
      data_prep = "sentiment"
    ),
    OperationalChallengeSentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?",
      viz_type = "bar",
      data_prep = "sentiment"
    ),
    ProfitabilitySentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of profitability?",
      viz_type = "bar",
      data_prep = "sentiment"
    ),
    ContractStabilityConfidence = list(
      question = "How confident are you in the stability of your contract in the coming year?",
      viz_type = "bar",
      data_prep = "confidence"
    ),
    CompanyStabilityConfidence = list(
      question = "How confident are you in the stability of the company you contracted with in the coming year?",
      viz_type = "bar",
      data_prep = "confidence"
    ),
    TopConcerns = list(
      question = "What are your top three concerns for the future of your business?",
      viz_type = "wordcloud",
      data_prep = "frequencies"
    ),
    RoutePlans = list(
      question = "Are you considering expanding, maintaining, or reducing your routes in the upcoming year?",
      viz_type = "bar",
      data_prep = "count"
    ),
    DemandPrediction = list(
      question = "Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?",
      viz_type = "bar",
      data_prep = "prediction"
    )
  ),
  AnecdotalInsights = list(
    SpecificChallenge = list(
      question = "Can you share a specific challenge you've faced in the past year and how you addressed it?",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis"
    ),
    SuccessStory = list(
      question = "Describe a recent success story or a significant milestone your company achieved.",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis"
    ),
    SuggestionForImprovement = list(
      question = "If you could suggest one change to improve contractor relations, what would it be?",
      viz_type = "wordcloud",
      data_prep = "frequencies"
    ),
    IndustryChangeImpact = list(
      question = "Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?",
      viz_type = "wordcloud",
      data_prep = "frequencies"
    ),
    RelationshipWithCompany = list(
      question = "Share an experience that exemplifies your relationship with the company your contract is with.",
      viz_type = "text_summary",
      data_prep = "qualitative_analysis"
    ),
    ChallengesAndRewards = list(
      question = "What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?",
      viz_type = "wordcloud",
      data_prep = "frequencies"
    )
  ),
  SurveyFeedback = list(
    Feedback = list(
      question = "Please provide any feedback you have regarding this survey.",
      viz_type = "wordcloud",
      data_prep = "frequencies"
    )
  )
)
