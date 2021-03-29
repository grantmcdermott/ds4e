# Data Science for Economists and Other Animals

<!-- badges: start -->
<!-- badges: end -->

This repository contains the source of the Data Science for Economists and Other
Animals book. The book is built using 
[bookdown](https://github.com/rstudio/bookdown).

The R packages used throughout the book can be installed through 
[renv](https://rstudio.github.io/renv/). Clone this repo and then run:

```r
# renv::init()   ## Only necessary if you didn't clone/open the repo as an RStudio project
renv::restore(prompt = FALSE)
```

**Aside: **While the `renv::restore()` command above should install [R package
binaries](https://packagemanager.rstudio.com/) on most operating systems (OS), 
it will not necessarily import _system_ dependencies on some Linux builds. For 
example, some key geospatial libraries will need to be installed separately 
through your distribution's package manager (e.g. aptitude). In each chapter, we 
do our best to detail any additional system requirements and who to install them. 
Alternatively, users may consider the 
[`remotes::system_requirements()`(https://remotes.r-lib.org/reference/system_requirements.html)
command.
