geodata := $(wildcard data/worldsimple.*)
votedata = data/Tour_1_Resultats_par_pays_240417.csv
dataok := worldsimpleready.Rds
out = docs/index.html

ALL: $(out)

$(out): $(dataok)
	Rscript --no-site-file --no-init-file -e "formatR::tidy_dir('R', arrow=T)"
	Rscript --no-site-file --no-init-file R/mapElections.R
	mv index.html $@

$(dataok): $(geodata) $(votedata)
	Rscript --no-site-file --no-init-file R/formatData.R

clean:
	rm $(out)
