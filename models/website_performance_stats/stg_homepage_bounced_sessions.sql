{{ config(materialized='table') }}
with source as (
  select * from {{ ref('stg_first_homepage_pageviews') }}
), pageviews as (
  select * from {{ ref('stg_pageviews')}}
),
stg_homepage_bounced_sessions as (
  SELECT
    source.created_at,
    source.website_session_id,
    COUNT(DISTINCT pageviews.website_pageview_id) AS "Page Views"
  FROM source
    INNER JOIN pageviews
    ON source.website_session_id = pageviews.website_session_id
  GROUP BY source.website_session_id,source.created_at
  HAVING COUNT(pageviews.website_pageview_id)=1
  ORDER BY "Page Views" DESC
)
select *
from stg_homepage_bounced_sessions
