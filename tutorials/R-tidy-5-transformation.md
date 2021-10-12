R Tidyverse: Data transformation
================
Kasper Welbers, Wouter van Atteveldt & Philipp Masur
2021-10

-   [Introduction](#introduction)
    -   [Installing tidyverse](#installing-tidyverse)
-   [Tidyverse basics](#tidyverse-basics)
    -   [Reading data: read\_csv](#reading-data-read_csv)
    -   [Subsetting with filter()](#subsetting-with-filter)
    -   [Aside: getting help on (tidy)
        function](#aside-getting-help-on-tidy-function)
    -   [Selecting certain columns](#selecting-certain-columns)
    -   [Sorting with arrange()](#sorting-with-arrange)
    -   [Adding or transforming variables with
        mutate()](#adding-or-transforming-variables-with-mutate)
-   [Working with Pipes](#working-with-pipes)

# Introduction

The goal of this tutorial is to get you acquainted with the
[Tidyverse](https://www.tidyverse.org/). Tidyverse is a collection of
packages that have been designed around a singular and clearly defined
set of principles about what data should look like and how we should
work with it. It comes with a nice introduction in the [R for Data
Science](http://r4ds.had.co.nz/) book, for which the digital version is
available for free. This tutorial deals with most of the material in
chapter 5 of that book.

In this part of the tutorial, we’ll focus on working with data using the
`tidyverse` package. This package includes the `dplyr` (data-pliers)
packages, which contains most of the tools we’re using below, but it
also contains functions for reading, analysing and visualising data that
will be explained later.

## Installing tidyverse

As before, `install.packages()` is used to download and install the
package (you only need to do this once on your computer) and `library()`
is used to make the functions from this package available for use
(required each session that you use the package).

``` r
install.packages('tidyverse') # only needed once
```

``` r
library(tidyverse)
```

Note: don’t be scared if you see a red message after calling `library`.
RStudio doesn’t see the difference between messages, warnings, and
errors, so it displays all three in red. You need to read the message,
and it will contain the word ‘error’ if there is an error, such as a
misspelled package:

``` r
library(tidyvers) # this will cause an error!
```

# Tidyverse basics

\[Note: Please review [R Basics Tutorial](R-tidy-4-basics.md) if you are
uncertain about objects, values, and functions.\]

As in most packages, the functionality in dplyr is offered through
functions. In general, a function can be seen as a command or
instruction to the computer to do something and (generally) return the
result. In the tidverse package `dplyr`, almost all `functions`
primarily operate on data sets, for example for filtering and sorting
data.

With a data set we mean a rectangular data frame consisting of rows
(often items or respondents) and columns (often measurements of or data
about these items). These data sets can be R `data.frames`, but
tidyverse has its own version of data frames called `tibble`, which is
functionally (almost) equivalent to a data frame but is more efficient
and somewhat easier to use.

As a very simply example, the following code creates a tibble containing
respondents, their gender, and their height:

``` r
tibble(resp = c(1,2,3), 
       gender = c("M","M","F"), 
       height = c(176, 165, 172))
```

## Reading data: read\_csv

The example above manually created a data set, but in most cases you
will start with data that you get from elsewhere, such as a csv file
(e.g. downloaded from an online dataset or exported from excel) or an
SPSS or Stata data file.

Tidyverse contains a function `read_csv` that allows you to read a csv
file directly into a data frame. You specify the location of the file,
either on your local drive or directly from the Internet!

The example below downloads an overview of gun polls from the [data
analytics site 538](https://fivethirtyeight.com/), and reads it into a
tibble using the read\_csv function:

``` r
url <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/poll-quiz-guns/guns-polls.csv"
d <- read_csv(url)
d
```

(Note that you can safely ignore the (red) message, they simply tell you
how each column was parsed)

The shows the first ten rows of the data set, and if the columns don’t
fit they are not printed. The remaining rows and columns are printed at
the bottom. For each column the data type is also mentioned (<int>
stands for integer, which is a *numeric* value; <chr> is textual or
*character* data). If you want to browse through your data, you can also
click on the name of the data.frame (d) in the top-right window
“Environment” tab or call `View(d)`.

## Subsetting with filter()

The `filter` function can be used to select a subset of rows. In the
guns data, the `Question` column specifies which question was asked. We
can select only those rows (polls) that asked whether the minimum
purchage age for guns should be raised to 21:

``` r
age21 <- filter(d, Question == 'age-21')
age21
```

This call is typical for a tidyverse function: the first argument is the
data to be used (`d`), and the remaining argument(s) contain information
on what should be done to the data.

Note the use of `==` for comparison: In R, `=` means assingment and `==`
means equals. Other comparisons are e.g. `>` (greather than), `<=` (less
than or equal) and `!=` (not equal). You can also combine multiple
conditions with logical (boolean) operators: `&` (and), `|` or, and `!`
(not), and you can use parentheses like in mathematics.

So, we can find all surveys where support for raising the gun age was at
least 80%:

``` r
filter(d, Question == 'age-21' & Support >= 80)
```

Note that this command did not assign the result to an object, so the
result is only displayed on the screen but not remembered. This can be a
great way to quickly inspect your data, but if you want to continue
analysing this subset you need to assign it to an object as above.

## Aside: getting help on (tidy) function

As explained earlier, to get help on a function you can type `?filter`
in the console or search for filter in the help pane. In both cases, you
need to specify that you mean filter from the dplyr package, as there is
also a filter function in other packages.

If you look at the help page, you will first see the general
*description*. This is followed by *Usage*, which shows how the function
should be called. In this case, it lists `filter(.data, ...)`. The first
argument (`.data`) makes sense, but the `...` is confusing. What is
means is that you can give an arbitrary number of extra arguments, that
will (in this case) all be used as filters. This is explained in the
*Arguments*: the `...` arguments are ‘Logical predicates defined in
terms of the variables in .data’.

The remainder give extra information on what exactly the function does
(Details), the output it produces (Value), and links to other useful
packages, functions, and finally a number examples.

Although it may seem intimidating at first, it is important to get used
to style of the R documentation as it is the primary source of
information on most functions and packages you will be using!

## Selecting certain columns

Where `filter` selects specific rows, `select` allows you to select
specific columns. Most simply, we can simply name the columns that we
want to retrieve them in that particular order.

``` r
select(age21, Population, Support, Pollster)
```

You can also specify a range of columns, for example all columns from
Support to Democratic Support:

``` r
select(age21, Support:`Democratic Support`)
```

Note the use of ‘backticks’ (reverse quotes) to specify the column name,
as R does not normally allow spaces in names.

Select can also be used to rename columns when selecting them, for
example to get rid of the spaces:

``` r
select(age21, Pollster, rep = `Republican Support`, dem = `Democratic Support`)
```

Note that `select` drops all columns not selected. If you only want to
rename columns, you can use the `rename` function:

``` r
rename(age21, start_date = Start, end_date = End)
```

Finally, you can drop a variable by adding a minus sign in front of a
name:

``` r
select(age21, -Question, -URL)
```

## Sorting with arrange()

You can easily sort a data set with `arrange`: you first specify the
data, and then the column(s) to sort on. To sort in descending order,
put a minus in front of a variable. For example, the following orders by
population and then by support (descending):

``` r
age21 <- arrange(age21, Population, -Support)
age21
```

Note that I assigned the result of arranging to the `age21` object
again, i.e. I replace the object by its sorted version. If I wouldn’t
assign it to anything, it would display it on screen but not remember
the sorting. Assigning a result to the same name means I don’t create a
new object, preventing the environment from being cluttered (and saving
me from the bother of thinking up yet another object name). For sorting,
this should generally be fine as the sorted data should contain the same
data as before. For subsetting, this means that the rows or columns are
actually deleted from the dataset (in memory), so you will have to read
the file again (or start from an earlier object) if you need those rows
or columns later.

## Adding or transforming variables with mutate()

The `mutate` function makes it easy to create new variables or to modify
existing ones. For those more familiar with SPSS, this is what you would
do with compute and recode.

If you look at the documentation page, you see that mutate works
similarly to `filter()` and `select()`, in the sense that the first
argument is the *tibble*, and then any number of additional arguments
can be given to perform mutations. The mutations themselves are named
arguments, in which you can provide any calculations using the existing
columns.

Here we’ll first create some variables and then look at the variables
(using the `select` function to focus on the changes). Specifically,
we’ll make a column for the absolute difference between the support
scores for republicans and democrats, as a measure of how much they
disagree.

``` r
age21 <- mutate(age21, party_diff = abs(`Republican Support` - `Democratic Support`))
select(age21, Question, Pollster, party_diff)
age21 <- arrange(age21, Population, -Support)
```

To transform (recode) a variable in the same column, you can simply use
an existing name in `mutate()` to overwrite it.

# Working with Pipes

If you look at the code above, you notice that the result of each
function is stored as an object, and that this object is used as the
first argument for the next function. Moreover, we don’t really care
about this temporary object, we only care about the final summary table.

This is a very common usage pattern, and it can be seen as a *pipeline*
of functions, where the output of each function is the input for the
next function. Because this is so common, tidyverse offers a more
convenient way of writing the code above using the pipeline operator
`%>%`. In sort, whenever you write `f(a, x)` you can replace it by
`a %>% f(x)`. If you then want to use the output of `f(a, x)` for a
second function, you can just add it to the pipe: `a %>% f(x) %>% f2(y)`
is equivalent to `f2(f(a,x), y)`, or more readable, `b=f(a,x); f2(b, y)`

Put simply, pipes take the output of a function, and directly use that
output as the input for the `.data` argument in the next function. As
you have seen, all the `dplyr` functions that we discussed have in
common that the first argument is a *tibble*, and all functions return a
*tibble*. This is intentional, and allows us to pipe all the functions
together.

This seems a bit abstract, but consider the code below, which is a
collection of statements from above:

``` r
d <- read_csv(url)
age21 <- filter(d, Question == 'age-21')
age21 <- mutate(age21, party_diff = abs(`Republican Support` - `Democratic Support`))
age21 <- select(age21, Question, Pollster, party_diff)
arrange(age21, -party_diff)
```

To recap, this reads the csv, filters by question, computes the
difference, drops other variables, and sorts. Since the output of each
function is the input of the next, we can also write this as a single
pipeline:

``` r
read_csv(url) %>% 
  filter(Question == 'age-21') %>% 
  mutate(party_diff = abs(`Republican Support` - `Democratic Support`)) %>%
  select(Question, Pollster, party_diff) %>% 
  arrange(-party_diff)
```

The nice thing about pipes is that it makes it really clear what you are
doing. Also, it doesn’t require making many intermediate objects (such
as `ds`). If applied right, piping allows you to make nicely contained
pieces of code to perform specific parts of your analysis from raw input
straight to results, including statistical modeling or visualization. It
usually makes sense to have each “step” in the pipeline in its own line.
This way, we can easily read the code line by line

Of course, you probably don’t want to replace your whole script with a
single pipe, and often it is nice to store intermediate values. For
example, you might want to download, clean, and subset a data set before
doing multiple analyses with it. In that case, you probably want to
store the result of downloading, cleaning, and subsetting as a variable,
and use that in your analyses.
