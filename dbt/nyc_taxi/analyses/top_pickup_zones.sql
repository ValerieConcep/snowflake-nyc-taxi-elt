-- Top 10 pickup zones by trip volume, with average total and tip %.
-- Finding: JFK trips average ~$82 (3-4x Manhattan) but ~14% tips vs ~21%,
-- likely because cash tips are not recorded in TLC data.
select
    z.borough,
    z.zone_name,
    count(*)                                   as trips,
    round(avg(f.total_amount), 2)              as avg_total,
    round(avg(f.tip_pct_of_fare) * 100, 1)     as avg_tip_pct
from {{ ref('fct_trips') }} f
join {{ ref('dim_zones') }} z
  on f.pickup_location_id = z.location_id
group by 1, 2
order by trips desc
limit 10
