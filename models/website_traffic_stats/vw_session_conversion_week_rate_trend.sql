-- Third Assignment Query
/*
  This report is on "Traffic Source Trends". Based on previous "Conversion
  Rate Analysis (CVR)", Marketing bid down on 'gsearch' and 'nonbrand'. We
  will now pull 'gsearch' and 'nonbrand' trend session volumes by week to see
  if this bids have affected volumes.
*/
{{ config(materialized='view') }}
with sessions as (
  select * from {{ source('mavenfuzzyfactory', 'website_sessions') }}
),
final as (
SELECT EXTRACT(YEAR from created_at) AS "Year",
	   MIN(DATE(created_at)) AS "Week",
	   COUNT (website_session_id) AS "Sessions"
FROM sessions
GROUP BY EXTRACT(YEAR from created_at),
		 EXTRACT(WEEK from created_at)
ORDER BY "Week"
)
select * from final
