{{
    config(
        materialized='incremental',
        unique_key='orderkey',
        on_schema_change='sync_all_columns'
    )
}}

with source as (

    select * from {{ source('tpch_sf1', 'orders') }}

),

{% if is_incremental() -%}
max_loaded_orderdate as (

    select max(orderdate) as max_orderdate

    from {{ this }}

),

{% endif -%}
renamed as (

    select
        o_orderkey as orderkey,
        o_custkey as custkey,
        o_orderstatus as orderstatus,
        o_totalprice as totalprice,
        o_orderdate as orderdate,
        o_orderpriority as orderpriority,
        o_clerk as clerk,
        o_shippriority as shippriority,
        o_comment as comment

    from source
    {% if is_incremental() -%}
    cross join max_loaded_orderdate
    where o_orderdate >= max_loaded_orderdate.max_orderdate
    {%- endif %}

)

select * from renamed
