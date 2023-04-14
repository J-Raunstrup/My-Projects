/*
Here's the first-touch query, in case you need it
*/

WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id)
SELECT ft.user_id,
    ft.first_touch_at,
    pv.utm_source,
		pv.utm_campaign
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
    -- own addition
    limit 10;

--own code starts here.
--1.
--How many campaigns and sources does CoolTShirts use? Which source is used for each campaign?
SELECT COUNT(DISTINCT utm_campaign)
FROM page_visits;
--output: COUNT(DISTINCT utm_campaign)
--8

SELECT COUNT(DISTINCT utm_source)
FROM page_visits;
--output: COUNT(DISTINCT utm_source)
--6

SELECT DISTINCT utm_source, utm_campaign
FROM page_visits;
--output: too much for text editor



--2.
--What pages are on the CoolTShirts website?
SELECT DISTINCT page_name
FROM page_visits;
--output:
/*
page_name
1 - landing_page
2 - shopping_cart
3 - checkout
4 - purchase
*/



--3.
--How many first touches is each campaign responsible for?
--no idea.

--code after hint used.
WITH first_touch AS (
    SELECT user_id,
        MIN(timestamp) as first_touch_at
    FROM page_visits
    GROUP BY user_id),
ft_attr AS (SELECT ft.user_id,
    ft.first_touch_at,
    pv.utm_source,
		pv.utm_campaign
FROM first_touch ft
JOIN page_visits pv
    ON ft.user_id = pv.user_id
    AND ft.first_touch_at = pv.timestamp
)
SELECT ft_attr.utm_source,
  ft_attr.utm_campaign,
  COUNT(*)
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;



--4.
--How many last touches is each campaign responsible for?
--copied and changed from previous query.
WITH last_touch AS (
    SELECT user_id,
      MAX(timestamp) as last_touch_at
    FROM page_visits
    GROUP BY user_id), 
  lt_attr AS (
    SELECT lt.user_id,
      lt.last_touch_at,
      pv.utm_source,
      pv.utm_campaign
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch_at = pv.timestamp
)
SELECT lt_attr.utm_source,
  lt_attr.utm_campaign,
  COUNT(*)
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;



--5.
--How many visitors make a purchase?
--own method working
SELECT DISTINCT COUNT(user_id)
FROM page_visits
WHERE page_name = '4 - purchase';

--following viewed from hint: can also be done as the following. i think this solution is better since it also outputs the name of the page. for each user id category.
SELECT DISTINCT COUNT(user_id), page_name
FROM page_visits
GROUP BY page_name;



--6.
--How many last touches on the purchase page is each campaign responsible for?
--own code before hint
/*
WITH last_touch AS (
  SELECT user_id,
    MAX(timestamp) as last_touch_at
  FROM page_visits
  GROUP BY user_id),
  lt_attr AS (
    SELECT lt.user_id,
    lt.last_touch_at,
    pv.utm_source,
    pv.utm_campaign
    FROM last_touch lt
    JOIN page_visits pv
      ON lt.user_id = pv.user_id
      AND lt.last_touch_at = pv.timestamp
  )
  SELECT lt_attr.utm_source,
  lt_attr.utm_campaign,
  COUNT(*)
  FROM lt_attr
  GROUP BY 1,2
  ORDER BY 3 DESC;
  */
--after hint not working
/*
  WITH last_touch AS (
  SELECT user_id,
    MAX(timestamp) as last_touch_at
  FROM page_visits
  WHERE page_name = '4 - campaign'
  GROUP BY user_id),
  lt_attr AS (
    SELECT lt.user_id,
    lt.last_touch_at,
    pv.utm_source,
    pv.utm_campaign
    FROM last_touch lt
    JOIN page_visits pv
      ON lt.user_id = pv.user_id
      AND lt.last_touch_at = pv.timestamp
  )
  SELECT lt_attr.utm_source,
  lt_attr.utm_campaign,
  COUNT(*)
  FROM lt_attr
  GROUP BY 1,2
  ORDER BY 3 DESC;
*/
-- after video working.
  WITH last_touch AS (
  SELECT user_id,
    MAX(timestamp) as last_touch_at
  FROM page_visits
  WHERE page_name = '4 - purchase'
  GROUP BY user_id)
SELECT lt.user_id,
    lt.last_touch_at,
    pv.utm_source,
    pv.utm_campaign,
    COUNT(utm_campaign)
    FROM last_touch lt
    JOIN page_visits pv
      ON lt.user_id = pv.user_id
      AND lt.last_touch_at = pv.timestamp
  GROUP BY utm_campaign
  ORDER BY 5 DESC;

  --7.
  --CoolTShirts can re-invest in 5 campaigns. Given your findings in the project, which should they pick and why?

  --wrong answer below
/*
i would say the following 5:
1. ny times. its in the top four in first and last touch attribution count of users. first touch is first web click. last touch is the purchase.
2. email. it represents  2 out of 3 last touch attribution count of users in the top 3. This is used for count of purchases
3. facebook. its the 2. best last touch attribution count of users. Hence more sales.
4. buzzfeed. it has almost as high a count of first touch attribution users as medium. and a little more sales.
5. medium. it has the most first touch attributions. though its ranked pretty low on last touch attribution count of users. Hence not as many sales.
*/

--new answer after looking at purchases for each campaign.
/*
i would say the following 5 since they are the campaigns with the higehst amount of purchases.
1. "weekly-newsletter". 
2. "retargetting-ad".
3. "retargetting-campaign".
4. "paid-search".
5. "ten-crazy-cool-tshirts-facts".
*/