# Development space for harvesting shot data
# This script will be incorporated into the extract script when complete.
# For a given game, extract the game's shot data from the game's summary web page.

# Load libraries
library(rvest)
library(dplyr)
library(stringr)
library(ggplot2)

# Load the etracted data.
# load(file = "season-smallmultiples-app/data/season_data_extracted.RData")

game_id = "400916206"


extract_game_shots <- function(game_id) {
  
  # Set the base url for all game PBP web pages.
  game_summary_base_url <- "http://www.espn.com/mens-college-basketball/game?gameId="
  
  # Extract the PBP web page html.
  game_summary_page <- read_html(paste(game_summary_base_url, game_id, sep = ""))
  
  # Extract the quarters values from the divs for each quarter's PBP section. In this case, quarters 1 and 2 represent periods 1 and 2.
  # Any quarter over 2 is an overtime period.
  game_shots <- game_summary_page %>%
    html_nodes(xpath = "//div[@class = 'shot-chart']//ul[starts-with(@class, 'shots ')]//li") %>%
    html_attrs() %>%
    do.call("rbind", .) %>%
    as.data.frame(stringsAsFactors = FALSE)
  
  colnames(game_shots) <- str_replace(colnames(game_shots), "-", "_")
  
  game_shots <- game_shots %>%
    mutate(game_id = game_id) %>%
    mutate(team_shot_id = str_extract(id,"\\d+$")) %>%
    mutate(is_shot_made = (class == "made")) %>%
    mutate(is_shot_team_home = (data_homeaway == "home")) %>%
    mutate(shot_coordinate_x = str_extract(style, ";left:\\d+%;")) %>%
    mutate(shot_coordinate_x = str_extract(shot_coordinate_x, "\\d+")) %>%
    mutate(shot_coordinate_x = as.numeric(shot_coordinate_x)) %>%
    mutate(shot_coordinate_y = str_extract(style, ";top:\\d+%;")) %>%
    mutate(shot_coordinate_y = str_extract(shot_coordinate_y, "\\d+")) %>%
    mutate(shot_coordinate_y = as.numeric(shot_coordinate_y)) %>%
    mutate(shot_points = grepl(" three ",data_text, ignore.case = T)) %>%
    mutate(shot_points = ifelse(shot_points, 3, 2)) %>%
    rename(game_period = data_period, shot_player_id = data_shooter) %>%
    select(game_id, game_period, is_shot_team_home, team_shot_id, shot_player_id, shot_coordinate_x, shot_coordinate_y, shot_points, is_shot_made)
    
   game_shots
   
}

test <- extract_game_shots(game_id) %>%
  group_by(is_shot_team_home, shot_coordinate_x, shot_coordinate_y) %>%
  summarise(shot_points = sum(shot_points))

ggplot(test, aes(x = shot_coordinate_x, y = shot_coordinate_y, z = shot_points, color = is_shot_team_home)) +
  geom_density_2d(fill=)


















