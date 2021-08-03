--- 
title: "Data Science for Economists and Other Animals"
author: "Grant McDermott and Ed Rubin"
date: "2021-08-03"
site: bookdown::bookdown_site
url: 'https\://grantmcdermott/ds4e'
github-repo: grantmcdermott/ds4e
twitter-handle: grant_mcdermott
documentclass: book
bibliography: [book.bib, packages.bib]
biblio-style: apalike
link-citations: yes
description: "A compendium of tools and tricks that we wish we'd been taught in grad school."
---

# Welcome {.unnumbered}

This is the website for **Data Science for Economists and Other Animals**. The 
book is very much in the early development stages, but draws from lecture 
material that we have been refining over the last several years. We're not 
actively looking for feedback yet, but hope to once we've managed to build out
enough of the chapters and basic book structure.

If you're interested in the motivation for this book, here is some placeholder text from Grant's syllabus:

> This seminar (ED: book) is targeted at economics PhD students (ED: and other animals) and will introduce you to the modern data science toolkit. While some material will likely overlap with your other quantitative and empirical methods courses, this is not just another econometrics course. Rather, my goal is bring you up to speed on the practical tools and techniques that I feel will most benefit your dissertation work and future research career. This includes many of the seemingly forgotten skills --- like where to find interesting data sets in the "wild" and how to actually clean them --- that are crucial to any successful scientific project, but are typically excluded from core econometrics and statistics classes. We will cover topics like version control and effective project management; programming; data acquisition (e.g. web-scraping), cleaning and visualization; GIS and remote sensing products; and tools for big data analysis (e.g. relational databases, cloud computation and machine learning). In short, we will cover things that I wish someone had taught me when I was starting out in graduate school.

We use renv to snapshot the project environment. You can install all of the 
packages needed to run the code in this book with:


```r
# renv::init() ## Only run this line if the next line returns an error
renv::restore(prompt = FALSE)
```

Note that you might need a few extra packages if you want to build the book locally (unlikely):


```r
library(bookdown)
library(bslib)
library(downlit)
library(usethis)
```



