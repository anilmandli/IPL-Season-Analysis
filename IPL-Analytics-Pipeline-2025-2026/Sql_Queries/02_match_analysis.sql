-- Q1. How many matches did each team win in 2025 and 2026?
select
       t.team_name,
       count(m.winner) as total_win
from teams t
join matches m
    on t.team_name = m.winner
group by t.team_name
order by total_win desc;

-- Q2. Which venue hosted the most matches?
select
      venue, count(venue) as matches_hosted
from matches 
group by venue
order by matches_hosted desc;

-- Q3. Did toss winners win more matches? 
--     Show toss win % vs match win % for each team.

-- total wins per team in 2025,2026
select 
     t.team_name ,
     count(m.winner) as total_win
from teams t
join matches m
    on t.team_name = m.winner
group by t.team_name
order by total_win desc;

-- total toss win per team in 2025,2026
select 
     t.team_name,
     count(m.toss_winner) as toss_win
from teams t
join matches m
    on t.team_name = m.toss_winner
group by t.team_name
order by toss_win desc;

-- total matches per team in 2025,2026
select
    t.team_name,
    count(m.match_id) as total_matches
from teams t
join matches m 
     on t.team_name = m.team1
     or t.team_name = m.team2
group by t.team_name
order by total_matches desc;

-- now toss win % vs match win%

with total_wins as (
select 
     t.team_name ,
     count(m.winner) as total_win
from teams t
join matches m
    on t.team_name = m.winner
group by t.team_name
order by total_win desc
),
total_toss_wins as (
select 
     t.team_name,
     count(m.toss_winner) as toss_win
from teams t
join matches m
    on t.team_name = m.toss_winner
group by t.team_name
order by toss_win desc
),
total_matches as (
select
    t.team_name,
    count(m.match_id) as total_matches
from teams t
join matches m 
     on t.team_name = m.team1
     or t.team_name = m.team2
group by t.team_name
order by total_matches desc
)
select 
      t.team_name,
      cast((ttw.toss_win / tm.total_matches) * 100 as decimal(5,2)) as toss_win_pct,
      cast((tw.total_win / tm.total_matches) * 100 as decimal(5,2))as total_win_pct
from total_wins tw
join total_toss_wins ttw
   on tw.team_name = ttw.team_name
join total_matches tm
   on ttw.team_name = tm.team_name
join teams t
   on tm.team_name = t.team_name
-- group by t.team_name
order by toss_win_pct desc, total_win_pct desc;

-- Q4. Which team won by the highest run margin?
select winner,
       winner_runs as highest_run_margin
from matches 
order by highest_run_margin desc
limit 1;

-- Q5. Which team won most matches batting first vs chasing?
-- total wins by teams
select 
     t.team_name ,
     count(m.winner) as total_win
from teams t
join matches m
    on t.team_name = m.winner
group by t.team_name
order by total_win desc;

-- total wins  while batting first
select t.team_name,
       count(m.winner_runs) as while_batting_first
from teams t
join matches m 
   on t.team_name = m.winner
where m.winner_runs != 0
group by t.team_name
order by  while_batting_first desc;

-- total wins while bowling first
select t.team_name,
       count(m.winner_wickets) as while_bowling_first
from teams t
join matches m 
   on t.team_name = m.winner
where m.winner_wickets != 0
group by t.team_name
order by  while_bowling_first desc;

with batting_first as (
select t.team_name,
       count(m.winner_runs) as while_batting_first
from teams t
join matches m 
   on t.team_name = m.winner
where m.winner_runs != 0
group by t.team_name
order by  while_batting_first desc
),
bowling_first as (
select t.team_name,
       count(m.winner_wickets) as while_bowling_first
from teams t
join matches m 
   on t.team_name = m.winner
where m.winner_wickets != 0
group by t.team_name
order by  while_bowling_first desc
)
select t.team_name,
       bt.while_batting_first,
       bot.while_bowling_first
from teams t
join batting_first bt
    on t.team_name = bt.team_name
join bowling_first bot
	on bt.team_name = bot.team_name
;
-- Which team won most matches batting first vs chasing?(actual part)

select q1.team_name as most_wins,
       q1.while_batting_first,
       'Sunrisers Hyderabad	9	0	Royal Challengers Bengaluru	13
       q2.team_name as most_win,
       q2.while_bowling_first
from
(
select t.team_name,
       count(m.winner_runs) as while_batting_first
from teams t
join matches m 
   on t.team_name = m.winner
where m.winner_runs != 0
group by t.team_name
order by  while_batting_first desc
limit 1
) as q1
cross join
(
select t.team_name,
       count(m.winner_wickets) as while_bowling_first
from teams t
join matches m 
   on t.team_name = m.winner
where m.winner_wickets != 0
group by t.team_name
order by  while_bowling_first desc
limit 1
) as q2;