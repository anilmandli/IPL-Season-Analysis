--      Player Consistency Score:
--      For each batsman calculate:
--      avg runs, std deviation of runs, consistency %
--      (lower std dev = more consistent)
--      Rank by consistency score.
with batters as (
select bt.player,
       count(*) as total_matches,
	   sum(bt.runs) as total_runs,
       round((sum(bt.runs) / count(*)),2)as avg_runs_per_inning,
	   round(stddev(bt.runs),2) as std_dev
from batting_stats bt
group by bt.player
),
metrixs as (
select *,
        case 
		 when avg_runs_per_inning = 0 then 0
         when ( 1 - (std_dev / avg_runs_per_inning)) * 100 < 0 then 0
         else round((1 - (std_dev / avg_runs_per_inning)) * 100, 2)
	   end as consistency_percentage,
       case 
         when total_matches < 3 then 'Insufficient Innings'
         when std_dev > avg_runs_per_inning then 'Extreme Volatility'
         when std_dev <= (avg_runs_per_inning * 0.4) then 'Highly Consistent'
         when std_dev <= (avg_runs_per_inning * 0.7) then 'Moderate'
         else 'Volatile / Match Winner' 
	  end as consistency_label
from batters
where total_matches > 5 and total_runs > 200
)
select m.*,
       dense_rank()over(order by consistency_percentage desc) as rnk
from metrixs m
;
--      Toss Impact Analysis:
--      For each team calculate:
--      total tosses won, matches won after winning toss,
--      toss-to-win conversion rate %
with total_match as (
select
    t.team_name,
    count(*) as total_matches
from teams t
join matches m
    on t.team_name = m.team1
    or t.team_name = m.team2
group by t.team_name
),
toss_wins as (
select
     t.team_name,
     count(m.toss_winner) as total_toss_win
from teams t
join matches m
    on t.team_name = m.toss_winner
group by t.team_name
),
match_wins as (
select t.team_name,
       count(m.winner) as matches_win
from teams t
join matches m
    on t.team_name = m.winner
group by t.team_name
),
tossesNmatches as(
select 
   count(winner) as tossNwin,winner
   from matches m
   where winner = toss_winner
 group by winner
 ),
base as (
select
     t.team_name,
     tm.total_matches,
     tw.total_toss_win,
     mw.matches_win,
     tnm.tossNwin,
     round((tnm.tossNwin / tw.total_toss_win) * 100 , 2) as toss_to_win_pct
from teams t
join total_match tm
    on t.team_name = tm.team_name
join toss_wins tw
    on tm.team_name = tw.team_name
join match_wins mw
    on tm.team_name = mw.team_name
join tossesNmatches tnm
    on mw.team_name = tnm.winner
)
SELECT
    *,
    CASE
        WHEN toss_to_win_pct > 70 THEN 'Critical Advantage'
        WHEN toss_to_win_pct > 50 THEN 'High Impact'
        WHEN toss_to_win_pct = 50 THEN 'Balanced'
        ELSE 'Low Impact'
    END AS toss_impact_label
FROM base;


--      Home vs Away performance:
--      Each team plays home matches at their city.
--      Compare win % at home vs away games.
-- cleaner 
with team_performance as (
   select 
      t.team_name,
      count(*) as total_matches,
      sum(case when m.city in (select distinct city from matches  where city = ('Dharamsala')) or t.city = m.city then 1 else 0 end) as home_matches,
      sum(case when t.city = m.city and m.winner = t.team_name then 1 else 0 end) as home_wins,
      sum(case when t.city != m.city then 1 else 0 end) as away_matches,
      sum(case when t.city != m.city and m.winner = t.team_name then 1 else 0 end) as away_wins
	from teams t
    join matches m
	  on t.team_name = m.team1
      or t.team_name = m.team2
	group by t.team_name
)
select team_name,
       total_matches,
       home_matches,
       home_wins,
       round( home_wins * 100.0 / home_matches, 2) as home_win_pct,
       away_matches,
       away_wins,
       round( away_wins * 100.0 / home_matches, 2) as away_win_pct
from team_performance
;

-- my first try
-- with total_match as (
-- select
--     t.team_name,
--     count(*) as total_matches
-- from teams t
-- join matches m
--     on t.team_name = m.team1
--     or t.team_name = m.team2
-- group by t.team_name
-- ),
--  home_win as (
-- select t.team_name,
--        count(m.winner) as home_wins
-- from teams t
-- join matches m
--     on t.team_name = m.winner
-- where t.city = m.city
-- group by t.team_name
-- ),
-- home_match as (
-- select
--     t.team_name,
--     count(*) as home_matches
-- from teams t
-- join matches m
--     on t.team_name = m.team1
--     or t.team_name = m.team2
--     where t.city = m.city
-- group by t.team_name
-- ),
-- away_match as (
-- select
--     t.team_name,
--     count(*) as away_matches
-- from teams t
-- join matches m
--     on t.team_name = m.team1
--     or t.team_name = m.team2
--     where t.city != m.city
-- group by t.team_name
-- ),
-- away_win as (
-- select t.team_name,
--        count(m.winner) as away_wins
-- from teams t
-- join matches m
--     on t.team_name = m.winner
-- where t.city != m.city
-- group by t.team_name
-- )
-- select 
--      hw.team_name, 
--      tm.total_matches,
--      hm.home_matches,
--      hw.home_wins,
--      round((hw.home_wins / hm.home_matches) * 100, 2) as home_win_percentage,
--      case 
--         when round((hw.home_wins / hm.home_matches) * 100, 2) >= 70 then 'Fortress (Virtually Unbeatable'
--         when round((hw.home_wins / hm.home_matches) * 100, 2) >= 55 then 'Dominant Home Force'
--         when round((hw.home_wins / hm.home_matches) * 100, 2) >= 45 then 'Balanced (Standard home Advantage)'
--         else 'Vulnerable Hosts'
-- 	 end as home_performance_lable,
--      am.away_matches,
--      aw.away_wins,
--      round((aw.away_wins / am.away_matches)* 100, 2) as away_win_percentage,
--      case 
-- 	   when round((aw.away_wins / am.away_matches)* 100, 2) >= 55 then 'Travel Warriors (Elite Away Record)'
--        when round((aw.away_wins / am.away_matches)* 100, 2) >= 45 then 'Strong Travelers'
--        when round((aw.away_wins / am.away_matches)* 100, 2) >= 35 then 'Competitive Visitors'
--        else 'Home-Sick (Poor Away Record)'
-- 	 end as away_performance_label
-- from home_win hw
-- join home_match hm
--     on hw.team_name = hm.team_name
-- join away_match am
--     on hm.team_name = am.team_name
-- join away_win aw
--     on am.team_name = aw.team_name
-- join total_match tm
--     on aw.team_name = tm.team_name
-- ;


 
 
--      Player of the Match Analysis:
--      Which player won most Player of the Match awards?
--      Which team produced most award winners?
WITH pom AS (
    (SELECT bt.player AS player_name, bt.team
     FROM batting_stats bt
     JOIN matches m ON bt.match_id = m.match_id
     WHERE bt.player = m.player_of_match)
    UNION ALL
    (SELECT bt.bowler AS player_name, bt.bowling_team AS team
     FROM bowling_stats bt
     JOIN matches m ON bt.match_id = m.match_id
     WHERE bt.bowler = m.player_of_match)
)
SELECT player_name, COUNT(*) AS pom_awards
FROM pom
GROUP BY player_name
ORDER BY pom_awards DESC
LIMIT 10;
-- for teams, most of the case winning team player won POM 
SELECT t.team_name, COUNT(*) AS pom_per_team
FROM teams t
join matches m
   on t.team_name = m.winner
GROUP BY t.team_name
ORDER BY pom_per_team DESC;

-- -- first try
-- with pom as (
-- (select
--       distinct(bt.player),
--       bt.team,
--       count(m.player_of_match) as pom_t
-- from batting_stats bt
-- join matches m
--     on bt.match_id = m.match_id
-- where bt.player = m.player_of_match 
-- group by bt.player,bt.team
-- )
-- union 
-- (
-- select
-- 	  distinct(bt.bowler),
--       bt.bowling_team,
--       count(m.player_of_match) as pom_t 
-- from bowling_stats bt
-- join matches m
--     on bt.match_id = m.match_id

-- where bt.bowler = m.player_of_match
-- group by bt.bowler,bt.bowling_team
-- )
-- )
-- select  p.team,
--        sum(p.pom_t) as pom_Per_team
-- from pom p
-- group by p.team
-- order by pom_per_team desc
-- ;
-- -- another

-- with pom as (
-- (select
--       distinct(bt.player),
--       bt.team,
--       sum(case when m.season =2025 then 1 else 0 end) as POMs_2025,
-- 	  sum(case when m.season = 2026 then 1 else 0 end) as POMs_2026
-- from batting_stats bt
-- join matches m
--     on bt.match_id = m.match_id
-- where bt.player = m.player_of_match 
-- group by bt.player,bt.team,m.season
-- )
-- union 
-- (
-- select
-- 	  distinct(bt.bowler),
--       bt.bowling_team,
--       sum(case when m.season =2025 then 1 else 0 end) as POMs_2025,
-- 	  sum(case when m.season = 2026 then 1 else 0 end) as POMs_2026
-- from bowling_stats bt
-- join matches m
--     on bt.match_id = m.match_id

-- where bt.bowler = m.player_of_match
-- group by bt.bowler,bt.bowling_team,m.season
-- )
-- )
-- select  p.team,
--        sum(p.POMs_2025) as pom_Per_team_2025,
--        sum(p.POMs_2026) as pom_per_team_2026
-- from pom p
-- group by p.team
-- ;


  
--   Season comparison dashboard query:
--      For each team show side by side:
--      wins_2025, wins_2026, runs_scored_2025,
--      runs_scored_2026, top_scorer_2025, top_scorer_2026
--      All in one query using CASE WHEN + GROUP BY.
with matchs as (
 SELECT
    t.team_name,
    COUNT(*)                                          AS total_matches,
    SUM(CASE WHEN m.season = 2025 THEN 1 ELSE 0 END)         AS matches_2025,
    SUM(CASE WHEN m.season = 2026 THEN 1 ELSE 0 END)         AS matches_2026
FROM teams t
JOIN matches m ON t.team_name = m.team1 or t.team_name = m.team2
GROUP BY t.team_name
),
wins as (
SELECT
    t.team_name,
    COUNT(m.winner)                                          AS total_wins,
    SUM(CASE WHEN m.season = 2025 THEN 1 ELSE 0 END)         AS wins_2025,
    SUM(CASE WHEN m.season = 2026 THEN 1 ELSE 0 END)         AS wins_2026
FROM teams t
JOIN matches m ON t.team_name = m.winner
GROUP BY t.team_name
),
runs as (
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
)
select 
      m.team_name,
      m.total_matches,
      w.total_wins,
	  r.total_runs,
      dense_rank() over(order by r.total_runs desc ) as rnk,
      m.matches_2025,
      w.wins_2025,
      r.runs_2025,
      dense_rank() over(order by r.runs_2025 desc ) as rnk_2025_runs,
      m.matches_2026,
      w.wins_2026,
	  r.runs_2026,
      dense_rank() over(order by r.runs_2026 desc ) as rnk_2026_runs
      
from 
   matchs m
   join wins w
       on m.team_name = w.team_name
	join runs r
       on w.team_name = r.team
;

      
      















