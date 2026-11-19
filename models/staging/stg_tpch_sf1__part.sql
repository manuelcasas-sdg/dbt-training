with source as (

    select * from {{ source('tpch_sf1', 'part') }}

),

renamed as (

    select
        p_partkey as partkey,
        p_name as name,
        p_mfgr as mfgr,
        p_brand as brand,
        p_type as type,
        p_size as size,
        p_container as container,
        p_retailprice as retailprice,
        p_comment as comment

    from source

)

select * from renamed
