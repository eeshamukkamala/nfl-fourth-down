select
    play_key,
    game_id,
    season,
    week,
    posteam,
    defteam,
    play_type,
    is_go_for_it,
    epa,
    fourth_down_converted,
    ydstogo,
    yardline_100,
    score_differential,
    case
        when ydstogo = 1 then '1'
        when ydstogo = 2 then '2'
        when ydstogo = 3 then '3'
        when ydstogo = 4 then '4'
        when ydstogo <= 10 then '5-10'
        else '11+'
    end as distance_bucket,
    case
        when score_differential < -3 then 'trailing'
        when score_differential > 3 then 'leading'
        else 'close'
    end as score_state,
    case
        when yardline_100 <= 20 then 'red_zone'
        when yardline_100 <= 30 then 'comfortable_field_goal_range'
        when yardline_100 <= 37 then 'field_goal_range'
        when yardline_100 <= 50 then 'midfield'
        else 'open_field'
    end as field_zone
from {{ ref('stg_pbp_fourth_downs') }}