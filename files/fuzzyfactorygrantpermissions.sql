--SELECT 'GRANT SELECT ON '||schemaname||'.“'||tablename||'” TO chartio_readonly;' FROM pg_tables WHERE schemaname IN ('mavenfuzzyfactory') ORDER BY schemaname, tablename;

GRANT SELECT ON mavenfuzzyfactory.order_item_refunds TO chartio_readonly;
GRANT SELECT ON mavenfuzzyfactory.order_items TO chartio_readonly;
GRANT SELECT ON mavenfuzzyfactory.orders TO chartio_readonly;
GRANT SELECT ON mavenfuzzyfactory.products TO chartio_readonly;
GRANT SELECT ON mavenfuzzyfactory.stg_first_homepage_pageviews TO chartio_readonly;
GRANT SELECT ON mavenfuzzyfactory.stg_homepage_bounced_sessions TO chartio_readonly;
GRANT SELECT ON mavenfuzzyfactory.tst_vw_session_conversion_rate TO chartio_readonly;
GRANT SELECT ON mavenfuzzyfactory.website_pageviews TO chartio_readonly;
GRANT SELECT ON mavenfuzzyfactory.website_sessions TO chartio_readonly;
