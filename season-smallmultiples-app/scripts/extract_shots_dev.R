# Development space for harvesting shot data
# This script will be incorporated into the extract script when complete.
# For a given game, extract the game's shot data from the game's summary web page.

# Load libraries
library(rvest)
library(dplyr)

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
    as.data.frame()

    game_shot_table
}