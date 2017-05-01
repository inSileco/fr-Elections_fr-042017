cat("\n---- START map_election ----\n")
# Packages required
library(magrittr)
library(htmlwidgets)
library(htmltools)
library(leaflet)
library(rgdal)

## 
wrld_adm <- readRDS("data/worldsimpleready.Rds")

## Remove France
idf <- which(wrld_adm@data$ISO3 == "FRA")
coo <- coordinates(wrld_adm)[idf, ] - c(0, 1)
wrld_adm <- wrld_adm[-idf, ]

## LABELS
cat("\n---- CREATING LABELS ----\n")
nbc <- nrow(wrld_adm@data)
ls_labels <- rep("", nbc)
vec_pos <- rep(0, nbc)
for (i in 1:nbc) {
    tot <- wrld_adm@data$voteTot[i]
    ls_labels[i] %<>% paste0("<strong>", wrld_adm@data$Pays.x[i], "</strong><br/><hr>")
    if (tot) {
        rk <- rank(tot - wrld_adm@data[i, 5:15], ties.method = "min")
        rk2 <- rank(tot - wrld_adm@data[i, 5:15], ties.method = "random")
        vec_pos[i] <- which(rk2 == 1)
        ls_labels[i] %<>% paste0("Nombre de votes : ", tot)
        for (j in 1:11) {
            id <- which(rk2 == j)
            vot <- wrld_adm@data[i, id + 4]
            pct <- round(100 * vot/wrld_adm@data$voteTot[i], 2)
            ls_labels[i] %<>% paste0("<br><strong>", j, ".</strong> ", names(wrld_adm@data)[id + 
                4], " : ", vot, " soit ", pct, "%")
        }
    }
}
ls_labels %<>% lapply(htmltools::HTML)

## COLORS (only 4 winners...)
vec_col <- c("white", "#232f70", "#232f70", "#01b2fb", "#97c121", "#c9462c", "#c9462c", 
    "#232f70", "#c9462c", "#c9462c", "#232f70", "#c9a00e")
ls_col <- vec_col[vec_pos + 1] %>% as.list

txt <- "<a href='resFR.html'> Résultat pour la France </a>"

## Creating the Map using leaflet;
cat("\n---- CREATING THE MAP ----\n")
map_elec <- leaflet(wrld_adm) %>% setView(lng = 5, lat = 10, zoom = 3) %>% addTiles() %>% 
    addPolygons(weight = 2, opacity = 1, color = ls_col, dashArray = "3", fillOpacity = 0.7, 
        highlight = highlightOptions(weight = 3, color = "#666", dashArray = "", 
            fillOpacity = 0.7, bringToFront = TRUE), label = ls_labels, labelOptions = labelOptions(style = list(`font-weight` = "normal", 
            padding = "3px 8px"), textsize = "15px", direction = "auto")) %>% addMarkers(coo[1], 
    coo[2], popup = txt, label = "France") %>% addEasyButton(easyButton(icon = "fa-github-square fa-2x", 
    title = "View source code", onClick = JS("function(btn){window.location.href = 'https://github.com/letiR/Elections_fr-042017';}"), 
    position = "topright")) %>% addProviderTiles(providers$Esri.WorldImagery)


## 
cat("\n---- SAVING THE MAP ----\n")
saveWidget(widget = map_elec, file = "index.html")
