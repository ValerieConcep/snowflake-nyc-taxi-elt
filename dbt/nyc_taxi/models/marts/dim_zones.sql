-- Dimension: one row per NYC TLC taxi zone.
select
    location_id::int    as location_id,
    borough,
    zone                as zone_name,
    service_zone
from {{ ref('taxi_zones') }}
