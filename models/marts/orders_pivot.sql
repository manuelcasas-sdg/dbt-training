with orders as (

    select
        orderdate,
        orderstatus,
        totalprice

    from {{ ref('stg_tpch_sf1__orders') }}

),

orders_pivoted as (

    select
        orderdate,
        sum(case when orderstatus = 'F' then 1 else 0 end) as count_f,
        sum(case when orderstatus = 'P' then 1 else 0 end) as count_p,
        sum(case when orderstatus = 'O' then 1 else 0 end) as count_o,
        sum(totalprice) as total_price

    from orders
    group by 1

),

final as (

    select
        orderdate,
        count_f,
        count_p,
        count_o,
        total_price

    from orders_pivoted

)

select * from final
