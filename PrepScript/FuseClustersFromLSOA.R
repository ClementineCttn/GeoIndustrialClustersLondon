library(rgdal)
library(rgeos)
library(maptools)
setwd("~/Documents/GeoIndustrialClustersLondon")

for (p in 90:99){
  print(p)
  LSOA_LDN = readOGR("data/LSOA_London.shp", layer = "LSOA_London", verbose = F)
  LSOA_LDN=spTransform(LSOA_LDN, CRS("+init=epsg:27700"))
  
  membership = read.csv(paste0("data/memb_cluster_p", p, ".txt"), sep =",", dec=".")
  LSOA_LDN@data = data.frame(LSOA_LDN@data, membership[match(LSOA_LDN@data$LSOA11CD, membership$id_point),])

  clusters <- unionSpatialPolygons(LSOA_LDN, LSOA_LDN@data$id_cluster)
  clustersData <- aggregate(LSOA_LDN@data[ , c("USUALRES", "HHOLDS")],
                           by = list(LSOA_LDN@data$id_cluster), FUN = sumNum)
  colnames(clustersData) <- c("squareID", "USUALRES", "HHOLDS")
  rownames(clustersData) <- clustersData[,1]
  spp <- SpatialPolygonsDataFrame(clusters,data=clustersData)
  writeOGR(spp, paste0("clusters/Clusters_p", p, ".shp"), layer = paste0("Clusters_p", p), driver="ESRI Shapefile")
  }
