# 🏏 IPL Analytics Dashboard — 2025 & 2026 Seasons

A full data analytics pipeline built on real IPL data — from raw ball-by-ball CSV files to SQL analysis to an interactive Power BI dashboard. This project covers the complete analyst workflow: data extraction, cleaning, database design, advanced SQL querying, Python visualization, and BI dashboarding.

---

##  Repository Contents

| File / Folder | Description |
|---|---|
| `data_loading_and_setup.ipynb` | Google Colab notebook — downloads raw ball-by-ball data, parses it, builds 5 clean tables, exports as CSV |
| `01_schema.sql` | CREATE TABLE statements for all 5 tables |
| `02_match_analysis.sql`,
`03_batting_analysis.sql`,
`04_bowling_analysis.sql`,
`05_window_functions.sql`,
`06_business_insight.sql` | 25 SQL analysis queries — basic to advanced, covering joins, CTEs, window functions, and business metrics |
| `visualization_notebook.ipynb` | Python notebook using Pandas + Matplotlib for chart-based analysis on exported query results |
| `ipl_dashboard_.pbix` | Power BI dashboard file — 2 interactive report pages |
| `README.md` | This file |

---

##  Data Source

Ball-by-ball data sourced from **[Cricsheet.org](https://cricsheet.org/downloads/)** — a free, community-maintained repository of cricket match data in structured CSV format.

**Scope:** Filtered to IPL **2025** and **2026** seasons only — 148 matches, 295,732+ deliveries.

---

##  Project Workflow

### 1. Data Extraction & Cleaning (Google Colab)
- Downloaded the full Cricsheet IPL zip (1000+ individual match files, one per match since 2008)
- Parsed Cricsheet's custom row-based CSV format (`info` rows for match metadata, `ball` rows for delivery data)
- Filtered the combined dataset down to the 2025 and 2026 seasons
- Built **5 clean relational tables** from the raw deliveries:
  - `teams` — team name, city, short name
  - `matches` — one row per match (date, venue, teams, toss, winner, margin)
  - `batting_stats` — aggregated batting performance per player per match
  - `bowling_stats` — aggregated bowling performance per player per match
  - `ball_by_ball` — full delivery-level detail (used for the Power BI head-to-head and match-phase analysis)
- Exported all 5 tables as CSV files

### 2. Database Setup (MySQL Workbench)
- Created the schema using `01_schema.sql`
- Imported all 5 CSVs using the Table Data Import Wizard

### 3. SQL Analysis (25 Queries)
Queries in  `02_match_analysis.sql`,`03_batting_analysis.sql`,`04_bowling_analysis.sql`,`05_window_functions.sql`,`06_business_insight.sql` are organized into 5 sections, progressing from basic to advanced:

| Section | Topics Covered |
|---|---|
| Match Analysis | Team wins, toss impact, venues, win margins, batting-first vs chasing |
| Batting Analysis | Top scorers, centuries, strike rate leaders, consistency |
| Bowling Analysis | Wicket takers, economy rate, 3-wicket hauls, team-wise leaders |
| Window Functions | Running totals, `RANK()`/`DENSE_RANK()`, `FIRST_VALUE`/`LAST_VALUE`, month-wise trends |
| Business Insights | Player consistency score (using `STDDEV`), toss-to-win conversion %, home vs away performance, Player of the Match analysis, full season comparison dashboard query |

### 4. Python Visualization (Matplotlib)
Query results exported as CSV from MySQL Workbench, loaded into `visualization_notebook.ipynb`, and charted using Pandas + Matplotlib — bar charts, scatter plots, and trend lines for batting, bowling, and team performance.

### 5. Power BI Dashboard
Connected Power BI Desktop directly to the local MySQL database. Used **Power Query** to unpivot the `team1`/`team2` columns in the matches table into a single `team_name` column (since Power BI only supports one active relationship per table pair) — this enabled accurate team-level filtering across all visuals.

**Page 1 — Match Overview**
![IPL Match Overview Dashboard Screenshot](https://1drv.ms/i/c/c3fc1c78ffbc671c/IQBTRZNE7M7bSb0Mmulcfe_OAd97l0fnZEg3sSsuRmpVZuA?e=HMWgdW)
)
- KPI cards: Total runs, total wickets, total matches
- Sum of runs by team (bar chart)
- Total wins by team (bar chart)
- Total wickets by player (bar chart)
- Total runs by player (bar chart)
- Matches hosted by top 5 venues (donut chart)
- Slicers: Team, Season
- Navigation button to switch to Player Insight page

**Page 2 — Player Insight**
![IPL Player Insights Dashboard Screenshot](https://1drv.ms/i/c/c3fc1c78ffbc671c/IQAKqIriZ1zLTrcsVEqH3myUAV8UkFF1_-0xMwrDxQt_ZL8?e=ZUvw1rhttps://1drv.ms/i/c/c3fc1c78ffbc671c/IQAKqIriZ1zLTrcsVEqH3myUAV8UkFF1_-0xMwrDxQt_ZL8?e=ZUvw1r)
- KPI cards: Batsman strike rate (adjusted to exclude wide balls), boundary %, bowler economy rate (strictly excluding leg-byes/byes), and total dot balls bowled.
- Dynamic Page Title: Programmed custom conditional formatting using a `SELECTEDVALUE` DAX measure to automatically update the dashboard header text to show the active player's name upon selection.
- Strike Rate vs Runs (scatter plot)
- Economy Rate vs Wickets (scatter plot)
- Toss decision breakdown by team (bat vs field)
- Runs by match phase — Powerplay / Middle Overs / Death Overs (donut chart)
- Wickets by match phase — Powerplay / Middle Overs / Death Overs (donut chart)
- Slicers with search: **Batter**, **Bowler**, **Match Phase**, **Season** — enables strict head-to-head comparison.
- Visual Interactions Control: Leveraged Power BI's "Edit Interactions" feature to decouple filter contexts between separate batsman and bowler selections. This isolates a standalone `H2H Wickets` custom DAX measure to track exact batter vs. bowler historical dismissals without breaking overall season stats.

---

##  Known Data Note

A small discrepancy of **±1 match** exists in the 2025 regular-season counts for 4 teams (RCB, Delhi Capitals, Kolkata Knight Riders, Punjab Kings) — confirmed to be a team-name inconsistency in a small number of source files from Cricsheet, not an error in the SQL logic. Playoff stage data (Qualifiers, Eliminator, Final) was independently verified and is fully accurate. This does not affect batting, bowling, or win-percentage analysis. Documented here for transparency.

---

##  Tech Stack

- **Python** — Pandas (data wrangling), Matplotlib (visualization)
- **Google Colab** — data extraction and cleaning environment
- **MySQL** — relational database and advanced SQL analysis (CTEs, Window Functions)
- **Power BI Desktop & DAX** — Relational data modeling, Power Query transformations, and advanced custom measures

---

##  How to Reproduce

1. Open `data_loading_and_setup.ipynb` in Google Colab, download the Cricsheet IPL zip, and run all cells to generate the 5 CSVs
2. Run `01_schema.sql` in MySQL Workbench to create the database schema
3. Import the 5 CSVs using the Table Data Import Wizard
4. Run any query from `02_match_analysis.sql`,`03_batting_analysis.sql`,`04_bowling_analysis.sql`,`05_window_functions.sql`,`06_business_insight.sql` for SQL-level analysis
5. Open `visualization_notebook.ipynb` to recreate the Python charts
6. Open `ipl_dashboard_.pbix` in Power BI Desktop to explore the interactive dashboard

---

*Part of my data analytics learning journey — built as a portfolio project for data analytics internship applications.*
