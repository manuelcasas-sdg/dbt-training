with source as (

    select * from {{ source('tpch_sf1', 'lineitem') }}

),

calculated as (

    select
        l_orderkey as orderkey,
        l_partkey as partkey,
        l_suppkey as suppkey,
        l_linenumber as linenumber,
        l_quantity as quantity,
        l_extendedprice as extendedprice,
        ROUND(l_extendedprice * (1- l_discount),2) AS discounted,
        ROUND(l_extendedprice * (1-l_discount) * (1-l_tax),2) as taxed,
        l_discount as discount,
        l_tax as tax,
        l_returnflag as returnflag,
        l_linestatus as linestatus,
        l_shipdate as shipdate,
        l_commitdate as commitdate,
        l_receiptdate as receiptdate,
        l_shipinstruct as shipinstruct,
        l_shipmode as shipmode,
        l_comment as comment

    from source

)

select * from calculated
