{{ config(materialized='incremental') }}
with sessions as (
  select *
  from {{ source('mavenfuzzyfactory', 'website_sessions') }}
--  where website_sessions.created_at < '2014-06-14'

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  where created_at > (select max(created_at) from {{ this }})

{% endif %}
)
select * from sessions
