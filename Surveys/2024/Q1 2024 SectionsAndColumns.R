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
