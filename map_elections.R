library(htmlwidgets)
library(htmltools)
library(leaflet)
library(rgdal)
library(rgeos)

## This is what I used to make the dataset ready
# library(rgdal)
# library(rgeos)
# world <- readOGR(dsn="/Users/KevCaz/Documents/Data/Geodata/Pays_adm/countries_shp",
#   layer="countries")
# wsimp <- gSimplify(world, tol=.05, topologyPreserve=T) %>% SpatialPolygonsDataFrame(data=world@data)
# writeOGR(wsimp, dsn="/Users/KevCaz/Desktop/", layer="countries", driver=ogrDrivers()[13,1])
# writeOGR(wsimp, dsn="country_geojson", layer="world", driver="GeoJSON")

wrld_adm <- readOGR(dsn="data/countries", layer="countries")
# Candidats
df_score <- read.csv2("data/Tour_1_Resultats_par_pays_240417.csv",
encoding="Latin-1")
ls_labels <- sprintf(
  "<strong>%s</strong>",
  wrld_adm@data$ISO3) %>% lapply(htmltools::HTML)

# Map
map_elec <- leaflet(wrld_adm_gsimp) %>%
  setView(lng = 5, lat = 10, zoom = 3) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addPolygons(
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 3,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = ls_labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px", direction = "auto")
      ) %>% addProviderTiles(providers$Esri.WorldImagery,options = providerTileOptions(minZoom=10, maxZoom=18))

saveWidget(widget = map_elec, file = "./index.html")
