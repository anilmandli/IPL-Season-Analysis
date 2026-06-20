-- Top 10 wicket takers across both seasons.
select 
     bt.bowler,
     bt.bowling_team,
     sum(bt.wickets) as total_wicket
from bowling_stats bt
group by  
     bt.bowler,
     bt.bowling_team
order by total_wicket desc
limit 10;

SELECT
    bowler,
    bowling_team,
    SUM(wickets)                                           AS total_wickets,
    SUM(overs)                                             AS total_overs,
    SUM(runs_given)                                        AS total_runs_given,
    ROUND(SUM(runs_given) / NULLIF(SUM(overs), 0), 2)     AS economy,
    COUNT(DISTINCT match_id)                               AS matches_played,
    ROUND(SUM(overs) / NULLIF(SUM(wickets), 0), 2)        AS bowling_avg,
    DENSE_RANK() OVER (ORDER BY SUM(wickets) DESC)         AS rnk
FROM bowling_stats
GROUP BY bowler, bowling_team
ORDER BY total_wickets DESC
LIMIT 10;

--  Which bowler has the best economy rate 
--  (minimum 10 overs bowled)?
WITH performance AS (
    SELECT
        bowler,
        bowling_team,
        SUM(runs_given)  AS total_runs_given,
        SUM(overs)       AS total_overs,
        SUM(wickets)     AS total_wickets,
        COUNT(*)         AS total_matches
    FROM bowling_stats
    GROUP BY bowler, bowling_team
)
SELECT
    bowler,
    bowling_team,
    total_overs,
    total_matches,
    total_wickets,
    ROUND(total_runs_given / NULLIF(total_overs, 0), 2) AS economy 
FROM performance
WHERE total_overs >= 10
ORDER BY economy
LIMIT 10;
-- Which bowler took the most 3-wicket hauls?
select 
   bowler,
   sum(case when wickets >=3 then 1 else 0 end) as 3_wicket_hauls,
   count(*) as total_match
from bowling_stats
group by bowler
order by 3_wicket_hauls desc
limit 10;

SELECT
    bowler,
    bowling_team,
    COUNT(*)                                                    AS total_matches,
    SUM(CASE WHEN wickets >= 5 THEN 1 ELSE 0 END)             AS five_wicket_hauls,
    SUM(CASE WHEN wickets >= 4 THEN 1 ELSE 0 END)             AS four_wicket_hauls,
    SUM(CASE WHEN wickets >= 3 THEN 1 ELSE 0 END)             AS three_wicket_hauls,
    SUM(CASE WHEN wickets = 0 THEN 1 ELSE 0 END)              AS wicketless_matches,
    SUM(wickets)                                                AS total_wickets
FROM bowling_stats
GROUP BY bowler, bowling_team
ORDER BY three_wicket_hauls DESC
LIMIT 10;

-- Show each team's leading wicket taker per season
-- using RANK() PARTITION BY season. 
-- Step 2: Rank within each team per season (full part)
WITH wickets_per_season AS (
    SELECT
        bs.bowler,
        bs.bowling_team,
        m.season,
        SUM(bs.wickets)  AS total_wickets,
        SUM(bs.overs)    AS total_overs
    FROM bowling_stats bs
    JOIN matches m ON bs.match_id = m.match_id
    GROUP BY bs.bowler, bs.bowling_team, m.season
),
ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY bowling_team, season   -- rank within each team PER season
            ORDER BY total_wickets DESC
        ) AS team_rank
    FROM wickets_per_season
)
SELECT
    season,
    bowling_team,
    bowler,
    total_wickets,
    total_overs,
    team_rank
FROM ranked
WHERE team_rank = 1          -- only show the top bowler per team per season
ORDER BY season, bowling_team;

-- Which bowler conceded the most wides overall?

select 
     bowler,
     sum(wides) as total_wides_conceded
from bowling_stats
group  by bowler
order by total_wides_conceded desc;


SELECT
    bowler,
    bowling_team,
    COUNT(DISTINCT match_id)                              AS matches_played,
    SUM(wides)                                            AS total_wides,
    SUM(noballs)                                          AS total_noballs,
    SUM(wides) + SUM(noballs)                             AS total_extras,
    ROUND(SUM(wides) / COUNT(DISTINCT match_id), 2)       AS wides_per_match,
    DENSE_RANK() OVER (ORDER BY SUM(wides) DESC)          AS rnk
FROM bowling_stats
GROUP BY bowler, bowling_team
ORDER BY total_wides DESC
LIMIT 15;
