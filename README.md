# Eagles fourth-down aggressiveness, 2020-2025

How often do the Philadelphia Eagles go for it on 4th down, and how does that compare with the rest of the NFL once you account for the situations they faced? Built with dbt, DuckDB and SQL on nflverse play-by-play data (regular seasons 2020-2025).

## Question

- **Part 1:** How often do the Eagles go for it on 4th down, compared with the league and with what a typical team would do in the same situations?
- **Part 2:** How successful are their go-for-it attempts (conversion rate and EPA)?

## What I found

The raw go rate says the Eagles became far more conservative in 2025. The situation-adjusted view tells a different story.

| Season | Eagles go rate | League go rate | Eagles rank (of 32) | Eagles go attempts |
|---|---|---|---|---|
| 2020 | 27.8% | 19.1% | 1 | 35 |
| 2021 | 22.3% | 20.8% | 12 | 25 |
| 2022 | 28.8% | 18.8% | 4 | 32 |
| 2023 | 24.5% | 19.6% | 4 | 26 |
| 2024 | 23.1% | 20.0% | 8 | 27 |
| 2025 | 17.1% | 23.3% | 28 | 20 |

Accounting for the situation (distance, field position, score), I compared each team's go attempts with the number a typical team would have made in the same spots ("expected go attempts"):

| Season | Eagles above expected | League average above expected | Difference |
|---|---|---|---|
| 2020 | +10.2 | -1.8 | +12.0 |
| 2021 | +2.3 | +0.8 | +1.5 |
| 2022 | +9.7 | -1.6 | +11.3 |
| 2023 | +9.3 | -0.1 | +9.4 |
| 2024 | +3.5 | -0.1 | +3.6 |
| 2025 | +5.2 | +2.8 | +2.4 |

- In 2020, 2022 and 2023 the Eagles went for it roughly 9 to 12 more times a season than a typical team in the same situations. The other seasons were closer to the league.
- In 2025 their raw go rate ranked 28th, but the situations they faced were punt-heavy (a typical team would have gone for it about 15 times) and they went for it 20 times. After accounting for that, they were slightly above the league norm, which itself rose that year.
- These are small samples (20 to 35 attempts per season), so a few plays can move any of these numbers.

## How it is built

| Layer | Model | What it does |
|---|---|---|
| Staging | `stg_pbp_fourth_downs` | One row per 4th-down punt, field goal, run or pass; adds `is_go_for_it` |
| Intermediate | `int_fourth_down_situations` | Adds distance, field zone and score-state labels |
| Marts | `mart_go_rate_team_season` | Go-for-it counts and rate by team and season |
| Marts | `mart_go_rate_ranked` | Adds the league rate and each team's rank within a season (window functions) |
| Marts | `mart_go_rate_situation_league` | League go rate in each situation (benchmark) |
| Marts | `mart_go_rate_vs_expected` | Actual vs. expected go attempts per team and season |

`dbt build` runs all 6 models and 13 tests (unique and not-null keys, accepted values for down, play type, the go-for-it flag and the situation labels).

## Definitions

- **Opportunity:** a 4th-down play that was a run, pass, punt or field goal. Penalty-wiped plays (`no_play`) and kneel-downs are left out.
- **Go for it:** a run or a pass.
- **Go rate:** go attempts divided by opportunities.
- **Situation:** distance to go (1, 2, 3, 4, 5-10, 11+), field zone (red zone, comfortable field goal range, field goal range, midfield, open field) and score state (trailing or leading by more than 3, otherwise close).
- **Expected go attempts:** for each of a team's opportunities, the league's go rate in that situation, added up.

## Limits

- The situation benchmark pools all six seasons and includes the team's own plays, so it is only an approximation of "a typical team."
- Situations are coarse. Time left in the game, weather, kicker range and the opponent are not considered. The field zone cutoffs are approximate.
- Some situations have few plays, so their rates are noisy.
- This describes what teams did. It does not say why, or whether going for it was the better choice.
- Part 2 (conversion rate, EPA) is not built yet.

## How to run

```bash
pip install dbt-duckdb duckdb pandas pyarrow
mkdir -p data
for y in 2020 2021 2022 2023 2024 2025; do
  curl -L -o data/play_by_play_$y.parquet https://github.com/nflverse/nflverse-data/releases/download/pbp/play_by_play_$y.parquet
done
dbt build
```

## Data

Play-by-play data comes from [nflverse](https://github.com/nflverse/nflverse-data) and is downloaded from its releases page, not stored in this repo. Check nflverse's terms before reusing it.