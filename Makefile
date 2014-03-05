all: move pandoc rmd2md reducepdf

vignettes: 
		cd inst/vign;\
		Rscript -e 'library(knitr); knit("spocc_vignette.Rmd")'

move:
		cp inst/vign/spocc_vignette.md vignettes
		cp -rf inst/vign/img/* vignettes/img/

pandoc:
		cd vignettes;\
		pandoc -H margins.sty spocc_vignette.md -o spocc_vignette.pdf --highlight-style=tango;\
		pandoc -H margins.sty spocc_vignette.md -o spocc_vignette.html --highlight-style=tango

rmd2md:
		cd vignettes;\
		cp spocc_vignette.md spocc_vignette.Rmd;\

reducepdf:
		Rscript -e 'tools::compactPDF("vignettes/spocc_vignette.pdf", gs_quality = "ebook")'