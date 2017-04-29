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
df_score <- df_score[-c(74,78),]

# extract % and rename candiates
df_score <- df_score[,c(1:2,14:ncol(df_score))]
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

# Convert % to numeric columns
# KC: I wonder if we should rather use the number of votes... we can easily get the % and
# we would be able to show the raw number of votes as you did on the first map
df_score[, 3:ncol(df_score)] <- apply(df_score[, 3:ncol(df_score)], 1, gsub,pattern="%",replacement="")
df_score[, 3:ncol(df_score)] <- apply(df_score[, 3:ncol(df_score)], 1, gsub,pattern=",",replacement=".")
df_score[, 3:ncol(df_score)] <- apply(df_score[, 3:ncol(df_score)], 1, as.numeric)


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
tmp <- merge(x =wrld_df, y = df_score[c('ISO3', 'voteTot')], by = "ISO3",
  all = TRUE, sort=TRUE)
tmp <- tmp[rank(wrld_df$ISO3),]
tmp$voteTot[is.na(tmp$voteTot)] <- 0
##
wrld_adm@data <- tmp
ls_labels <- sprintf(
  "<strong>%s</strong><br/><hr> Nombre de votes: %d",
  as.character(wrld_adm@data$ISO3), wrld_adm@data$voteTot) %>% lapply(htmltools::HTML)

## Colors
dfcol <- data.frame(
    candidat = c("jlm", "lepen", "macron", "hamon", "fillon"), # "#23408f" bleu Fillon
    couleur = c("#c9462c", "#232f70", "#bbbbbb", "#97c121", "#000000")
)

cat("\n---- CREATING THE MAP ----\n")
##  Creating the Map using leaflet;
map_elec <- leaflet(wrld_adm) %>%
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
##
cat("\n---- SAVING THE MAP ----\n")
saveWidget(widget = map_elec, file = "./index.html")
