with supplier_summary as (

    select
        suppkey,
        phone,
        region_name,
        nation_name,
        total_available_quantity,
        total_supply_cost,
        distinct_part_count

    from {{ ref('int_supplier_parts_summary') }}

),

nation_aggregated as (

    select
        nation_name,
        region_name,
        count(suppkey) as supplier_count,
        sum(total_available_quantity) as total_available_quantity,
        sum(total_supply_cost) as total_supply_cost,
        sum(distinct_part_count) as total_part_offerings

    from supplier_summary
    group by 1, 2

),

final as (

    select
        nation_name,
        region_name,
        supplier_count,
        total_available_quantity,
        total_supply_cost,
        total_part_offerings

    from nation_aggregated

)

select * from final
