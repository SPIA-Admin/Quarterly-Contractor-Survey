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
      title = "Dispatches/Week" ,
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
      response_summary = "<p>Common experiences emerged around issues such as hiring, fleet maintenance, financial strain due to increased costs and reduced contract rates, and the challenge of maintaining profitability amidst these adversities.</p>
<p>The actions respondents have taken to address these challenges include hiring specialized staff such as fleet technicians and recruiting companies, shifting to alternative vendor agreements for better rates, leasing vehicles to manage upfront costs, and adjusting operational strategies such as scheduling and workforce management to improve efficiency and reduce dependency on unreliable factors.</p>",
      quote_of_intrest = "<span style='color:#E7A922; background-color:#E5E5DD; text-align:center;'>**\"*Our contracts have been reduced year over year across the board. One small contract, our revenue dropped almost 15%... We cannot fathom how [Contract Partner]could reduce all of our revenue when the cost of labor, fuel and equipment has gone up drastically.*\"**</span><br>"
    ),
    SuccessStory = list(
      question = "Describe a recent success story or a significant milestone your company achieved.",
      title = "Success Stories" ,
      subtitle="What success have you recently achieved?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Describe a recent success story or a significant milestone your company achieved.\" AS Response FROM responses where Response <> ''",
      response_summary = "<p>Respondents painted a picture of resilience and achievement despite the challenges they faced; With a notable emphasis on safety, operational excellence, and strategic growth.</p>
<p>Their achievements span a range of areas, including safety milestones such as <i>\"14 months no accidents,\"</i> and operational successes like <i>\"Highest performing peak season as a company.\"</i> Several Service Providers highlighted their success in achieving Gold status.</p>",
      quote_of_intrest = "<span style='color:#E7A922; background-color:#E5E5DD; text-align:center;'>**\"*Negotiated higher paying contract, on average $0.57 per stop higher.*\"**</span><br>"
    ),
    SuggestionForImprovement = list(
      question = "If you could suggest one change to improve contractor relations, what would it be?",
      title = "Contract Improvements" ,
      subtitle="What is your suggestion to improve the relationship with your contract partner?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"If you could suggest one change to improve contractor relations, what would it be?\" AS Response FROM responses where Response <> ''",
      response_summary = "<p>There is a broad consensus among Service Providers on the need for improvements in the relationship with their Contract Partner, with a strong focus on fairness, transparency, and financial viability. 
<br><br>A need to:
<br>•	Eliminate inefficiencies.
<br>•	Understand how rates are calculated.
<br>•	Address the accuracy of volume projections.
<br>•	Be treated as true partners, not adversaries.
<br>•	Have fair contract terms with rates reflective of the economy.</p>",
      quote_of_intrest = "<span style='color:#E7A922; background-color:#E5E5DD; text-align:center;'>**\"*[Contract Partner] needs to stop forcing regulation after regulation on contractors … at a great monetary cost.*\"**</span><br>"
    ),
    IndustryChangeImpact = list(
      question = "Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?",
      title = "Industry Changes" ,
      subtitle="What will impact our industy in the next year?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Are there any upcoming industry changes or trends that you believe will impact your business positively or negatively in the next year?\" AS Response FROM responses where Response <> ''",
      response_summary = "<p>The responses to this survey question reflect a mix of apprehension and cautious optimism regarding the future of the logistics and delivery industry. 
<br><br>Key concerns and anticipated changes include:
<br>•	Integration of Contract Partner business segments.
<br>•	Electric Vehicles (EVs).
<br>•	Competition and Market Dynamics.
<br>•	Economic and Political Factors.
<br>•	Labor Market and Costs.
<br>•	Inflation.</p>",
      quote_of_intrest = "<span style='color:#E7A922; background-color:#E5E5DD; text-align:center;'>**\"*[Other shippers] will continue to take share from [Contract Partner] because they are more efficient and changing more rapidly for the future.*\"**</span><br>"
    ),
    RelationshipWithCompany = list(
      question = "Share an experience that exemplifies your relationship with the company your contract is with.",
      title = "Partnership Dynamics" ,
      subtitle="What is the relationship with your contract partner like?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"Share an experience that exemplifies your relationship with the company your contract is with.\" AS Response FROM responses where Response <> ''",
      response_summary = "<p>Service Providers depict a range of experiences with their Contract Partners, revealing a complex relationship. A common topic is a sense of disillusionment and frustration, with feelings of being undervalued, unsupported, and at times, exploited. 
<br><br>Contractors express dissatisfaction with the lack of access to necessary support and transparent communication, feeling left to navigate challenges on their own.
<br><br>Many respondents highlight the financial pressures they face, particularly due to inflation. The strain is exacerbated by operational inefficiencies which impact their ability to plan and execute their work effectively.</p>",
      quote_of_intrest = "<span style='color:#E7A922; background-color:#E5E5DD; text-align:center;'>**\"*We were asked to run contingency so we did… [Contract Partner] missed several payments to us and when we did get paid, it was always the wrong amount… We took all of the risk and ended up breaking even.*\"**</span><br>"
    ),
    ChallengesAndRewards = list(
      question = "What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?",
      title = "If only I had known..." ,
      subtitle="What should everyone know about being a Service Provider?",
      viz_type = "wordcloud",
      sql_query = "SELECT \"What's one thing you wish outsiders knew about the challenges and rewards of being a Service Provider contractor?\" AS Response FROM responses where Response <> ''",
      response_summary = "<p>Service Providers underscore the demanding nature of the work, the misconception of it being a passive income venture, and the importance of having a solid operational and cultural foundation within their companies. They highlight the misunderstanding by the public, who often do not realize that they are small business owners not large and impersonal corporation.
<br><br>The impact on personal well-being and relationships is a significant concern, with the business's financial and emotional stress leading to strains on marriages and personal lives.</p>",
      quote_of_intrest = "<span style='color:#E7A922; background-color:#E5E5DD; text-align:center;'>**\"*We work so hard to make things happen for [Contract Partner] and don't make great profits … We bail them out all of the time and are met with a constant barrage of texts, phone calls, and email about equipment, service, and [Contract Partner]-specific requirements.*\"**</span><br>"
    )
  )
)
