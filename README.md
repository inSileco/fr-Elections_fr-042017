## Elections_fr-042017

Cartographie du vote des français de l'étranger - 1er Tour - 2017

Carte réalisée avec Leaflet (appelé via R, voir les packages utilisés ci-dessous et la [documentation](https://rstudio.github.io/leaflet/)).


## Disponibilités des données

- [Résultats du vote des Français résidant à l’étranger au premier tour de l’élection présidentielle 2017](
https://www.data.gouv.fr/fr/datasets/resultats-du-vote-des-francais-residant-a-letranger-au-premier-tour-de-lelection-presidentielle-2017/)

- Données pour les frontières administratives sont disponibles en ligne, nous avons utilisé la version 2.8 de GADM [GADM](ttp://www.gadm.org/version2). Nous avons simplement simplifié ces données pour les rendre plus légères (function `gSimplify()` du package R `rgeos`, voir le fichier `simpleWorld.R`).


## Liste des Packages R requis

1. magrittr
1. htmlwidgets
1. htmltools
1. leaflet
1. countrycode
1. rgdal
1. stringdist


## TODO

- [X] merger les résultats du Kosovo avec la Serbie;
- [X] merger les résultats de Jérusalem avec Israël;
- [X] couleur pour le gagnant;
- [X] détails des résultats;
- [X] faire la France => voir https://github.com/letiR/fr-departement-election
- [ ] Inverser les couleurs entre le candidat macron et fillon (http://www.lemonde.fr/les-decodeurs/article/2017/04/26/presidentielle-les-francais-de-l-etranger-ont-vote-macron-a-40-au-premier-tour_5117947_4355770.html) NB
on change sur la prochaine carte
- [X] Ajouter une légende
- [X] Ajouter le titre
- [ ] Ajouter les couches par candidats
