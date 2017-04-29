library(htmlwidgets)
library(htmltools)
library(leaflet)
library(countrycode)
library(rgdal)


# Importing the dshapefile
wrld_adm <- readOGR(dsn="data", layer="worldsimple")

# Candidats
df_score <-read.csv2("data/Tour_1_Resultats_par_pays_240417.csv",stringsAsFactors=FALSE)

# extract % and rename candiates
df_score <- df_score[,c(1,14:ncol(df_score))]
names(df_score)[2:ncol(df_score)] <- c(
  "M. Nicolas DUPONT-AIGNAN",
  "Mme. Marine LE PEN",
  "M. Emmanuel MACRON",
  "M. Benoît HAMON",
  "Mme. Nathalie ARTHAUD",
  "M. Philippe POUTOU",
  "M. Jacques CHEMINADE",
  "M. Jean LASSALLE",
  "M. Jean Luc MÉLENCHON",
  "M. François ASSELINEAU",
  "M. François FILLON")

# Convert % to numeric columns
df_score[,2:ncol(df_score)] <- apply(df_score[,2:ncol(df_score)],1,gsub,pattern="%",replacement="")
df_score[,2:ncol(df_score)] <- apply(df_score[,2:ncol(df_score)],1,gsub,pattern=",",replacement=".")
df_score[,2:ncol(df_score)] <- apply(df_score[,2:ncol(df_score)],1,as.numeric)

# clean sp data.frame
wrld_adm@data <- data.frame(Pays=wrld_adm@data$FRENCH)

# merge with country base on iso3c
iso3c <- read.csv("./data/iso3-fr.csv",header=FALSE)
df_score$ISO3 <- ''
for(r in 1:nrow(df_score)){
  df_score$ISO3[r] <- as.character(iso3c[stringdist::amatch(df_score$Pays[r], iso3c$V4, maxDist=Inf),'V4'])
}

countrycode(tolower(df_score$Pays), 'country.name.fr','iso3c')

ls_labels <- sprintf(
  "<strong>%s</strong>",
  wrld_adm@data$ISO3) %>% lapply(htmltools::HTML)

  countries_sp <- wrld_adm@data$FAO


##  Creating the Map using leaflet;
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
      ) %>% addProviderTiles(providers$Esri.WorldImagery)

saveWidget(widget = map_elec, file = "./index.html")
