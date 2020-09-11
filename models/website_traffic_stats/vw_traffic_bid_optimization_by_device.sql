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
{{ config(materialized='view') }}
-- {{ source('mavenfuzzyfactory', 'website_sessions') }}

with sessions as (
  select * from {{ ref('stg_sessions') }}
),
-- {{ source('mavenfuzzyfactory', 'orders') }}
orders as (
  select
    *
  from  {{ ref('stg_orders') }}
),
final as (
SELECT utm_source as Source,
       utm_campaign as Campaign,
 	   device_type,
       COUNT(DISTINCT website_sessions.website_session_id) AS "Sessions",
	   COUNT(DISTINCT order_id) AS "Orders",
	   ROUND(CAST(COUNT(DISTINCT order_id) AS decimal)/CAST(COUNT(DISTINCT website_sessions.website_session_id) AS decimal), 4)  AS "Session->Order Conversion"
FROM mavenfuzzyfactory.website_sessions
	LEFT JOIN mavenfuzzyfactory.orders
	ON orders.website_session_id = website_sessions.website_session_id
/*
WHERE website_sessions.utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
	  AND website_sessions.created_at < '2012-05-11'
*/
GROUP BY 1,2,3
)
select * from final
