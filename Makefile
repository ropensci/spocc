all: move rmd2md

move:
		cp inst/vign/spocc.md vignettes
		cp -rf inst/vign/img/* vignettes/img/

rmd2md:
		cd vignettes;\
		mv spocc.md spocc.Rmd
