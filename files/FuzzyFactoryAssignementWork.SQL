-- psql -h localhost -d FuzzyFactory -U postgres -p 5432 -a -q -f createmavenfuzzyfactory-postgres.sql 
-- psql -h chartio-dbt-09032020.cevjpmn7ct9r.us-east-2.rds.amazonaws.com -d FuzzyFactory -U postgres -p 5432 -a -q -f createmavenfuzzyfactory-postgres.sql


--======================================================================
/*
	Analyzing Website Traffic Sources
*/
--======================================================================

-- First version of query
SELECT utm_content,
	   COUNT(DISTINCT website_sessions.website_session_id) AS "Sessions",
	   COUNT(DISTINCT order_id) AS "Orders",
	   ROUND(CAST(COUNT(DISTINCT order_id) AS decimal)/CAST(COUNT(DISTINCT website_sessions.website_session_id) AS decimal), 3)  AS "Session->Order Conversion"
FROM mavenfuzzyfactory.website_sessions 
	LEFT JOIN mavenfuzzyfactory.orders 
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY utm_content
ORDER BY "Sessions" DESC;


-- First Assignment Query
/* 
   The website has been live for almost a month now. So we would like to see
   where the bulk of the sessions is coming from as of yesterday ('2012-04-12').
   
   Specifically, marketing/sales would like to see a breakdown by UTM_SOURCE,
   UTM_CAMPAIGN, and HTTP_REFERER.
*/
SELECT utm_source,
	   utm_campaign,
	   http_referer,
	   COUNT(DISTINCT website_sessions.website_session_id) AS "Sessions"
FROM mavenfuzzyfactory.website_sessions 
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY "Sessions" DESC;

--Second Assignment Query
/*
  'gsearch' and 'nonbrand' are major sources for out website sessions. But,
  are they contributing significantly to sales conversions?
  
  We now need to calculate the conversion rate from Session->Order. Based upon
  the current "price per click", a CVR or at least 4% is necessary. If it is 
  lower, then we will need to reduce our bids.
  
  CVR= ~3% (0.029)
*/
SELECT COUNT(DISTINCT website_sessions.website_session_id) AS "Sessions",
	   COUNT(DISTINCT order_id) AS "Orders",
	   ROUND(CAST(COUNT(DISTINCT order_id) AS decimal)/CAST(COUNT(DISTINCT website_sessions.website_session_id) AS decimal),3)  AS "Session->Order Conversion"
FROM mavenfuzzyfactory.website_sessions 
	LEFT JOIN mavenfuzzyfactory.orders 
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
	  AND website_sessions.created_at < '2012-04-14';
	  
-- Third Assignment Query
/*
  This report is on "Traffic Source Trends". Based on previous "Conversion 
  Rate Analysis (CVR)", Marketing bid down on 'gsearch' and 'nonbrand'. We 
  will now pull 'gsearch' and 'nonbrand' trend session volumes by week to see
  if this bids have affected volumes.
*/
SELECT EXTRACT(YEAR from created_at) AS "Year",
	   MIN(DATE(created_at)) AS "Week",
	   COUNT (website_session_id) AS "Sessions"
FROM mavenfuzzyfactory.website_sessions
WHERE website_sessions.utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
	  AND website_sessions.created_at < '2012-05-10'
GROUP BY EXTRACT(YEAR from created_at),
		 EXTRACT(WEEK from created_at)
ORDER BY "Week";

-- Fourth Assignment Query
/*
  	Traffic Source Bid Optimizations
	Traffic Source Trends indicate that based on our lower bids traffice volumes
	are indeed being affected. One bit of information that is clear is that bids 
	are now the same for both 'desktop' and 'mobile' devices. But it appears 
	that the experience on mobile devices is not great. How can we confirm this.
	
	This report now pulls conversion rates (CVR) from session to order by device 
	type fromo before '2012-05-11'.
	
	Sure enough, conversion rates from mobile devices are quite low.
*/
SELECT device_type,
       COUNT(DISTINCT website_sessions.website_session_id) AS "Sessions",
	   COUNT(DISTINCT order_id) AS "Orders",
	   ROUND(CAST(COUNT(DISTINCT order_id) AS decimal)/CAST(COUNT(DISTINCT website_sessions.website_session_id) AS decimal), 4)  AS "Session->Order Conversion"
FROM mavenfuzzyfactory.website_sessions
	LEFT JOIN mavenfuzzyfactory.orders 
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
	  AND website_sessions.created_at < '2012-05-11'
GROUP BY device_type;

-- Fifth Assignment Query
/*
  	Traffic Source Bid Optimizations by Granular Segments. 
	Let's now pull the weekly volumes by 'device_type'
*/

SELECT MIN(DATE(created_at)) AS "Week",
	   COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS "Mobile Count",
	   COUNT(DISTINCT CASE WHEN device_type='desktop' THEN website_session_id ELSE NULL END) AS "Desktop Count"
FROM mavenfuzzyfactory.website_sessions
WHERE  (website_sessions.created_at > '2012-04-15'
	  AND website_sessions.created_at < '2012-06-09')
	  AND website_sessions.utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
GROUP BY EXTRACT(YEAR from created_at),
	  	 EXTRACT(WEEK from created_at)
ORDER BY "Week";

-- Another practice query
SELECT primary_product_id,
	   COUNT(DISTINCT CASE WHEN items_purchased=1 THEN order_id ELSE NULL END) AS count_single_item_order,
	   COUNT(DISTINCT CASE WHEN items_purchased=2 THEN order_id ELSE NULL END) AS count_two_item_order
FROM mavenfuzzyfactory.orders 
WHERE order_id BETWEEN 31000 AND 32000
GROUP BY 1;

--======================================================================
/*
	Analyzing Website Performance
*/
--======================================================================

-- Total historical page view for every page on the website. Answers the question, what are
-- the most viewed pages on the website?
-- "WHERE website_pageview_id < 1000" has bee commented out to reveal the complete history.
SELECT pageview_url,
       COUNT(DISTINCT website_pageview_id) AS "Page Views"
FROM mavenfuzzyfactory.website_pageviews
-- WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY "Page Views" DESC;

-- Entry Page Analysis
-- What was the entry page for each unique sesssion?
CREATE TEMPORARY TABLE first_pageview AS
SELECT website_session_id,
	   MIN(website_pageview_id) AS "mn_pv_id"
FROM mavenfuzzyfactory.website_pageviews
-- WHERE website_pageview_id < 1000
GROUP BY website_session_id
ORDER BY website_session_id;

drop table first_pageview;

select * from first_pageview;

-- What were the most popular Entry Pages?
SELECT website_pageviews.pageview_url AS "Landing Page", -- aka Entry Page
       COUNT (DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN mavenfuzzyfactory.website_pageviews
	ON first_pageview."mn_pv_id"=website_pageviews.website_pageview_id
GROUP BY "Landing Page"
ORDER BY sessions_hitting_this_lander DESC;


-- What was the Entry Page for each session?
-- "ORDER BY" confirms data is correct.
SELECT first_pageview.website_session_id,
	   website_pageviews.pageview_url AS "Landing Page" -- aka Entry Page
FROM first_pageview
	INNER JOIN mavenfuzzyfactory.website_pageviews
	ON first_pageview."mn_pv_id"=website_pageviews.website_pageview_id
	AND first_pageview.website_session_id = website_pageviews.website_session_id
ORDER BY first_pageview.website_session_id
	
-- First Assignment Query
-- Most viewed pages ranked by session volume.
SELECT pageview_url,
	   COUNT(DISTINCT website_session_id) "Session Views"
FROM mavenfuzzyfactory.website_pageviews
--WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY "Session Views" DESC;

-- Second Assignment Query
-- List of Top Entry Pages
SELECT website_pageviews.pageview_url AS "Landing Page", -- aka Entry Page
       COUNT (DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN mavenfuzzyfactory.website_pageviews
	ON first_pageview."mn_pv_id"=website_pageviews.website_pageview_id
--WHERE website_pageviews.created_at < '2012-06-09'
GROUP BY "Landing Page";


/*
  Landing Page Performance and Testing
*/

-- BUSINESS CONTEXT: We want to see landing page performance for a certain time frame

-- STEP 1: Find the first website_pageview_id for relevant sessions.
-- STEP 2: Identify the landing page for each session.
-- STEP 3: Count page views for each session in order to indentify bounces.
-- STEP 4: Summarize total sessions and bounced sessions by landing page.

-- STEP 1: Find the first website_pageview_id for relevant sessions.
-- Finding the minimum website pageview id associated with each session that we care about
-- (Testing quering and associting the data with a temporary table)
CREATE TEMPORARY TABLE first_pageviews_demo AS
SELECT website_pageviews.website_session_id,
	   MIN(website_pageviews.website_pageview_id) AS "mn_pageview_id"
FROM mavenfuzzyfactory.website_pageviews
	INNER JOIN mavenfuzzyfactory.website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
	AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY website_pageviews.website_session_id
ORDER BY website_pageviews.website_session_id;

-- STEP 2: Identify the landing page for each session.
CREATE TEMPORARY TABLE sessions_w_landing_page_demo AS
SELECT first_pageviews_demo.website_session_id,
	   website_pageviews.pageview_url AS landing_page
FROM first_pageviews_demo
	JOIN mavenfuzzyfactory.website_pageviews 
	ON website_pageviews.website_pageview_id = first_pageviews_demo."mn_pageview_id"; -- website pageview is the landing page view.
	
SELECT * FROM sessions_w_landing_page_demo;
	
-- STEP 3: Count page views for each session in order to indentify bounces.
--  Createing the "bounced_sessions_only" temporary table for this purpose.
CREATE TEMPORARY TABLE bounced_sessions_only AS
SELECT sessions_w_landing_page_demo.website_session_id,
       sessions_w_landing_page_demo.landing_page,
	   COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_landing_page_demo
	LEFT JOIN mavenfuzzyfactory.website_pageviews 
	ON website_pageviews.website_session_id = sessions_w_landing_page_demo.website_session_id
GROUP BY sessions_w_landing_page_demo.website_session_id,
       sessions_w_landing_page_demo.landing_page
HAVING COUNT(DISTINCT website_pageviews.website_pageview_id) = 1;

-- STEP 4: Summarize total sessions and bounced sessions by landing page.
SELECT sessions_w_landing_page_demo.landing_page,
	   sessions_w_landing_page_demo.website_session_id,
	   bounced_sessions_only.website_session_id AS bounced_sessions
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only 
	ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
ORDER BY sessions_w_landing_page_demo.website_session_id;

-- Final Output
   -- Execute the previous query with a count of records.
   -- Group by landing page and add column that calculates the bounce rate.
   --- What is a bad/good bounce rate?
SELECT sessions_w_landing_page_demo.landing_page,
	   COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS sessions,
	   COUNT(DISTINCT bounced_sessions_only.website_session_id) AS bounced_session_id,
	   CAST(COUNT(DISTINCT bounced_sessions_only.website_session_id) AS decimal)/CAST(COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS decimal) AS bounce_rate
FROM sessions_w_landing_page_demo
	LEFT JOIN bounced_sessions_only 
	ON sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
GROUP BY sessions_w_landing_page_demo.landing_page;
ORDER BY sessions_w_landing_page_demo.website_session_id;

-- Third Assignment Query
-- Landing Page Bounce Rates
-- JMW Solution --> THIS WORKS
CREATE TEMPORARY TABLE first_homepage_pageviews AS
SELECT website_pageviews.website_session_id,
	   MIN(website_pageviews.website_pageview_id) AS mn_pageview_id
FROM mavenfuzzyfactory.website_pageviews
	INNER JOIN mavenfuzzyfactory.website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
	AND website_sessions.created_at < '2014-06-14' 
--	AND website_pageviews.pageview_url='/home'
GROUP BY website_pageviews.website_session_id
ORDER BY website_pageviews.website_session_id;

-- JMW Solution --> THIS WORKS
CREATE TEMPORARY TABLE homepage_bounced_sessions AS 
SELECT first_homepage_pageviews.website_session_id,
	   COUNT(DISTINCT website_pageviews.website_pageview_id) AS "Page Views"
FROM first_homepage_pageviews
	INNER JOIN mavenfuzzyfactory.website_pageviews
	ON first_homepage_pageviews.website_session_id = website_pageviews.website_session_id
GROUP BY first_homepage_pageviews.website_session_id
HAVING COUNT(website_pageviews.website_pageview_id)=1
ORDER BY "Page Views" DESC;

SELECT first_homepage_pageviews.website_session_id,
	   homepage_bounced_sessions.website_session_id
FROM first_homepage_pageviews 
	LEFT OUTER JOIN homepage_bounced_sessions
	ON homepage_bounced_sessions.website_session_id = first_homepage_pageviews.website_session_id;


-- Third Assignment Final Query
-- Landing Page Bounce Rates = .433
-- Double check this with the solution. These numbers seem high. ***THESE NUMBERS ARE INDEED CORRECT***
SELECT 
	   COUNT (DISTINCT first_homepage_pageviews.website_session_id ) AS sessions,
	   COUNT(DISTINCT homepage_bounced_sessions.website_session_id) AS bounced_sessions,
	   CAST(COUNT(DISTINCT homepage_bounced_sessions.website_session_id) AS decimal)/ CAST(COUNT(DISTINCT first_homepage_pageviews.website_session_id ) AS decimal) AS bounce_rate
FROM first_homepage_pageviews 
	LEFT OUTER JOIN homepage_bounced_sessions
	ON homepage_bounced_sessions.website_session_id = first_homepage_pageviews.website_session_id;

/*
  Landing Page Performance and Testing (Course solution code)
*/

-- BUSINESS CONTEXT: We want to see landing page performance for a certain time frame

-- STEP 1: Find the first website_pageview_id for relevant sessions.
-- STEP 2: Identify the landing page for each session. (Course solution code)
-- STEP 3: Count page views for each session in order to indentify bounces.
-- STEP 4: Summarize total sessions and bounced sessions by landing page.

-- STEP 1: Find the first website_pageview_id for relevant sessions.
-- Finding the minimum website pageview id associated with each session that we care about
-- (Testing quering and associting the data with a temporary table)

--======================================================================
-- STEP 1: Find the first website_pageview_id for relevant sessions.(Course solution code)
CREATE TEMPORARY TABLE first_homepage_pageviews_CS AS
SELECT website_pageviews.website_session_id,
	   MIN(website_pageviews.website_pageview_id) AS mn_pageview_id
FROM mavenfuzzyfactory.website_pageviews
WHERE website_pageviews.created_at < '2014-06-14'
--	AND website_pageviews.pageview_url='/home' (JMW addition)
GROUP BY website_pageviews.website_session_id;

SELECT * FROM first_homepage_pageviews_CS;

-- STEP 2: Identify the landing page for each session. (Course solution code)
-- (This step is actually redundant since EVERY sesssion begins on '/home' )
CREATE TEMPORARY TABLE sessions_w_home_landing_page_CS AS
SELECT first_homepage_pageviews_CS.website_session_id,
	   website_pageviews.pageview_url AS landing_page
FROM first_homepage_pageviews_CS
	LEFT JOIN mavenfuzzyfactory.website_pageviews 
	ON website_pageviews.website_pageview_id = first_homepage_pageviews_CS.mn_pageview_id
WHERE website_pageviews.pageview_url='/home'; 

SELECT * FROM sessions_w_home_landing_page_CS
ORDER BY website_session_id;

-- STEP 3: Count page views for each session in order to indentify bounces. (Course solution code)
CREATE TEMPORARY TABLE bounced_sessions_CS AS 
SELECT sessions_w_home_landing_page_CS.website_session_id,
       sessions_w_home_landing_page_CS.landing_page,
	   COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM sessions_w_home_landing_page_CS
	LEFT JOIN mavenfuzzyfactory.website_pageviews
	ON sessions_w_home_landing_page_CS.website_session_id = website_pageviews.website_session_id
GROUP BY sessions_w_home_landing_page_CS.website_session_id, sessions_w_home_landing_page_CS.landing_page
HAVING COUNT(website_pageviews.website_pageview_id)=1
ORDER BY count_of_pages_viewed DESC;

-- STEP 4: Summarize total sessions and bounced sessions by landing page. (Course solution code)
--- (sessions=72529, bounced_sessions=31437, bounce_rate=.433)
SELECT 
	   COUNT (DISTINCT sessions_w_home_landing_page_CS.website_session_id) AS sessions,
	   COUNT (DISTINCT bounced_sessions_CS.website_session_id) as bounced_sessions,
	   CAST(COUNT(DISTINCT bounced_sessions_CS.website_session_id) AS decimal)/ CAST(COUNT(DISTINCT sessions_w_home_landing_page_CS.website_session_id ) AS decimal) AS bounce_rate
FROM sessions_w_home_landing_page_CS 
	LEFT OUTER JOIN bounced_sessions_CS
	ON sessions_w_home_landing_page_CS.website_session_id = bounced_sessions_CS.website_session_id


	
--======================================================================

--======================================================================
-- Fourth Assignment Query
-- Landing Page Bounce Rates A/B Testing (STUB)
-- "Help Analyzing LP Tests"
/*
 A new custom landing page (/lander-1) has been created in response to the 
 previous bounce rate analysis that had been done. This page is meant to 
 now be used in a 50/50 test against the "home page" (/home) for our 'gsearch'
 and 'nonbrand' traffic.
 
 The challenge is to pull and compare bounce rates between the two pages since
 the page was launched. 
 
*/
-- STEP 0: Find out when the new page '/lander-1' launched (Course solution code).
-- STEP 1: Find the first website_pageview_id for relevant sessions (Course solution code).
-- STEP 2: Identify the landing page for each session. (Course solution code)
-- STEP 3: Count page views for each session in order to indentify bounces (Course solution code).
-- STEP 4: ummarize total sessions and bounced sessions by landing page (Course solution code).

-- STEP 0: Find out when the new page '/lander-1' launched (Course solution code)
-- created_at '2012-06-19 00:35:54' (First time '/lander-1' was displayed on the site)
-- first_pageview_id '23504'
SELECT MIN(created_at) first_date_created,
       MIN(website_pageview_id) first_pageview_id
FROM mavenfuzzyfactory.website_pageviews
WHERE pageview_url='/lander-1';

-- STEP 1: Find the first website_pageview_id for relevant sessions (Course solution code).
CREATE TEMPORARY TABLE first_test_pageviews_CS AS
SELECT website_pageviews.website_session_id,
	   MIN(website_pageviews.website_pageview_id) AS mn_pageview_id
FROM mavenfuzzyfactory.website_pageviews
	INNER JOIN mavenfuzzyfactory.website_sessions
    ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at < '2012-07-28'
	AND website_pageviews.website_pageview_id > 23504
	AND utm_source='gsearch'
	AND utm_campaign='nonbrand'
--	AND website_pageviews.pageview_url='/home' (JMW addition)
GROUP BY website_pageviews.website_session_id;

-- STEP 2: Identify the landing page for each session. (Course solution code)
drop table nonbrand_test_sessions_w_landing_page_CS;
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page_CS AS
SELECT first_test_pageviews_CS.website_session_id,
	   website_pageviews.pageview_url as landing_page
FROM first_test_pageviews_CS
	LEFT JOIN mavenfuzzyfactory.website_pageviews
	ON website_pageviews.website_pageview_id = first_test_pageviews_CS.mn_pageview_id
WHERE website_pageviews.pageview_url='/home'
	OR  website_pageviews.pageview_url='/lander-1'
ORDER BY first_test_pageviews_CS.website_session_id;

-- STEP 3: Count page views for each session in order to indentify bounces (Course solution code).
CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions_CS AS 
SELECT nonbrand_test_sessions_w_landing_page_CS.website_session_id,
	   nonbrand_test_sessions_w_landing_page_CS.landing_page,
	   COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM nonbrand_test_sessions_w_landing_page_CS
	INNER JOIN mavenfuzzyfactory.website_pageviews
	ON nonbrand_test_sessions_w_landing_page_CS.website_session_id = website_pageviews.website_session_id
GROUP BY nonbrand_test_sessions_w_landing_page_CS.website_session_id, nonbrand_test_sessions_w_landing_page_CS.landing_page
HAVING COUNT(website_pageviews.website_pageview_id)=1
ORDER BY count_of_pages_viewed DESC;

-- STEP 4: ummarize total sessions and bounced sessions by landing page (Course solution code).
SELECT nonbrand_test_sessions_w_landing_page_CS.landing_page,
	   nonbrand_test_sessions_w_landing_page_CS.website_session_id,
	   nonbrand_test_bounced_sessions_CS.website_session_id as bounced_website_session_id
FROM nonbrand_test_sessions_w_landing_page_CS 
	LEFT OUTER JOIN nonbrand_test_bounced_sessions_CS
	ON nonbrand_test_sessions_w_landing_page_CS.website_session_id = nonbrand_test_bounced_sessions_CS.website_session_id
ORDER BY nonbrand_test_sessions_w_landing_page_CS.website_session_id;

-- Fourth Assignment Final Query
-- Landing Page Bounce Rates A/B Testing (STUB)

SELECT nonbrand_test_sessions_w_landing_page_CS.landing_page,
	   COUNT(DISTINCT nonbrand_test_sessions_w_landing_page_CS.website_session_id) AS Sessions,
	   COUNT(DISTINCT nonbrand_test_bounced_sessions_CS.website_session_id) AS Bounced_Sessions,
	   CAST(COUNT(DISTINCT nonbrand_test_bounced_sessions_CS.website_session_id) AS decimal)/ CAST(COUNT(DISTINCT nonbrand_test_sessions_w_landing_page_CS.website_session_id ) AS decimal) AS bounce_rate

FROM nonbrand_test_sessions_w_landing_page_CS 
	LEFT OUTER JOIN nonbrand_test_bounced_sessions_CS
	ON nonbrand_test_sessions_w_landing_page_CS.website_session_id = nonbrand_test_bounced_sessions_CS.website_session_id
GROUP BY nonbrand_test_sessions_w_landing_page_CS.landing_page;

--======================================================================


select * from mavenfuzzyfactory.website_pageviews where website_session_id = 1059
order by website_pageview_id;

select * from mavenfuzzyfactory.orders where website_session_id = 1059;
