cat("\n---- START formatDataDepartement ----\n")
library(xlsx)


### Import data
votes <- read.xlsx("data/elections_tour1_departement.xlsx", 1)
voix <- read.xlsx("data/elections_tour1_departement.xlsx", 2)

voix[, "nom"] <- tolower(gsub("-| ", "", voix[, "nom"]))
voix[, "nom"] <- tolower(gsub("é", "e", voix[, "nom"]))
candidats <- sort(unique(voix[, "nom"]))

for (i in 1:length(candidats)) {
    dat <- voix[which(voix[, "nom"] == candidats[i]), c("no_departement", "voix")]
    colnames(dat)[2] <- candidats[i]
    votes <- merge(votes, dat, by = "no_departement", all = TRUE)
}

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



## writing the R object (easy to use afterwards)
cat("\n---- WRITING RDS ----\n\n")
saveRDS(wrld_adm, file = "data/worldsimpleready.Rds")
