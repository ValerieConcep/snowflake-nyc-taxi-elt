-- Fact: one row per valid yellow taxi trip (Jan-Mar 2024).
-- Excludes invalid trips identified in analyses/data_quality_profile.sql:
--   negative totals (refunds/voids), zero distance, dropoff not after pickup,
--   and pickups outside the loaded period.
with trips as (

    select * from {{ ref('stg_yellow_trips') }}

)

select
    trip_id,

    -- foreign keys to dimensions
    pickup_at::date                                   as pickup_date,
    pickup_location_id,
    dropoff_location_id,

    -- descriptive attributes
    vendor_id,
    rate_code_id,
    payment_type_id,
    pickup_at,
    dropoff_at,
    passenger_count,

    -- measures
    trip_distance_miles,
    datediff(second, pickup_at, dropoff_at) / 60.0    as trip_duration_minutes,
    fare_amount,
    tip_amount,
    tolls_amount,
    total_amount,
    case when fare_amount > 0
         then round(tip_amount / fare_amount, 4)
    end                                               as tip_pct_of_fare

from trips
where total_amount >= 0
  and trip_distance_miles > 0
  and dropoff_at > pickup_at
  and pickup_at >= '2024-01-01'
  and pickup_at <  '2024-04-01'
