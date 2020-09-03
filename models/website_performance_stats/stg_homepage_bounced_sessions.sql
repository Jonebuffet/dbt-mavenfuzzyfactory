{{ config(materialized='table') }}
with source as (
  select * from {{ ref('stg_first_homepage_pageviews') }}
),
stg_homepage_bounced_sessions as (
  SELECT 
    source.website_session_id,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS "Page Views"
  FROM source 
    INNER JOIN mavenfuzzyfactory.website_pageviews
    ON source.website_session_id = website_pageviews.website_session_id
  GROUP BY source.website_session_id
  HAVING COUNT(website_pageviews.website_pageview_id)=1
  ORDER BY "Page Views" DESC
)
select *
from stg_homepage_bounced_sessions
