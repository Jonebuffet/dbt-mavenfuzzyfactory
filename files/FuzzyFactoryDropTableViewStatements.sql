drop view if exists mavenfuzzyfactory.stg_sessions;
drop view if exists mavenfuzzyfactory.stg_orders;
drop view if exists mavenfuzzyfactory.vw_traffic_bid_optimization_by_device;
drop view if exists mavenfuzzyfactory.vw_traffic_bid_optimization_by_week;
drop view if exists mavenfuzzyfactory.vw_session_conversion_rate;
drop view if exists mavenfuzzyfactory.vw_session_conversion_week_rate_trend;
drop view if exists mavenfuzzyfactory.vw_landing_page_bounce_rates;
drop view if exists mavenfuzzyfactory.vw_campaign_conversion_rate;

drop table if exists mavenfuzzyfactory.stg_first_homepage_pageviews;
drop table if exists mavenfuzzyfactory.stg_homepage_bounced_sessions;
commit;
