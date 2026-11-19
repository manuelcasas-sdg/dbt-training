with source as (

    select * from {{ source('tpch_sf1', 'supplier') }}

),

renamed as (

    select
        s_suppkey as suppkey,
        s_name as name,
        s_address as address,
        s_nationkey as nationkey,
        s_phone as phone,
        s_acctbal as acctbal,
        s_comment as comment

    from source

)

select * from renamed
