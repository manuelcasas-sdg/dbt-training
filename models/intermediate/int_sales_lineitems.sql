with lineitems as (

    select
        orderkey,
        linenumber,
        partkey,
        suppkey,
        quantity,
        extendedprice,
        discounted,
        taxed,
        discount,
        tax,
        returnflag,
        linestatus,
        shipdate,
        commitdate,
        receiptdate,
        shipinstruct,
        shipmode

    from {{ ref('stg_tpch_sf1__lineitem') }}

),

orders as (

    select
        orderkey,
        custkey,
        orderstatus,
        totalprice,
        orderdate,
        orderpriority,
        clerk,
        shippriority

    from {{ ref('stg_tpch_sf1__orders') }}

),

customers as (

    select
        custkey,
        name,
        nationkey,
        mktsegment,
        acctbal

    from {{ ref('stg_tpch_sf1__customer') }}

),

customer_nations as (

    select
        nationkey,
        name as customer_nation_name,
        regionkey

    from {{ ref('stg_tpch_sf1__nation') }}

),

customer_regions as (

    select
        regionkey,
        name as customer_region_name

    from {{ ref('stg_tpch_sf1__region') }}

),

parts as (

    select
        partkey,
        name,
        mfgr,
        brand,
        type,
        size,
        container,
        retailprice

    from {{ ref('stg_tpch_sf1__part') }}

),

suppliers as (

    select
        suppkey,
        name,
        nationkey,
        phone

    from {{ ref('stg_tpch_sf1__supplier') }}

),

supplier_nations as (

    select
        nationkey,
        name as supplier_nation_name,
        regionkey

    from {{ ref('stg_tpch_sf1__nation') }}

),

supplier_regions as (

    select
        regionkey,
        name as supplier_region_name

    from {{ ref('stg_tpch_sf1__region') }}

),

partsupp as (

    select
        partkey,
        suppkey,
        availqty,
        supplycost

    from {{ ref('stg_tpch_sf1__partsupp') }}

),

joined as (

    select
        lineitems.orderkey,
        lineitems.linenumber,
        lineitems.partkey,
        lineitems.suppkey,
        orders.custkey,
        lineitems.quantity,
        lineitems.extendedprice as gross_sales,
        round(lineitems.extendedprice - lineitems.discounted, 2) as discount_amount,
        lineitems.discounted as net_sales_after_discount,
        round(lineitems.discounted - lineitems.taxed, 2) as tax_amount,
        lineitems.taxed as net_sales_including_tax,
        round(lineitems.quantity * partsupp.supplycost, 2) as cost_amount,
        round(lineitems.discounted - lineitems.quantity * partsupp.supplycost, 2) as gross_profit,
        lineitems.discount,
        lineitems.tax,
        lineitems.returnflag,
        lineitems.linestatus,
        lineitems.shipdate,
        lineitems.commitdate,
        lineitems.receiptdate,
        lineitems.shipinstruct,
        lineitems.shipmode,
        orders.orderstatus,
        orders.totalprice,
        orders.orderdate,
        orders.orderpriority,
        orders.clerk,
        orders.shippriority,
        customers.name as customer_name,
        customers.mktsegment,
        customers.acctbal as customer_acctbal,
        customer_nations.customer_nation_name,
        customer_regions.customer_region_name,
        parts.name as part_name,
        parts.mfgr,
        parts.brand,
        parts.type as part_type,
        parts.size as part_size,
        parts.container,
        parts.retailprice,
        suppliers.name as supplier_name,
        suppliers.phone as supplier_phone,
        supplier_nations.supplier_nation_name,
        supplier_regions.supplier_region_name,
        partsupp.availqty,
        partsupp.supplycost

    from lineitems
    inner join orders
        on lineitems.orderkey = orders.orderkey
    inner join customers
        on orders.custkey = customers.custkey
    inner join customer_nations
        on customers.nationkey = customer_nations.nationkey
    inner join customer_regions
        on customer_nations.regionkey = customer_regions.regionkey
    inner join parts
        on lineitems.partkey = parts.partkey
    inner join suppliers
        on lineitems.suppkey = suppliers.suppkey
    inner join supplier_nations
        on suppliers.nationkey = supplier_nations.nationkey
    inner join supplier_regions
        on supplier_nations.regionkey = supplier_regions.regionkey
    inner join partsupp
        on lineitems.partkey = partsupp.partkey
        and lineitems.suppkey = partsupp.suppkey

),

final as (

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
        discount,
        tax,
        returnflag,
        linestatus,
        shipdate,
        commitdate,
        receiptdate,
        shipinstruct,
        shipmode,
        orderstatus,
        totalprice,
        orderdate,
        orderpriority,
        clerk,
        shippriority,
        customer_name,
        mktsegment,
        customer_acctbal,
        customer_nation_name,
        customer_region_name,
        part_name,
        mfgr,
        brand,
        part_type,
        part_size,
        container,
        retailprice,
        supplier_name,
        supplier_phone,
        supplier_nation_name,
        supplier_region_name,
        availqty,
        supplycost

    from joined

)

select * from final
