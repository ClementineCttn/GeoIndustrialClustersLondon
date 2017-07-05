##########################################
# Geoindustrial Cluster London
# Clementine Cottineau 
# UCL - CASA - UDL
# 5 July 2017
##########################################

library(shiny)
library(leaflet)

shinyUI(
  fluidPage(
    headerPanel(
      "GeoIndustrial clusters in London 2007-2016"
    ),
      column(4,  sliderInput("p","Proximity threshold",
        min = 90, max = 99, value = 98)),
    column(4,  checkboxInput("circles","Add Circles",value=F)),
    
    column(4,  sliderInput("year","Year",
        min = 2008, max = 2016, value = 2016, animate = T
    )),
     column(4,   selectInput(
      "qualvariable",
      "Colour Map by...",
      choices = c("cluster id" = "squareID",
                  "mean distance of in-movers" = "m_mean_dist_in",
                  "mean distance of out-movers" = "m_mean_dist_out",
                  "median distance of in-movers" = "m_med_dist_in",
                  "median distance of out-movers" = "m_med_dist_out"),
      selected = "m_mean_dist_in"
    )),
    column(4,  sliderInput("normalisation","Reduce circles size by...",
                           min = 1, max = 100, value = 1)),
    column(4,   selectInput(
      "quantvariable",
      "Size of circles by...",
      choices = c("number of establishments in cluster" = "e_n",
      "number of establishment births since past year" = "e_birth",
      "number of establishment deaths since past year" = "e_death",
      "number of establishments in cluster already present a year before" = "e_intra",
      "number of establishments which have moved in the cluster" = "e_n_in",
      "number of establishments which have moved out of the cluster" = "e_n_out"),
       selected = "e_n"
    )),
    leafletOutput('map')
    )
  )
    
    