
select * from {{ ref('nation_supplier_summary')}}
where total_available_quantity < total_supply_cost