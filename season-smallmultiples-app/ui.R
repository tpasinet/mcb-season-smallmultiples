shinyUI(fluidPage(
  
  titlePanel(a(href="http://www.espn.com/mens-college-basketball/team/schedule/_/id/277", "WVU Men's Basketball Season 2017")),
  
  p("Data harvested from ESPN game play-by-play web pages, ",
    a(href="http://www.espn.com/mens-college-basketball/playbyplay?gameId=400916206", "an example play-by-play web page"), ".",
    "See this project's code on GitHub, ",
    a(href="https://github.com/tpasinet/mcb-season-smallmultiples","mcb-season-smallmultiples"), "."),
  
  fluidRow(
    tags$head(tags$style(".shiny-plot-output{height:100vh !important;}")),
    tabsetPanel(
      tabPanel("Scores",
               fluidRow(
                 
                 column(1,
                        p("")
                 ),
                 
                 column(11,
                        fluidRow(h4("Fix Axes to the Same Scale"),
                                 column(2,
                                        checkboxInput("fix_score_axis_x", label = "Fix X Axis", value = FALSE)
                                 ),
                                 column(10,
                                        checkboxInput("fix_score_axis_y", label = "Fix Y Axis", value = FALSE)
                                 )
                        )
                 )
               ),
               plotOutput("scoresPlot")),
      
      tabPanel("Margin",
               fluidRow(
                 
                 column(1,
                        p("")
                 ),
                 
                 column(11,
                        fluidRow(h4("Fix Axes to the Same Scale"),
                                 column(2,
                                        checkboxInput("fix_margin_axis_x", label = "Fix X Axis", value = FALSE)
                                 ),
                                 column(10,
                                        checkboxInput("fix_margin_axis_y", label = "Fix Y Axis", value = TRUE)
                                 )
                        )
                 )
               ),plotOutput("marginPlot"))
      )
    )
))