-- For each batsman show their running total of runs
-- across matches ordered by match date.

select
     bt.player,
     bt.team,
     m.match_date,
     m.season,
     bt.runs,
     sum(bt.runs) over(partition by bt.player order by m.match_date) as running_total_runs,
     count(bt.match_id) over(partition by bt.player order by m.match_date) as inning_so_far,
     round(
          sum(bt.runs) over(partition by bt.player order by m.match_date)  /
          count(bt.match_id) over(partition by bt.player order by m.match_date)
          ,2)  as running_avg
from batting_stats bt
join matches m
     on bt.match_id = m.match_id;
	
--  Rank batsmen within each team by total runs
--  using DENSE_RANK PARTITION BY team.
with TopScorer as (
select
     player,
     team,
     count(*) as total_innings,
     sum(runs) as total_runs,
     round(sum(runs) * 100.0 / sum(balls_faced),2) as strike_rate,
      max(runs) as bestt_score,
     dense_rank() over(partition by team order by sum(runs) desc) as rnk
from batting_stats
group by player,team
)
select tp.*
from topscorer tp
where tp.rnk <= 5;

-- For each match show the highest individual score
with ranked as (
select match_id,
	   player,
       team,
       runs,
       rank() over(partition by match_id order by runs desc) as score_rnk
from batting_stats
)
select 
	r.match_id,
    m.match_date,
    m.season,
    m.team1,
    m.team2,
    r.player    as top_scorer,
    r.team,
    r.runs      as highest_score
from ranked r
join matches m on r.match_id = m.match_id
where r.score_rnk = 1;

-- Show month wise run scoring trend for 2025
-- and compare with 2026 using CASE WHEN + GROUP BY.
with month_wise as (
select
    month(m.match_date) as month_no,
    monthname(m.match_date) as month_name,
    case when year(m.match_date) = 2025 then sum(bt.runs) else 0 end as season_2025,
    case when year(m.match_date) = 2026 then sum(bt.runs) else 0 end as season_2026
from batting_stats bt
join matches m
     on bt.match_id = m.match_id
group by month_no,month_name,m.match_date
)
select mw.month_no,
       mw.month_name,
       sum(mw.season_2025) as total_runs_2025,
       sum(mw.season_2026) as total_runs_2026,
       sum(mw.season_2025) + sum(mw.season_2026) as combined_runs,
       round(
            (sum(mw.season_2026) - sum(mw.season_2025))* 100.0
            / nullif(sum(mw.season_2025),0)
            ,1) as yoy_growth_percentage
from month_wise mw
group by mw.month_no,mw.month_name
order by mw.month_no;

--  Find players whose latest match score was their 
--  career best using LAST_VALUE + CTe
with high_score as (
select
    distinct player,
    max(runs) over(partition by player) as highest_score,
	last_value(runs) over(partition by player order by m.match_date
       rows between unbounded preceding and unbounded following) as latest_score
from batting_stats
join matches m
    on batting_stats.match_id = m.match_id
group by player,m.match_id,runs
)
select
     hs.player,
     hs.highest_score,
     hs.latest_score
from high_score hs
where hs.highest_score = hs.latest_score
order by hs.latest_score desc
limit 10;
