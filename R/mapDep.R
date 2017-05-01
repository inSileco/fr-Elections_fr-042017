library(sp)
library(mapview)
library(htmlwidgets)

### Candidates names and colors
cols <- c("#a41515", "#131413", "#464a4c", "#008abf", "#73bddd", "#f49ec4", "#ce9e76",
    "#84726e", "#ffd670", "#e12625", "#fb6e52", "#ffffff", "#3c3c3c", "#000000")

noms <- c("ARTHAUD", "ASSELINEAU", "CHEMINADE", "DUPONTAIGNAN", "FILLON", "HAMON",
    "LASSALLE", "LEPEN", "MACRON", "MELENCHON", "POUTOU", "BLANCS", "NULS", "ABSTENTION")

graph <- c("Arthaud", "Asselineau", "Cheminade", "Dupont-Aignan", "Fillon", "Hamon",
    "Lassalle", "Le Pen", "Macron", "Mélenchon", "Poutou", "Blanc", "Nul", "Abstention")

noms <- tolower(noms)
color <- data.frame(noms, cols, graph)


### Import votes
votes <- readRDS("data/votes_tour1_departement.rds")
### Summary by candidates
x <- apply(votes[, -c(1, 2, 3, 5, 8)], 2, sum)
x <- data.frame(noms = names(x), votes = x, row.names = NULL)
x <- merge(x, color, by = "noms", all = TRUE)
x <- x[order(x[, "votes"], decreasing = FALSE), ]

### Leaflet via mapview
mypop <- paste0("<image src='./fig/graph-", shp@data[, "HASC_2"], ".png' width=750 height=400>")

map_dep <- mapView(shp, color = as.character(shp@data$color), alpha = 0, label = as.character(shp@data[,
    "NAME_2"]), legend = FALSE, col.regions = "white", alpha.regions = 1, popup = mypop)

cat("\n---- SAVING MAP DEP ----\n")
mapshot(map_dep, url = paste0(getwd(), "/docs/resFR.html"))
# saveWidget(widget = map_dep, file = 'docs/resFR.html')

file:///fig/graph-FR.YO.png
