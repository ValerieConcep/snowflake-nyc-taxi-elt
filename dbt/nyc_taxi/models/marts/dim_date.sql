-- Dimension: one row per calendar day covering the loaded trip period.
with days as (

    select
        dateadd(day, row_number() over (order by seq4()) - 1, '2024-01-01'::date) as date_day
    from table(generator(rowcount => 91))   -- Jan 1 through Mar 31, 2024

)

select
    date_day,
    year(date_day)                        as year,
    quarter(date_day)                     as quarter,
    month(date_day)                       as month,
    monthname(date_day)                   as month_name,
    day(date_day)                         as day_of_month,
    dayofweekiso(date_day)                as day_of_week,     -- 1 = Monday ... 7 = Sunday
    dayname(date_day)                     as day_name,
    dayofweekiso(date_day) in (6, 7)      as is_weekend
from days
