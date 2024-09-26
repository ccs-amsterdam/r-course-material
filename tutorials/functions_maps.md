Fuctions and mapping
================
Wouter van Atteveldt
September 2024

- [Introduction](#introduction)
- [Writing your own Functions](#writing-your-own-functions)
  - [Why use functions?](#why-use-functions)
- [Mapping](#mapping)
  - [The `map` function](#the-map-function)
  - [Mapping to data frames](#mapping-to-data-frames)
  - [Showing progress](#showing-progress)

## Introduction

All the time that you have been using R, you have been using
**functions**. For example, consider the call to sort a data frame
`data` by a column `result`:

``` r
sorted <- arrange(data, result)
```

The code above is a **function call**: the function is called `arrange`.
This function is called with `data` and `results` as **arguments**: the
function is asked to do something with these objects, in this case, sort
the object `data` using the `results` column. Finally, the function
**returns** a value, which we store as sorted.

So far, all these functions were either built-in to R (like `mean`), or
imported from a package like `tidyverse`. However, you can also write
your own functions in R.

For example, try calling the code below:

``` r
library(tidyverse)
hello <- function(name) {
  greeting <- str_c("Hello, ", name, ", good to see you!")
  return(greeting)
}

hello("World")
```

What happens if you put your own name instead of “World” in the last
line? What happens if you add another call at the bottom,
e.g. `hello("it's me")`? And what happens if you remove all `hello(...)`
calls?

## Writing your own Functions

The general syntax to create a function is as follows:

``` r
my_name <- function(arguments) {
  # ... body ...
}
```

For example, earlier we created the function `hello`:

``` r
hello <- function(name) {
  greeting <- str_c("Hello, ", name, ", good to see you!")
  return(greeting)
}
```

The first line, `function(name)`, creates a function which requires one
argument, `name`. This function is assigned the name `hello` (but of
course we could have assigned it any name we wanted!).

The function *body* is the part between the curly brackets `{...}`. The
first line calls the `str_c` function, which simply **c**ombines the
**str**ings (text) in its arguments to create the `greeting`. The second
line **returns** this value, meaning that when you call this function,
the result will be this greeting.

Note that the code above doesn’t actually really do anything. If
*defines* the functions, but the function is not actually executed until
you call it, i.e. with `hello('world')`

<div class="Info">

The code above explicitly `return`s the result. If you don’t include a
return value, the result of the last line will be implictly returned.
So, we could also have written:

``` r
hello <- function(name) {
  str_c("Hello, ", name, ", good to see you!")
}
```

Since this is shorter, many R veterans will prefer this – but of course
it’s up to you how you write your functions. They are your functions,
after all!

</div>

### Why use functions?

The code above shows how you can create a function, but doesn’t really
tell you **why** (or when) you should do this.

The main benefit of using functions is because it allows you to re-use
code more efficiently. For example, suppose you need to compute z-scores
for different columns, e.g. in the Dutch demographics data:

``` r
library(tidyverse)
demographics <- read_csv("https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/dutch_demographics.csv")
demographics |> select(gemeente, v01_pop:v43_nl) |>
  mutate(
    v01_pop_z=(v01_pop - mean(v01_pop)) / sd(v01_pop),
    v57_density_z=(v57_density - mean(v57_density)) / sd(v57_density),
    v43_nl_z=(v43_nl - mean(v43_nl)) / sd(v43_nl)
  )
```

The code above works, but it is cumbersome to type: imagine doing this
for 20 variables! Also, the code is error prone: it’s easy to make a
small mistake with code like this, and often hard to spot. Finally, the
code is hard to read: you see a lot of computations, but it’s not
trivial to see that these are z-score calculations, all it’s not even
easy to see that they’re all the same computation.

**Exercise:** In the code below, a function `zscore` is created and the
z-score calculation for `v01_pop` is changed to use this function. Can
you change the other two calculations? Check the result with the call
above. Are the results the same?

``` r
library(tidyverse)
zscore <- function(x) {
  z <- (x - mean(x)) / sd(x)
  return(z)
}

demographics <- read_csv("https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/dutch_demographics.csv")
demographics |> select(gemeente, v01_pop:v43_nl) |>
  mutate(
    v01_pop_z=zscore(v01_pop),
    v57_density_z=(v57_density - mean(v57_density)) / sd(v57_density),
    v43_nl_z=(v43_nl - mean(v43_nl)) / sd(v43_nl)
  )
```

Congratulations! You now know all you really need to know about creating
your own functions in R.

<div class="Info">

If you need to do the same calculation on multiple columns, tidyverse
also has a built-in function `across` to do this. If they are
essentially the same variable, e.g. for different years, you could also
`pivot_longer` the columns so they all fold into a single column, and do
a regular `mutate` on that column. These functions are not explained in
this tutorial, but you can read `help(across)` and `help(pivot_longer)`
if you’re curious!

</div>

## Mapping

One of the places functions come in handy is when you need to run an
operation on multiple objects. For example, maybe you need to clean
multiple files, analyse reports from different years, etc.

In that case, you can of course create a function for the action,
e.g. `clean_report`, and then call that function multiple times.
However, if the number of items becomes large, it is not so nice to copy
paste the same line over and over again:

``` r
clean_report <- function(report_file) {
  # TODO: do something smart with the report file!
}

report_1980 <- clean_report("report_1980.pdf")
report_1981 <- clean_report("report_1981.pdf")
# ....
report_2023 <- clean_report("report_1981.pdf")
```

### The `map` function

One way to solve this is using the tidyverse `map` functions. To use
map, you call the `map` function with two arguments: a list of objects,
and a function to be called on each of those objects.

The following (dummy) code has a function to claims to be analysing some
sort of report (but in reality just returns a random number), which is
then called on three different reports in a single `map` call:

``` r
library(tidyverse)
clean_report <- function(report_file) {
  # We should really extract the GDP from the country from the report
  # But I'm too lazy now, so let's just get a random number!
  gdp <- rnorm(1, mean=0, sd=1)
  return(gdp)
}

report_files = c("report_1980.pdf", "report_1981.pdf", "report_2023.pdf")
reports <- map(report_files, clean_report)
reports
```

Go ahead and run the code! As you can see, the code calls the
clean_report function on each item in the `report_file`s, and returns
the individual (random) results.

Note: the `rnorm` simply returns one (or more) values from a normal
distribution. Can you try changing e.g. the mean and seeing how it
affects the results?

(of course, in a real analysis this should actually extract information
from the report, but too keep things simple we just guess a number here.
I swear that’s not how we normally do our analyses!)

### Mapping to data frames

The resulting `reports` looks a bit strange, because it’s a `list`,
which is not an object type we have seen a lot so far. In most cases, we
would prefer to work with data frames rather than lists.

Fortunately, this is quite easy as well. For this, we need to make two
changes to our code. First, the function should return a `data.frame` –
or a `tibble`, which is just a fancy tidyverse version of a data frame.
Second, we pipe the result of `map` into the `list_rbind()` function,
which takes the **list** of individual tibble results and **bind**s
their **r**ows into a single tibble. That’s all!

``` r
library(tidyverse)
clean_report <- function(report_file) {
  gdp <- rnorm(1, mean=0, sd=1)
  tibble(report=report_file, gdp=gdp)
}

report_files = c("report_1980.pdf", "report_1981.pdf", "report_2023.pdf")
reports <- map(report_files, clean_report) |> list_rbind()
reports
```

As you can see, the code above creates a `tibble` containing the report
name in addition to the gdp result. It is a good practice to include
some identified of the input (e.g. file name, url, country name, etc) in
the result of the function, as that makes it easy to see which result
came from which input.

**Exercise**: Can you add another column to the tibble above, for
example drawing a second random number?

### Showing progress

The example above finished really quickly because we’re not actually
doing any analysis. Often, the work can take quite long, for example if
we need to read in each file, extract some numbers from it, and do
complicated modeling on it.

In such cases, it is nice if you can see how far along the process is.
This is made really easy using mapping functions: you can just add an
argument `.progress=TRUE` to the map call.

In the code below, we mimick a really slow processing by adding
`Sys.sleep(.5)` in the function, meaning that it will take half a second
to ‘process’ each report. We also generate a longer list of reports, by
automatically creating file names from all numbers between 1980 and
2023:

``` r
library(tidyverse)
clean_report <- function(report_file) {
  Sys.sleep(.1)  # Working hard, or hardly working?
  gdp <- rnorm(1, mean=0, sd=1)
  tibble(report=report_file, gdp=gdp)
}

report_files = str_c("report_", 1980:2023, ".pdf")
map(report_files, clean_report, .progress=TRUE) |> list_rbind()
```

Note: unfortunately the interactive tutorials do not display the
progress bar. To see it in action, copy the code above into R and run
it!
