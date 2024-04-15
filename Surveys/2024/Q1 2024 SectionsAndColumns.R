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
      title = "Contract Partner",
      subtitle = "",
      viz_type = "bar",
      sql_query = "SELECT
    COALESCE(
        NULLIF(CONCAT(\"Which company is your Service Provider agreement contracted with?\", ''), ''),
        'Unspecified'
    ) AS Response,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
FROM Responses
GROUP BY \"Which company is your Service Provider agreement contracted with?\"
ORDER BY Metric DESC"
    ),
    Services = list(
      question = "What is/are the service(s) you are contracted for?",
      title = "Offerings",
      subtitle = "",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(NULLIF(CONCAT(val.\"What is/are the service(s) you are contracted for?\", ''), ''), 'Unspecified') AS Response,
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
      title = "Location" ,
      subtitle="",
      viz_type = "map",
      sql_query = "SELECT COALESCE(NULLIF(CONCAT(\"In which state/territory/province is your contract based? \", ''), ''),  'Unspecified') AS Response,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
        FROM Responses
        GROUP BY Response
        ORDER BY Metric DESC"
    ),
    Territory = list(
      question = "What best describes the primary territories of your routes?",
      title = "Territory" ,
      subtitle="",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(NULLIF(CONCAT(val.\"What best describes the primary territories of your routes?\", ''), ''), 'Unspecified') AS Response,
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
      title = "Segmentation" ,
      subtitle="",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(NULLIF(CONCAT(\"What percentage of your deliveries are to residential addresses versus business addresses?\", ''), ''), 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY \"What percentage of your deliveries are to residential addresses versus business addresses?\"
      ORDER BY Metric DESC"
    ),
    AdditionalAgreements = list(
      question = "How many additional Service Provider agreements does your company have?",
      title = "Agreements" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(NULLIF(CONCAT(\"How many additional Service Provider agreements does your company have?\"::string, ''), ''), 'Unspecified') AS Response,
      COUNT(*) AS Metric
      FROM Responses
      GROUP BY \"How many additional Service Provider agreements does your company have?\"
      ORDER BY Response"
    ),
    OperationStart = list(
      question = "When did your company begin operations under a Service Provider agreement?",
      title = "Years in Operation" ,
      subtitle="",
      viz_type = "histogram",
      sql_query = paste("SELECT 
      	CASE WHEN \"When did your company begin operations under a Service Provider agreement?\" <> '' 
      	THEN (2024 - EXTRACT(YEAR FROM CAST(\"When did your company begin operations under a Service Provider agreement?\" AS DATE)))::string
      	ELSE 'Unspecified'
      	END as Response, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP By Response
      ORDER BY Metric")
    )
   ),
  Financials = list(
    RevenuePercentage = list(
      question = "Approximately what percentage of your revenues comes directly from your Service Provider contract.",
      title = "Revenue from Contract" ,
      subtitle="",
      viz_type = "bar",
      sql_query = "SELECT  COALESCE(NULLIF(CONCAT(\"Approximately what  percentage of your revenues comes directly from your Service Provider contract.\", ''), ''), 'Unspecified') AS Response,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
        FROM Responses
        Group BY Response
        Order BY Metric desc"
    ),
    FinancialHealth = list(
      question = "On a scale of 1-5, how would you rate your company's financial health over the past year?",
      title = "Financial Health Rating" ,
      subtitle="1-Very Poor to 5-Excellent",
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
      title = "Year-Over-Year Revenue" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(NULLIF(CONCAT(\"Over the past year, have your year-over-year revenues:\", ''), ''), 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    YearOverYearProfit = list(
      question = "Over the past year, have your year-over-year profit margins:",
      title = "Year-Over-Year Profit" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(NULLIF(CONCAT(\"Over the past year, have your year-over-year profit margins:\", ''), ''), 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    FinancialChallenges = list(
      question = "What are the major financial challenges you face?",
      title = "Major Financial Challenges" ,
      subtitle="",
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
      title = "Operational Constancy" ,
      subtitle="1-Very Poor to 5-Excellent",
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
      title = "Year-Over-Year Efficiency" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(NULLIF(CONCAT(\"Over the past year, has your year-over-year operational efficiency:\"::string, ''), ''), 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    CurrentOperationalEfficiency = list(
      question = "On a scale of 1-5, how would you rate your company's current operational efficiency?",
      title = "Current Efficiency" ,
      subtitle="1-Very Poor to 5-Excellent",
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
      title = "Operational Challenges" ,
      subtitle="",
      viz_type = "bar",
      sql_query = "SELECT COALESCE(NULLIF(CONCAT(OC.\"What are the major operational challenges you face?\"::string, ''), ''), 'Unspecified') AS Response,
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
      title = "Dispatches per wk" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT \"How many routes in an average week are dispatch to service your contract?\" AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response ASC"
    ),
    RoutesExpansion = list(
      question = "Have you expanded or reduced your routes in the past year?",
      title = "Year-Over-Year Growth" ,
      subtitle="",
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
      title = "Drivers/Week" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT COALESCE(\"How many drivers are used to support your contract in an average week?\",'Unspecified') AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response DESC"
    ),
    HelpersPerWeek = list(
      question = "How many helper/jumpers are used to support your contract in an average week?",
      title = "Helpers & Jumpers/Week" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT COALESCE(\"How many helper/jumpers are used to support your contract in an average week?\", 'Unspecfied') AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    ManagersPerWeek = list(
      question = "How many managers are used to support your contract in an average week?",
      title = "Managers/Week" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT COALESCE(\"How many managers are used to support your contract in an average week?\", 'Unspecfied') AS Response,
      COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Responses) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Metric DESC"
    ),
    AdminPositions = list(
      question = "How many administrative & executive (non-operations) positions does your company employ?",
      title = "Executives and Administrators" ,
      subtitle="non-operations positions",
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
      title = "Prio Year Health" ,
      subtitle="1-Very Poor to 5-Excellent",
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
      title = "Present Health" ,
      subtitle="1-Very Poor to 5-Excellent",
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
      title = "Future Health" ,
      subtitle="1-Very Poor to 5-Excellent",
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
      title = "Growth Prospects" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(NULLIF(CONCAT(\"Compared to the past year, how do you feel about the upcoming year in terms of business growth?\", ''), ''), 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response DESC"
    ),
    OperationalChallengeSentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?",
      title = "Operational Challenges" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
      COALESCE(NULLIF(CONCAT(\"Compared to the past year, how do you feel about the upcoming year in terms of operational challenges?\", ''), ''), 'Unspecified') AS Response,
      ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
      FROM Responses
      GROUP BY Response
      ORDER BY Response DESC"
    ),
    ProfitabilitySentiment = list(
      question = "Compared to the past year, how do you feel about the upcoming year in terms of profitability?",
      title = "Profitability Predictions" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
    COALESCE(NULLIF(CONCAT(\"Compared to the past year, how do you feel about the upcoming year in terms of profitability?\", ''), ''), 'Unspecified') AS Response,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
    FROM Responses
    GROUP BY Response
    ORDER BY Response DESC"
    ),
    ContractStabilityConfidence = list(
      question = "How confident are you in the stability of your contract in the coming year?",
      title = "Contract Confidence" ,
      subtitle="1-Very Poor to 5-Excellent",
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
      title = "Partner Confidence" ,
      subtitle="1-Very Poor to 5-Excellent",
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
      title = "Concerns for the Future" ,
      subtitle="Top 3",
      viz_type = "StackedBar",
      sql_query = "WITH UnpivotedConcerns AS (
        SELECT
            COALESCE(NULLIF(CONCAT(\"What are your top three concerns for the future of your business? [First concern]\", ''), ''), 'Unspecified') AS Concern,
            'First Concern' AS Rank
        FROM Responses
        UNION ALL
        SELECT
            COALESCE(NULLIF(CONCAT(\"What are your top three concerns for the future of your business? [Second concern]\", ''), ''), 'Unspecified') AS Concern,
            'Second Concern'
        FROM Responses
        UNION ALL
        SELECT
            COALESCE(NULLIF(CONCAT(\"What are your top three concerns for the future of your business? [Third concern]\", ''), ''), 'Unspecified') AS Concern,
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
ORDER BY RC.Concern, RC.Rank"
    ),
    RoutePlans = list(
      question = "Are you considering expanding, maintaining, or reducing your routes in the upcoming year?",
      title = "Route Changes" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
      	COALESCE(NULLIF(CONCAT(\"Are you considering expanding, maintaining, or reducing your routes in the upcoming year?\", ''), ''), 'Unspecified')
               AS Response,
              ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS Metric
              FROM Responses
              GROUP BY Response
              ORDER BY Metric DESC"
    ),
    DemandPrediction = list(
      question = "Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?",
      title = "Demand Projections" ,
      subtitle="",
      viz_type = "categorical",
      sql_query = "SELECT
        	COALESCE(NULLIF(CONCAT(\"Do you believe the demand for delivery services in your region will increase, decrease, or remain the same in the next year?\", ''), ''), 'Unspecified')

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
      title = "Challenges Faced" ,
      subtitle="What challenge have you faced and how did you address it?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Can you share a specific challenge you've faced in the past year and how you addressed it?\" AS Response FROM responses where Response <> ''",
      response_summary = "<p>A wide array of challenges were faced in the past year, centered around operational and financial difficulties. Themes emerge around issues such as hiring, fleet maintenance, financial strain due to increased costs and reduced contract rates, and the challenge of maintaining profitability amidst these adversities. Respondents have taken various actions to address these challenges, including hiring specialized staff such as fleet technicians and recruiting companies, shifting to alternative vendor agreements for better rates, leasing vehicles to manage upfront costs, and adjusting operational strategies such as scheduling and workforce management to improve efficiency and reduce dependency on unreliable factors.</p>",
      quote_of_intrest = "\"<b><i>Our contracts have been reduced year over year across the board. One small contract, our revenue dropped almost 15%... We cannot fathom how [Contract Partner]could reduce all of our revenue when the cost of labor, fuel and equipment has gone up drastically.</i></b>\""
    ),
    SuccessStory = list(
      question = "Describe a recent success story or a significant milestone your company achieved.",
      title = "Success Stories" ,
      subtitle="What success have you recently achieved?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Describe a recent success story or a significant milestone your company achieved.\" AS Response FROM responses where Response <> ''",
      response_summary = "<p>Respondents paint a picture of resilience and achievement despite the challenges faced by companies, with a notable emphasis on safety, operational excellence, and strategic growth. Many highlighted their success in achieving Gold status, a significant milestone that represents a high level of performance in our industry. The achievements span a range of areas, including safety milestones such as \"14 months no accidents,\" and operational successes like \"Highest performing peak season as a company.\"</p>",
      quote_of_intrest = "<b><i>Negotiated higher paying contract, on average $0.57 per stop higher.</i></b>"
    ),
    SuggestionForImprovement = list(
      question = "If you could suggest one change to improve contractor relations, what would it be?",
      title = "Contract Improvements" ,
      subtitle="What is your suggestion to improve the relationship with your contract partner?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"If you could suggest one change to improve contractor relations, what would it be?\" AS Response FROM responses where Response <> ''",
      response_summary = "<p>The responses to this survey question reflect a broad consensus among contractors on the need for improvements in their relationship with their Contract Partner, with a strong focus on fairness, transparency, and financial viability. The suggestions for change are diverse but center on several key themes:
•	Transparency and Honesty: Respondents call for more transparency in how rates are calculated and a desire for the Contract Partner to treat contractors as true partners rather than adversaries. This includes a call for honesty and a genuine partnership approach.
•	Financial Fairness: Many responses emphasize the need for better pay, more fair contract terms, and adjustments to rates that reflect current economic realities, including inflation and increased operational costs.
•	Operational Improvements: Suggestions include addressing internal organizational issues with the Contract Partner that impact contractors, improving the dispute process, eliminating inefficient services like Sunday delivery, and enhancing the accuracy of delivery routing and scheduling.
•	Communication and Support: Contractors seek improved communication, more support from the Contract Partner, especially for new contractors, and a desire to be listened to and act on contractor feedback more effectively.</p>",
      quote_of_intrest = "<b><i>[Contract Partner] needs to stop forcing regulation after regulation on contractors. We have to spend so much time training drivers before they can even get on the road....at a great monetary cost. We do not get compensated properly for the amount of money we have to spend on training. Additionally, [Contract Partner] knows [expletive] well that most contractors have massive amounts of debt and rely on continuing the relationship to service that debt. When they 'negotiate' they give us an ultimatum rather than a true opportunity to negotiate.</i></b>"
    ),
    IndustryChangeImpact = list(
      question = "Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?",
      title = "Industry Changes" ,
      subtitle="What will impact our industy in the next year?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?\" AS Response FROM responses where Response <> ''",
      response_summary = "The responses to this survey question reflect a mix of apprehension and cautious optimism regarding the future of the logistics and delivery industry. Key concerns and anticipated changes include:
•	Integration of Contract Partner business segments: Many contractors anticipate the integration to have a significant impact on operations. While some hope for increased efficiency and volume, others fear it will lead to more complexity and inefficiency without adequate compensation.
•	Electric Vehicles (EVs): The shift towards electric vehicles is seen as a significant trend, with some viewing it positively for its potential environmental and operational benefits, and others concerned about the challenges and costs of transitioning to an all-electric fleet.
•	Competition and Market Dynamics: Respondents note the increasing competition between USPS, Amazon, and UPS, which could impact their Contract Partner’s market share. The competitive landscape is seen as both a threat and an opportunity, depending on the Contract Partners' ability to adapt and innovate.
•	Economic and Political Factors: The presidential race and potential economic policies are mentioned as external factors that could impact the business environment, with concerns about the economy's direction and the regulatory landscape, especially regarding labor and environmental regulations.
•	Labor Market and Costs: Rising labor costs and the challenge of maintaining competitive pay rates are highlighted as ongoing issues. The tight labor market and the need to compete for workers are seen as critical factors affecting operational costs and efficiency.
•	Inflation: Inflation is a concern for many, with fears that rising costs will not be matched by corresponding increases in compensation, impacting profitability.",
      quote_of_intrest = "[Other shippers], and probably other smaller logistics companies, will continue to take share from [Contract Partner] because they are more efficient and changing more rapidly for the future."
    ),
    RelationshipWithCompany = list(
      question = "Share an experience that exemplifies your relationship with the company your contract is with.",
      title = "Partnership Dynamics" ,
      subtitle="What is the relationship with your contract partner like?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Share an experience that exemplifies your relationship with the company your contract is with.\" AS Response FROM responses where Response <> ''",
      response_summary = "The survey responses vividly depict a range of experiences that contractors have with their Contract Partners, revealing a complex and often strained relationship. A common theme across many responses is a sense of disillusionment and frustration, with contractors feeling undervalued, unsupported, and at times, exploited. Key points of contention include:
•	Lack of Support and Transparency: Contractors express dissatisfaction with the lack of access to necessary support and transparent communication, feeling left to navigate challenges on their own.
•	Financial and Operational Strain: Many respondents highlight the financial pressures they face, particularly due to inflation, and perceive a lack of effort from their Contract Partner to provide relief or fair compensation. The strain is exacerbated by operational inefficiencies, such as inaccurate delivery estimates, which significantly impact contractors' ability to plan and execute their work effectively.
•	Adversarial Relationship: The sentiment that the relationship between a Contract Partner and its contractors is more adversarial than collaborative is a recurring theme. This is epitomized by experiences of negotiation difficulties, perceived indifference to contractors' operational realities, and unilateral rule changes.
•	Instances of Neglect and Inefficiency: Some contractors share specific instances that underscore their challenges, such as unpaid contingency work, mismanagement, and unmet promises from senior management. These experiences contribute to a feeling of being overburdened and underappreciated.",
      quote_of_intrest = "We have several contracts. A Contractor about 5 hours away from us walked away from their contract with zero notice. We were asked to run contingency so we did... [Contract Partner] missed several payments to us and when we did get paid, it was always the wrong amount... Doing the contingency work hurt our overall service... We took all of the risk and ended up breaking even... We will never run contingency again."
    ),
    ChallengesAndRewards = list(
      question = "What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?",
      title = "If only I had known..." ,
      subtitle="What should everyone know about being a Service Provider?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?\" AS Response FROM responses where Response <> ''",
      response_summary = "The responses vividly convey the challenging and often disheartening realities faced by Service Provider contractors. There's a stark depiction of a relationship characterized by imbalance, where contractors bear the brunt of financial and operational pressures with limited support or fair compensation from the Contracting Partner. Key themes include:
•	Financial and Operational Strain: Contractors highlight the financial challenges and risks involved, including the significant investment required with minimal returns, the stress of being financially tethered to the company, and the perception that they earn \"cents on the dollar\" compared to the profits of their Contracting Partner.
•	Lack of Autonomy and Support: Many responses express frustration with the lack of autonomy and the feeling of being at the mercy of the Contracting Partner’s policies and decisions, which can be capricious and poorly communicated. The sense of being an \"employee without benefits or protections\" underscores the vulnerability of contractors in this relationship.
•	Misconceptions and Reality: Contractors wish outsiders understood the demanding nature of the work, the misconception of it being a passive income venture, and the importance of having a solid operational and cultural foundation within their companies. They also highlight the misunderstanding by the public, who often do not realize that these contractors are small business owners facing considerable challenges, not part of a large, impersonal corporation.
•	Emotional and Personal Toll: The impact on personal well-being and relationships is a significant concern, with the business's financial and emotional stress leading to strains on marriages and personal lives. The constant pressure and lack of adequate rewards contribute to a sentiment of disillusionment and regret among some contractors.",
      quote_of_intrest = "[Contract Partner] does not give a [explicative] about contractors. We work so hard to make things happen for [Contract Partner] and don't make great profits. It's a living and supports my family but it is not worth it. Contractors take all of the risk, take on all of the liability and do not get compensated commensurately for it. [Contract Partner] has the memory of a goldfish. We bail them out all of the time and are met with a constant barrage of texts, phone calls, and email about equipment, service, and [Contract Partner]-specific requirements."
    )
  )
)
