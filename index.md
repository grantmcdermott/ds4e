--- 
title: "Data Science for Economists and Other Animals"
author: "Grant McDermott and Ed Rubin"
date: "2021-03-29"
site: bookdown::bookdown_site
documentclass: book
bibliography: [book.bib, packages.bib]
biblio-style: apalike
link-citations: yes
description: "A compendium of tools and tricks that we wish we'd been taught in grad school."
---

# Welcome {.unnumbered}

Placeholder text from my syllabus:

> This seminar is targeted at economics PhD students and will introduce you to the modern data science toolkit. While some material will likely overlap with your other quantitative and empirical methods courses, this is not just another econometrics course. Rather, my goal is bring you up to speed on the practical tools and techniques that I feel will most benefit your dissertation work and future research career. This includes many of the seemingly forgotten skills --- like where to find interesting data sets in the ``wild'' and how to actually clean them --- that are crucial to any successful scientific project, but are typically excluded from core econometrics and statistics classes. We will cover topics like version control and effective project management; programming; data acquisition (e.g. web-scraping), cleaning and visualization; GIS and remote sensing products; and tools for big data analysis (e.g. relational databases, cloud computation and machine learning). In short, we will cover things that I wish someone had taught me when I was starting out in graduate school.

We use renv to snapshot the project environment. You can install all of the 
packages needed to run the code in this book with:


```r
# renv::init() ## Only run this line if the next line returns an error
renv::restore(prompt = FALSE)
```

Note that you might need a few extra packages if you want to build the book locally (unlikely):


```r
library(bslib)
library(downlit)
library(usethis)
```



