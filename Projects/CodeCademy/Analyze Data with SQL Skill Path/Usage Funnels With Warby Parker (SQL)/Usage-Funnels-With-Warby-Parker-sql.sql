
 --1.
 --Select all columns from the first 10 rows. What columns does the table have?

 SELECT *
 FROM survey
 LIMIT 10;

 -- column names: question,	user_id,	response

 /*output:
question	user_id	response
1. What are you looking for?	005e7f99-d48c-4fce-b605-10506c85aaf7	Women's Styles
2. What's your fit?	005e7f99-d48c-4fce-b605-10506c85aaf7	Medium
3. Which shapes do you like?	00a556ed-f13e-4c67-8704-27e3573684cd	Round
4. Which colors do you like?	00a556ed-f13e-4c67-8704-27e3573684cd	Two-Tone
1. What are you looking for?	00a556ed-f13e-4c67-8704-27e3573684cd	I'm not sure. Let's skip it.
2. What's your fit?	00a556ed-f13e-4c67-8704-27e3573684cd	Narrow
5. When was your last eye exam?	00a556ed-f13e-4c67-8704-27e3573684cd	<1 Year
3. Which shapes do you like?	00bf9d63-0999-43a3-9e5b-9c372e6890d2	Square
5. When was your last eye exam?	00bf9d63-0999-43a3-9e5b-9c372e6890d2	<1 Year
2. What's your fit?	00bf9d63-0999-43a3-9e5b-9c372e6890d2	Medium
*/



--2.
--What is the number of responses for each question?
SELECT *, COUNT(question)
FROM survey
GROUP BY question
ORDER BY COUNT(question) DESC;

/*output: 
question	user_id	response	COUNT(question)
1. What are you looking for?	005e7f99-d48c-4fce-b605-10506c85aaf7	Women's Styles	500
2. What's your fit?	005e7f99-d48c-4fce-b605-10506c85aaf7	Medium	475
3. Which shapes do you like?	00a556ed-f13e-4c67-8704-27e3573684cd	Round	380
4. Which colors do you like?	00a556ed-f13e-4c67-8704-27e3573684cd	Two-Tone	361
5. When was your last eye exam?	00a556ed-f13e-4c67-8704-27e3573684cd	<1 Year	270
Database Schema

answer: question 1 count 500.
question 2 count 475
question 3 count 380
question 4 count 361
question 5 count 270
*/



--3. 
--Which question(s) of the quiz have a lower completion rates?
--What do you think is the reason?

--done. check excel file for cleaner view.

--question	user_id	response	COUNT(question)	% of answers
--1. What are you looking for?	005e7f99-d48c-4fce-b605-10506c85aaf7	Women's Styles	500	100%
-- 2. What's your fit?	005e7f99-d48c-4fce-b605-10506c85aaf7	Medium	475	95%
-- 3. Which shapes do you like?	00a556ed-f13e-4c67-8704-27e3573684cd	Round	380	76%
-- 4. Which colors do you like?	00a556ed-f13e-4c67-8704-27e3573684cd	Two-Tone	361	72%
-- 5. When was your last eye exam?	00a556ed-f13e-4c67-8704-27e3573684cd	<1 Year	270	54%


--4.
--Let’s find out whether or not users who get more pairs to try on at home will be more likely to make a purchase.

-- The data will be distributed across three tables:
-- quiz
-- home_try_on
-- purchase

-- Examine the first five rows of each table
-- What are the column names?

SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;

/*
quiz column names: user_id,	style,	fit,	shape,	color

home_try_on column names: user_id,	number_of_pairs,	address

purchase column names: user_id,	product_id,	style,	model_name,	color,	price
*/



--5.
--Use a LEFT JOIN to combine the three tables, starting with the top of the funnel (quiz) and ending with the bottom of the funnel (purchase).

-- Select only the first 10 rows from this table (otherwise, the query will run really slowly).

SELECT 
q.user_id, 
h.user_id IS NOT NULL AS 'is_home_try_on', 
h.number_of_pairs, 
p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
  ON q.user_id = h.user_id
LEFT JOIN purchase p
  ON p.user_id = q.user_id
LIMIT 10;


--you can give a mini alias to table. when left joinning and specifying from where. by typing a space tag ' ' then after that specifying an alias for the table.



--6.
--What are some actionable insights for Warby Parker?
WITH q AS (
  SELECT '1-quiz' AS stage, COUNT(DISTINCT user_id)
  FROM quiz
),
h AS (
  SELECT '2-home-try-on' AS stage, COUNT(DISTINCT user_id)
  FROM home_try_on
), 
p AS (
  SELECT '3-purchase' AS stage, COUNT(DISTINCT user_id)
  FROM purchase
)
SELECT *
FROM q
UNION ALL SELECT *
FROM h
UNION ALL SELECT *
FROM p;



WITH base_table AS (
  SELECT DISTINCT q.user_id, h.user_id IS NOT NULL AS 'is_home_try_on', h.number_of_pairs AS 'AB_variant', p.user_id IS NOT NULL AS 'is_purchase'
  FROM quiz q
  LEFT JOIN home_try_on h
    ON q.user_id = h.user_id
  LEFT JOIN purchase p
    ON p.user_id = q.user_id
)
SELECT AB_variant,
  SUM(CASE WHEN is_home_try_on = 1
  THEN 1
  ELSE 0
  END) 'home_trial',
  SUM(CASE WHEN is_purchase = 1
  THEN 1
  ELSE 0
  END) 'purchase'
FROM base_table
GROUP BY AB_variant
HAVING home_trial > 0;



--actionable insights: it seems that there are more people buying glasses when they can try on 5 pairs. 
--However we dont know if this is too expensive for the buisness to ship or if there are some hidden expense we dont know about. 
--We also haven't calculated if that specific cost will make 5 instead of 3 pairs per trial justifiable. Though just looking at glass sales. 
--There are more sales where there are 5 glasses purchased.