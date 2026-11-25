{{ config(materialized='table') }}

select
    season,
    posteam,
    go_attempts,
    conversions_above_expected,
    rank() over (partition by season order by conversions_above_expected desc) as conversions_rank,
    round(avg(conversions_above_expected) over (partition by season), 2) as league_avg_above_expected,
    epa_above_expected_per_attempt,
    rank() over (partition by season order by epa_above_expected_per_attempt desc) as epa_rank
from {{ ref('mart_go_for_it_vs_expected') }}