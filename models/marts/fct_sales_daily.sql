{{
    config(
        materialized='incremental',
        unique_key='orderdate'
    )
}}

with

{% if is_incremental() -%}
max_loaded_orderdate as (

    select max(orderdate) as max_orderdate

    from {{ this }}

),

{% endif -%}
sales as (

    select
        orderkey,
        linenumber,
        orderdate,
        quantity,
        gross_sales,
        discount_amount,
        net_sales_after_discount,
        tax_amount,
        net_sales_including_tax,
        cost_amount,
        gross_profit,
        returnflag

    from {{ ref('int_sales_lineitems') }}
    {% if is_incremental() -%}
    cross join max_loaded_orderdate
    where orderdate >= max_loaded_orderdate.max_orderdate
    {%- endif %}

),

daily_aggregated as (

    select
        orderdate,
        count(distinct orderkey) as order_count,
        count(*) as lineitem_count,
        sum(quantity) as quantity_sold,
        sum(gross_sales) as gross_sales,
        sum(discount_amount) as discount_amount,
        sum(net_sales_after_discount) as net_sales_after_discount,
        sum(tax_amount) as tax_amount,
        sum(net_sales_including_tax) as net_sales_including_tax,
        sum(cost_amount) as cost_amount,
        sum(gross_profit) as gross_profit,
        sum(case when returnflag = 'R' then quantity else 0 end) as returned_quantity

    from sales
    group by 1

),

final as (

    select
        orderdate,
        order_count,
        lineitem_count,
        quantity_sold,
        gross_sales,
        discount_amount,
        net_sales_after_discount,
        tax_amount,
        net_sales_including_tax,
        cost_amount,
        gross_profit,
        returned_quantity

    from daily_aggregated

)

select * from final
