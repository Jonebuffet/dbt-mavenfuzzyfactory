{{ config(materialized='incremental') }}
with pageviews as (
  select *
  from {{ source('mavenfuzzyfactory', 'website_pageviews') }}

  {% if is_incremental() %}

    -- this filter will only be applied on an incremental run
    where created_at > (select max(created_at) from {{ this }})

  {% endif %}
  )
  select * from pageviews
