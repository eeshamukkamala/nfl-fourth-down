select *
from (
    select
        (select sum(go_attempts) from {{ ref('mart_go_for_it_vs_expected') }}) as mart_total,
        (select count(*) from {{ ref('int_fourth_down_situations') }} where is_go_for_it = 1) as source_total
)
where mart_total != source_total