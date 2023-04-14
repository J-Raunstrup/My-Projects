 --1.
 --Take a look at the first 100 rows of data in the subscriptions table. How many different segments do you see?
 SELECT *
 FROM subscriptions
 LIMIT 100;

 --output: a lot of data.

 SELECT COUNT(DISTINCT segment)
 FROM subscriptions
 LIMIT 100;

 --output: "2"



--2.
--no idea

--code after hint used.

SELECT MIN(subscription_start), MAX(subscription_start)
FROM subscriptions;

/*output: "MIN(subscription_start)	MAX(subscription_start)
2016-12-01	2017-03-30" */

--answer: start january to end of march.



--3.
--To get started, create a temporary table of months.
--code before hint.
/*WITH 'months' AS */

--code after hint.
WITH months AS
(SELECT
  '2017-01-01' as first_day,
  '2017-01-31' as last_day
UNION
SELECT
  '2017-02-01' as first_day,
  '2017-02-31' as last_day
UNION
SELECT
  '2017-03-01' as first_day,
  '2017-03-01' as last_day
),



--4.
--Create a temporary table, cross_join, from subscriptions and your months. Be sure to SELECT every column.
cross_join AS
(SELECT * FROM subscriptions
  CROSS JOIN months
),



--5. 
--Create a temporary table, status, from the cross_join table you created.
 status AS
(SELECT id,
first_day AS month, segment,
CASE
  WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL) THEN 1
  ELSE 0
END AS is_active,
CASE
  WHEN (subscription_start < first_day) AND (subscription_end > first_day OR subscription_end IS NULL) THEN 1
  ELSE 0
END AS is_active, 



--6.
--Add an is_canceled_87 and an is_canceled_30 column to the status temporary table.
CASE
  WHEN (subscription_end BETWEEN first_day AND last_day) THEN 1
  ELSE 0
  END AS is_canceled
FROM cross_join),



-- 7.
--Create a status_aggregate temporary table that is a SUM of the active and canceled subscriptions for each segment,
--for each month.
status_aggregate AS (
SELECT 
month, segment,
SUM(is_active) AS sum_active,
SUM(is_canceled) AS sum_canceled
FROM status
GROUP BY month, segment)

--8.
--Calculate the churn rates for the two segments over the three month period. Which segment has a lower churn rate?

SELECT month, segment,
1.0 * sum_canceled / sum_active AS churn_rate_segment
FROM status_aggregate;

--output:"month	churn_rate_segment_87	churn_rate_segment_30
/*
2017-01-01	0.251798561151079	0.107913669064748
2017-02-01	0.32034632034632	0.0649350649350649
2017-03-01	0.0188323917137476	0.0564971751412429"
*/

--answer: churn rate 30 has a lower rate.

--9.
--How would you modify this code to support a large number of segments?