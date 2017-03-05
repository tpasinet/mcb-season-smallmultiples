library(rvest)
wvuSchedulePage <- read_html("http://www.espn.com/mens-college-basketball/team/schedule/_/id/277")
wvuScheduleTable <- wvuSchedulePage %>%
  html_nodes("table") %>%
  .[[1]] %>%
   html_table()