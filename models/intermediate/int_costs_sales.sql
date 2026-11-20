select
    orderkey,
    linenumber,
    partkey,
    suppkey,
    custkey,
    quantity,
    gross_sales,
    discount_amount,
    net_sales_after_discount,
    tax_amount,
    net_sales_including_tax,
    cost_amount,
    gross_profit,
    orderdate,
    orderstatus,
    shipdate

from {{ ref('int_sales_lineitems') }}