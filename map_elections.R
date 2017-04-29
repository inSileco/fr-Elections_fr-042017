cat("\n---- START ----\n")
# Packages required
library(magrittr)
library(htmlwidgets)
library(htmltools)
library(leaflet)
library(countrycode)
library(rgdal)
library(stringdist)


# Importing the results
df_score <-read.csv2("data/Tour_1_Resultats_par_pays_240417.csv",stringsAsFactors=FALSE)

# I temporarly removed Kosovo as we do not have the boundaries... we could merge
# the resuts with Serbie's ones... it may be a political issue though...
# Same for Isrêl and Jerusalem
df_score <- df_score[-c(74,78), ]

# extract votes and rename candiates (better to use votes and calcule % afterwards)
df_score <- df_score[, c(1:13)]
names(df_score)[2:ncol(df_score)] <- c(
  "voteTot",
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




# Importing the shapefile
wrld_adm <- readOGR(dsn="data", layer="worldsimple")

## RENAME some countries to ease the match...
iso3c <- read.csv("./data/iso3-fr.csv", header=FALSE, stringsAsFactors=F)
iso3c$V5[c(51, 58, 105, 106, 117, 125, 142, 182, 230)] <- c("CONGO", "TCHÈQUE",
"IRAN", "IRAK", "CORÉE DU SUD", "LIBYE", "MOLDAVIE", "RUSSIE", "TANZANIE")
##
df_score$ISO3 <- ""
for(r in 1:nrow(df_score)){
  df_score$ISO3[r] <- as.character(iso3c[stringdist::amatch(df_score$Pays[r],
    toupper(iso3c$V5), maxDist=20), 'V4'])
}
##
# length(unique(df_score$ISO3))
# df_score[c('ISO3','Pays')]
# wrld_adm@data
wrld_df <- data.frame(
  ISO3 = as.character(wrld_adm@data$ISO3),
  Pays = as.character(wrld_adm@data$FRENCH),
  stringsAsFactors = FALSE
  )
tmp <- merge(x =wrld_df, y = df_score, by = "ISO3",
  all = TRUE, sort=TRUE)
tmp <- tmp[rank(wrld_df$ISO3),]
tmp[is.na(tmp)] <- 0
wrld_adm@data <- tmp


## LABELS
nbc <- nrow(wrld_adm@data)
ls_labels <- rep("", nbc)
vec_pos <- rep(0, nbc)
for (i in 1:nbc){
  tot <- wrld_adm@data$voteTot[i]
  ls_labels[i] %<>% paste0("<strong>", wrld_adm@data$Pays.x[i],
  "</strong><br/><hr>")
  if (tot) {
    rk <- rank(tot-wrld_adm@data[i, 5:15], ties.method = "min")
    rk2 <- rank(tot-wrld_adm@data[i, 5:15], ties.method = "random")
    vec_pos[i] <- which(rk2 == 1)
    ls_labels[i] %<>% paste0("Nombre de votes : ",  tot)
    print(rk2)
    for (j in 1:11){
      id <- which(rk2==j)
      vot <- wrld_adm@data[i, id+4]
      pct <- round(100*vot/wrld_adm@data$voteTot[i], 2)
      ls_labels[i] %<>% paste0(
         "<br><strong>", j, ".</strong> ", names(wrld_adm@data)[id+4],
         " : ", vot, " soit ", pct, "%"
        )
    }
  }
}

ls_labels %<>% lapply(htmltools::HTML)


## COLORS
vec_col <- c("white", "#232f70", "#232f70", "#01b2fb",  "#97c121", "#c9462c", "#c9462c",
  "#232f70", "#c9462c", "#c9462c", "#232f70", "#c9a00e")
ls_col <- vec_col[vec_pos+1] %>% as.list



cat("\n---- CREATING THE MAP ----\n")
##  Creating the Map using leaflet;
map_elec <- leaflet(wrld_adm) %>%
  setView(lng = 5, lat = 10, zoom = 3) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addPolygons(
    weight = 2,
    opacity = 1,
    color = ls_col,
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
      ) %>%
      # addLegend(pal = as.list(dfcol$couleur), values = as.list(dfcol$candidat), opacity = 0.7, title = "Vote des Français établis à l'étrander",
      # position = "bottomright") %>%
    addProviderTiles(providers$Esri.WorldImagery)
##
cat("\n---- SAVING THE MAP ----\n")
saveWidget(widget = map_elec, file = "./index.html")
