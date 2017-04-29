#### How to get the shapefile we use for the map.
## Packages required
library(rgdal)
library(rgeos)
## Create a foler
if (!dir.exists("raw")) dir.create("raw")
## You can download the data on http://www.gadm.org/version2
## You may use R, note that this will take a while...
download.file('http://biogeo.ucdavis.edu/data/gadm2.8/gadm28.gdb.zip',
destfile="raw/gadm28.shp.zip")
## unzip
unzip("raw/gadm28.shp.zip", exdir="raw/")
## Importing the shapelfile downloaded (large file, so it takes a while)
world <- readOGR(dsn="raw", layer="gadm28")
## Simplify
wsimp <- gSimplify(world, tol=.06, topologyPreserve=T) %>% SpatialPolygonsDataFrame(data=world@data)
## writing the new shapefile (see ogrDrivers() for the name of the drivers)
## as ESRI Shapefile
writeOGR(wsimp, dsn="data/", layer="worldsimple", driver="ESRI Shapefile")
## as GeoJSON
writeOGR(wsimp, dsn="worldsimple_geojson", layer="world", driver="GeoJSON")


# world <- readOGR(dsn="../../Dropbox/LetiR/countries_shp", layer="countries")
