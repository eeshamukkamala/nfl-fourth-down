{{ config(materialized='table') }}

select
    distance_bucket,
    field_zone,
    count(*) as go_attempts,
    sum(fourth_down_converted) as conversions,
    1.0 * sum(fourth_down_converted) / count(*) as conversion_rate,
    avg(epa) as avg_epa
from {{ ref('int_fourth_down_situations') }}
where is_go_for_it = 1
group by distance_bucket, field_zone
order by distance_bucket, field_zone