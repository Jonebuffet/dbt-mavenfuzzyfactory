{{ config(materialized='incremental') }}
with orders as (
select *
from {{ source('mavenfuzzyfactory', 'orders') }}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  where created_at > (select max(created_at) from {{ this }})

{% endif %}
)
select * from orders
