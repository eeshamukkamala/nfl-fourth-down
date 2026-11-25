{{ config(materialized='table') }}

select
    p.season,
    p.posteam,
    count(*) as fourth_down_opportunities,
    sum(p.is_go_for_it) as actual_go_attempts,
    round(sum(b.go_rate), 1) as expected_go_attempts,
    round(sum(p.is_go_for_it) - sum(b.go_rate), 1) as go_attempts_above_expected
from {{ ref('int_fourth_down_situations') }} p
join {{ ref('mart_go_rate_situation_league') }} b
    on p.distance_bucket = b.distance_bucket
   and p.field_zone = b.field_zone
   and p.score_state = b.score_state
group by p.season, p.posteam
order by p.season, p.posteam