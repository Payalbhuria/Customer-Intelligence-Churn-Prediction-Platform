--View data--
SELECT *
FROM `customer-churn-platform.customer_intelligence.customer_data`
LIMIT 10;

--Total customers--
SELECT
COUNT(*) AS total_customers
FROM `customer-churn-platform.customer_intelligence.customer_data`;

--Check churn values--
SELECT DISTINCT Churn
FROM `customer-churn-platform.customer_intelligence.customer_data`;

--Churn rate--
SELECT
ROUND(
(COUNTIF(Churn=1)*100.0)/COUNT(*),
2
) AS churn_rate
FROM `customer-churn-platform.customer_intelligence.customer_data`;

--Customer count by churn--
SELECT
Churn,
COUNT(*) AS customers
FROM `customer-churn-platform.customer_intelligence.customer_data`
GROUP BY Churn;

--Average age of churned customers--
SELECT
AVG(Age) AS avg_age
FROM `customer-churn-platform.customer_intelligence.customer_data`
WHERE Churn=1;

--Average tenure of churned customers--
SELECT
AVG(Tenure) AS avg_tenure
FROM `customer-churn-platform.customer_intelligence.customer_data`
WHERE Churn=1;

--Support calls analysis--
SELECT
`Support Calls`,
COUNT(*) AS customers
FROM `customer-churn-platform.customer_intelligence.customer_data`
WHERE Churn=1
GROUP BY `Support Calls`
ORDER BY customers DESC;

--Payment delay analysis--
SELECT
AVG(`Payment Delay`) AS avg_payment_delay
FROM `customer-churn-platform.customer_intelligence.customer_data`
WHERE Churn=1;

--Subscription analysis--
SELECT
`Subscription Type`,
COUNT(*) AS churn_customers
FROM `customer-churn-platform.customer_intelligence.customer_data`
WHERE Churn=1
GROUP BY `Subscription Type`
ORDER BY churn_customers DESC;

--Contract analysis--
SELECT
`Contract Length`,
COUNT(*) AS churn_customers
FROM `customer-churn-platform.customer_intelligence.customer_data`
WHERE Churn=1
GROUP BY `Contract Length`
ORDER BY churn_customers DESC;

--Total spend analysis--
SELECT
Churn,
AVG(`Total Spend`) AS avg_spend
FROM `customer-churn-platform.customer_intelligence.customer_data`
GROUP BY Churn;

--Create ML model--
CREATE OR REPLACE MODEL
`customer-churn-platform.customer_intelligence.churn_model`

OPTIONS(
  model_type='logistic_reg',
  input_label_cols=['Churn']
)

AS

SELECT
Age,
Gender,
Tenure,

`Usage Frequency` AS Usage_Frequency,
`Support Calls` AS Support_Calls,
`Payment Delay` AS Payment_Delay,
`Subscription Type` AS Subscription_Type,
`Contract Length` AS Contract_Length,
`Total Spend` AS Total_Spend,
`Last Interaction` AS Last_Interaction,

Churn

FROM `customer-churn-platform.customer_intelligence.customer_data`;

--Evaluate model--
SELECT *
FROM ML.EVALUATE(
MODEL `customer-churn-platform.customer_intelligence.churn_model`
);

--Predict churn--
SELECT *
FROM ML.PREDICT(
MODEL `customer-churn-platform.customer_intelligence.churn_model`,
(
SELECT
Age,
Gender,
Tenure,

`Usage Frequency` AS Usage_Frequency,
`Support Calls` AS Support_Calls,
`Payment Delay` AS Payment_Delay,
`Subscription Type` AS Subscription_Type,
`Contract Length` AS Contract_Length,
`Total Spend` AS Total_Spend,
`Last Interaction` AS Last_Interaction

FROM `customer-churn-platform.customer_intelligence.customer_data`
)
);

-- new table--
CREATE OR REPLACE TABLE
`customer-churn-platform.customer_intelligence.predicted_customers`

AS

SELECT *
FROM ML.PREDICT(
MODEL `customer-churn-platform.customer_intelligence.churn_model`,
(
SELECT
CustomerID,
Age,
Gender,
Tenure,

`Usage Frequency` AS Usage_Frequency,
`Support Calls` AS Support_Calls,
`Payment Delay` AS Payment_Delay,
`Subscription Type` AS Subscription_Type,
`Contract Length` AS Contract_Length,
`Total Spend` AS Total_Spend,
`Last Interaction` AS Last_Interaction

FROM `customer-churn-platform.customer_intelligence.customer_data`
)
);
--high-risk customers--
SELECT
CustomerID,
predicted_Churn,
predicted_Churn_probs

FROM `customer-churn-platform.customer_intelligence.predicted_customers`

WHERE predicted_Churn=1
LIMIT 20;