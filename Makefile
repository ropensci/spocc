all: knit pandoc

knit:
		Rscript --vanilla -e 'library(knitr); knit("spocc_ms.Rnw")'

pandoc:
		pandoc spocc_ms.tex -o spocc_ms.pdf --highlight-style=tango;\
		pandoc spocc_ms.tex -o spocc_ms.html --highlight-style=tango;\
		pandoc spocc_ms.html -o spocc_ms.md
