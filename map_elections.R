library(htmlwidgets)
library(htmltools)
library(leaflet)

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
map_elec <- leaflet(wrld_adm) %>%
  setView(lng = 5, lat = 10, zoom = 3) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addPolygons(
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
      ) %>% addProviderTiles(providers$Stamen.Toner)

saveWidget(widget = map_elec, file = "index.html")
