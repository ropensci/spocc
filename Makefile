all: move pandoc rmd2md cleanup

vignettes: 
		cd inst/vign;\
		Rscript -e 'library(knitr); knit("spocc_guide.Rmd")'

move:
		cp inst/vign/spocc_guide.md vignettes

pandoc:
		cd vignettes;\
		pandoc -H margins.sty spocc_guide.md -o spocc_guide.pdf;\
		pandoc -H margins.sty spocc_guide.md -o spocc_guide.html

rmd2md:
		cd vignettes;\
		cp spocc_guide.md spocc_guide.Rmd;\

cleanup:
		cd inst/vign;\
		rm spocc_guide.md