with source as (

    select * from {{ source('tpch_sf1', 'partsupp') }}

),

renamed as (

    select
        ps_partkey as partkey,
        ps_suppkey as suppkey,
        ps_availqty as availqty,
        ps_supplycost as supplycost,
        ps_comment as comment

    from source

)

select * from renamed
