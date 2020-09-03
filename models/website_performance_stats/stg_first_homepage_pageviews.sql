{{ config(materialized='table') }}
SELECT website_pageviews.website_session_id,
	   MIN(website_pageviews.website_pageview_id) AS mn_pageview_id
FROM mavenfuzzyfactory.website_pageviews
	INNER JOIN mavenfuzzyfactory.website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
	AND website_sessions.created_at < '2014-06-14' 
--	AND website_pageviews.pageview_url='/home'
GROUP BY website_pageviews.website_session_id
ORDER BY website_pageviews.website_session_id
