##########################################
# GeoIndustrial Clusters London
# Clementine Cottineau 
# UCL - CASA - UDL
# 5 July 2017
##########################################

require(sp)
require(rgdal)
require(leaflet)
require(rgeos)
require(raster)
require(maptools)
require(RColorBrewer)

#############################
######  Import and pre-process Data
##############################

ukgrid = "+init=epsg:27700"
latlong = "+init=epsg:4326"


for (p in 90:99){
  cluster = readOGR(dsn = paste0("clusters/Clusters_p",p,".shp"), layer = paste0("Clusters_p",p))
  evol = read.csv(paste0("data/evol_Clusters_p", p, "_sup10.csv"), sep=",", dec=".")
  colnames(evol) = paste0("e_", colnames(evol))
  migration = read.csv(paste0("data/distMigToClusters", p, "_sup10.csv"), sep=",", dec=".")
  lastrow = dim(migration)[1] - 1
  migration = migration[1:lastrow,]
  colnames(migration) = paste0("m_", colnames(migration))
  d = cbind(evol, migration)
  cluster@data = data.frame(cluster@data, d[match(cluster@data$squareID, d$e_clusters),])
  cluster <- spTransform(cluster,CRS("+init=epsg:4326"))
  centroids=gCentroid(cluster,byid=TRUE)
  cluster@data$lat = centroids@coords[,"y"]
  cluster@data$long = centroids@coords[,"x"]
  assign(paste0("clusters_p", p), cluster)
}


mapClusters = function(cluster, QualToMap, QuantToMap, circles, sizeParam){
  cluster@data$WhatToMap_qual = cluster@data[, QualToMap]
  cluster@data$WhatToMap_quant = cluster@data[, QuantToMap]
  
  if(QualToMap == "squareID"){
    n = length(cluster@data$squareID)
    cluster@data$squareIDcolor = sample(cluster@data$squareID, n, replace=FALSE) 
     factpal <- colorFactor(rainbow(n), cluster@data$squareIDcolor)
    leaflet(data = cluster) %>% addProviderTiles("CartoDB.Positron") %>%
      clearShapes() %>% 
      setView(lng = -0.1, lat = 51.5,zoom = 10) %>%
      addPolygons(stroke = F,
                  smoothFactor = 0,
                  fillColor=~factpal(squareIDcolor) , 
                  fillOpacity = 0.5,
                  layerId = ~squareID)
  } else {
  cluster@data$VarToCut = as.numeric(cluster@data$WhatToMap_qual)
  ColorRamp = "Reds"
  Breaks = c(0, 1, 2, 4, 6, 10, 20)
  t = gsub(QualToMap,pattern = "_", replacement = " ")
  vPal6 <- brewer.pal(n = 6, name = ColorRamp)
  
  cluster@data$WhatToMap_qual <-
    as.character(
      cut(
        cluster@data$VarToCut,
        breaks = Breaks,
        labels = vPal6,
        include.lowest = TRUE,
        right = FALSE
      )
    )
  vLegendBox <-
    as.character(levels(
      cut(
        cluster@data$VarToCut,
        breaks = Breaks,
        include.lowest = TRUE,
        right = FALSE
      )
    ))
  
  cluster@data$WhatToMap_qual = ifelse(is.na(cluster@data$WhatToMap_qual), "white", cluster@data$WhatToMap_qual)
  
if(circles == T){
  leaflet(cluster) %>% addProviderTiles("CartoDB.Positron") %>%
    clearShapes() %>% setView(lng = -0.1, lat = 51.5,zoom = 10) %>%
    addPolygons(stroke = F,
      smoothFactor = 0,
      fillColor = ~WhatToMap_qual,
      fillOpacity = 0.5,
      layerId = ~squareID,
      popup = ~VarToCut,
      options = popupOptions(maxWidth = 100)
      ) %>%
     addCircleMarkers(~long, ~lat, radius = ~sqrt(WhatToMap_quant)/sizeParam) %>%
    addLegend("bottomright",
      colors = vPal6,
      labels = vLegendBox,
      title = t)
} else {
    leaflet(cluster) %>% addProviderTiles("CartoDB.Positron") %>%
      clearShapes() %>% setView(lng = -0.1, lat = 51.5,zoom = 10) %>%
      addPolygons(stroke = F,
                  smoothFactor = 0,
                  fillColor = ~WhatToMap_qual,
                  fillOpacity = 0.5,
                  layerId = ~squareID,
                  popup = ~VarToCut,
                  options = popupOptions(maxWidth = 100)
      ) %>%
       addLegend("bottomright",
                colors = vPal6,
                labels = vLegendBox,
                title = t)
}
  }
}


##############################
######  Outputs functions
##############################

shinyServer(function(input, output, session) {
  
  
  
  ##############################
  ######  Reactive functions
  ##############################
  
  
  clusterMap <- reactive({
    p = input$p
  cluster = get(paste0("clusters_p", p))
    return(cluster)
      })
 
   
  ##############################
  ######  Outputs 
  ##############################
  
  output$map = renderLeaflet({
    cluster_map = clusterMap()
    selected_year = input$year
    selected_qual_variable = input$qualvariable
    selected_quant_variable = input$quantvariable
    circles = input$circles
    if(selected_qual_variable == "squareID"){
      qual_var_to_map = selected_qual_variable
    } else {
      qual_var_to_map = paste0(selected_qual_variable, "_", selected_year)
      }
    quant_var_to_map = paste0(selected_quant_variable, "_", selected_year)
    param = input$normalisation
    mapClusters(cluster = cluster_map, QualToMap = qual_var_to_map, QuantToMap = quant_var_to_map, 
                circles = circles, sizeParam = param)
  })
  
})
    