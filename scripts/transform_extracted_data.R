# Load libraries
library(stringr)
library(dplyr)
library(lubridate)

load("./data/season_data_extracted.RData")

season_schedule <- season_schedule_extracted %>%
  mutate(season_year_start = as.character(as.integer(season_year) - 1)) %>%
  mutate(game_date = ifelse(grepl("(Nov|Dec)", date), season_year_start, season_year)) %>%
  mutate(game_date = paste(date, game_date, sep = ', ')) %>%
  mutate(game_date = parse_date_time(game_date, "%a, %b! %d!, %Y!")) %>%
  mutate(is_home_game = grepl("^vs", opponent)) %>%
  mutate(opponent = gsub("(vs|@|#\\d+)", "", opponent, perl=TRUE)) %>%
  mutate(opponent = gsub("\\*", "", opponent, perl=TRUE)) %>%
  mutate(is_win = grepl("^W", result, perl = TRUE)) %>%
  mutate(result = str_extract(result, "\\d+-\\d+")) %>%
  mutate(score_win = str_extract(result, "^\\d+")) %>%
  mutate(score_win = as.numeric(score_win)) %>%
  mutate(score_lose = str_extract(result, "\\d+$")) %>%
  mutate(score_lose = as.numeric(score_lose)) %>%
  mutate(score_team_total = if_else(is_win, score_win, score_lose)) %>%
  mutate(score_opponent_total = if_else(is_win, score_lose, score_win)) %>%
  mutate(opponent_id = str_extract(row_class, "\\d+$")) %>%
  mutate(opponent_id = as.numeric(opponent_id)) %>%
  mutate(game_index = rownames(.)) %>%
  select(team_id, season_year, game_id, game_index, game_date, opponent_id, opponent, is_home_game, is_win, score_team_total, score_opponent_total)

season_pbp <- season_pbp_extracted %>%
  filter(play_score_change != 'combined-score no-change') %>%
  inner_join(season_schedule, by = "game_id") %>%
  mutate(game_score_cumm_home = str_extract(SCORE, "\\d+$")) %>%
  mutate(game_score_cumm_away = str_extract(SCORE, "^\\d+")) %>%
  mutate(game_period = str_extract(game_quarter, "\\d+$")) %>%
  mutate(game_period = as.numeric(game_period)) %>%
  mutate(score_team_cumm = ifelse(is_home_game, game_score_cumm_home, game_score_cumm_away)) %>%
  mutate(score_team_cumm = as.numeric(score_team_cumm)) %>%
  mutate(score_opponent_cumm = if_else(is_home_game, game_score_cumm_away, game_score_cumm_home)) %>%
  mutate(score_opponent_cumm = as.numeric(score_opponent_cumm)) %>%
  mutate(score_combined_total = score_team_cumm + score_opponent_cumm) %>%
  mutate(score_team_diff = score_team_cumm - score_opponent_cumm) %>%
  mutate(period_time_sec = ifelse(game_period <= 2, 1200, 300) - seconds(ms(time))) %>%
  mutate(game_time_sec = seconds(ifelse(game_period <= 2, (game_period -1) * 1200, 2400 + ((game_period - 2)  * 300)))) %>%
  mutate(game_time_sec = game_time_sec + period_time_sec) %>%
  mutate(play_timestamp = as.POSIXct(game_date + game_time_sec)) %>%
  mutate(play_timestamp = as_datetime(play_timestamp)) %>%
  mutate(period_time_sec = second(period_time_sec)) %>%
  mutate(game_time_sec = second(game_time_sec)) %>%
  mutate(game_score_result = paste(as.character(score_team_total), "-", as.character(score_opponent_total), sep = "")) %>%
  mutate(game_title_score = paste(game_date, ifelse(is_home_game, "vs", "@"), opponent, ifelse(is_win, "W", "L"), game_score_result)) %>%
  mutate(game_score_team_margin = score_team_total - score_opponent_total) %>%
  mutate(game_score_team_margin = paste(ifelse(game_score_team_margin > 0, "+", ""), as.character(game_score_team_margin), sep = "")) %>%
  mutate(game_title_margin = paste(game_date, ifelse(is_home_game, "vs", "@"), opponent, ifelse(is_win, "W", "L"), game_score_team_margin)) %>%
  rename(play_description = PLAY) %>%
  select(extract_timestamp, team_id, season_year, game_id, game_title_score, game_title_margin, game_date, opponent_id, opponent, is_home_game, is_win, score_team_total, score_opponent_total, play_timestamp, game_period, period_time_sec, game_time_sec, play_description, score_team_cumm, score_opponent_cumm, score_combined_total, score_team_diff)

save(season_schedule, season_pbp, file="./data/season_data_transformed.RData")
