all: move rmd2md

move:
		cp inst/vign/spocc_vignette.md vignettes
		cp -rf inst/vign/img/* vignettes/img/

rmd2md:
		cd vignettes;\
		mv spocc_vignette.md spocc_vignette.Rmd
