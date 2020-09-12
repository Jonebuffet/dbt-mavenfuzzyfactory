{{ config(materialized='table') }}
with sessions as (
--  {{ source('mavenfuzzyfactory', 'website_sessions') }}
  select * from {{ ref('stg_sessions') }}
),
pageviews as (
-- {{ source('mavenfuzzyfactory', 'orders') }}
  select
    *
  from {{ ref('stg_pageviews') }}
),
final as (
SELECT sessions.created_at,
     pageviews.website_session_id,
	   MIN(pageviews.website_pageview_id) AS mn_pageview_id
FROM pageviews
	INNER JOIN sessions
	ON sessions.website_session_id = pageviews.website_session_id
--	AND website_sessions.created_at < '2014-06-14'
--	AND website_pageviews.pageview_url='/home'
GROUP BY pageviews.website_session_id,sessions.created_at
ORDER BY pageviews.website_session_id
)
select * from final
