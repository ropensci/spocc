RSCRIPT = Rscript --no-init-file

all: move rmd2md

move:
		cp inst/vign/spocc.md vignettes;\
		cp -r inst/vign/img/ vignettes/img/

rmd2md:
		cd vignettes;\
		mv spocc.md spocc.Rmd

install: doc build
	R CMD INSTALL . && rm *.tar.gz

build:
	R CMD build .

docs:
	${RSCRIPT} -e "pkgdown::build_site()"

doc:
	${RSCRIPT} -e "devtools::document()"

eg:
	${RSCRIPT} -e "devtools::run_examples()"

codemeta:
	${RSCRIPT} -e "codemetar::write_codemeta()"

check:
	${RSCRIPT} -e 'devtools::check(document = FALSE, cran = TRUE)'

test:
	${RSCRIPT} -e 'devtools::test()'

testspsf:
	${RSCRIPT} -e 'testthat::test_dir("tests/testother")'
