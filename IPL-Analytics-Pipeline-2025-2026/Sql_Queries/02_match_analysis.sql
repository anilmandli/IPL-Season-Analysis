-- How many matches did each team win in 2025 and 2026?
select
       t.team_name,
       count(m.winner) as total_win
from teams t
join matches m
    on t.team_name = m.winner
group by t.team_name
order by total_win desc;
-- per season
SELECT
    t.team_name,
    COUNT(m.winner)                                          AS total_wins,
    SUM(CASE WHEN m.season = 2025 THEN 1 ELSE 0 END)         AS wins_2025,
    SUM(CASE WHEN m.season = 2026 THEN 1 ELSE 0 END)         AS wins_2026
FROM teams t
JOIN matches m ON t.team_name = m.winner
GROUP BY t.team_name
ORDER BY total_wins DESC;

-- Which venue hosted the most matches?
select
      venue, count(venue) as matches_hosted
from matches 
group by venue
order by matches_hosted desc;

-- and answer
SELECT
    venue,
    city,
    COUNT(*)                                            AS matches_hosted,
    SUM(CASE WHEN season = 2025 THEN 1 ELSE 0 END)      AS hosted_2025,
    SUM(CASE WHEN season = 2026 THEN 1 ELSE 0 END)      AS hosted_2026
FROM matches
GROUP BY venue, city
ORDER BY matches_hosted DESC
LIMIT 10;


--   Did toss winners win more matches? 
--     Show toss win % vs match win % for each team.


-- -- total wins per team in 2025,2026
-- select 
--      t.team_name ,
--      count(m.winner) as total_win
-- from teams t
-- join matches m
--     on t.team_name = m.winner
-- group by t.team_name
-- order by total_win desc;

-- -- total toss win per team in 2025,2026
-- select 
--      t.team_name,
--      count(m.toss_winner) as toss_win
-- from teams t
-- join matches m
--     on t.team_name = m.toss_winner
-- group by t.team_name
-- order by toss_win desc;

-- -- total matches per team in 2025,2026
-- select
--     t.team_name,
--     count(m.match_id) as total_matches
-- from teams t
-- join matches m 
--      on t.team_name = m.team1
--      or t.team_name = m.team2
-- group by t.team_name
-- order by total_matches desc;

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
      cast((tw.total_win / tm.total_matches) * 100 as decimal(5,2))as total_win_pct,
      -- did winning toss help?
	  CAST((tw.total_win / tm.total_matches) * 100 AS DECIMAL(5,2)) -
      CAST((ttw.toss_win / tm.total_matches) * 100 AS DECIMAL(5,2)) AS win_pct_diff
from total_wins tw
join total_toss_wins ttw
   on tw.team_name = ttw.team_name
join total_matches tm
   on ttw.team_name = tm.team_name
join teams t
   on tm.team_name = t.team_name
 group by t.team_name
order by toss_win_pct desc, total_win_pct desc;

--  Which team won by the highest run margin?

-- select winner,
--        winner_runs as highest_run_margin
-- from matches 
-- order by highest_run_margin desc
-- limit 1;
-- -- alternative
-- SELECT
--     winner,
--     CASE
--         WHEN team1 = winner THEN team2
--         ELSE team1
--     END AS defeated_team,
--     match_date,
--     venue,
--     winner_runs AS winning_margin_runs
-- FROM matches
-- ORDER BY winner_runs DESC
-- LIMIT 1;

-- Top 5 biggest run margin wins
SELECT
    winner,
    CASE WHEN team1 = winner THEN team2 ELSE team1 END AS defeated,
    match_date,
    winner_runs AS margin
FROM matches
WHERE winner_runs > 0
ORDER BY winner_runs DESC
LIMIT 5;

--  Which team won most matches batting first vs chasing?

-- total wins by teams
-- select 
--      t.team_name ,
--      count(m.winner) as total_win
-- from teams t
-- join matches m
--     on t.team_name = m.winner
-- group by t.team_name
-- order by total_win desc;

-- -- total wins  while batting first
-- select t.team_name,
--        count(m.winner_runs) as while_batting_first
-- from teams t
-- join matches m 
--    on t.team_name = m.winner
-- where m.winner_runs != 0
-- group by t.team_name
-- order by  while_batting_first desc;

-- -- total wins while bowling first
-- select t.team_name,
--        count(m.winner_wickets) as while_bowling_first
-- from teams t
-- join matches m 
--    on t.team_name = m.winner
-- where m.winner_wickets != 0
-- group by t.team_name
-- order by  while_bowling_first desc;

-- for all teams
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
       'VS' as seprator,
       q2.team_name as most_win,
       q2.while_bowling_first
from
(
select t.team_name,
       count(m.winner_runs) as while_batting_first
from teams t
join matches m 
   on t.team_name = m.winner
where m.winner_runs > 0
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
where m.winner_wickets > 0
group by t.team_name
order by  while_bowling_first desc
limit 1
) as q2;

-- second answer
WITH TopBattingFirst AS (
    SELECT winner AS team_name, COUNT(*) AS wins
    FROM matches
    WHERE winner_runs > 0
    GROUP BY winner
    ORDER BY wins DESC
    LIMIT 1
),
TopChasing AS (
    SELECT winner AS team_name, COUNT(*) AS wins
    FROM matches
    WHERE winner_wickets > 0
    GROUP BY winner
    ORDER BY wins DESC
    LIMIT 1
)
SELECT 
    b.team_name AS most_wins_batting_first,
    b.wins AS batting_first_count,
    'vs' AS label,
    c.team_name AS most_wins_chasing,
    c.wins AS chasing_count
FROM TopBattingFirst b
CROSS JOIN TopChasing c;

-- Owerall summary
WITH batting_first AS (
    SELECT
        winner AS team_name,
        COUNT(*) AS batting_first_wins
    FROM matches
    WHERE winner_runs > 0
    GROUP BY winner
),
chasing AS (
    SELECT
        winner AS team_name,
        COUNT(*) AS chasing_wins
    FROM matches
    WHERE winner_wickets > 0
    GROUP BY winner
)
SELECT
    t.team_name,
    COALESCE(bf.batting_first_wins, 0)  AS batting_first_wins,
    COALESCE(c.chasing_wins, 0)         AS chasing_wins,
    -- which style suits this team more?
    CASE
        WHEN COALESCE(bf.batting_first_wins, 0) >
             COALESCE(c.chasing_wins, 0)
        THEN 'Better batting first'
        WHEN COALESCE(c.chasing_wins, 0) >
             COALESCE(bf.batting_first_wins, 0)
        THEN 'Better chasing'
        ELSE 'Equal'
    END AS preferred_style
FROM teams t
LEFT JOIN batting_first bf ON t.team_name = bf.team_name
LEFT JOIN chasing c        ON t.team_name = c.team_name
ORDER BY batting_first_wins DESC;
