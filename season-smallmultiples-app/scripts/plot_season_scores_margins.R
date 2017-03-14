# Load libraries
library(ggvis)
library(ggplot2)
library(magrittr)

load(file ="./data/season_data_transformed.RData")

ggplot(season_pbp, aes(game_time_min, score_team_cumm)) +
  ggtitle("WVU Men's Basketball 2017 Cumulative Score by Game") +
  geom_line(color = "blue") +
  geom_line(aes(y = score_opponent_cumm), color = "gray") +
  geom_vline(xintercept = 20) +
  geom_vline(xintercept = 40) +
  facet_wrap(~ game_title_score, scales = "free") +
  theme(strip.text.x = element_text(size = 8)) +
  theme_bw() +
  ylab("Cumulative Points") +
  xlab("Game Timein Minutes")

ggplot(season_pbp, aes(game_time_min, score_team_diff)) +
  ggtitle("WVU Men's Basketball 2017 Score Margin by Game") +
  geom_line(color = "blue") +
  geom_hline(yintercept = 0, color = "gray") +
  geom_vline(xintercept = 20) +
  geom_vline(xintercept = 40) +
  facet_wrap(~ game_title_margin, scales = "free_x") +
  theme(strip.text.x = element_text(size = 8)) +
  theme_bw() +
  ylab("Score Margin") +
  xlab("Game Time in Minutes")
