# The R Shiny server file that defines the logic for the plots.

# Load libraries
library(shiny)
library(ggplot2)

# Load the transformed play-by-play data.
load(file ="data/season_pbp.Rda")

# Define a function that determines how to fix the axes of the facets from inputs provided by the user defined in the ui.R file
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

# The main Shiny server section.
shinyServer(function(input, output) {
  
  # Render the cumulative score plot.
  output$scoresPlot <- renderPlot({
    
    # Determine how to fix the axes of the facets.
    axes_fixed <- fix_axes(input$fix_score_axis_x, input$fix_score_axis_y)
    
    # Create the cumulative score plot.
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
  
  # Render the points margin plot.
  output$marginPlot <- renderPlot({
    
    # Determine how to fix the axes of the facets.
    axes_fixed <- fix_axes(input$fix_margin_axis_x, input$fix_margin_axis_y)
    
    # Create the points margin plot.
    ggplot(season_pbp, aes(game_time_min, score_team_diff)) +
      geom_line(color = "blue") +
      geom_hline(yintercept = 0, color = "gray") +
      geom_vline(xintercept = 20) +
      geom_vline(xintercept = 40) +
      facet_wrap(~ game_title_margin, scales = axes_fixed) +
      theme_bw() +
      ylab("Points Margin") +
      xlab("Game Time in Minutes")
  })
})