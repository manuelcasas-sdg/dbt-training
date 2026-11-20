select
    orderkey,
    linenumber

from {{ ref('int_sales_lineitems') }}
where abs(gross_sales - discount_amount - net_sales_after_discount) > 0.01
   or abs(net_sales_after_discount - tax_amount - net_sales_including_tax) > 0.01
   or abs(net_sales_after_discount - cost_amount - gross_profit) > 0.01
