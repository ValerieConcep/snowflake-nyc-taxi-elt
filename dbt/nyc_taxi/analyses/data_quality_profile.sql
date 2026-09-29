-- Data-quality profile of staged yellow taxi trips.
-- Used to find the Parquet timestamp bug (all trips were out of range
-- until microsecond epochs were converted with to_timestamp_ntz(x, 6))
-- and to size the invalid-trip filters applied in fct_trips.
select
    count(*)                                                          as total_trips,
    count_if(total_amount < 0)                                        as negative_total,
    count_if(trip_distance_miles = 0)                                 as zero_distance,
    count_if(dropoff_at <= pickup_at)                                 as dropoff_before_pickup,
    count_if(pickup_at < '2024-01-01' or pickup_at >= '2024-04-01')   as outside_jan_to_mar,
    count_if(passenger_count is null)                                 as missing_passenger_count
from {{ ref('stg_yellow_trips') }}
