{{ config(materialized='table') }}

select
    season,
    posteam,
    fourth_down_opportunities,
    fourth_down_go_attempts,
    go_rate,
    1.0 * sum(fourth_down_go_attempts) over (partition by season)
        / sum(fourth_down_opportunities) over (partition by season) as league_go_rate,
    rank() over (partition by season order by go_rate desc) as go_rate_rank
from {{ ref('mart_go_rate_team_season') }}
order by season, go_rate_rank