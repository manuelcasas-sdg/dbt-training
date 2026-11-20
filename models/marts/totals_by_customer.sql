with sales as (

    select
        custkey,
        customer_name,
        customer_nation_name,
        customer_region_name,
        mktsegment,
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
        gross_profit

    from {{ ref('int_sales_lineitems') }}

),

customer_aggregated as (

    select
        custkey,
        any_value(customer_name) as customer_name,
        any_value(customer_nation_name) as customer_nation_name,
        any_value(customer_region_name) as customer_region_name,
        any_value(mktsegment) as mktsegment,
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
        max(orderdate) as latest_orderdate

    from sales
    group by 1

),

final as (

    select * from customer_aggregated

)

select * from final