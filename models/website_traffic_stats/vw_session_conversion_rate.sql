/*
  'gsearch' and 'nonbrand' are major sources for out website sessions. But,
  are they contributing significantly to sales conversions?
  
  We now need to calculate the conversion rate from Session->Order. Based upon
  the current "price per click", a CVR or at least 4% is necessary. If it is 
  lower, then we will need to reduce our bids.
  
  CVR= ~3% (0.029)
*/
with source_data as (
SELECT COUNT(DISTINCT website_sessions.website_session_id) AS "Sessions",
	   COUNT(DISTINCT order_id) AS "Orders",
	   ROUND(CAST(COUNT(DISTINCT order_id) AS decimal)/CAST(COUNT(DISTINCT website_sessions.website_session_id) AS decimal),3)  AS "Session->Order Conversion"
FROM mavenfuzzyfactory.website_sessions 
	LEFT JOIN mavenfuzzyfactory.orders 
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
      AND website_sessions.created_at < '2012-04-14'
)
select * from source_data