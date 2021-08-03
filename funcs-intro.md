# (PART) Programming {-} 

# Functions: Introductory concepts {#funcs-intro}
 
## Software requirements

### R packages 

- New: **pbapply**
- Already used: **tidyverse**, **data.table** 

We'll be sticking mostly with base R functions in this chapter. But we'll also show you a few extra features and considerations for the main data wrangling packages. As per usual, run the following code chunk to install (if necessary) and load everything.


```r
if (!require("pacman")) install.packages("pacman")
pacman::p_load(pbapply, data.table, tidyverse)
```

## Basic syntax

We have already seen and used a multitude of functions in R. Some of these functions come pre-packaged with base R (e.g. `mean()`), while others are from external packages (e.g. `dplyr::filter()`). Regardless of where they come from, functions in R all adopt the same basic syntax:

```r
function_name(ARGUMENTS)
```

For much of the time, we will rely on functions that other people have written for us. However, you can --- and should! --- write your own functions too. This is easy to do with the generic **`function()`** function.^[Yes, it's a function that let's you write functions. Very meta.] The syntax will again look familiar to you:

```r
function(ARGUMENTS) {
  OPERATIONS
  return(VALUE)
}
```

While it's possible and reasonably common to write anonymous functions like the above, we typically write functions because we want to reuse code. For this typical use-case it makes sense to name our functions.^[Remember: "In R, everything is an object and everything has a name."]

```r
my_func = 
  function(ARGUMENTS) {
    OPERATIONS
    return(VALUE)
  }
```

For some short functions, you don't need to invoke the curly brackets or assign an explicit return object (more on this below). In these cases, you can just write your function on a single line:

```r
my_short_func = function(ARGUMENTS) OPERATION
```

Try to give your functions short, pithy names that are informative to both you and anyone else reading your code. This is harder than it sounds, but will pay off down the road.

## A simple example {#simple-square}

Let's write out a simple example function, which gives the square of an input number.


```r
square =        ## Our function name
  function(x) { ## The argument(s) that our function takes as an input
    x^2         ## The operation(s) that our function performs
  }
```

Test it.

```r
square(3)
#> [1] 9
```

Great, it works. Note that for this simple example we could have written everything on a single line; i.e. `square = function(x) x^2` would work just as well. (Confirm this for yourself.) However, we're about to add some extra conditions and options to our function, which will strongly favour the multi-line format.

> **Aside:** We wish to emphasise that our little `square()` function is not exciting or, indeed, particularly useful. R's built-in arithmetic functions already take care of (vectorised) exponentiation and do so very efficiently. (See `?Arithmetic`.) However, we're going to continue with this conceptually simple example, since it will provide a clear framework for demonstrating some general principles about functions in R.

### Specifying return values

Notice that we didn't specify a return value for our function. This will work in many cases because R's default behaviour is to automatically return the final object that you created within the function. However, this won't always be the case. Opinions on this differ, but our own recommendation is that you get into the habit of assigning the return object(s) explicitly with `return()`. Let's modify our function to do exactly that.


```r
square = 
  function(x) { 
    ## Create an intermediary object (that will be returned)
    x_sq = x^2  
    
    ## The value(s) or object(s) that we want returned.
    return(x_sq)  
  }
```

Again, test that it works.

```r
square(5)
#> [1] 25
```

Specifying an explicit return value is also helpful when we want to return more than one object. For example, let's say that we want to remind our user what variable they used as an argument in our function:


```r
square = 
  function(x) { 
    x_sq = x^2 
    
    ## The list of object(s) that we want returned.
    return(list(value = x, value_squared = x_sq))
  }
```


```r
square(3)
#> $value
#> [1] 3
#> 
#> $value_squared
#> [1] 9
```

Note that multiple return objects have to be combined in a list. We didn't have to name these separate list elements --- i.e. "value" and "value_squared" --- but it will be helpful for users of our function. Nevertheless, remember that many objects in R contain multiple elements (vectors, data frames, and lists are all good examples of this). So we can also specify one of these "array"-type objects within the function itself if that provides a more convenient form of output. For example, we could combine the input and output values into a data frame:


```r
square = 
  function(x) { 
    x_sq = x^2 
    
    ## Bundle up our input and output values into a convenient dataframe.
    d = data.frame(value=x, value_squared=x_sq) 
    
    return(d)
  }
```

Test.

```r
square(12)
#>   value value_squared
#> 1    12           144
```


### Specifying default argument values

Another thing worth noting about R functions is that you can assign default argument values. You have already encountered some examples of this in action.^[E.g. Type `?rnorm` and see that it provides a default mean and standard deviation of 0 and 1, respectively.] We can add a default option to our own function pretty easily.

```r
square = 
  function(x = 1) { ## Setting the default argument value 
    x_sq = x^2 
    d = data.frame(value = x, value_squared = x_sq)
    
    return(d)
  }
```


```r
square()  ## Will take the default value of 1.
#>   value value_squared
#> 1     1             1
square(2) ## Now takes the explicit value that we give it.
#>   value value_squared
#> 1     2             4
```

We'll return to the issues of specifying default values, handling invalid inputs, and general debugging in Section \@ref(debugging). 

### Aside: Environments and lexical scoping

Before continuing, take a second to note that none of the intermediate objects that we created inside the above functions (`x_sq`, `df`, etc.) have made their way into your global environment.^[Look in the "Environment" pane of your RStudio session.] R has a set of so-called [*lexical scoping*](https://adv-r.hadley.nz/functions.html#lexical-scoping) rules, which  govern where it stores and evaluates the values of different objects. Without going into too much depth, the practical implication of lexical scoping is that functions operate in a quasi-sandboxed [*environment*](https://adv-r.hadley.nz/environments.html). They don't return or use objects in the global environment unless they are forced to (e.g. with a `return()` command). Similarly, a function will only look to outside environments (e.g. a level "up") to find an object if it doesn't see the object named within itself.

We'll revisit the ideas of distinct object environments and lexical scoping when we get to functional programming in Section \@ref(functional-programming) below, and then again in Section \@ref(debugging).

## Control flow

Now that we've got a good sense of the basic function syntax, it's time to learn control flow. That is, we want to control the order (or "flow") of statements and operations that our functions evaluate. 

### if and ifelse

We've already encountered conditional statements like `if()` and `ifelse()` numerous times in the book thus far.^[E.g Conditional mutation in the tidyverse (see [here](https://raw.githack.com/uo-ec607/lectures/master/05-tidyverse/05-tidyverse.html#38).] However, let's see how they can work in our own bespoke functions by slightly modifying our `square` function. This time, instead of specifying a default input value of 1 in the function argument itself, we'll specify a value of `NULL`. Then we'll use an `if()` statement to reassign this default to one.


```r
square = 
  function(x = NULL) {  ## Default value of NULL
    if (is.null(x)) x = 1 ## Re-assign default to 1
    
    x_sq = x^2 
    d = data.frame(value = x, value_squared = x_sq)
    
    return(d)
  }
square()
#>   value value_squared
#> 1     1             1
```

Why go through the rigmarole of specifying a NULL default inpute if we're going to change it to 1 anyway? Admittedly, this is a pretty silly thing to do in the above example. However, consider what it buys us in the next code chunk:


```r
square = 
  function(x = NULL) {
    
    if (is.null(x)) { ## Start multi-line IF statement with `{`
      x = 1
      ## Message to users:
      message("No input value provided. Using default value of 1.")
      }               ## Close multi-line if statement with `}`
    
    x_sq = x^2 
    d = data.frame(value = x, value_squared = x_sq)
    
    return(d)
  }
square()
#> No input value provided. Using default value of 1.
#>   value value_squared
#> 1     1             1
```

This time, by specifying NULL in the argument --- alongside the expanded `if()` statement --- our function now both takes a default value *and* generates a helpful message.^[Think about how you might have tried to achieve this if we'd assigned the `x = 1` default directly in function argument as before. It quickly gets complicated, because how can your message discriminate whether a user left the argument blank or deliberately entered `square(1)`?] Note too the use of curly brackets for conditional operations that span multiple lines after an `if()` statement. 
This provides a nice segue to `ifelse()` statements. As we've already seen , these be written as a single conditional call where the format is:


```r
ifelse(CONDITION, DO IF TRUE, DO IF FALSE)
```

Within our own functions, though we're more likely to write them over several lines. Consider, for example a new function that evaluates whether our `square()` function is doing its job properly.


```r
eval_square =
  function(x) {
    
    if (square(x)$value_squared == x*x) {
      ## What to do if the condition is TRUE 
      message("Nailed it.")
    } else {
      ## What to do if the condition is FALSE
      message("Dude, your function sucks.")
    }
    
  }
eval_square(64)
#> Nailed it.
```

#### Aside: ifelse gotchas and alternatives

The base R `ifelse()` function normally works great and we use it all the time. However, there are a couple of "gotcha" cases that you should be aware of. Consider the following (silly) function which is designed to return either today's date, or the day before.


```r
today = function(...) ifelse(..., Sys.Date(), Sys.Date()-1)
today(TRUE)
#> [1] 18842
```

You are no doubt surprised to find that our function returns a number instead of a date. This is because `ifelse()` automatically converts date objects to numeric as a way to get around some other type conversion strictures. Confirm for yourself by converting it back the other way around with: `as.Date(today(TRUE), origin = "1970-01-01")`. 

> **Aside:** The "dot-dot-dot" argument (`...`) that we've used above is a convenient shortcut that allows users to enter unspecified arguments into a function. This is beyond the scope of this chapter, but can prove to be an incredibly useful and flexible programming strategy. We highly encourage you to look at the [relevant section](https://adv-r.hadley.nz/functions.html#fun-dot-dot-dot) of *Advanced R* to get a better idea.

To guard against this type of unexpected behaviour, in addition to various other optimizations, both **dplyr** and **data.table** offer their own versions of `ifelse` statements. We won't explain these next code chunks in depth --- consult the relevant help pages if needed --- but here are adapted versions of our `today()` function based on these alternatives.

First, `dplyr::if_else()`:


```r
today2 = function(...) dplyr::if_else(..., Sys.Date(), Sys.Date()-1)
today2(TRUE)
#> [1] "2021-08-03"
```

Second, `data.table::fifelse()`:


```r
today3 = function(...) data.table::fifelse(..., Sys.Date(), Sys.Date()-1)
today3(TRUE)
#> [1] "2021-08-03"
```

### *case when* (nested ifelse)

As you may have guessed, it's certainly possible to write nested `ifelse()` statements. For example,


```r
ifelse(CONDITION1, DO IF TRUE, ifelse(CONDITION2, DO IF TRUE, ifelse(...)))
```

However, these nested statements quickly become difficult to read and troubleshoot. A better solution was originally developed in SQL with the `CASE WHEN` statement. Both **dplyr** with `case_when()` and **data.table** with `fcase()` provide implementations R. Here is a simple illustration of both implementations.


```r
x = 1:10

## dplyr::case_when()
case_when(
  x <= 3 ~ "small",
  x <= 7 ~ "medium",
  TRUE ~ "big" ## Default value. Could also write `x > 7 ~ "big"` here.
  )
#>  [1] "small"  "small"  "small"  "medium" "medium" "medium" "medium" "big"   
#>  [9] "big"    "big"

## data.table::fcase()
fcase(
    x <= 3, "small",
    x <= 7, "medium",
    default = "big" ## Default value. Could also write `x > 7, "big"` here.
    )
#>  [1] "small"  "small"  "small"  "medium" "medium" "medium" "medium" "big"   
#>  [9] "big"    "big"
```

Not to belabour the point, but you can easily use these *case when* implementations inside of data frames/tables too.


```r
## dplyr::case_when()
data.frame(x = 1:10) %>%
    mutate(grp = case_when(x <= 3 ~ "small",
                           x <= 7 ~ "medium",
                           TRUE ~ "big"))
#>     x    grp
#> 1   1  small
#> 2   2  small
#> 3   3  small
#> 4   4 medium
#> 5   5 medium
#> 6   6 medium
#> 7   7 medium
#> 8   8    big
#> 9   9    big
#> 10 10    big
## data.table::fcase()
data.table(x = 1:10)[, grp := fcase(x <= 3, "small",
                                    x <= 7, "medium",
                                    default = "big")][]
#>      x    grp
#>  1:  1  small
#>  2:  2  small
#>  3:  3  small
#>  4:  4 medium
#>  5:  5 medium
#>  6:  6 medium
#>  7:  7 medium
#>  8:  8    big
#>  9:  9    big
#> 10: 10    big
```


## Iteration

Alongside control flow, the most important early programming skill to master is iteration. In particular, we want to write functions that can iterate --- or *map* --- over a set of inputs.^[Our focus in this chapter will only be on sequential iteration. We'll explore parallel iteration in a few chapters.] By far the most common way to iterate across different programming languages is *for* loops. Indeed, we already saw some examples of *for* loops back in the shell lecture (see [here](https://raw.githack.com/uo-ec607/lectures/master/03-shell/03-shell.html#95)). However, while R certainly accepts standard *for* loops, we're going to advocate that you adopt what is known as a "functional programming" approach to writing loops. Let's dive into the reasons why and how these approaches differ.

### Vectorisation

The first question you should be asking yourself is: "Do I need to iterate at all?"

You may remember from earlier chapters that we spoke about R being *vectorised*. This means that we can apply a function over an entire vector all at once, rather than having to iterate explicitly over each element. Vectorisation is a common feature of high-level programming languages like R and Python. What's really happening with vectorisation is that a loop *is* being called behind the scenes. But that loop is implemented in a low-level compiled language like C or Fortran.^[To borrow a phrase from Jenny Bryan: "Someone has to write a for loop. It just doesn't have to be you."] Let's demonstrate this property with our `square` function:

```r
square(1:5)
#>   value value_squared
#> 1     1             1
#> 2     2             4
#> 3     3             9
#> 4     4            16
#> 5     5            25
square(c(2, 4))
#>   value value_squared
#> 1     2             4
#> 2     4            16
```

So, again, you may not need to think about explicit iteration at all. 

That being said, there are certainly cases where you *will* need to think about iteration. For the remainder of this section, we'll explore with some simple examples --- some of which are already vectorised! --- that provide a mental springboard for thinking about more complex cases.

### *for* loops

In R, standard *for* loops take a pretty intuitive form. For example:


```r
for(i in 1:10) print(LETTERS[i])
#> [1] "A"
#> [1] "B"
#> [1] "C"
#> [1] "D"
#> [1] "E"
#> [1] "F"
#> [1] "G"
#> [1] "H"
#> [1] "I"
#> [1] "J"
```

Note that in cases where we want to "grow" an object via a *for* loop, we first have to create an empty (or NULL) object.


```r
kelvin = 300:305
fahrenheit = NULL
# fahrenheit = vector("double", length(kelvin)) ## Better than the above. Why?
for(k in 1:length(kelvin)) {
  fahrenheit[k] = kelvin[k] * 9/5 - 459.67
}
fahrenheit
#> [1] 80.33 82.13 83.93 85.73 87.53 89.33
```

Unfortunately, basic *for* loops in R also come with some downsides. Historically, they used to be significantly slower and memory consumptive than alternative methods (see below). This has largely been resolved, but we've still run into cases where an inconspicuous *for* loop has brought an entire analysis crashing to its knees.^[[Exhibit A](https://github.com/grantmcdermott/bycatch/commit/18dbed157f0762bf4b44dfee437d6f319561c160). Trust us: debugging these cases is not much fun.] The bigger problem with *for* loops, however, is that they deviate from the norms and best practices of **functional programming**. 

### Functional programming

The concept of functional programming (FP) is arguably the most important thing that you can take away from this chapter. In his excellent book, *Advanced R*, [Hadley Wickham](http://adv-r.had.co.nz/Functional-programming.html) explains the core idea as follows.

> R, at its heart, is a functional programming (FP) language. This means that it provides many tools for the creation and manipulation of functions. In particular, R has what’s known as first class functions. You can do anything with functions that you can do with vectors: you can assign them to variables, store them in lists, pass them as arguments to other functions, create them inside functions, and even return them as the result of a function. 

That may seem a little abstract, so [here](https://www.youtube.com/embed/GyNqlOjhPCQ?rel=0&amp;start=372) is video of Hadley giving a much more intuitive explanation through a series of examples.

<iframe width="710" height="400" src="https://www.youtube.com/embed/GyNqlOjhPCQ?rel=0&amp;start=372" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

</br>

**Summary:** *for* loops tend to emphasise the *objects* that we're working with (say, a vector of numbers) rather than the *operations* that we want to apply to them (say, get the mean or median or whatever). This is inefficient because it requires us to continually write out the *for* loops by hand rather than getting an R function to create the for-loop for us. 

As a corollary, *for* loops also pollute our global environment with the variables that are used as counting variables. Take a look at your "Environment" pane in RStudio. What do you see? In addition to the `kelvin` and `fahrenheit` vectors that we created, we also see two variables `i` and `k` (equal to the last value of their respective loops). Creating these auxiliary variables is almost certainly not an intended outcome when your write a for-loop.^[The best case we can think of is when you are trying to keep track of the number of loops, but even then there are much better ways of doing this.] More worryingly, they can cause programming errors when we inadvertently refer to a similarly-named variable elsewhere in our script. So we best remove them manually as soon as we're finished with a loop. 


```r
rm(i, k)
```

Another annoyance arrived in cases where we want to "grow" an object as we iterate over it (e.g. the `fahrenheit` object in our second example). In order to do this with a *for* loop, we had to go through the rigmarole of creating an empty object first.

FP allows to avoid the explicit use of loop constructs and its associated downsides. In practice, there are two ways to implement FP in R: 

1. The `*apply` family of functions in base R.
2. The `map*()` family of functions from the [**purrr**](https://purrr.tidyverse.org/).

Let's explore these in more depth.

#### lapply and co.

Base R contains a very useful family of `*apply` functions. We won't go through all of these here, but they all follow a similar philosophy and syntax. The good news is that this syntax very closely mimics the syntax of basic for-loops. For example, consider the code below, which is analogous to our first *for* loop above, but now invokes a **`base::lapply()`** call instead. 


```r
# for(i in 1:10) print(LETTERS[i]) ## Our original for loop (for comparison)
lapply(1:10, function(i) LETTERS[i])
#> [[1]]
#> [1] "A"
#> 
#> [[2]]
#> [1] "B"
#> 
#> [[3]]
#> [1] "C"
#> 
#> [[4]]
#> [1] "D"
#> 
#> [[5]]
#> [1] "E"
#> 
#> [[6]]
#> [1] "F"
#> 
#> [[7]]
#> [1] "G"
#> 
#> [[8]]
#> [1] "H"
#> 
#> [[9]]
#> [1] "I"
#> 
#> [[10]]
#> [1] "J"
```

A couple of things to notice. 

First, check your "Environment" pane in RStudio. Do you see an object called "i" in the Global Environment? (The answer should be"no".) Again, this is because of R's lexical scoping rules, which mean that any object created and invoked by a function is evaluated in a sandboxed environment outside of your global environment.

Second, notice how little the basic syntax changed when switching over from `for()` to `lapply()`. Yes, there are some differences, but the essential structure remains the same: We first provide the iteration list (`1:10`) and then specify the desired function or operation (`LETTERS[i]`).

Third, notice that the returned object is a *list*. The `lapply()` function can take various input types as arguments --- vectors, data frames, lists --- but always returns a list, where each element of the returned list is the result from one iteration of the loop. (So now you know where the "l" in "**l**apply" comes from.) 

#### Aside: Binding and simplifying lists

Okay, but what if you don't want your iteration output to remain in list form? There several options here, depending on the type of output you want (vector, data frame, etc.) As we imagine is the case for most social scientists, our preferred data structure is the data frame. So, we typically want to bind the different list elements into a single data frame. There are three simple ways to do this:

- **Base R**: `do.call("rbind")`
- **dplyr**: `bind_rows()`
- **data.table**: `rbindlist()`

Which of these three options you choose is largely a matter of taste and constraints. Do you feel like loading a package? (If not, then go with `do.call("rbind")`.) Is performance paramount? (If yes, then go with `data.table::rbindlist()`). But, for the most part, any of them should be fine. As an example, here's a slightly modified version of our previous function that now yields a data frame:


```r
lapply(1:10, function(i) data.frame(num = i, let = LETTERS[i])) %>%
  # do.call("rbind", .)      ## Also works
  # data.table::rbindlist()  ## Ditto
  dplyr::bind_rows()
#>    num let
#> 1    1   A
#> 2    2   B
#> 3    3   C
#> 4    4   D
#> 5    5   E
#> 6    6   F
#> 7    7   G
#> 8    8   H
#> 9    9   I
#> 10  10   J
```

Taking a step back --- and while the default list-return behaviour may not sound ideal at first --- we use `lapply()` more frequently than any of the other `apply` family members. A key reason is that our functions often return multiple objects of different type (which makes lists the only sensible format). Or, they return a single data frame (which is where `do.call("rbind")` and co. enter the picture). 

For what it's worth, another option that would work well in the present particular case is `sapply()`. This stands for "**s**implify apply" and is essentially a wrapper around `lapply` that tries to return simplified output that matches the input type. So, it will try to return a vector if you it a vector, etc. For example:


```r
sapply(1:10, function(i) LETTERS[i]) 
#>  [1] "A" "B" "C" "D" "E" "F" "G" "H" "I" "J"
```

##### Aside: Progress bars!

Who doesn't like progress bars? Personally, we find it incredibly helpful to see how a function is progressing, or get a sense of how much longer we can expect to wait before completion.

Along those lines, we're big fans of the [**pbapply**](https://github.com/psolymos/pbapply) package, which is a lightweight wrapper around the `*apply` functions that adds a progress bar. `pbapply` offers equivalents for all members of the `*apply` family. But the one that we use most often (unsurprisingly) is `pbapply::pblapply()`. 

*Note: You will need to run this next example interactively to see the effect properly.*


```r
# library(pbapply) ## Already loaded

pblapply(1:10, function(i) {
  d = data.frame(num = i, let = LETTERS[i])
  Sys.sleep(1)
  return(d)
  }) %>%
  bind_rows()
#>    num let
#> 1    1   A
#> 2    2   B
#> 3    3   C
#> 4    4   D
#> 5    5   E
#> 6    6   F
#> 7    7   G
#> 8    8   H
#> 9    9   I
#> 10  10   J
```

Another thing that we really like about the `pblapply()` function is that it easily extends to parallel (i.e. multicore) processing. We'll cover this next in Chapter \@ref(parallel), though.

At the time of writing, there's also a newish package on the scene, [**progressr**](https://github.com/HenrikBengtsson/progressr), which provides a unified API for progress updates across multiple iteration frameworks in R. We won't cover it here, but it's pretty neat and simple to use, so check it out.

#### purrr package

The **tidyverse** offers its own enhanced implementation of the base `*apply()` functions through the [**purrr**](https://purrr.tidyverse.org/) package.^[In their [words](https://r4ds.had.co.nz/iteration.html): "The apply family of functions in base R solve a similar problem *[i.e. to purrr]*, but purrr is more consistent and thus is easier to learn."] The key function to remember here is `purrr::map()`. And, indeed, the syntax and output of this command are effectively identical to `base::lapply()`:


```r
map(1:10, function(i) { ## only need to swap `lapply` for `map`
  d = data.frame(num = i, let = LETTERS[i])
  return(d)
  })
#> [[1]]
#>   num let
#> 1   1   A
#> 
#> [[2]]
#>   num let
#> 1   2   B
#> 
#> [[3]]
#>   num let
#> 1   3   C
#> 
#> [[4]]
#>   num let
#> 1   4   D
#> 
#> [[5]]
#>   num let
#> 1   5   E
#> 
#> [[6]]
#>   num let
#> 1   6   F
#> 
#> [[7]]
#>   num let
#> 1   7   G
#> 
#> [[8]]
#>   num let
#> 1   8   H
#> 
#> [[9]]
#>   num let
#> 1   9   I
#> 
#> [[10]]
#>   num let
#> 1  10   J
```

Given these similarities, we won't spend much time on **purrr**. However, many readers may find it to be the optimal entry point for programming and iteration; particularly those that also rely on **tidyverse** for their workflow. One additional thing worth flagging is the fact that `map()` also comes with its own variants, which are useful for returning objects of a desired type. For example, we can use `purrr::map_df()` to return a data frame.


```r
map_df(1:10, function(i) { ## don't need bind_rows with `map_df`
  d = data.frame(num = i, let = LETTERS[i])
  return(d)
  })
#>    num let
#> 1    1   A
#> 2    2   B
#> 3    3   C
#> 4    4   D
#> 5    5   E
#> 6    6   F
#> 7    7   G
#> 8    8   H
#> 9    9   I
#> 10  10   J
```

Note that this is more efficient (i.e. involves less typing) than the `lapply()` version, since we don't have to go through the extra step of binding rows at the end.


### Create and iterate over named functions

As you may have guessed already, we can split the function and the iteration (and binding) into separate steps. This is generally a good idea, since you typically create (named) functions with the goal of reusing them. 


```r
## Create a named function
num_to_alpha = 
  function(i) {
  d = data.frame(num = i, let = LETTERS[i])
  return(d)
  }
```

Now, we can easily iterate over our function using different input values. For example,

```r
lapply(1:10, num_to_alpha) %>% bind_rows()
#>    num let
#> 1    1   A
#> 2    2   B
#> 3    3   C
#> 4    4   D
#> 5    5   E
#> 6    6   F
#> 7    7   G
#> 8    8   H
#> 9    9   I
#> 10  10   J
```
Or, say

```r
map_df(c(1, 5, 26, 3), num_to_alpha)
#>   num let
#> 1   1   A
#> 2   5   E
#> 3  26   Z
#> 4   3   C
```

### Iterate over multiple inputs

Thus far, we have only been working with functions that take a single input when iterating. For example, we feed them a single vector (even though that vector contains many elements that drive the iteration process). But what if we want to iterate over multiple inputs? Consider the following function, which takes two separate variables `x` and `y` as inputs, combines them in a data frame, and then uses them to create a third variable `z`. 

> **Note:** Again, this is a rather silly function that we could easily improve upon using standard (vectorised) tools. But our goal here is to demonstrate programming principles with simple examples that carry over to more complicated cases where vectorisation is not possible.


```r
## Create a named function
multi_func = 
  function(x, y) {
    z = (x + y) / sqrt(x)
    data.frame(x, y, z)
  }
```

Before continuing, quickly test that it works using non-iterated inputs.


```r
multi_func(1, 6)
#>   x y z
#> 1 1 6 7
```

Great, it works. Now let's imagine that we want to iterate over various levels of both `x` and `y`. There are two basics approaches that we can follow to achieve this: 

1. Use `base::mapply()`/`base::Map()` or `purrr::pmap()`.
2. Use a data frame of input combinations. 

We'll quickly review both approaches, continuing with the `multi_func()` function that we just created above.

#### Use `mapply()`/`Map()` or `pmap()`

Both **base** R --- through `mapply()`/`Map()` --- and **purrr** --- through `pmap` --- can handle multiple input cases for iteration. The latter is slightly easier to work with in our view, since the syntax is closer (nearly identical) to the single input case. Still, we'll demonstrate using both versions below.

First, `base::mapply()`:

```r
## Note that the inputs are now moved to the *end* of the call. Also, mapply() 
## is based on sapply(), so we also have to tell it not to simplify if we want 
## to keep the list structure.
mapply(
  multi_func,
  x = 1:5,         ## Our "x" vector input
  y = 6:10,        ## Our "y" vector input
  SIMPLIFY = FALSE ## Tell it not to simplify to keep the list structure
  ) %>%
  do.call("rbind", .)
#>   x  y        z
#> 1 1  6 7.000000
#> 2 2  7 6.363961
#> 3 3  8 6.350853
#> 4 4  9 6.500000
#> 5 5 10 6.708204
```

> **Note:** If you don't feel like typing `SIMPLIFY = FALSE`, then `Map()` is a light wrapper around `mapply()` that does this automatically. Try it yourself by slightly editing the above function to use `Map()` instead of `mapply()`.

Second, `purrr::pmap()`:

```r
## Note that the function inputs are combined in a list and come first.
pmap_df(
  list(x = 1:5, y = 6:10), 
  multi_func
  )
#>   x  y        z
#> 1 1  6 7.000000
#> 2 2  7 6.363961
#> 3 3  8 6.350853
#> 4 4  9 6.500000
#> 5 5 10 6.708204
```


#### Using a data frame of input combinations

While the above approaches work perfectly well, an alternative approach is to "cheat" by feeding multi-input functions a *single* data frame that specifies the necessary combination of variables by row. We'll demonstrate how this works in a second. But first, let's motivate why you might want to do this. The short answer is that it can give you more control over your functions and inputs. Specifically:

- You don't have to worry about accidentally feeding separate inputs of different lengths. Try running the above functions with an `x` vector input of `1:10`, for example. (Leave everything else unchanged.) `pmap()` will at least fail to iterate and give you a helpful message, but `mapply` will actually complete with totally misaligned columns. Putting everything in a (rectangular) data frame forces you to ensure the equal length of inputs *a priori*.
- Like us, you may find yourself frequently needing to run a function over all possible combinations of a set of inputs. In these cases, it is typically much more convenient to create a data frame of combinations first, which can then be passed to functions directly.^[Creating combination data frames is easily done with `base::expand.grid()`, or the equivalent `tidyr::expand_grid()` and `data.table:CJ()` functions.]
- Keeping things down to a single input argument can really help to make your code cleaner and simpler to understand. This is especially true for complicated functions that have a lot of nesting (i.e. functions of functions) and/or parallelization.

Those justifications aside, let's see how this might work with an example. Consider the following function:


```r
parent_func =
  ## Main function: Takes a single data frame as an input
  function(input_df) {
    d =
      ## Nested iteration function
      map_df(
      1:nrow(input_df), ## i.e. Iterate (map) over each row of the input data frame
      function(n) {
        ## Extract the `x` and `y` values from row "n" of the data frame
        x = input_df$x[n]
        y = input_df$y[n]
        ## Apply our function on the the extracted values
        multi_func(x, y)
      })
    return(d)
    }
```

There are three conceptual steps to the above code chunk:

1. First, we create a new function called `parent_func()`, which takes a single input: a data frame containing `x` and `y` columns (and potentially other columns too). 
2. This input data frame is then passed to a second (nested) function, which will *iterate over the rows of the data frame*. 
3. During each iteration, the `x` and `y` values for that row are passed to our original `multi_func()` function. This will return a data frame containing the desired output.

Let's test that it worked using two different input data frames.


```r
## Case 1: Iterate over x=1:5 and y=6:10
input_df1 = data.frame(x = 1:5, y = 6:10)
parent_func(input_df1)
#>   x  y        z
#> 1 1  6 7.000000
#> 2 2  7 6.363961
#> 3 3  8 6.350853
#> 4 4  9 6.500000
#> 5 5 10 6.708204

## Case 2: Iterate over *all possible combinations* of x=1:5 and y=6:10
input_df2 = expand.grid(x = 1:5, y = 6:10)
parent_func(input_df2)
#>    x  y         z
#> 1  1  6  7.000000
#> 2  2  6  5.656854
#> 3  3  6  5.196152
#> 4  4  6  5.000000
#> 5  5  6  4.919350
#> 6  1  7  8.000000
#> 7  2  7  6.363961
#> 8  3  7  5.773503
#> 9  4  7  5.500000
#> 10 5  7  5.366563
#> 11 1  8  9.000000
#> 12 2  8  7.071068
#> 13 3  8  6.350853
#> 14 4  8  6.000000
#> 15 5  8  5.813777
#> 16 1  9 10.000000
#> 17 2  9  7.778175
#> 18 3  9  6.928203
#> 19 4  9  6.500000
#> 20 5  9  6.260990
#> 21 1 10 11.000000
#> 22 2 10  8.485281
#> 23 3 10  7.505553
#> 24 4 10  7.000000
#> 25 5 10  6.708204
```


## Further resources

In Chapters \@ref(funcs-adv) and \@ref(parallel), we'll dive into more advanced programming and function topics (debugging, parallel implementation, etc.). However, we hope that this chapter has given you solid grasp of the fundamentals. We highly encourage you to start writing some of your own functions. You will be doing this a *lot* as your career progresses. Establishing an early mastery of function writing will put you on the road to awesome data science success<sup>TM</sup>. Here are some additional resources for both inspiration and reference:

- Garrett Grolemund and Hadley Wickham's [*<b>R for Data Science</b>*](http://r4ds.had.co.nz) book --- esp. chapters [19 ("Functions)")](http://r4ds.had.co.nz/functions.html) and [21 ("Iteration)")](http://r4ds.had.co.nz/iteration.html) --- covers much of the same ground as we have here, with particular emphasis on the **purrr** package for iteration.
- If you're looking for an in-depth treatment, then we can highly recommend Hadley's [*<b>Advanced R</b>*](https://adv-r.hadley.nz) (2nd ed.) He provides a detailed yet readable overview of all the concepts that we touched on in this chapter, including more on his (and R's) philosophy regarding functional programming (see [Section ||](https://adv-r.hadley.nz/fp.html)). 
- If you're in the market for a more concise overview of the different `*apply()` functions, then we recommend [this blog post](https://nsaunders.wordpress.com/2010/08/20/a-brief-introduction-to-apply-in-r/) by Neil Saunders.
- On the other end of the scale, Jenny Bryan (all hail) has created a fairly epic [purrr tutorial](https://jennybc.github.io/purrr-tutorial) mini-website. (Bonus: She goes into more depth about working with lists and list columns.)

## Addendum: Inspecting function source code

Looking inside a function is not only important for debugging --- a subject covered in \@ref(debugging) --- but is also a great way to pick up programming tips and tricks. We refer to this as inspecting a function's *source code*. For some functions, viewing the source code is a simple matter of typing the function name into your R console (without the parentheses!) and letting R print the object to screen. Try this yourself with the `num_to_alpha` function that we created earlier. Or, here's the source code for `replace()`, arguably the simplest base R function around:


```r
replace
#> function (x, list, values) 
#> {
#>     x[list] <- values
#>     x
#> }
#> <bytecode: 0x55ea810d2338>
#> <environment: namespace:base>
```

Unfortunately, the simple print-function-to-screen approach doesn't work once you start getting into functions that have different dispatch "methods" (e.g. associated with S3 or S4 classes), or rely on compiled code underneath the hood (e.g. written in C or Fortran). The good news is that you can still view the source code, although it does require a bit more legwork. As a quick example, consider what happens if we try to look at the source code for R's generic `summary` function.


```r
summary
#> function (object, ...) 
#> UseMethod("summary")
#> <bytecode: 0x55ea7c0bd208>
#> <environment: namespace:base>
```

The `UseMethod("summary")` part is telling us that R will invoke different methods for summarising different objects, depending on their class. Obviously, this makes sense. We wouldn't expect a data frame to be summarised in the same way as a regression object. To see which methods are available to `summary` in our current R session, we can use the `methods()` function:


```r
methods(summary)
#>  [1] summary,ANY-method             summary,DBIObject-method      
#>  [3] summary.aov                    summary.aovlist*              
#>  [5] summary.aspell*                summary.check_packages_in_dir*
#>  [7] summary.connection             summary.data.frame            
#>  [9] summary.Date                   summary.default               
#> [11] summary.Duration*              summary.ecdf*                 
#> [13] summary.factor                 summary.ggplot*               
#> [15] summary.glm                    summary.haven_labelled*       
#> [17] summary.hcl_palettes*          summary.infl*                 
#> [19] summary.Interval*              summary.lm                    
#> [21] summary.loess*                 summary.manova                
#> [23] summary.matrix                 summary.mlm*                  
#> [25] summary.nls*                   summary.packageStatus*        
#> [27] summary.Period*                summary.POSIXct               
#> [29] summary.POSIXlt                summary.ppr*                  
#> [31] summary.prcomp*                summary.princomp*             
#> [33] summary.proc_time              summary.rlang_error*          
#> [35] summary.rlang_trace*           summary.srcfile               
#> [37] summary.srcref                 summary.stepfun               
#> [39] summary.stl*                   summary.table                 
#> [41] summary.tukeysmooth*           summary.vctrs_sclr*           
#> [43] summary.vctrs_vctr*            summary.warnings              
#> see '?methods' for accessing help and source code
```

Here we see the list of possible summary methods, which all take the form `summary.OBJECTCLASS`. Behind the scenes, when we call `summary(x)`, R first determines the class of `x` and then dispatches to the appropriate summary method. If `x` is a data frame, it will invoke `summary.data.frame()`. If `x` is an `lm` object, it will invoke `summary.lm`. And so forth.^[As an aside, this insight also provides the key to extending a generic function like `summary()`. We simply need to define a new method for the particular object class that we're interested in (say "foo") using the same syntax form: `summary.foo = ...`.] Accessing the source code of a particular summary method is then a straightforward matter of being explicit about object class. For example:


```r
summary.data.frame
#> function (object, maxsum = 7L, digits = max(3L, getOption("digits") - 
#>     3L), ...) 
#> {
#>     ncw <- function(x) {
#>         z <- nchar(x, type = "w")
#>         if (any(na <- is.na(z))) {
#>             z[na] <- nchar(encodeString(z[na]), "b")
#>         }
#>         z
#>     }
#>     z <- lapply(X = as.list(object), FUN = summary, maxsum = maxsum, 
#>         digits = 12L, ...)
#>     nv <- length(object)
#>     nm <- names(object)
#>     lw <- numeric(nv)
#>     nr <- if (nv) 
#>         max(vapply(z, function(x) NROW(x) + !is.null(attr(x, 
#>             "NAs")), integer(1)))
#>     else 0
#>     for (i in seq_len(nv)) {
#>         sms <- z[[i]]
#>         if (is.matrix(sms)) {
#>             cn <- paste(nm[i], gsub("^ +", "", colnames(sms), 
#>                 useBytes = TRUE), sep = ".")
#>             tmp <- format(sms)
#>             if (nrow(sms) < nr) 
#>                 tmp <- rbind(tmp, matrix("", nr - nrow(sms), 
#>                   ncol(sms)))
#>             sms <- apply(tmp, 1L, function(x) paste(x, collapse = "  "))
#>             wid <- sapply(tmp[1L, ], nchar, type = "w")
#>             blanks <- paste(character(max(wid)), collapse = " ")
#>             wcn <- ncw(cn)
#>             pad0 <- floor((wid - wcn)/2)
#>             pad1 <- wid - wcn - pad0
#>             cn <- paste0(substring(blanks, 1L, pad0), cn, substring(blanks, 
#>                 1L, pad1))
#>             nm[i] <- paste(cn, collapse = "  ")
#>         }
#>         else {
#>             sms <- format(sms, digits = digits)
#>             lbs <- format(names(sms))
#>             sms <- paste0(lbs, ":", sms, "  ")
#>             lw[i] <- ncw(lbs[1L])
#>             length(sms) <- nr
#>         }
#>         z[[i]] <- sms
#>     }
#>     if (nv) {
#>         z <- unlist(z, use.names = TRUE)
#>         dim(z) <- c(nr, nv)
#>         if (anyNA(lw)) 
#>             warning("probably wrong encoding in names(.) of column ", 
#>                 paste(which(is.na(lw)), collapse = ", "))
#>         blanks <- paste(character(max(lw, na.rm = TRUE) + 2L), 
#>             collapse = " ")
#>         pad <- floor(lw - ncw(nm)/2)
#>         nm <- paste0(substring(blanks, 1, pad), nm)
#>         dimnames(z) <- list(rep.int("", nr), nm)
#>     }
#>     else {
#>         z <- character()
#>         dim(z) <- c(nr, nv)
#>     }
#>     attr(z, "class") <- c("table")
#>     z
#> }
#> <bytecode: 0x55ea81648b50>
#> <environment: namespace:base>
```

By the way, it's also possible to go the other way around; you can view all of the generic methods associated with a particular object class. For example, there are *lots* of valid methods associated with data frames:


```r
methods(class = "data.frame") 
#>   [1] [                 [[                [[<-              [<-              
#>   [5] $<-               add_count         aggregate         anti_join        
#>   [9] anyDuplicated     anyNA             arrange_          arrange          
#>  [13] as_factor         as_tibble         as.col_spec       as.data.frame    
#>  [17] as.data.table     as.list           as.matrix         as.tbl           
#>  [21] auto_copy         by                cbind             coerce           
#>  [25] coerce<-          collapse          collect           complete_        
#>  [29] complete          compute           count             dim              
#>  [33] dimnames          dimnames<-        distinct_         distinct         
#>  [37] do_               do                dplyr_col_modify  dplyr_reconstruct
#>  [41] dplyr_row_slice   drop_na_          drop_na           droplevels       
#>  [45] duplicated        edit              expand_           expand           
#>  [49] extract_          extract           fill_             fill             
#>  [53] filter_           filter            format            formula          
#>  [57] fortify           full_join         gather_           gather           
#>  [61] ggplot_add        glimpse           group_by_         group_by         
#>  [65] group_data        group_indices_    group_indices     group_keys       
#>  [69] group_map         group_modify      group_nest        group_size       
#>  [73] group_split       group_trim        group_vars        groups           
#>  [77] head              initialize        inner_join        intersect        
#>  [81] is.na             left_join         Math              merge            
#>  [85] mutate_           mutate            n_groups          na.exclude       
#>  [89] na.omit           nest_by           nest_join         nest_legacy      
#>  [93] nest              Ops               pivot_longer      pivot_wider      
#>  [97] plot              print             prompt            pull             
#> [101] rbind             relocate          rename_           rename_with      
#> [105] rename            replace_na        right_join        row.names        
#> [109] row.names<-       rows_delete       rows_insert       rows_patch       
#> [113] rows_update       rows_upsert       rowsum            rowwise          
#> [117] same_src          sample_frac       sample_n          select_          
#> [121] select            semi_join         separate_         separate_rows_   
#> [125] separate_rows     separate          setdiff           setequal         
#> [129] show              slice_            slice_head        slice_max        
#> [133] slice_min         slice_sample      slice_tail        slice            
#> [137] slotsFromS3       split             split<-           spread_          
#> [141] spread            stack             str               subset           
#> [145] summarise_        summarise         summary           Summary          
#> [149] t                 tail              tally             tbl_vars         
#> [153] transform         transmute_        transmute         type.convert     
#> [157] ungroup           union_all         union             unique           
#> [161] unite_            unite             unnest_legacy     unnest           
#> [165] unstack           within            xtfrm            
#> see '?methods' for accessing help and source code
```

In this brief addendum, we've focused on the source code for different dispatch methods. Accessing compiled source code (e.g. written in C or Fortran) is a bit more complicated and, frankly, beyond the scope of what we want to show you here. You are already well-equipped to peruse many of the key R functions that you are likely to be using. For a full length treatment of how to access source code of R functions, we recommend any of the three sources:

- Joshua Ulrich's StackOverflow Q/A: https://stackoverflow.com/a/19226817/4115816
- Jenny Bryan's summary: https://github.com/jennybc/access-r-source
- Jim Hester's **lookup** package, which can do all of the legwork for you if don't feel like dealing with manual complications: https://github.com/jimhester/lookup
