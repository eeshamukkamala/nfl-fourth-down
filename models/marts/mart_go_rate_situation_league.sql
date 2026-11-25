{{ config(materialized='table') }}

select
    distance_bucket,
    field_zone,
    score_state,
    count(*) as fourth_down_opportunities,
    sum(is_go_for_it) as fourth_down_go_attempts,
    1.0 * sum(is_go_for_it) / count(*) as go_rate
from {{ ref('int_fourth_down_situations') }}
group by distance_bucket, field_zone, score_state
order by distance_bucket, field_zone, score_state