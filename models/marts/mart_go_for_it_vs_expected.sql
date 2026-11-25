{{ config(materialized='table') }}

with plays as (
    select season, posteam, distance_bucket, field_zone,
           fourth_down_converted, epa
    from {{ ref('int_fourth_down_situations') }}
    where is_go_for_it = 1
),

-- the team's own totals per situation, across all seasons
team_situation as (
    select posteam, distance_bucket, field_zone,
           count(*) as team_attempts,
           sum(fourth_down_converted) as team_conversions,
           sum(epa) as team_epa_sum
    from plays
    group by posteam, distance_bucket, field_zone
),

-- every play gets a benchmark that excludes its own team
play_benchmark as (
    select
        p.season,
        p.posteam,
        p.fourth_down_converted,
        p.epa,
        1.0 * (b.conversions - t.team_conversions)
            / (b.go_attempts - t.team_attempts) as expected_conversion,
        (b.avg_epa * b.go_attempts - t.team_epa_sum)
            / (b.go_attempts - t.team_attempts) as expected_epa
    from plays p
    join team_situation t
        on p.posteam = t.posteam
       and p.distance_bucket = t.distance_bucket
       and p.field_zone = t.field_zone
    join {{ ref('mart_go_for_it_situation_league') }} b
        on p.distance_bucket = b.distance_bucket
       and p.field_zone = b.field_zone
)

select
    season,
    posteam,
    count(*) as go_attempts,
    sum(fourth_down_converted) as actual_conversions,
    round(sum(expected_conversion), 1) as expected_conversions,
    round(sum(fourth_down_converted) - sum(expected_conversion), 1) as conversions_above_expected,
    round(sqrt(sum(expected_conversion * (1 - expected_conversion))), 2) as standard_error,
    round((sum(fourth_down_converted) - sum(expected_conversion))
          / sqrt(sum(expected_conversion * (1 - expected_conversion))), 2) as z_score,
    round(avg(epa), 3) as avg_epa,
    round(avg(expected_epa), 3) as expected_avg_epa,
    round(avg(epa) - avg(expected_epa), 3) as epa_above_expected_per_attempt
from play_benchmark
group by season, posteam
order by season, posteam