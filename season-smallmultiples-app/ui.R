shinyUI(fluidPage(
  
  titlePanel(a(href="http://www.espn.com/mens-college-basketball/team/schedule/_/id/277", "WVU Men's Basketball Season 2017"), "WVU Men's Basketball Season 2017"),
  
  p("Data harvested from ESPN game play-by-play web pages, ",
    a(href="http://www.espn.com/mens-college-basketball/playbyplay?gameId=400916206", "an example play-by-play web page"), ".",
    "See this project's code on GitHub, ",
    a(href="https://github.com/tpasinet/mcb-season-smallmultiples","mcb-season-smallmultiples"), "."),
  
  fluidRow(
    tags$head(tags$style(".shiny-plot-output{height:100vh !important;}")),
    tabsetPanel(
      tabPanel("Scores",
               
               p("This is a small multiples display of every scoring play in every game of the season represented as a cumulative line for WVU in blue and their opponent in gray. The black, vertical lines represent the first and second period boundaries."),
               
               hr(),
               
               fluidRow(
                 
                 column(1,
                        p("")
                 ),
                 
                 column(11,
                        fluidRow(p("Fix Axes to the Same Scale"),
                                 column(2,
                                        checkboxInput("fix_score_axis_x", label = "Fix X Axis", value = FALSE)
                                 ),
                                 column(10,
                                        checkboxInput("fix_score_axis_y", label = "Fix Y Axis", value = FALSE)
                                 )
                        )
                 )
               ),
               
               hr(),
               
               plotOutput("scoresPlot")),
      
      tabPanel("Margin",
               
               p("This is a small multiples display of points margin after every scoring play in every game of the season represented as a line for WVU. The gray line at the zero mark on the y axis provides reference. The black, vertical lines represent the first and second period boundaries."),
               
               hr(),
               
               fluidRow(
                 
                 column(1,
                        p("")
                 ),
                 
                 column(11,
                        fluidRow(p("Fix Axes to the Same Scale"),
                                 column(2,
                                        checkboxInput("fix_margin_axis_x", label = "Fix X Axis", value = FALSE)
                                 ),
                                 column(10,
                                        checkboxInput("fix_margin_axis_y", label = "Fix Y Axis", value = TRUE)
                                 )
                        )
                 )
               ),
               
               hr(),
               
               plotOutput("marginPlot"))
      )
    )
))