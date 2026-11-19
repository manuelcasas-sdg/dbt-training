with partsupp as (

    select
        partkey,
        suppkey,
        availqty,
        supplycost

    from {{ ref('stg_tpch_sf1__partsupp') }}

),

supplier as (

    select
        suppkey,
        phone,
        nationkey

    from {{ ref('stg_tpch_sf1__supplier') }}

),

nation as (

    select
        nationkey,
        name as nation_name,
        regionkey

    from {{ ref('stg_tpch_sf1__nation') }}

),

region as (

    select
        regionkey,
        name as region_name

    from {{ ref('stg_tpch_sf1__region') }}

),

supplier_parts_aggregated as (

    select
        partsupp.suppkey,
        supplier.phone,
        region.region_name,
        nation.nation_name,
        sum(partsupp.availqty) as total_available_quantity,
        sum(partsupp.supplycost) as total_supply_cost,
        count(distinct partsupp.partkey) as distinct_part_count

    from partsupp
    inner join supplier
        on partsupp.suppkey = supplier.suppkey
    inner join nation
        on supplier.nationkey = nation.nationkey
    inner join region
        on nation.regionkey = region.regionkey
    group by 1, 2, 3, 4

),

final as (

    select
        suppkey,
        phone,
        region_name,
        nation_name,
        total_available_quantity,
        total_supply_cost,
        distinct_part_count

    from supplier_parts_aggregated

)

select * from final
