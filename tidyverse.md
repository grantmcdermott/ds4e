# (PART) Data wrangling {-} 

# Tidyverse

_In this chapter, we will introduce the first of two major data wrangling ecosystems within R. Namely, the very popular **tidyverse** family of packages ([link](https://www.tidyverse.org)). As the previous sentence suggests, the **tidyverse** consists of a number of inter-related packages, although we will limit ourselves here to tasks related to data cleaning and wrangling. In the next chapter, we will cover much of the same functionality using the also-very-popular **data.table** package ([link](https://rdatatable.gitlab.io/data.table)). Both ecosystems have their merits and ardent proponents. We therefore think it worthwhile to cover both and expose our readers to the different options at hand. While you may find yourself strongly preferring one to the other, our take-home message will be that both offer very powerful frameworks for that most essential of data science tasks: getting your data into shape._

## Software requirements

### R packages 

We only require two R packages for this chapter.

- New: **nycflights13**
- Already used: **tidyverse**

We'll hold off loading these libraries for now, although please make sure that they are installed on your system. If you cloned the companion book repository from GitHub and used the recommended **renv** install method (Chapter \@ref(sw-intro)), then they should already be available to you. If not, then you can install them both with the following command.

```r
install.packages(c('tidyverse', 'nycflights13'))
```

## Tidyverse basics

### Tidyverse vs. Base R (vs. data.table)

Newcomers to R are often surprised by the degree of choice --- some would say fragmentation --- within the language. There are, invariably, many ways to achieve the same goal and several packages may provide equivalent functionality via different syntax. One topic over which much digital ink has be spilled is the "tidyverse vs. base R" debate. We won't delve into this debate here, in part because we have already covered some important base R concepts in the previous chapter. However, we also feel that there are compelling arguments to introduce the **tidyverse** early in a book like the one you are reading. 

- The documentation and community support are outstanding.
- Having a consistent philosophy and syntax makes it easier to learn.
- Provides a convenient "front-end" to big data tools that we will cover later in the book.
- For data cleaning, wrangling, and plotting, the **tidyverse** offers some important improvements over base R.

Having said that, we want to emphasise that the **tidyverse** is not the only game in town for data work in R. For example, we are huge fans of the **data.table** package and will dedicate the entire next chapter to it. A larger point is that, while we may steer you towards certain methods or packages in this book, you shouldn't feel bound by our recommendations. Base R is extremely flexible and powerful (and stable). There are some things that you'll have to venture outside of the **tidyverse** for and you may, for example, find that a combination of **tidyverse** and base R is the best solution to a particular problem.^[Two excellent base R data manipulation tutorials are available [here](https://www.rspatial.org/intr/index.html) and [here](https://github.com/matloff/fasteR).]

One point of convenience is that there is often a direct correspondence between a **tidyverse** command and its base R equivalent. These generally follow a `tidyverse::snake_case` vs `base::period.case` rule. For example:

| tidyverse  |  base |
|---|---|
| `?readr::read_csv`  | `?utils::read.csv` |
|  `?dplyr::if_else` |  `?base::ifelse` |
|  `?tibble::tibble` |  `?base::data.frame` |
|  etc. |  etc. |

  
If you call up the above examples, you'll see that the **tidyverse** alternative typically offers some enhancements or other useful options (and occassional restrictions) over its base counterpart.

### Tidyverse packages

Let's load the **tidyverse** meta-package and take a look at the output.


```r
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
#> ✔ ggplot2 3.3.5     ✔ purrr   0.3.4
#> ✔ tibble  3.1.3     ✔ dplyr   1.0.7
#> ✔ tidyr   1.1.3     ✔ stringr 1.4.0
#> ✔ readr   2.0.0     ✔ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
```

We see that we have actually loaded a number of packages (which could also be loaded individually): **ggplot2**, **tibble**, **dplyr**, etc. We can also see information about the package versions and some namespace conflicts.

Note that the tidyverse actually comes with a lot more packages than those that are just loaded automatically.^[It also includes a *lot* of dependencies upon installation. This is a matter of some [controversy](http://www.tinyverse.org/).]


```r
tidyverse_packages()
#>  [1] "broom"         "cli"           "crayon"        "dbplyr"       
#>  [5] "dplyr"         "dtplyr"        "forcats"       "googledrive"  
#>  [9] "googlesheets4" "ggplot2"       "haven"         "hms"          
#> [13] "httr"          "jsonlite"      "lubridate"     "magrittr"     
#> [17] "modelr"        "pillar"        "purrr"         "readr"        
#> [21] "readxl"        "reprex"        "rlang"         "rstudioapi"   
#> [25] "rvest"         "stringr"       "tibble"        "tidyr"        
#> [29] "xml2"          "tidyverse"
```

We'll use several of these additional packages later in the book (e.g. **rvest** for webscraping). However, for the remainder of this chapter we will focus on two packages:

1. **dplyr** 
2. **tidyr**

These are the workhorse packages for data cleaning and wrangling. They are thus the ones that you will likely use most often in your data science work, especially given how much time data work requires in every project.

### An aside on pipes (`%>%` and `|>`)

<!-- We already learned about pipes in our [lecture](https://raw.githack.com/uo-ec607/lectures/master/03-shell/03-shell.html#91) on the bash shell.  -->
The **tidyverse** loads its own pipe operator, which is written as `%>%`.^[The **tidyverse** pipe is also known as the "magrittr" pipe --- [geddit?](https://en.wikipedia.org/wiki/The_Treachery_of_Images) --- and was originally bundled in the **magrittr** package ([link](https://magrittr.tidyverse.org/)). This package can do some other neat things if you're inclined to explore.]
  
We want to reiterate how cool pipes are, and how using them can dramatically improve the experience of reading and writing code. Compare the following two code chunks, which do exactly the same thing:

:::::: {.columns}
::: {.column width="48%" data-latex="{0.48\textwidth}"}

Piped code:


```r
mtcars %>% 
	filter(cyl==4) %>% 
	group_by(am) %>% 
	summarise(mpg_mean = mean(mpg))
#> # A tibble: 2 × 2
#>      am mpg_mean
#>   <dbl>    <dbl>
#> 1     0     22.9
#> 2     1     28.1
```
:::

::: {.column width="4%" data-latex="{0.04\textwidth}"}
\ <!-- an empty Div (with a white space), serving as a column separator -->
:::

::: {.column width="48%" data-latex="{0.48\textwidth}"}

Non-piped code:


```r
summarise(
	group_by(
		filter(mtcars, cyl==4), 
		am), 
	mpg_mean = mean(mpg)
	)
#> # A tibble: 2 × 2
#>      am mpg_mean
#>   <dbl>    <dbl>
#> 1     0     22.9
#> 2     1     28.1
```
:::
::::::
\ <!-- an empty Div again to give some extra space before the next block -->

The piped version of the code reads from left to right, exactly how we think of these operations in our heads. Take this object (`mtcars`), do this (`filter`), then do this (`group_by`), then do that (`summarise`). In contrast, the non-piped code totally inverts the logical order of execution. (The final summarising operation comes first!) Who wants to read things inside out?

Note that it's possible write both of the above code chunks on a single line. But splitting the commands over several lines tends to greatly improve the readability of one's code. Vertical space costs us nothing in a programming environment and so we might as well use it.

The **tidyverse** pipe (aka **magrittr** pipe) has proven so popular that several other data science and programming languages have implemented their own versions. Indeed, the R Core team introduced a "native" pipe to base R in version 4.1.0, denoted `|>`. This base R pipe differs somewhat in its implementation and does not offer a perfect like-for-like equivalent.^[A good summary of the differences at the time of write is provided [here](https://www.r-bloggers.com/2021/05/the-new-r-pipe/).] But for the most part, you should be able to use them interchangeably. Using our previous sequence of commands to illustrate:


```r
mtcars |>
	filter(cyl==4) |>
	group_by(am) |>
	summarise(mpg_mean = mean(mpg))
#> # A tibble: 2 × 2
#>      am mpg_mean
#>   <dbl>    <dbl>
#> 1     0     22.9
#> 2     1     28.1
```

## dplyr

_To be added..._
