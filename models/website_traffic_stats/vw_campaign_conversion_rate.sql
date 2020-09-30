/*
  'gsearch' and 'nonbrand' are major sources for out website sessions. But,
  are they contributing significantly to sales conversions?

  We now need to calculate the conversion rate from Session->Order. Based upon
  the current "price per click", a CVR or at least 4% is necessary. If it is
  lower, then we will need to reduce our bids.

  CVR= ~3% (0.029)
*/
{{ config(materialized='view') }}
with sessions as (
--  {{ source('mavenfuzzyfactory', 'website_sessions') }}
  select * from {{ ref('stg_sessions') }}
),
orders as (
-- {{ source('mavenfuzzyfactory', 'orders') }}
  select
    *
  from {{ ref('stg_orders') }}
),
final as (
SELECT
     sessions.utm_source AS "Source",
     sessions.utm_campaign AS "Campaign",
     COUNT(DISTINCT sessions.website_session_id) AS "Sessions",
	   COUNT(DISTINCT orders.order_id) AS "Orders",
	   ROUND(CAST(COUNT(DISTINCT orders.order_id) AS decimal)/CAST(COUNT(DISTINCT sessions.website_session_id) AS decimal),3)  AS "Session->Order Conversion"
FROM sessions
	LEFT JOIN orders
	ON orders.website_session_id = sessions.website_session_id
  GROUP BY 1,2
/*
WHERE sessions.utm_source = 'gsearch'
      AND sessions.utm_campaign = 'nonbrand'
      AND sessions.created_at < '2012-04-14'
*/
)
select * from final
