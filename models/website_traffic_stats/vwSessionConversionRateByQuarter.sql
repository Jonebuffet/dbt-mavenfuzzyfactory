/*
  This report is on "Traffic Source Trends". Based on previous "Conversion
  Rate Analysis (CVR)", Marketing bid down on 'gsearch' and 'nonbrand'. We
  will now pull 'gsearch' and 'nonbrand' trend session volumes by week to see
  if this bids have affected volumes.
*/
{{ config(materialized='view') }}
-- {{ source('mavenfuzzyfactory', 'website_sessions') }}
with sessions as (
  select * from {{ ref('stg_sessions') }}
),
orders as (
  select * from {{ ref('stg_orders') }}
),
final as (
SELECT CONCAT(EXTRACT(YEAR from sessions.created_at), '-Q', EXTRACT(QUARTER from sessions.created_at)) "Quarter",
--	   COUNT (website_session_id) AS "Sessions"
       ROUND(CAST(COUNT(DISTINCT orders.order_id) AS decimal)/CAST(COUNT(DISTINCT sessions.website_session_id) AS decimal), 4)  AS "Order Conversion"
FROM sessions
LEFT JOIN orders
ON orders.website_session_id = sessions.website_session_id
--GROUP BY EXTRACT(YEAR from created_at),
--		 EXTRACT(QUARTER from created_at)
GROUP BY 1
ORDER BY "Quarter"
)
select * from final
