cat("\n---- START formatData ----\n")
library(magrittr)
library(rgdal)
library(stringdist)

# Importing the results
df_score <- read.csv2("data/Tour_1_Resultats_par_pays_240417.csv", stringsAsFactors = FALSE)

for (i in c(2:13)) {
    # Merging Jerusalem and Israel
    df_score[71, i] <- df_score[71, i] + df_score[74, i]
    # Merging Serbia and Kosovo
    df_score[121, i] <- df_score[121, i] + df_score[78, i]
}
df_score <- df_score[-c(74, 78), ]

# extract votes and rename candiates (better to use votes and calcule %
# afterwards)
df_score <- df_score[, c(1:13)]
names(df_score)[2:ncol(df_score)] <- c("voteTot", "M. Nicolas DUPONT-AIGNAN", "Mme. Marine LE PEN", 
    "M. Emmanuel MACRON", "M. Benoît HAMON", "Mme. Nathalie ARTHAUD", "M. Philippe POUTOU", 
    "M. Jacques CHEMINADE", "M. Jean LASSALLE", "M. Jean Luc MÉLENCHON", "M. François ASSELINEAU", 
    "M. François FILLON")


# Importing the shapefile
wrld_adm <- readOGR(dsn = "data", layer = "worldsimple")

## RENAME some countries to ease the match...
iso3cm <- iso3c <- read.csv("./data/iso3-fr.csv", header = FALSE, stringsAsFactors = F)
iso3cm$V5[c(40, 51, 58, 62, 105, 106, 117, 120, 125, 142, 182, 211, 230, 240)] <- c("CENTRAFRICAINE (RÉPUBLIQUE)", 
    "CONGO", "TCHÈQUE (RÉPUBLIQUE)", "DOMINICAINE (RÉPUBLIQUE)", "IRAN", "IRAK", 
    "CORÉE DU SUD", "LAOS", "LIBYE", "MOLDAVIE", "RUSSIE", "SYRIE", "TANZANIE", 
    "SERBIE")
## SERBIE SYRIE TCHEQ EQUATEUR
df_score$ISO3 <- ""
for (r in 1:nrow(df_score)) {
    df_score$ISO3[r] <- as.character(iso3c[stringdist::amatch(df_score$Pays[r], toupper(iso3cm$V5), 
        maxDist = 20), "V4"])
}
## Seems like there is an issue with Serbia; manual fix.
df_score$ISO3[df_score$ISO3 == "SCG"] <- "SRB"

## checks length(unique(df_score$ISO3)) table(df_score$ISO3)
## df_score[c('ISO3','Pays')]
wrld_df <- data.frame(ISO3 = as.character(wrld_adm@data$ISO3), Pays = as.character(wrld_adm@data$FRENCH), 
    stringsAsFactors = FALSE)
tmp <- merge(x = wrld_df, y = df_score, by = "ISO3", all = TRUE, sort = TRUE)
rownames(tmp) <- NULL
tmp <- tmp[rank(wrld_df$ISO3), ]
tmp[is.na(tmp)] <- 0
wrld_adm@data <- tmp


## writing the R object (easy to use afterwards)
cat("\n---- WRITING RDS ----\n\n")
saveRDS(wrld_adm, file = "data/worldsimpleready.Rds")
