-- Top 10 run scorers across 2025 and 2026 combined.
with top_scorer as (
select
    player,
    team,
    sum(runs) as total_runs,
    sum(balls_faced) as total_balls,
    count(*) as total_match
from batting_stats
group by player,team
order by total_runs desc 
limit 10
)
select tp.*,
       cast((tp.total_runs / total_balls) * 100 as decimal(5,2) ) as strike_rate
from top_scorer tp
;
-- 2025 ,2026
WITH top_scorer AS (
    SELECT
        bs.player,
        bs.team,
        SUM(bs.runs)                                              AS total_runs,
        SUM(bs.balls_faced)                                       AS total_balls,
        COUNT(DISTINCT bs.match_id)                               AS total_matches,
        SUM(CASE WHEN m.season = 2025 THEN bs.runs ELSE 0 END)   AS runs_2025,
        SUM(CASE WHEN m.season = 2026 THEN bs.runs ELSE 0 END)   AS runs_2026
    FROM batting_stats bs
    JOIN matches m ON bs.match_id = m.match_id
    GROUP BY bs.player, bs.team
)
SELECT
    RANK() OVER (ORDER BY total_runs DESC)                       AS rnk,
    player, team,
    total_runs, total_balls, total_matches,
    runs_2025, runs_2026,
    CAST(total_runs * 100.0 / total_balls AS DECIMAL(5,2))       AS strike_rate
FROM top_scorer
ORDER BY total_runs DESC
LIMIT 10;

-- Which player scored the most centuries (100+ runs in a match)?
select 
     player,
     team,
     count(*) as Most_centuries,
     max(runs) as highest_score,
     sum(runs) as total_runs_in_centuries,
     round(avg(runs),1) as avg_century_score
from batting_stats
where runs >= 100
group by player,
         team
order by Most_centuries desc;

--  Which player has the best strike rate 
-- (minimum 200 balls faced across all matches)?
with top_scorer as (
select
    player,
    team,
    sum(runs) as total_runs,
    sum(balls_faced) as total_balls,
    count(*) as total_match
from batting_stats
group by player,team
)
select tp.*,
       cast((tp.total_runs / total_balls) * 100 as decimal(5,2) ) as strike_rate
from top_scorer tp
where tp.total_balls >= 200
order by strike_rate desc
;
-- top 10
with top_scorer as (
select
    player,
    team,
    sum(runs) as total_runs,
    sum(balls_faced) as total_balls,
    count(*) as total_match
from batting_stats
group by player,team
)
select tp.*,
       cast((tp.total_runs / total_balls) * 100 as decimal(5,2) ) as strike_rate,
        CAST(tp.total_runs * 1.0 / tp.total_match   AS DECIMAL(5,2))  AS avg_per_match
from top_scorer tp
where tp.total_balls >= 200
order by strike_rate desc
limit 10
;

--  Show each player's highest score, lowest score, 
--  and average score per innings.

with min_max_score as (
select 
    player,
    team,
    max(runs) as highest_score,
    min(runs) as lowest_score,
    sum(runs) as total_runs,
    sum(balls_faced) as total_balls,
    count(*) as total_match
from batting_stats
group by player,team
)
select 
     dmms.player,
     mms.team,
     mms.highest_score,
     mms.lowest_score,
     mms.total_runs,
     mms.total_match,
     cast(( mms.total_runs / mms.total_match) as decimal(5,2) ) as average_runs_per_inning
from min_max_score mms
order by average_runs_per_inning desc;

 -- Which team scored the most runs overall?
--  Break it down by season.

select 
    bt.team,
    m.season,
    sum(bt.runs) as total_runs
from batting_stats bt
join matches m
    on bt.match_id = m.match_id
group by 
         bt.team,
         m.season
order by m.season,total_runs desc;
-- more clean
select
   bt.team,
   sum(bt.runs)                                           as total_runs,
   sum(case when m.season = 2025 then bt.runs else 0 end) as runs_2025,
   sum(case when m.season = 2026 then bt.runs else 0 end) as runs_2026,
   sum(case when m.season = 2026 then bt.runs else 0 end) -
   sum(case when m.season = 2025 then bt.runs else 0 end) as runs_growth,
   dense_rank() over(order by sum(bt.runs) desc)          as rnk
from batting_stats bt
join matches m
   on bt.match_id = m.match_id
group by bt.team
order by total_runs desc;
