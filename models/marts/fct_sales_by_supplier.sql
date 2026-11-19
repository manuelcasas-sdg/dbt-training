with sales as (

    select
        suppkey,
        supplier_name,
        supplier_nation_name,
        supplier_region_name,
        custkey,
        linenumber,
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

supplier_aggregated as (

    select
        suppkey,
        any_value(supplier_name) as supplier_name,
        any_value(supplier_nation_name) as supplier_nation_name,
        any_value(supplier_region_name) as supplier_region_name,
        count(*) as lineitem_count,
        count(distinct custkey) as customer_count,
        sum(quantity) as quantity_sold,
        sum(gross_sales) as gross_sales,
        sum(discount_amount) as discount_amount,
        sum(net_sales_after_discount) as net_sales_after_discount,
        sum(tax_amount) as tax_amount,
        sum(net_sales_including_tax) as net_sales_including_tax,
        sum(cost_amount) as cost_amount,
        sum(gross_profit) as gross_profit

    from sales
    group by 1

),

final as (

    select * from supplier_aggregated

)

select * from final
