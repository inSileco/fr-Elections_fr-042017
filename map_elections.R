library(htmlwidgets)
library(leaflet)

getwd()

map_elec <- leaflet() %>%
  setView(lng = 5, lat = 10, zoom = 3) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addProviderTiles(providers$Stamen.Toner)

saveWidget(widget = map_elec, file = "index.html")
