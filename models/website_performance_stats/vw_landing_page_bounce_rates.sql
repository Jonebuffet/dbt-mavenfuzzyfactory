with bounced_sessions as (
  select * from {{ ref('stg_homepage_bounced_sessions') }}
),
page_views as (
  select * from {{ ref('stg_first_homepage_pageviews') }}
),
final as (
SELECT 
	   COUNT (DISTINCT page_views.website_session_id ) AS sessions,
	   COUNT(DISTINCT bounced_sessions.website_session_id) AS bounced_sessions,
	   CAST(COUNT(DISTINCT bounced_sessions.website_session_id) AS decimal)/ CAST(COUNT(DISTINCT page_views.website_session_id ) AS decimal) AS bounce_rate
FROM page_views 
	LEFT OUTER JOIN bounced_sessions
	ON bounced_sessions.website_session_id = page_views.website_session_id
)
select *
from final
