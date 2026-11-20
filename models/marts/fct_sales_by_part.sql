with sales as (

    select
        partkey,
        part_name,
        brand,
        mfgr,
        part_type,
        custkey,
        suppkey,
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

part_aggregated as (

    select
        partkey,
        any_value(part_name) as part_name,
        any_value(brand) as brand,
        any_value(mfgr) as mfgr,
        any_value(part_type) as part_type,
        count(*) as lineitem_count,
        count(distinct custkey) as customer_count,
        count(distinct suppkey) as supplier_count,
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

    select * from part_aggregated

)

select * from final
