all: move pandoc rmd2md

vignettes: 
		cd inst/vign;\
		Rscript -e 'library(knitr); knit("spocc_guide.Rmd")'

move:
		cp inst/vign/spocc_guide.md vignettes
		cp -rf inst/vign/img/* vignettes/img/

pandoc:
		cd vignettes;\
		pandoc -H margins.sty spocc_guide.md -o spocc_guide.pdf --highlight-style=tango;\
		pandoc -H margins.sty spocc_guide.md -o spocc_guide.html --highlight-style=tango

rmd2md:
		cd vignettes;\
		cp spocc_guide.md spocc_guide.Rmd;\