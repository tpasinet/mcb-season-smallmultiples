# Load libraries
library(rvest)
library(stringr)
library(dplyr)
library(lubridate)
library(ggplot2)

# Define constants
# Take me home...
team_id <- "277"
season_end_year <- "2017"
season_start_year <- season_end_year %>%
  as.integer() %>%
  - 1 %>%
  as.character()

# Define functins
extract_season_schedule <- function(team_id, season_end_year) {
  schedule_base_url <- "http://www.espn.com/mens-college-basketball/team/schedule/_/id/"
  
  season_schedule <- read_html(paste(schedule_base_url, team_id, "/year/",season_end_year, sep = "")) %>%
    html_node(xpath = "//div[@id = 'showschedule']//*//table")
  
  # Get row classes
  row_classes <- season_schedule %>%
    html_nodes(xpath = "//tr") %>%
    html_attr("class")
  
  # Get schedule data as a table
  season_schedule_table <- season_schedule %>%
    html_table()
  
  # Get column headers
  column_headers <- season_schedule_table %>%
    slice(which(row_classes == "colhead")) %>%
    as.character() %>%
    gsub("/[A-Z]+$", "", .) %>%
    tolower()
  
  #Set variable names
  colnames(season_schedule_table) <- column_headers
  
  # Get game IDs from score link
  game_ids <- season_schedule %>%
    html_nodes(xpath = "//table//tr//td//*[contains(@class, 'score')]//a") %>%
    html_attr("href") %>%
    str_extract("/gameId/\\d+$") %>%
    str_replace("/gameId/","")
  
  # Add row classes, filter out not result rows, add team, season year, game ids, and row class
  season_schedule_table <- season_schedule_table %>%
    mutate(row_class = row_classes) %>%
    filter(grepl("^[a-z]+row ", row_class)) %>%
    filter(grepl("^[WLDT]\\d", result)) %>%
    mutate(team_id = team_id) %>%
    mutate(season_year = season_end_year) %>%
    mutate(game_id = game_ids)
  
  season_schedule_table
}

extract_game_pbp <- function(game_id) {
  game_pbp_base_url <- "http://www.espn.com/mens-college-basketball/playbyplay?gameId="
  
  game_pbp_page <- read_html(paste(game_pbp_base_url, game_id, sep = ""))
  
  game_quarters <- game_pbp_page %>%
    html_nodes(xpath = "//div[starts-with(@id, 'gp-quarter-')]") %>%
    html_attr("id")
  
  game_pbp_table <- lapply(game_quarters, extract_quarter_pbp, game_pbp_page = game_pbp_page) %>%
    bind_rows() %>%
    mutate(game_id = game_id)
  
  game_pbp_table
}

extract_quarter_pbp <- function(game_pbp_page, game_quarter) {
  
  quarter_pbp <- game_pbp_page %>%
    html_nodes(xpath = paste("//div[@id = '", game_quarter,"']//table", sep = ""))
    
  score_changes <- quarter_pbp %>%
    html_nodes(xpath = "*//td[starts-with(@class, 'combined-score')]") %>%
    html_attr("class") 
    
  quarter_pbp_table <- quarter_pbp %>%
    html_table(fill = TRUE) %>%
    .[[1]] %>%
    select(time, PLAY, SCORE) %>%
    mutate(game_quarter = game_quarter) %>%
    mutate(play_score_change = score_changes)
  
  quarter_pbp_table
}

# Get the team's season schedule
season_schedule <- extract_season_schedule(team_id, season_end_year)

# Get the team's season's plays
season_pbp <- lapply(season_schedule$game_id, extract_game_pbp) %>%
  bind_rows()

save(season_schedule, season_pbp, file="data/season_data_extracted.RData")

season_schedule <- season_schedule %>%
  mutate(game_date = ifelse(grepl("(Nov|Dec)", date), season_start_year, season_end_year)) %>%
  mutate(game_date = paste(date, game_date, sep = ', ')) %>%
  mutate(game_date = parse_date_time(game_date, "%a, %b! %d!, %Y!")) %>%
  mutate(is_home_game = grepl("^vs", opponent)) %>%
  mutate(opponent = gsub("(vs|@|#\\d+)", "", opponent, perl=TRUE)) %>%
  mutate(opponent = gsub("\\*", "", opponent, perl=TRUE)) %>%
  mutate(is_win = grepl("^W", result, perl = TRUE)) %>%
  mutate(result = gsub("[A-Z ]", "", result)) %>%
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

season_pbp <- season_pbp %>%
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
  mutate(game_title = paste(game_date, ifelse(is_home_game, "vs", "@"), opponent, ifelse(is_win, "W", "L"))) %>%
  rename(play_description = PLAY) %>%
  select(team_id, season_year, game_id, game_title, game_date, opponent_id, opponent, is_home_game, is_win, score_team_total, score_opponent_total, play_timestamp, game_period, period_time_sec, game_time_sec, play_description, score_team_cumm, score_opponent_cumm, score_combined_total, score_team_diff)

save(season_schedule, season_pbp, file="data/season_data_conditioned.RData")

ggplot(season_pbp, aes((game_time_sec/60), score_team_cumm)) +
  ggtitle("WVU Men's Basketball 2017 Cumulative Points by Game") +
  geom_vline(xintercept = 20) +
  geom_vline(xintercept = 40) +
  geom_line(color = "blue") +
  geom_line(aes(y = score_opponent_cumm), color = "gray") +
  facet_wrap(~ game_title, scales = "free") +
  theme_bw() +
  ylab("Cumulative Points") +
  xlab("Game Timein Minutes")

ggplot(season_pbp, aes((game_time_sec/60), score_team_diff)) +
  ggtitle("WVU Men's Basketball 2017 Score Margin by Game") +
  geom_vline(xintercept = 20) +
  geom_vline(xintercept = 40) +
  geom_line(color = "blue") +
  geom_hline(yintercept = 0, color = "gray") +
  facet_wrap(~ game_title, scales = "free_x") +
  theme_bw() +
  ylab("Score Margin") +
  xlab("Game Time in Minutes")
