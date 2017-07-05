##########################################
# Project Land Use change in London
# Clementine Cottineau 
# UCL - CASA - UDL
# 1 November 2016
##########################################

library(shiny)
library(leaflet)



shinyUI(
  fluidPage(
    headerPanel(
      "GeoIndustrial clusters in London 2007-2016"
    ),
      column(6,  sliderInput("p","Proximity threshold",
        min = 90, max = 99, value = 98)),
    column(6,  sliderInput("year","Year",
        min = 2008, max = 2016, value = 2016, animate = T
    )),
    column(6,   selectInput(
      "qualvariable",
      "Colour Map by...",
      choices = c("cluster id" = "squareID",
                  "mean distance of in-movers" = "m_mean_dist_in",
                  "mean distance of out-movers" = "m_mean_dist_out",
                  "median distance of in-movers" = "m_med_dist_in",
                  "median distance of out-movers" = "m_med_dist_out"),
      selected = "squareID"
    )),
    column(6,   selectInput(
      "quantvariable",
      "Size of circles by...",
      choices = c("n", "birth", "death", "intra", "n in", "n out", "USUALRES"),
      selected = "n"
    )),
    leafletOutput('map')#,
    # selectInput(
    #   "table",
    #   "Table to print",
    #   choices = c("Absolute number of conversion"="N", 
    #               "Percentage in lines" = "LinePct",
    #               "Percentage in columns" = "ColPct"),
    #   selected = "N"
    # ),
    # h4("In line: previous land  use. In column: proposed use"),
    # dataTableOutput('transitions'),
    # # HTML(
    #   'For More:
    #   <a href=https://github.com/ClementineCttn/LandUseChangeLondon>https://github.com/ClementineCttn/LandUseChangeLondon</a>'
    # )
    # 
  )
  )
    
    