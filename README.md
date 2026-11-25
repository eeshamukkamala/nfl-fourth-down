# Eagles fourth-down aggressiveness, 2020-2025

How often do the Philadelphia Eagles go for it on 4th down, and how does that compare with the rest of the NFL once you account for the situations they faced? Built with dbt, DuckDB and SQL on nflverse play-by-play data (regular seasons 2020-2025).

## Question

- **Part 1:** How often do the Eagles go for it on 4th down, compared with the league and with what a typical team would do in the same situations?
- **Part 2:** How successful are their go-for-it attempts (conversion rate and EPA)?

## Part 1 Findings 

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

## Part 2 Findings

Each go-for-it play is compared with what other teams did in the same situation (same distance bucket and field zone). The benchmark leaves out the team being measured, so a team's own plays never count toward its own benchmark.

| Season | Go attempts | Conversions | Above expected | League avg above expected | Conversions rank (of 32) | EPA above expected per attempt | EPA rank (of 32) |
|---|---|---|---|---|---|---|---|
| 2020 | 35 | 15 | -0.8 | +0.31 | 22 | +0.010 | 23 |
| 2021 | 25 | 11 | -2.4 | -0.09 | 30 | -0.239 | 25 |
| 2022 | 32 | 22 | +4.3 | -0.71 | 2 | +0.532 | 5 |
| 2023 | 26 | 19 | +4.2 | -0.31 | 1 | +0.559 | 2 |
| 2024 | 27 | 19 | +3.4 | +0.56 | 5 | +0.443 | 7 |
| 2025 | 20 | 11 | +0.6 | +0.24 | 13 | +0.371 | 9 |

The Eagles were below average in 2020 and 2021 (22nd and 30th in conversions above expected), among the best in the league from 2022 to 2024 (2nd, 1st and 5th), and closer to the middle in 2025 (13th). Their EPA per attempt tells the same story, and stays high in 2025 (9th) even though their conversion count was near expected. The jump starts in 2022, when the tush push became their signature play, but this analysis does not isolate that play, so the link is a hypothesis, not a finding. League averages are not exactly zero because the benchmark pools all six seasons.

With only 20 to 35 attempts per season, I measured how far luck alone could move each number. The standard error is the typical swing you'd expect if the Eagles were an average team in the same situations, and the z-score is how many standard errors the Eagles are above or below that. No single season is more than 2 standard errors from average (z-scores of -0.28, -1.01, +1.58, +1.74, +1.35 and +0.30 for 2020 to 2025). Across all six seasons the Eagles are +9.3 conversions above expected with a standard error of 6.1 (z = 1.5): suggestive of an edge, but luck can't be ruled out.

I first built the benchmark with all teams' plays pooled, then rebuilt it so the team being analyzed is not included in the league benchmark. The results moved by at most 0.1 conversions per season, so the finding does not depend on that choice.

## How it is built

| Layer | Model | What it does |
|---|---|---|
| Staging | `stg_pbp_fourth_downs` | One row per 4th-down punt, field goal, run or pass; adds `is_go_for_it` |
| Intermediate | `int_fourth_down_situations` | Adds distance, field zone and score-state labels |
| Marts | `mart_go_rate_team_season` | Go-for-it counts and rate by team and season |
| Marts | `mart_go_rate_ranked` | Adds the league rate and each team's rank within a season (window functions) |
| Marts | `mart_go_rate_situation_league` | League go rate in each situation (benchmark) |
| Marts | `mart_go_rate_vs_expected` | Actual vs. expected go attempts per team and season |
| Marts | `mart_go_for_it_team_season` | Go-for-it attempts, conversions and average EPA by team and season |
| Marts | `mart_go_for_it_situation_league` | League conversion rate and EPA in each distance and field-zone situation (benchmark) |
| Marts | `mart_go_for_it_vs_expected` | Actual vs. expected conversions and EPA per team and season, with the team's own plays removed from the benchmark |
| Marts | `mart_go_for_it_ranked` | Ranks every team's results within each season, and adds the league average (window functions) |

`dbt build` runs all 10 models and 21 tests (unique and not-null keys, accepted values for down, play type, the go-for-it flag and the situation labels, not-null checks on the Part 2 models, and a check that no go-for-it plays drop out of the expected-conversions model).

## Definitions

- **Opportunity:** a 4th-down play that was a run, pass, punt or field goal. Penalty-wiped plays (`no_play`) and kneel-downs are left out.
- **Go for it:** a run or a pass.
- **Go rate:** go attempts divided by opportunities.
- **Situation:** distance to go (1, 2, 3, 4, 5-10, 11+), field zone (red zone, comfortable field goal range, field goal range, midfield, open field) and score state (trailing or leading by more than 3, otherwise close).
- **Expected go attempts:** for each of a team's opportunities, the league's go rate in that situation, added up.
- **Conversion rate:** go-for-it plays that gained a first down or touchdown, divided by go-for-it attempts.
- **EPA (expected points added):** how much a play changed the offense's expected points on the drive, from nflverse's model. Positive means the play helped.
- **Expected conversions (Part 2):** for each go-for-it play, the conversion rate of other teams in the same distance bucket and field zone, added up. Score state is not used here.
- **Standard error and z-score:** the standard error is how far a team's total conversions would typically swing from luck alone if it were an average team in the same situations. The z-score is the team's conversions above expected divided by that number. Beyond about 2 is unlikely to be luck alone.

## Limits

- Part 1's benchmark pools all six seasons and includes the team's own plays, so it is only an approximation of "a typical team." Part 2's benchmark removes the team being measured.
- Situations are grouped only by distance and field zone, so a tush push is treated like any other 4th-and-1. Time left in the game, weather, kicker range and the opponent are not considered. The field zone cutoffs are approximate.
- Some situations have few plays, so their rates are noisy.
- This describes what teams did. It does not say why, or whether going for it was the better choice.
- Small samples: the Eagles had 20 to 35 go-for-it attempts per season, so any single season could be luck. Across all six seasons they are +9.3 conversions above expected (z = 1.5), which is suggestive but not conclusive.
- I highlight 2022 to 2024 because the tush push became the Eagles' signature play in 2022, not because of how those seasons turned out. Still, three seasons with 26 to 32 attempts each is a small base for a strong claim.
- Ranks include every team, even those with only a few go-for-it attempts in a season, so one long play can move a small team's rank a lot.
- Teams choose when to go for it, so EPA on go-for-it plays reflects favorable situations, not just execution. It also does not compare going for it with punting or kicking.

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