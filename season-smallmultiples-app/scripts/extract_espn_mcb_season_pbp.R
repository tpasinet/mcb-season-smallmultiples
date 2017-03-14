# Load libraries
library(rvest)
library(stringr)
library(dplyr)
library(lubridate)

# Define constants
# Take me home...
team_id <- "277"
season_year <- "2017"

# Define functins
extract_season_schedule <- function(team_id, season_year) {
  schedule_base_url <- "http://www.espn.com/mens-college-basketball/team/schedule/_/id/"
  
  season_schedule <- read_html(paste(schedule_base_url, team_id, "/year/",season_year, sep = "")) %>%
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
    mutate(season_year = season_year) %>%
    mutate(game_id = game_ids) %>%
    mutate(game_index = row_number())
  
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
    mutate(play_score_change = score_changes) %>%
    mutate(play_period_index = row_number())
  
  quarter_pbp_table
}

# Get the team's season schedule
season_schedule_extracted <- extract_season_schedule(team_id, season_year) %>%
  mutate(extract_timestamp = Sys.time())

# Get the team's season's plays
season_pbp_extracted <- lapply(season_schedule_extracted$game_id, extract_game_pbp) %>%
  bind_rows() %>%
  mutate(extract_timestamp = Sys.time())

save(season_schedule_extracted, season_pbp_extracted, file="./data/season_data_extracted.RData")