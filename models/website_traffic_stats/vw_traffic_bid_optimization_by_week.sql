-- Fifth Assignment Query
/*
  	Traffic Source Bid Optimizations by Granular Segments.
	Let's now pull the weekly volumes by 'device_type'
*/
{{ config(materialized='view') }}
-- {{ source('mavenfuzzyfactory', 'website_sessions') }}
with sessions as (
  select * from {{ ref('stg_sessions') }}
),
final as (
SELECT MIN(DATE(created_at)) AS "Week",
	   COUNT(DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS "Mobile Count",
	   COUNT(DISTINCT CASE WHEN device_type='desktop' THEN website_session_id ELSE NULL END) AS "Desktop Count"
FROM sessions
/*
WHERE  (website_sessions.created_at > '2012-04-15'
	  AND website_sessions.created_at < '2012-06-09')
	  AND website_sessions.utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
*/
GROUP BY EXTRACT(YEAR from created_at),
	  	 EXTRACT(WEEK from created_at)
ORDER BY "Week"
)
select * from final
