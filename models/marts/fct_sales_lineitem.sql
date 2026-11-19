with sales as (

    select
        orderkey,
        linenumber,
        custkey,
        suppkey,
        partkey,
        orderdate,
        shipdate,
        orderstatus,
        quantity,
        gross_sales,
        discount_amount,
        net_sales_after_discount,
        tax_amount,
        net_sales_including_tax,
        cost_amount,
        gross_profit,
        returnflag,
        customer_name,
        customer_nation_name,
        customer_region_name,
        mktsegment,
        supplier_name,
        supplier_nation_name,
        supplier_region_name,
        part_name,
        brand,
        mfgr,
        part_type

    from {{ ref('int_sales_lineitems') }}

),

final as (

    select * from sales

)

select * from final
