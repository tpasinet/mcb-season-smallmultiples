# Given a R RData file containing NCAA Men's Basketball schedule and game play-by-play (PBP) data extracted fro ESPN game web pages,
# transform the data for use in graphs of cumulative scores and points margin by game by second. 

# Load libraries.
library(dplyr)
library(stringr)
library(lubridate)

# Load the etracted data.
load(file = "season-smallmultiples-app/data/season_data_extracted.RData")

# Transform the etracted schedule data for use in the transformation of the game PBP data
season_schedule <- season_schedule_extracted %>%
  # Construct a POSIX date from date parts stored as text for use in constructing a play timestamp.
  # Dates in the table do not have year parts. Dervie the year given the month part and season year.
  mutate(season_year_start = as.character(as.integer(season_year) - 1)) %>%
  mutate(game_date = ifelse(grepl("(Nov|Dec)", date), season_year_start, season_year)) %>%
  mutate(game_date = paste(date, game_date, sep = ', ')) %>%
  mutate(game_date = parse_date_time(game_date, "%a, %b! %d!, %Y!")) %>%
  # Condition the opponents name by removing unnecessary characters.
  mutate(game_status = str_extract(opponent, "^vs|@")) %>%
  mutate(opponent = str_replace(opponent, "^vs|@", "")) %>%
  mutate(opponent = str_replace(opponent, "\\*", "")) %>%
  mutate(opponent = str_replace(opponent, "\\(?#?\\d+\\)?","")) %>%
  # Determine if the game was a win for the team whose schedule is being transformed.
  mutate(is_win = grepl("^W", result, perl = TRUE)) %>%
  # Extract the score result and split into a score for the team and a score for the opponent.
  mutate(result = str_extract(result, "\\d+-\\d+")) %>%
  mutate(score_win = str_extract(result, "^\\d+")) %>%
  mutate(score_win = as.numeric(score_win)) %>%
  mutate(score_lose = str_extract(result, "\\d+$")) %>%
  mutate(score_lose = as.numeric(score_lose)) %>%
  mutate(score_team_total = if_else(is_win, score_win, score_lose)) %>%
  mutate(score_opponent_total = if_else(is_win, score_lose, score_win)) %>%
  # Extract and append the opponent's team id.
  mutate(opponent_id = str_extract(row_class, "\\d+$")) %>%
  mutate(opponent_id = as.numeric(opponent_id)) %>%
  # Select only columns of actual interest.
  select(team_id, season_year, game_id, game_index, game_date, game_status, opponent_id,
         opponent, is_win, score_team_total, score_opponent_total)

# Given transformed schedule data, transform the extracted PBP data
season_pbp <- season_pbp_extracted %>%
  # Filter out any plays that did not result in a score change for either team.
  filter(play_score_change != 'combined-score no-change') %>%
  # Join data from the transformed schedule data.
  inner_join(season_schedule, by = "game_id") %>%
  # Set the period of the play.
  mutate(game_period = str_extract(game_quarter, "\\d+$")) %>%
  mutate(game_period = as.numeric(game_period)) %>%
  # Derive the team and opponent scores for each play.
  mutate(game_team_home = str_extract(game_team_home, "t:\\d+")) %>%
  mutate(game_team_home = str_replace(game_team_home, "t:", "")) %>%
  mutate(is_team_home = {game_team_home == team_id}) %>%
  mutate(game_score_cumm_home = str_extract(SCORE, "\\d+$")) %>%
  mutate(game_score_cumm_away = str_extract(SCORE, "^\\d+")) %>%
  mutate(score_team_cumm = ifelse(is_team_home, game_score_cumm_home, game_score_cumm_away)) %>%
  mutate(score_team_cumm = as.numeric(score_team_cumm)) %>%
  mutate(score_opponent_cumm = if_else(is_team_home, game_score_cumm_away, game_score_cumm_home)) %>%
  mutate(score_opponent_cumm = as.numeric(score_opponent_cumm)) %>%
  # Derive a combined score as an alternative method for indicating score changes. May depricate in the future.
  mutate(score_combined_total = score_team_cumm + score_opponent_cumm) %>%
  # Derive the points margin from the perspective of the team.
  mutate(score_team_diff = score_team_cumm - score_opponent_cumm) %>%
  # Derive a play timestamp by converting the time in period to a time in game and appending the result to the game date. 
  mutate(period_time_sec = ifelse(game_period <= 2, 1200, 300) - seconds(ms(time))) %>%
  mutate(game_time_sec = seconds(ifelse(game_period <= 2, (game_period -1) * 1200, 2400 + ((game_period - 2)  * 300)))) %>%
  mutate(game_time_sec = game_time_sec + period_time_sec) %>%
  mutate(play_timestamp = as.POSIXct(game_date + game_time_sec)) %>%
  mutate(play_timestamp = as_datetime(play_timestamp)) %>%
  # Derive other usefule time indexes for the play.
  mutate(period_time_sec = second(period_time_sec)) %>%
  mutate(game_time_sec = second(game_time_sec)) %>%
  mutate(game_time_min = game_time_sec / 60) %>%
  # Derive tiltles for use in facet labels. May depricate in favor of facet labeling from schedule data.
  mutate(game_score_result = paste(as.character(score_team_total), "-", as.character(score_opponent_total), sep = "")) %>%
  mutate(game_title_score = paste(game_date, game_status, opponent, ifelse(is_win, "W", "L"), game_score_result)) %>%
  mutate(game_score_team_margin = score_team_total - score_opponent_total) %>%
  mutate(game_score_team_margin = paste(ifelse(game_score_team_margin > 0, "+", ""), as.character(game_score_team_margin), sep = "")) %>%
  mutate(game_title_margin = paste(game_date, game_status, opponent, ifelse(is_win, "W", "L"), game_score_team_margin)) %>%
  # Derive a play ID that uniquely identifies the play using metadata.
  mutate(play_id = paste(game_id, str_pad(as.character(game_period), 2, "left", "0"), str_pad(as.character(play_period_index), 3, "left", "0"), sep = "")) %>%
  # Give the PLAY column a more descriptive name.
  rename(play_description = PLAY) %>%
  # Select only columns of interest or use.
  select(extract_timestamp, team_id, season_year, game_id, game_title_score, game_title_margin, game_date, opponent_id, opponent, is_team_home, is_win, score_team_total, score_opponent_total, play_id, play_timestamp, game_period, period_time_sec, game_time_sec, game_time_min, play_description, score_team_cumm, score_opponent_cumm, score_combined_total, score_team_diff)

# Save the transformed data.
save(season_schedule, file="season-smallmultiples-app/data/season_schedule.Rda")
save(season_pbp, file="season-smallmultiples-app/data/season_pbp.Rda")

