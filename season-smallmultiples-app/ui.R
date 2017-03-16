# R Shiny UI script for the Season Small Multiples Project.
# This script defines the use interface layout and behavior of the Shiny app.

shinyUI(fluidPage(
  # Define the title panel including a link to WVU's 2017 schedule on ESPN.com .
  titlePanel(
    a(href = "http://www.espn.com/mens-college-basketball/team/schedule/_/id/277/year/2017", "WVU Men's Basketball Season 2017"),
    "WVU Men's Basketball Season 2017"
  ),
  
  # Describe the application.
  p(
    "Extending the intent of ESPN's ", a(href = "http://www.espn.com/mens-college-basketball/game?gameId=400916206", "Game Flow"), " graphs this display presents macro and micro patterns of game flow across an entire season using a",
    a(href = "https://en.wikipedia.org/wiki/Small_multiple", "small multiples"),
    " technique. Data was harvested from ESPN game play-by-play web pages, ",
    a(href = "http://www.espn.com/mens-college-basketball/playbyplay?gameId=400916206", "an example play-by-play web page"),
    ".",
    "See this project's code on GitHub, ",
    a(href = "https://github.com/tpasinet/mcb-season-smallmultiples", "mcb-season-smallmultiples"),
    "."
  ),
  
  # Define the section of the display containing the plots and controls.
  fluidRow(
    # Force the graphs to use the full height of the page.
    tags$head(tags$style(
      ".shiny-plot-output{height:100vh !important;}"
    )),
    
    # Set the size of the control boxes.
    tags$head(tags$style(".controlRow{height:30px;}")),
    
    # Set the font size of the load messages.
    tags$head(tags$style(".loadMessage{font-size: 200%;}")),
    
    # Define a tabbed panel containing the graphs and their controls.
    tabsetPanel(
      # Define the tab panel containing the cumulative score plots.
      tabPanel(
        "Cumulative Scores",
        
        # Describe the cumulative score plot.
        p(
          "Each graph represents one game in WVU's 2017 season. The lines plot the cumulative score for each team over the course of the game, WVU as blue and their opponent as gray.
          The black, vertical lines represent the first and second period boundaries. Zoom in and out by pressing the Ctrl key and the + or - key. Reset the zoom by pressing the Ctrl key and the 0 key."
        ),
        
        # Define a horizontal line to offset the control section
        hr(),
        
        # Define the control box.
        fluidRow(class = "controlRow",
                 
                 # Define column for spacing with an empty element.
                 column(1,
                        p("")),
                 
                 # Define column containing controls for fixing axes
                 column(11,
                        
                        # Define row containing the controls.
                        fluidRow(
                          p("Fix Axes to the Same Range"),
                          
                          # Define the checkbox for fixing the x axes.
                          column(
                            2,
                            checkboxInput("fix_score_axis_x", label = "Fix X Axes to the Same Range", value = FALSE)
                          ),
                          
                          # Define the checkbox for fixing the y axes.
                          column(
                            10,
                            checkboxInput("fix_score_axis_y", label = "Fix Y Axes to the Same Range", value = FALSE)
                          )
                        ))),
        
        # Display an informative message to the user while the plots are being generated.
        conditionalPanel(
          condition = "$('html').hasClass('shiny-busy')",
          tags$div(class = "loadMessage",
                   "Generating Plots...")
        ),
        
        # Define the plot output for the cumulative score plots. This is where the graphs display.
        plotOutput("scoresPlot")
        
        ),
      
      # Define the tab panel containing the points margin plots.
      tabPanel(
        "Points Margin",
        
        # Describe the cumulative score plot.
        p(
          "Each graph represents one game in WVU's 2017 season. The lines plot the points margin for WVU over the course of the game.
          The black, vertical lines represent the first and second period boundaries. Zoom in and out by pressing the Ctrl key and the + or - key. Reset the zoom by pressing the Ctrl key and the 0 key."
        ),
        
        # Define a horizontal line to offset the control section
        hr(),
        
        # Define the control box.
        fluidRow(class = "controlRow",
                 
                 # Define column for spacing with an empty element.
                 column(1,
                        p("")),
                 
                 # Define column containing controls for fixing axes
                 column(11,
                        
                        # Define row containing the controls.
                        fluidRow(
                          p("Fix Axes to the Same Scale"),
                          
                          # Define the checkbox for fixing the x axes.
                          column(
                            2,
                            checkboxInput("fix_margin_axis_x", label = "Fix X Axes to the Same Scale", value = FALSE)
                          ),
                          
                          # Define the checkbox for fixing the y axes.
                          column(
                            10,
                            checkboxInput("fix_margin_axis_y", label = "Fix Y Axes to the Same Scale", value = TRUE)
                          )
                        ))),
        
        # Display an informative message to the user while the plots are being generated.
        conditionalPanel(
          condition = "$('html').hasClass('shiny-busy')",
          tags$div(class = "loadMessage",
                   "Generating Plots...")
        ),
        
        # Define the plot output for the cumulative score plots. This is where the graphs display.
        plotOutput("marginPlot")
        
        )
    )
  )
))