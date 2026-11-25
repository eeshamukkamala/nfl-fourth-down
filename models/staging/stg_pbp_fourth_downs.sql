{{ config(materialized='table') }}

select
    game_id || '_' || cast(play_id as varchar) as play_key,
    play_id,
    game_id,
    season,
    season_type,
    week,
    posteam,
    defteam,
    down,
    ydstogo,
    yardline_100,
    qtr,
    game_seconds_remaining,
    score_differential,
    play_type,
    epa,
    fourth_down_converted,
    case when play_type in ('pass', 'run') then 1 else 0 end as is_go_for_it

from read_parquet('data/play_by_play_*.parquet', union_by_name=true)
where season >= 2020
    and season_type = 'REG'
    and down = 4
    and play_type in ('pass', 'run', 'field_goal', 'punt')