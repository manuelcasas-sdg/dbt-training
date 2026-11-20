select
    orderkey,
    linenumber,
    shipdate
from {{ ref('stg_tpch_sf1__lineitem') }}
where shipdate is null
    or shipdate < date '1990-01-01'
    or shipdate > current_date