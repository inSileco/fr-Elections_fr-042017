# Elections_fr-042017
Cartographie du vote des français de l'étranger - 1er Tour - 2017

Carye réalisée avec Leaflet (appelé via R, voir les packages utilisés ci-dessous et la [documentation](https://rstudio.github.io/leaflet/)).


# Disponibilités des données

- [Résultats du vote des Français résidant à l’étranger au premier tour de l’élection présidentielle 2017](
https://www.data.gouv.fr/fr/datasets/resultats-du-vote-des-francais-residant-a-letranger-au-premier-tour-de-lelection-presidentielle-2017/)

- Données pour les frontières administratives sont disponibles en ligne, sur le site de [GADM](http://www.gadm.org) par exemple. Nous avons simplement simplifié ces données pour les rendre plus légères (function `gSimplify()` du package R `rgeos`).


# Packages requis

```
library(htmlwidgets)
library(htmltools)
library(leaflet)
library(rgdal)
```
