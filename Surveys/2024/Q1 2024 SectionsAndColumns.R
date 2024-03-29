# Organizing column names into lists based on categories
survey_categories <- list(
  Demographics = list(
    Provider = "Which company is your Service Provider agreement contracted with?",
    Services = "What is/are the service(s) you are contracted for?",
    Location = "In which state/territory/province is your contract based? ",
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
  SurveyFeedback = list(Feedback = "Please provide any feedback you have regarding this survey.")
)

# List of columns to be normalized
columns_to_normalize <- c(
  "Demographics$Services" = survey_categories$Demographics$Services,
  "Demographics$Territory" = survey_categories$Demographics$Territory,
  "Financials$FinancialChallenges" = survey_categories$Financials$FinancialChallenges,
  "Operations$OperationalChallenges" = survey_categories$Operations$OperationalChallenges
)






# property data_prep is not currently used.
survey_categorie_caharts <- list(
  Demographics = list(
    Provider = list(
      question = "Which company is your Service Provider agreement contracted with?",
      viz_type = "bar",
      sql_query = "SELECT
        COALESCE(\"Which company is your Service Provider agreement contracted with?\", 'Unspecified') AS Response,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
        FROM Responses
        GROUP BY \"Which company is your Service Provider agreement contracted with?\"
        ORDER BY Metric DESC"
    ),
    Services = list(
      question = "What is/are the service(s) you are contracted for?",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(val.\"What is/are the service(s) you are contracted for?\", 'Unspecified') AS Response,
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses_Junction_Demographics_Services) AS Metric
        FROM Responses AS R
        JOIN Responses_Junction_Demographics_Services AS jun
        ON R.response_id = jun.response_id
        JOIN Demographics_Services AS val
        ON jun.value_id = val.value_id
        GROUP BY val.\"What is/are the service(s) you are contracted for?\"
        ORDER BY Metric DESC"
    ),
    Location = list(
      question = "In which state/territory/province is your contract based? ",
      viz_type = "map",
      sql_query = "SELECT LOWER(COALESCE(\"In which state/territory/province is your contract based? \", 'Unspecified')) AS Response,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
        FROM Responses
        GROUP BY Response
        ORDER BY Metric DESC"
    ),
    Territory = list(
      question = "What best describes the primary territories of your routes?",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(val.\"What best describes the primary territories of your routes?\", 'Unspecified') AS Response,
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses_Junction_Demographics_Territory) AS Metric
        FROM Responses AS R
        JOIN Responses_Junction_Demographics_Territory AS jun
        ON R.response_id = jun.response_id
        JOIN Demographics_Territory AS val
        ON jun.value_id = val.value_id
        GROUP BY Response
        ORDER BY Metric DESC"
    ),
    DeliveryType = list(
      question = "What percentage of your deliveries are to residential addresses versus business addresses?",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(\"What percentage of your deliveries are to residential addresses versus business addresses?\", 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY \"What percentage of your deliveries are to residential addresses versus business addresses?\"
      ORDER BY Metric DESC"
    ),
    AdditionalAgreements = list(
      question = "How many additional Service Provider agreements does your company have?",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(\"How many additional Service Provider agreements does your company have?\", 'Unspecified') AS Response,
      COUNT(*) AS Metric
      FROM Responses
      GROUP BY \"How many additional Service Provider agreements does your company have?\"
      ORDER BY Response"
    )#,
    # OperationStart = list(
    #   question = "When did your company begin operations under a Service Provider agreement?",
    #   viz_type = "timeline",
    #   sql_query = paste("SELECT ",
    #     "2024 - EXTRACT(YEAR FROM CAST(\"When did your company begin operations under a Service Provider agreement?\" AS DATE)) AS CompanyAge, ",
    #     "COUNT(*) AS NumberOfCompanies ",
    #     "FROM duckdb_database.main.Responses ",
    #     "GROUP BY CompanyAge ",
    #     "ORDER BY CompanyAge ")
    # )
  ),
  Financials = list(
    RevenuePercentage = list(
      question = "Approximately what percentage of your revenues comes directly from your Service Provider contract.",
      viz_type = "bar",
      sql_query = "SELECT  COALESCE(\"Approximately what  percentage of your revenues comes directly from your Service Provider contract.\", 'Unspecified') AS Response,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
        FROM Responses
        Group BY Response
        Order BY Metric desc"
    ),
    FinancialHealth = list(
      question = "On a scale of 1-5, how would you rate your company's financial health over the past year?",
      viz_type = "histogram",
      sql_query = "SELECT
        COALESCE(\"On a scale of 1-5, how would you rate your company's financial health over the past year?\"::string, 'Unspecified') AS Response,
        COUNT(*)  AS Metric
        FROM Responses
        GROUP BY Response
        ORDER BY Response ASC"
    ),
    YearOverYearRevenue = list(
      question = "Over the past year, have your year-over-year revenues:",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(\"Over the past year, have your year-over-year revenues:\", 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    YearOverYearProfit = list(
      question = "Over the past year, have your year-over-year profit margins:",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(\"Over the past year, have your year-over-year profit margins:\", 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    FinancialChallenges = list(
      question = "What are the major financial challenges you face?",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(FC.\"What are the major finical challenges you face?\", 'Unspecified') AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses_Junction_Financials_FinancialChallenges) AS Metric
      FROM Responses AS R
      JOIN Responses_Junction_Financials_FinancialChallenges AS RJFC
      ON R.response_id = RJFC.response_id
      JOIN Financials_FinancialChallenges AS FC
      ON RJFC.value_id = FC.value_id
      GROUP BY Response
      ORDER BY Metric DESC"
    )
  ),
  Operations = list(
    OperationalConstancy = list(
      question = "On a scale of 1-5, how would you rate your company's operational constancy over the past year?",
      viz_type = "histogram",
      sql_query = "SELECT
      COALESCE(\"On a scale of 1-5, how would you rate your company's operational constancy over the past year?\"::string, 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response Asc"
    ),
    OperationalEfficiencyChange = list(
      question = "Over the past year, has your year-over-year operational efficiency:",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(\"Over the past year, has your year-over-year operational efficiency:\"::string, 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    CurrentOperationalEfficiency = list(
      question = "On a scale of 1-5, how would you rate your company's current operational efficiency?",
      viz_type = "histogram",
      sql_query = "SELECT
      COALESCE(\"On a scale of 1-5, how would you rate your company's current operational efficiency?\"::string, 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response Asc"
    ),
    OperationalChallenges = list(
      question = "What are the major operational challenges you face?",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(OC.\"What are the major operational challenges you face?\"::string, 'Unspecified') AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses_Junction_Operations_OperationalChallenges) AS Metric
      FROM Responses AS R
      JOIN Responses_Junction_Operations_OperationalChallenges AS RJOC
      ON R.response_id = RJOC.response_id
      JOIN Operations_OperationalChallenges AS OC
      ON RJOC.value_id = OC.value_id
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    RoutesPerWeek = list(
      question = "How many routes in an average week are dispatched to service your contract?",
      viz_type = "categorical",
      sql_query = "SELECT \"How many routes in an average week are dispatch to service your contract?\" AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response ASC"
    ),
    RoutesExpansion = list(
      question = "Have you expanded or reduced your routes in the past year?",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(\"Have you expanded or reduced your routes in the past year?\", 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    DriversPerWeek = list(
      question = "How many drivers are used to support your contract in an average week?",
      viz_type = "categorical",
      sql_query = "SELECT COALESCE(\"How many drivers are used to support your contract in an average week?\",'Unspecified') AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response DESC"
    ),
    HelpersPerWeek = list(
      question = "How many helper/jumpers are used to support your contract in an average week?",
      viz_type = "categorical",
      sql_query = "SELECT COALESCE(\"How many helper/jumpers are used to support your contract in an average week?\", 'Unspecfied') AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    ManagersPerWeek = list(
      question = "How many managers are used to support your contract in an average week?",
      viz_type = "categorical",
      sql_query = "SELECT COALESCE(\"How many managers are used to support your contract in an average week?\", 'Unspecfied') AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    AdminPositions = list(
      question = "How many administrative & executive (non-operations) positions does your company employ?",
      viz_type = "categorical",
      sql_query = "SELECT \"How many administrative & executive (non-operations) positions does your company employ?\" AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses ) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    )
  ),
  SentimentAndOutlook = list(
    BusinessHealthPast = list(
      question = "How would you rate the overall health of your business one year ago?",
      viz_type = "histogram",
      sql_query = "SELECT
      COALESCE(\"How would you rate the overall health of your business one year ago?\"::string, 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response ASC"
    ),
    BusinessHealthPresent = list(
      question = "How would you currently rate the overall health of your business?",
      viz_type = "histogram",
      sql_query = "SELECT
      COALESCE(\"How would you currently rate the overall health of your business?\"::string, 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response ASC"
    ),
    BusinessHealthFuture = list(
      question = "How would you rate your prediction for the overall health of your business one year from now?",
      viz_type = "histogram",
      sql_query = "SELECT
      COALESCE(\"How would you rate your prediction for the overall health of your business one year from now?\"::string, 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response ASC"
    ),
    BusinessGrowthSentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of business growth?",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(\"Compared to the past year, how do you feel about the upcoming year in terms of business growth?\", 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response DESC"
    ),
    OperationalChallengeSentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(\"Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?\", 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response DESC"
    ),
    ProfitabilitySentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of profitability?",
      viz_type = "categorical",
      sql_query = "SELECT
    COALESCE(\"Compared to the past year, how do you feel about the upcoming year in terms of profitability?\", 'Unspecified') AS Response,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
    FROM Responses
    GROUP BY Response
    ORDER BY Response DESC"
    ),
    ContractStabilityConfidence = list(
      question = "How confident are you in the stability of your contract in the coming year?",
      viz_type = "histogram",
      sql_query = "SELECT
    COALESCE(\"How confident are you in the stability of your contract in the coming year?\"::string, 'Unspecified') AS Response,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
    FROM Responses
    GROUP BY Response
    ORDER BY Response ASC"
    ),
    CompanyStabilityConfidence = list(
      question = "How confident are you in the stability of the company you contracted with in the coming year?",
      viz_type = "histogram",
      sql_query = "SELECT
    COALESCE(\"How confident are you in the stability of the company you contracted with in the coming year?\"::string, 'Unspecified') AS Response,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
    FROM Responses
    GROUP BY Response
    ORDER BY Response ASC"
    ),
    TopConcerns = list(
      question = "What are your top three concerns for the future of your business?",
      viz_type = "StackedBar",
      sql_query = "WITH UnpivotedConcerns AS (
        SELECT
            CASE
                WHEN \"What are your top three concerns for the future of your business? [First concern]\" = '' THEN 'Unspecified'
                ELSE \"What are your top three concerns for the future of your business? [First concern]\"
            END AS Concern,
            'First Concern' AS Rank
        FROM Responses
        UNION ALL
        SELECT
            CASE
                WHEN \"What are your top three concerns for the future of your business? [Second concern]\" = '' THEN 'Unspecified'
                ELSE \"What are your top three concerns for the future of your business? [Second concern]\"
            END,
            'Second Concern'
        FROM Responses
        UNION ALL
        SELECT
            CASE
                WHEN \"What are your top three concerns for the future of your business? [Third concern]\" = '' THEN 'Unspecified'
                ELSE \"What are your top three concerns for the future of your business? [Third concern]\"
            END,
            'Third Concern'
        FROM Responses
),
RankedConcerns AS (
        SELECT Concern, Rank, COUNT(*) AS Count
        FROM UnpivotedConcerns
        GROUP BY Concern, Rank
),
TotalConcerns AS (
        SELECT COUNT(*) AS Total
        FROM UnpivotedConcerns
)
SELECT RC.Concern AS Response, RC.Rank AS Rank, (RC.Count * 100.0) / TC.Total AS Metric
FROM RankedConcerns RC, TotalConcerns TC
ORDER BY RC.Concern, CASE RC.Rank
    WHEN 'First Concern' THEN 1
    WHEN 'Second Concern' THEN 2
    WHEN 'Third Concern' THEN 3
END"
    ),
    RoutePlans = list(
      question = "Are you considering expanding, maintaining, or reducing your routes in the upcoming year?",
      viz_type = "categorical",
      sql_query = "SELECT
      	CASE
      		WHEN \"Are you considering expanding, maintaining, or reducing your routes in the upcoming year?\" = '' THEN 'Unspecified'
      		ELSE COALESCE(\"Are you considering expanding, maintaining, or reducing your routes in the upcoming year?\", 'Unspecified')
      	END
               AS Response,
              ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
              FROM Responses
              GROUP BY Response
              ORDER BY Metric DESC"
    ),
    DemandPrediction = list(
      question = "Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?",
      viz_type = "categorical",
      sql_query = "SELECT
        	CASE
        		WHEN \"Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?\" = '' THEN 'Unspecified'
        		ELSE COALESCE(\"Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?\", 'Unspecified')
        	END
                 AS Response,
                ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
                FROM Responses
                GROUP BY Response
                ORDER BY Metric DESC"
    )
  ),
  AnecdotalInsights = list(
    SpecificChallenge = list(
      question = "Can you share a specific challenge you've faced in the past year and how you addressed it?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Can you share a specific challenge you've faced in the past year and how you addressed it?\" AS Response FROM responses where Response <> ''"
    ),
    SuccessStory = list(
      question = "Describe a recent success story or a significant milestone your company achieved.",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Describe a recent success story or a significant milestone your company achieved.\" AS Response FROM responses where Response <> ''"
    ),
    SuggestionForImprovement = list(
      question = "If you could suggest one change to improve contractor relations, what would it be?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"If you could suggest one change to improve contractor relations, what would it be?\" AS Response FROM responses where Response <> ''"
    ),
    IndustryChangeImpact = list(
      question = "Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?\" AS Response FROM responses where Response <> ''"
    ),
    RelationshipWithCompany = list(
      question = "Share an experience that exemplifies your relationship with the company your contract is with.",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Share an experience that exemplifies your relationship with the company your contract is with.\" AS Response FROM responses where Response <> ''"
    ),
    ChallengesAndRewards = list(
      question = "What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?\" AS Response FROM responses where Response <> ''"
    )
  )
)
