create database if not exists  ipl_real_db;
use ipl_real_db;

 -- table - 1 : matches
 create table matches (
	match_id        INT,
	season          INT,
    match_date      DATE,
    match_number    INT,
    venue           VARCHAR(100),
    city            VARCHAR(50),
    team1           VARCHAR(60),
    team2           VARCHAR(60),
    toss_winner     VARCHAR(60),
    toss_decision   VARCHAR(10),
    winner          VARCHAR(60),
    winner_runs     INT,
    winner_wickets  INT,
    player_of_match VARCHAR(100)
);

-- Table 2: batting_stats
CREATE TABLE batting_stats (
    match_id        INT,
    team            VARCHAR(60),
    player          VARCHAR(100),
    runs            INT,
    balls_faced     INT,
    fours           INT,
    sixes           INT,
    is_out          INT,
    strike_rate     DECIMAL(6,2)
);

-- Table 3: bowling_stats
CREATE TABLE bowling_stats (
    match_id        INT,
    bowling_team    VARCHAR(60),
    bowler          VARCHAR(100),
    runs_given      INT,
    wickets         INT,
    wides           INT,
    noballs         INT,
    legal_balls     INT,
    overs           DECIMAL(5,1),
    economy         DECIMAL(5,2)
);

-- Table 4: ball_by_ball
CREATE TABLE ball_by_ball (
    match_id            INT,
    innings             INT,
    over_ball           VARCHAR(10),
    batting_team        VARCHAR(60),
    striker             VARCHAR(100),
    non_striker         VARCHAR(100),
    bowler              VARCHAR(100),
    runs_off_bat        INT,
    extras              INT,
    wides               INT,
    noballs             INT,
    byes                INT,
    legbyes             INT,
    penalty             INT,
    wicket_type         VARCHAR(30),
    player_dismissed    VARCHAR(100),
    team1               VARCHAR(60),
    team2               VARCHAR(60),
    season              INT,
    match_date          DATE,
    match_number        INT,
    venue               VARCHAR(100),
    city                VARCHAR(50),
    toss_winner         VARCHAR(60),
    toss_decision       VARCHAR(10),
    winner              VARCHAR(60),
    winner_runs         INT,
    winner_wickets      INT,
    player_of_match     VARCHAR(100),
    total_runs          INT,
    is_wicket           INT,
    bowling_team        VARCHAR(60)
);


select  * from matches;
select * from batting_stats;
select * from bowling_stats;
select * from ball_by_ball;

ALTER TABLE matches
ADD PRIMARY KEY (match_id);

ALTER TABLE batting_stats
ADD INDEX idx_match_id (match_id);

ALTER TABLE ball_by_ball
ADD INDEX idx_match_id (match_id);

ALTER TABLE batting_stats
ADD INDEX idx_player (player);

ALTER TABLE bowling_stats
ADD INDEX idx_bowler (bowler);

SHOW INDEX FROM matches;
SHOW INDEX FROM batting_stats;

select  * from matches;
select * from batting_stats;
select * from bowling_stats;
select * from ball_by_ball;


