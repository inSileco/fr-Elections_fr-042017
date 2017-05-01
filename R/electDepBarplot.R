library(sp)
library(mapview)


if (!dir.exists("docs/fig")) dir.create("docs/fig", showWarnings = FALSE)

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


### Barplot total I change
png("docs/fig/elections-pays.pdf", width = 14, height = 8, res = 300)
par(mar = c(3, 6, 1, 1), family = "serif", xaxs = "i", yaxs = "i")
plot(0, type = "n", xlim = c(0, 11500000), ylim = c(1 - 0.5, nrow(x) + 0.5), axes = FALSE, 
    ann = FALSE)
rect(0, 0, 11500000, nrow(x) + 0.5, col = "#e7e7e7", border = "#e7e7e7")
abline(v = seq(1e+06, 11500000, by = 1e+06), col = "white", lty = 3)
for (i in 1:nrow(x)) {
    if (as.character(x[i, "noms"]) %in% c("abstention", "nuls", "blancs")) {
        rect(0, i - 0.33, x[i, "votes"], i + 0.33, col = "#252525", border = NA, 
            density = 10, angle = 45)
        texte <- gsub("\\.", ",", paste0(as.character(format(round(100 * x[i, "votes"]/sum(x[, 
            "votes"]), 2))), "%"))
    } else {
        rect(0, i - 0.33, x[i, "votes"], i + 0.33, col = as.character(x[i, "cols"]), 
            border = as.character(x[i, "cols"]))
        texte <- paste0(gsub("\\.", ",", paste0(as.character(format(round(100 * x[i, 
            "votes"]/sum(x[, "votes"]), 2))), "%")), " (", gsub("\\.", ",", paste0(as.character(format(round(100 * 
            x[i, "votes"]/sum(votes[, "exprimes"]), 2))), "%")), ")")
    }
    text(x[i, "votes"], i, texte, pos = 4, font = 2)
}
par(mgp = c(3, 0.25, 0))
options(scipen = 16)
axis(2, seq(1, nrow(x)), as.character(x[, "graph"]), las = 1, lwd = 0)
axis(1, seq(0, 11500000, by = 1e+06), seq(0, 11500000, by = 1e+06), lwd = 0)
rect(7750000, 0, 11500000, 2.25, col = "#e7e7e7", border = "#e7e7e7")
text(x = 7750000, y = 1.25, "ÉLECTION PRÉSIDENTIELLE FRANÇAISE 2017\nRÉSULTAT DU PREMIER TOUR", 
    pos = 4, cex = 1, font = 2)
mtext(side = 1, line = 1.75, "Nombre de voix obtenues", font = 2)
dev.off()



### Import France department shapefile
shp <- readRDS("data/FRA_adm2.rds")
dat <- data.frame(shp@data)
dat <- dat[, c("OBJECTID", "NAME_1", "NAME_2", "HASC_2")]
dat <- merge(dat, votes, by.x = "NAME_2", by.y = "departement", all.x = TRUE, all.y = FALSE)
dat <- dat[order(dat[, "OBJECTID"]), c(2, 3, 1, 4:ncol(dat))]
dat[, "first"] <- as.character(apply(dat[, 12:ncol(dat)], 1, function(x) names(x)[which(x == 
    max(x))]))
dat[, "color"] <- NA
for (i in 1:nrow(dat)) dat[i, "color"] <- as.character(x[which(x[, "noms"] == dat[i, 
    "first"]), "cols"])
shp@data <- dat


### Export popup barplots 1 per department
for (j in 1:length(shp)) {
    vals <- t(shp@data[j, 12:22])[, 1]
    dat <- data.frame(noms = names(vals), value = round(100 * vals/sum(vals), 2))
    dat <- merge(dat, color, by = "noms", all = TRUE)
    dat <- dat[which(!is.na(dat[, "value"])), ]
    dat <- dat[order(dat[, "value"], decreasing = FALSE), ]
    
    png(paste0("docs/fig/graph-", shp@data[j, "HASC_2"], ".png"), pointsize = 4, 
        width = 960, height = 520, res = 300)
    par(mar = c(2, 6, 1, 1), family = "serif", xaxs = "i", yaxs = "i")
    plot(0, type = "n", xlim = c(0, 40), ylim = c(0.5, 11.5), axes = FALSE, ann = FALSE)
    rect(0, 0, 40, 11.5, col = "#e7e7e7", border = "#e7e7e7")
    abline(v = seq(5, 35, by = 5), col = "white", lty = 3, lwd = 0.25)
    for (i in 1:length(vals)) {
        rect(0, i - 0.33, dat[i, "value"], i + 0.33, col = as.character(dat[i, "cols"]), 
            border = as.character(dat[i, "cols"]))
        texte <- gsub("\\.", ",", paste0(dat[i, "value"], "%"))
        text(dat[i, "value"], i, texte, pos = 4, font = 2)
    }
    par(mgp = c(3, 0.25, 0))
    options(scipen = 16)
    axis(2, seq(1, 11), as.character(dat[, "graph"]), las = 1, lwd = 0)
    axis(1, seq(0, 40, by = 5), seq(0, 40, by = 5), lwd = 0)
    rect(7750000, 0, 40, 2.25, col = "#e7e7e7", border = "#e7e7e7")
    text(x = 40, y = 1.25, labels = shp@data[j, "NAME_2"], pos = 2, cex = 1, font = 2)
    dev.off()
}
