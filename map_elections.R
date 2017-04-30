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
df_score <- read.csv2("data/Tour_1_Resultats_par_pays_240417.csv",stringsAsFactors=FALSE)

for (i in c(2:13)) {
  # Merging Jerusalem and Israel
  df_score[71,i] <- df_score[71,i] + df_score[74,i]
  # Merging Serbia and Kosovo
  df_score[121,i] <- df_score[121,i] + df_score[78,i]
}
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
iso3cm <- iso3c <- read.csv("./data/iso3-fr.csv", header=FALSE, stringsAsFactors=F)
iso3cm$V5[c(40, 51, 58, 62, 105, 106, 117, 120, 125, 142, 182, 211, 230, 240)] <- c(
  "CENTRAFRICAINE (RÉPUBLIQUE)", "CONGO", "TCHÈQUE (RÉPUBLIQUE)", "DOMINICAINE (RÉPUBLIQUE)",
  "IRAN", "IRAK", "CORÉE DU SUD", "LAOS", "LIBYE", "MOLDAVIE", "RUSSIE",
  "SYRIE", "TANZANIE", "SERBIE")
## SERBIE SYRIE TCHEQ EQUATEUR
df_score$ISO3 <- ""
for(r in 1:nrow(df_score)){
  df_score$ISO3[r] <- as.character(iso3c[stringdist::amatch(df_score$Pays[r],
    toupper(iso3cm$V5), maxDist=20), 'V4'])
}
## Seems like there is an issue with Serbia
df_score$ISO3[df_score$ISO3=="SCG"] <- "SRB"

## checks
# length(unique(df_score$ISO3))
# table(df_score$ISO3)
# df_score[c('ISO3','Pays')]
# wrld_adm@data
wrld_df <- data.frame(
  ISO3 = as.character(wrld_adm@data$ISO3),
  Pays = as.character(wrld_adm@data$FRENCH),
  stringsAsFactors = FALSE
  )
tmp <- merge(x =wrld_df, y = df_score, by = "ISO3",
  all = TRUE, sort=TRUE)
rownames(tmp) <- NULL
tmp <- tmp[rank(wrld_df$ISO3),]
tmp[is.na(tmp)] <- 0
wrld_adm@data <- tmp
## Remove France
idf <- which(wrld_adm@data$ISO3=="FRA")
wrld_adm <- wrld_adm[-idf,]

## LABELS
cat("\n---- CREATING LABELS ----\n")
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

## COLORS (only 4 winners...)
vec_col <- c("white", "#232f70", "#232f70", "#01b2fb",  "#97c121", "#c9462c", "#c9462c",
  "#232f70", "#c9462c", "#c9462c", "#232f70", "#c9a00e")
ls_col <- vec_col[vec_pos+1] %>% as.list

## I decided to remove France (makes clearer that we do not include it and we
## we can see Monaco!)

##  Creating the Map using leaflet;
cat("\n---- CREATING THE MAP ----\n")
map_elec <- leaflet(wrld_adm) %>%
  setView(lng = 5, lat = 10, zoom = 3) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addPolygons(
    weight = 1,
    opacity = 1,
    color = ls_col,
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 1,
      color = "#ffffff",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = ls_labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px", direction = "auto")) %>% addProviderTiles("Esri.WorldImagery")


##
cat("\n---- SAVING THE MAP ----\n")
saveWidget(widget = map_elec, file = "index.html")
