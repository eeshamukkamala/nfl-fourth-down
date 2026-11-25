{{ config(materialized='table') }}

select 
season,
posteam,
count(*) as fourth_down_opportunities,
sum(is_go_for_it) as fourth_down_go_attempts,
1.0 * sum(is_go_for_it) / count(*) as go_rate
from {{ ref('int_fourth_down_situations') }}
group by season, posteam 
order by season, posteam