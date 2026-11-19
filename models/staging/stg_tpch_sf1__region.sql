with source as (

    select * from {{ source('tpch_sf1', 'region') }}

),

renamed as (

    select
        r_regionkey as regionkey,
        r_name as name,
        r_comment as comment

    from source

)

select * from renamed
