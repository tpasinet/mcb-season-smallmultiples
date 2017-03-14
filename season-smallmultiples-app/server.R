# Load libraries
library(shiny)
library(ggplot2)

load(file ="data/season_pbp.Rda")

shinyServer(function(input, output) {
   
  output$scoresPlot <- renderPlot({
    
    fix_score_scales <- if(input$fix_score_axis_x == FALSE & input$fix_score_axis_y == FALSE){
      "free"
    } else if(input$fix_score_axis_x == TRUE & input$fix_score_axis_y == TRUE){
      "fixed"
    } else if(input$fix_score_axis_x == TRUE & input$fix_score_axis_y == FALSE){
      "free_y"
    } else if(input$fix_score_axis_x == FALSE & input$fix_score_axis_y == TRUE){
      "free_x"
    } else {
      "error"
    }
    
    ggplot(season_pbp, aes(game_time_min, score_team_cumm)) +
      geom_line(color = "blue") +
      geom_line(aes(y = score_opponent_cumm), color = "gray") +
      geom_vline(xintercept = 20) +
      geom_vline(xintercept = 40) +
      facet_wrap(~ game_title_score, scales = fix_score_scales) +
      theme_bw() +
      ylab("Cumulative Points") +
      xlab("Game Timein Minutes")
    
  })
  
  output$marginPlot <- renderPlot({
    
    fix_margin_scales <- if(input$fix_margin_axis_x == FALSE & input$fix_margin_axis_y == FALSE){
      "free"
    } else if(input$fix_margin_axis_x == TRUE & input$fix_margin_axis_y == TRUE){
      "fixed"
    } else if(input$fix_margin_axis_x == TRUE & input$fix_margin_axis_y == FALSE){
      "free_y"
    } else if(input$fix_margin_axis_x == FALSE & input$fix_margin_axis_y == TRUE){
      "free_x"
    } else {
      "error"
    }
    
    ggplot(season_pbp, aes(game_time_min, score_team_diff)) +
      geom_line(color = "blue") +
      geom_hline(yintercept = 0, color = "gray") +
      geom_vline(xintercept = 20) +
      geom_vline(xintercept = 40) +
      facet_wrap(~ game_title_margin, scales = fix_margin_scales) +
      theme_bw() +
      ylab("Score Margin") +
      xlab("Game Time in Minutes")
    
  })
  
})