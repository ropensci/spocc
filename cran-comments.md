R CMD CHECK passed on my local OS X install on R 3.2.5-patched and R development 
version, Ubuntu running on Travis-CI, and Win-Builder.

This submission fixes a bug, uses explicit encoding on httr::content() calls
and changes to using tibble for data.frames.

Thanks! Scott Chamberlain
