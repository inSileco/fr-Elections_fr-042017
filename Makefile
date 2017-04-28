all:
	Rscript --no-site-file --no-init-file map_elections.R
	mv index.html docs/index.html
