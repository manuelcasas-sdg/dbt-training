with source as (

    select * from {{ source('tpch_sf1', 'customer') }}

),

renamed as (

    select
        c_custkey as custkey,
        c_name as name,
        c_address as address,
        c_nationkey as nationkey,
        c_phone as phone,
        c_acctbal as acctbal,
        c_mktsegment as mktsegment,
        c_comment as comment

    from source

)

select * from renamed
