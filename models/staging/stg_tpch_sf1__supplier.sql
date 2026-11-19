with source as (

    select * from {{ source('tpch_sf1', 'supplier') }}

),

country_phone_codes as (

    select
        country,
        phone_code::varchar as phone_code

    from {{ source('seeds', 'country_phone_codes') }}
    qualify row_number() over (
        partition by phone_code
        order by country asc
    ) = 1

),

renamed as (

    select
        s_suppkey as suppkey,
        s_name as name,
        s_address as address,
        s_nationkey as nationkey,
        split_part(s_phone, '-', 1) as phone_prefix,
        {{ format_phone_number('s_phone') }} as phone,
        s_acctbal as acctbal,
        s_comment as comment

    from source

),

joined as (

    select
        renamed.suppkey,
        renamed.name,
        renamed.address,
        renamed.nationkey,
        renamed.phone,
        country_phone_codes.country as phone_country,
        renamed.acctbal,
        renamed.comment

    from renamed
    left join country_phone_codes
        on renamed.phone_prefix = country_phone_codes.phone_code

),

final as (

    select
        -- Primary Key
        suppkey,

        -- Foreign Keys
        nationkey,

        -- Attributes
        name,
        address,
        phone,
        phone_country,
        comment,

        -- Financials
        acctbal

    from joined

)

select * from final
