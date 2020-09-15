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
  SELECT
      CONCAT(EXTRACT(YEAR from sessions.created_at), '-Q', EXTRACT(QUARTER from sessions.created_at)) qtr,
  	--EXTRACT(YEAR from website_sessions.created_at) AS yr,
  	--EXTRACT(QUARTER from website_sessions.created_at) AS qtr,
  	ROUND(CAST(COUNT(DISTINCT orders.order_id) AS DECIMAL)/CAST(COUNT(DISTINCT sessions.website_session_id) AS DECIMAL),3) AS session_to_order_conv_rate,
      ROUND(SUM(price_usd)/COUNT(DISTINCT orders.order_id),2) AS revenue_per_order,
      ROUND(SUM(price_usd)/COUNT(DISTINCT sessions.website_session_id),2) AS revenue_per_session
  FROM sessions
  	LEFT JOIN orders
  		ON sessions.website_session_id = orders.website_session_id
  GROUP BY 1
  ORDER BY qtr
)
select * from final
