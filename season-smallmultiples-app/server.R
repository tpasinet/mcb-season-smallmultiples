# Load libraries
library(shiny)
library(ggplot2)

load(file ="data/season_pbp.Rda")

fix_axes <- function(fix_axis_x, fix_axis_y) {
  
  if(fix_axis_x == FALSE & fix_axis_y == FALSE){
    "free"
  } else if(fix_axis_x == TRUE & fix_axis_y == TRUE){
    "fixed"
  } else if(fix_axis_x == TRUE & fix_axis_y == FALSE){
    "free_y"
  } else if(fix_axis_x == FALSE & fix_axis_y == TRUE){
    "free_x"
  } else {
    "error"
  }
  
}

shinyServer(function(input, output) {
   
  output$scoresPlot <- renderPlot({
    
    axes_fixed <- fix_axes(input$fix_score_axis_x, input$fix_score_axis_y)
    
    ggplot(season_pbp, aes(game_time_min, score_team_cumm)) +
      geom_line(color = "blue") +
      geom_line(aes(y = score_opponent_cumm), color = "gray") +
      geom_vline(xintercept = 20) +
      geom_vline(xintercept = 40) +
      facet_wrap(~ game_title_score, scales = axes_fixed) +
      theme_bw() +
      ylab("Cumulative Points") +
      xlab("Game Time in Minutes")
    
  })
  
  output$marginPlot <- renderPlot({
    
    axes_fixed <- fix_axes(input$fix_margin_axis_x, input$fix_margin_axis_y)
    
    ggplot(season_pbp, aes(game_time_min, score_team_diff)) +
      geom_line(color = "blue") +
      geom_hline(yintercept = 0, color = "gray") +
      geom_vline(xintercept = 20) +
      geom_vline(xintercept = 40) +
      facet_wrap(~ game_title_margin, scales = axes_fixed) +
      theme_bw() +
      ylab("Score Margin") +
      xlab("Game Time in Minutes")
    
  })
  
})