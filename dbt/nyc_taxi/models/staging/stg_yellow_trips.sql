-- Staging: rename, cast, and de-duplicate raw yellow taxi trips.
with source as (

    select * from {{ source('nyc_taxi', 'yellow_trips') }}

),

renamed as (

    select
        md5(concat_ws('|',
            coalesce(vendorid::varchar, ''),
            coalesce(tpep_pickup_datetime::varchar, ''),
            coalesce(tpep_dropoff_datetime::varchar, ''),
            coalesce(pulocationid::varchar, ''),
            coalesce(dolocationid::varchar, ''),
            coalesce(trip_distance::varchar, ''),
            coalesce(total_amount::varchar, '')
        ))                                          as trip_id,

        vendorid::int                               as vendor_id,
        ratecodeid::int                             as rate_code_id,
        payment_type::int                           as payment_type_id,
        pulocationid::int                           as pickup_location_id,
        dolocationid::int                           as dropoff_location_id,

        tpep_pickup_datetime::timestamp_ntz         as pickup_at,
        tpep_dropoff_datetime::timestamp_ntz        as dropoff_at,

        passenger_count::int                        as passenger_count,
        trip_distance::number(10, 2)                as trip_distance_miles,
        store_and_fwd_flag = 'Y'                    as is_store_and_forward,

        fare_amount::number(10, 2)                  as fare_amount,
        extra::number(10, 2)                        as extra_amount,
        mta_tax::number(10, 2)                      as mta_tax_amount,
        tip_amount::number(10, 2)                   as tip_amount,
        tolls_amount::number(10, 2)                 as tolls_amount,
        improvement_surcharge::number(10, 2)        as improvement_surcharge_amount,
        congestion_surcharge::number(10, 2)         as congestion_surcharge_amount,
        airport_fee::number(10, 2)                  as airport_fee_amount,
        total_amount::number(10, 2)                 as total_amount,

        _source_file,
        _loaded_at

    from source

)

select *
from renamed
-- The raw TLC data contains exact duplicate trips; keep one of each.
qualify row_number() over (partition by trip_id order by _loaded_at desc) = 1
