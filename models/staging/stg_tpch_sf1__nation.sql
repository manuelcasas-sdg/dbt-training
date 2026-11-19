with source as (

    select * from {{ source('tpch_sf1', 'nation') }}

),

renamed as (

    select
        n_nationkey as nationkey,
        n_name as name,
        n_regionkey as regionkey,
        n_comment as comment

    from source

)

select * from renamed
