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
ORDER BY "Week"
