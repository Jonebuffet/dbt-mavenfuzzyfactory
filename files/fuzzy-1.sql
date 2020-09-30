
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
SELECT utm_source,
	   utm_campaign,
	   http_referer,
	   COUNT(DISTINCT website_sessions.website_session_id) AS "Sessions"
FROM mavenfuzzyfactory.website_sessions 
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY "Sessions" DESC;

--Second Assignment Query
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


/*
	Analyzing Website Performance
*/
SELECT pageview_url,
       COUNT(DISTINCT website_pageview_id) AS "Page Views"
FROM mavenfuzzyfactory.website_pageviews
WHERE website_pageview_id < 1000
GROUP BY pageview_url
ORDER BY "Page Views" DESC;

-- Entry Page Analysis
CREATE TEMPORARY TABLE first_pageview AS
SELECT website_session_id,
	   MIN(website_pageview_id) AS "mn_pv_id"
FROM mavenfuzzyfactory.website_pageviews
WHERE website_pageview_id < 1000
GROUP BY website_session_id
ORDER BY website_session_id;

drop table first_pageview;

select * from first_pageview;

-- What was the most popular Entry Pages.
SELECT website_pageviews.pageview_url AS "Landing Page", -- aka Entry Page
       COUNT (DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN mavenfuzzyfactory.website_pageviews
	ON first_pageview."mn_pv_id"=website_pageviews.website_pageview_id
GROUP BY "Landing Page";

-- What was the Entry Page for each sessions
SELECT first_pageview.website_session_id,
	   website_pageviews.pageview_url AS "Landing Page" -- aka Entry Page
FROM first_pageview
	LEFT JOIN mavenfuzzyfactory.website_pageviews
	ON first_pageview."mn_pv_id"=website_pageviews.website_pageview_id;
	
-- First Assignment Query
-- Most viewed pages ranked by session volume.
SELECT pageview_url,
	   COUNT(DISTINCT website_session_id) "Session Views"
FROM mavenfuzzyfactory.website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY "Session Views" DESC;

-- Second Assignment Query
-- List of Top Entry Pages
SELECT website_pageviews.pageview_url AS "Landing Page", -- aka Entry Page
       COUNT (DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM first_pageview
	LEFT JOIN mavenfuzzyfactory.website_pageviews
	ON first_pageview."mn_pv_id"=website_pageviews.website_pageview_id
WHERE website_pageviews.created_at < '2012-06-09'
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
CREATE TEMPORARY TABLE first_homepage_pageviews AS
SELECT website_pageviews.website_session_id,
	   MIN(website_pageviews.website_pageview_id) AS mn_pageview_id
FROM mavenfuzzyfactory.website_pageviews
	INNER JOIN mavenfuzzyfactory.website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
	AND website_sessions.created_at < '2014-06-14' 
	AND website_pageviews.pageview_url='/home'
GROUP BY website_pageviews.website_session_id
ORDER BY website_pageviews.website_session_id;

DROP TABLE first_homepage_pageviews;

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
-- Double check this with the solution. These numbers seem high.
SELECT COUNT (DISTINCT first_homepage_pageviews.website_session_id ) AS sessions,
	   COUNT(DISTINCT homepage_bounced_sessions.website_session_id) AS bounced_sessions,
	   CAST(COUNT(DISTINCT homepage_bounced_sessions.website_session_id) AS decimal)/ CAST(COUNT(DISTINCT first_homepage_pageviews.website_session_id ) AS decimal) AS bounce_rate
FROM first_homepage_pageviews 
	LEFT OUTER JOIN homepage_bounced_sessions
	ON homepage_bounced_sessions.website_session_id = first_homepage_pageviews.website_session_id;



--======================================================================
-- Fouth Assignment Query
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

select * 
from website_sessions 
where website_session_id=1;

CREATE TEMPORARY TABLE first_homepage_pageviews AS
SELECT website_pageviews.website_session_id,
	   MIN(website_pageviews.website_pageview_id) AS mn_pageview_id
FROM mavenfuzzyfactory.website_pageviews
	INNER JOIN mavenfuzzyfactory.website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
	AND website_sessions.created_at < '2014-06-14' 
	AND website_pageviews.pageview_url='/home'
GROUP BY website_pageviews.website_session_id
ORDER BY website_pageviews.website_session_id;

DROP TABLE first_homepage_pageviews;

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

-- Fourth Assignment Final Query
-- Landing Page Bounce Rates A/B Testing (STUB)

SELECT COUNT (DISTINCT first_homepage_pageviews.website_session_id ) AS sessions,
	   COUNT(DISTINCT homepage_bounced_sessions.website_session_id) AS bounced_sessions,
	   CAST(COUNT(DISTINCT homepage_bounced_sessions.website_session_id) AS decimal)/ CAST(COUNT(DISTINCT first_homepage_pageviews.website_session_id ) AS decimal) AS bounce_rate
FROM first_homepage_pageviews 
	LEFT OUTER JOIN homepage_bounced_sessions
	ON homepage_bounced_sessions.website_session_id = first_homepage_pageviews.website_session_id;
--======================================================================


























select * from mavenfuzzyfactory.website_pageviews where website_session_id = 1059
order by website_pageview_id;

select * from mavenfuzzyfactory.orders where website_session_id = 1059;