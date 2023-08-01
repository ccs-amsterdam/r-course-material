Tidyverse I: tidy data
================

- <a href="#introduction-to-tidyverse"
  id="toc-introduction-to-tidyverse">Introduction to Tidyverse</a>
  - <a href="#installing-tidyverse" id="toc-installing-tidyverse">Installing
    tidyverse</a>
- <a href="#reading-data" id="toc-reading-data">Reading Data</a>
  - <a href="#creating-a-tibble" id="toc-creating-a-tibble">Creating a
    tibble</a>
  - <a href="#a-note-on-functions-and-assignment"
    id="toc-a-note-on-functions-and-assignment">A note on functions and
    assignment</a>
  - <a href="#reading-data-with-read_csv"
    id="toc-reading-data-with-read_csv">Reading data with
    <code>read_csv</code></a>
  - <a href="#exercise-downloading-data"
    id="toc-exercise-downloading-data">Exercise: downloading data</a>
- <a href="#selecting-renaming-and-filtering-data"
  id="toc-selecting-renaming-and-filtering-data">Selecting, renaming and
  filtering data</a>
  - <a href="#cleaning-columns-with-select-and-rename"
    id="toc-cleaning-columns-with-select-and-rename">Cleaning columns with
    <code>select</code> and <code>rename</code></a>
  - <a href="#renaming-and-non-standard-names"
    id="toc-renaming-and-non-standard-names">Renaming and non-standard
    names</a>
  - <a href="#assigning-results-to-objects"
    id="toc-assigning-results-to-objects">Assigning results to objects</a>
  - <a href="#exercise" id="toc-exercise">Exercise</a>

## Introduction to Tidyverse

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

### Installing tidyverse

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
misspelled package.

As a fairly trivial example, try running the (error) code below, have a
look at the error message, and fix the problem:

``` r
library(tidyvers) 
```

## Reading Data

\[Note: Please review [R Basics Tutorial](R-tidy-4-basics.md) if you are
uncertain about objects, values, and functions.\]

As in most packages, the functionality in dplyr is offered through
functions. In general, a function can be seen as a command or
instruction to the computer to do something and (generally) return the
result.

In the tidverse packages, almost all `functions` primarily operate on
data sets, for example for filtering and sorting data.

With a data set we mean a rectangular data frame consisting of rows
(often items or respondents) and columns (often measurements of or data
about these items). These data sets can be R `data.frames`, but
tidyverse has its own version of data frames called `tibble`, which is
mostly the same as a data frame but is more efficient and somewhat
easier to use.

### Creating a tibble

As a very simply example, the following code creates a tibble containing
respondents with a second column listing their gender:

``` r
respondents <- tibble(resp_id = c(1,2,3), 
                      gender = c("M","M","F"))
```

Let’s say our respondents are 24, 32 and 27 years old. Can you add a
column called ‘age’ that specifies this age for the respondents?

``` r
respondents <- tibble(resp_id = c(1,2,3), 
                      gender = c("M","M","F"))
respondents
```

    ## # A tibble: 3 × 2
    ##   resp_id gender
    ##     <dbl> <chr> 
    ## 1       1 M     
    ## 2       2 M     
    ## 3       3 F

### A note on functions and assignment

In the exercise above, you used the `tibble` function to create a new
data frame, which you then *assigned* to the respondents object. If you
would not have assigned it to an object, R would simply print the result
of the function on the screen and then forget all about it. So, whenever
you want R to remember the result of a function, you need to assign it
to an object and give it a name. You can also re-use an existing name,
in which case the object will be over-written by the new result.

When writing R code, 90% of your lines will follow this pattern of
calling a function on some arguments (e.g. the data), and assigning it
to an object:

``` r
my_object <- some_function(arguments)
```

### Reading data with `read_csv`

The example above manually created a data set, but in most cases you
will start with data that you get from elsewhere, such as a csv file
(e.g. downloaded from an online dataset or exported from excel) or an
SPSS or Stata data file.

Tidyverse contains a function `read_csv` that allows you to read a csv
file directly into a data frame. You specify the location of the file,
either on your local drive or directly from the Internet!

The example below downloads an overview of gun polls from the [data
analytics site 538](https://fivethirtyeight.com/), and reads it into a
tibble using the read_csv function:

``` r
url <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/poll-quiz-guns/guns-polls.csv"
gunpolls <- read_csv(url)
gunpolls
```

    ## # A tibble: 57 × 9
    ##    Question     Start   End     Pollster Population Support `Republican Support`
    ##    <chr>        <chr>   <chr>   <chr>    <chr>        <dbl>                <dbl>
    ##  1 age-21       2/20/18 2/23/18 CNN/SSRS Registere…      72                   61
    ##  2 age-21       2/27/18 2/28/18 NPR/Ips… Adults          82                   72
    ##  3 age-21       3/1/18  3/4/18  Rasmuss… Adults          67                   59
    ##  4 age-21       2/22/18 2/26/18 Harris … Registere…      84                   77
    ##  5 age-21       3/3/18  3/5/18  Quinnip… Registere…      78                   63
    ##  6 age-21       3/4/18  3/6/18  YouGov   Registere…      72                   65
    ##  7 age-21       3/1/18  3/5/18  Morning… Registere…      76                   72
    ##  8 arm-teachers 2/23/18 2/25/18 YouGov/… Registere…      41                   69
    ##  9 arm-teachers 2/20/18 2/23/18 CBS News Adults          44                   68
    ## 10 arm-teachers 2/27/18 2/28/18 Rasmuss… Adults          43                   71
    ## # ℹ 47 more rows
    ## # ℹ 2 more variables: `Democratic Support` <dbl>, URL <chr>

(Note that you can safely ignore the (red) message, they simply tell you
how each column was parsed)

The shows the first ten rows of the data set, and for each column the
data type is also mentioned: `<dbl>` stands for double, which is a
*numeric* value; `<chr>` is textual or *character* data.

Note that on your own computer, R will print a message if not all rows
or columns could be printed. If you want to browse through your data,
you can also click on the name of the data.frame (gunpolls) in the
top-right window “Environment” tab or call `View(d)`.

### Exercise: downloading data

A csv file of the political polls just after the fall of the Dutch
cabinet Rutte IV can be found at <https://i.amcat.nl/peiling.csv>. Can
you download that file and assign it to an object called `polls`?

``` r
polls <- ____
polls
```

## Selecting, renaming and filtering data

In the previous section, you managed to download data from the Internet.
Often, this data needs to be cleaned before we can use it for analysis.

R Tidyverse has a number of functions that can be used for data
cleaning. As a first step, let’s learn how to use `select` and `rename`
to change the *columns* of a data frame.

### Cleaning columns with `select` and `rename`

Let’s continue with the gun polls data we used above:

``` r
url <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/poll-quiz-guns/guns-polls.csv"
gunpolls <- read_csv(url)
gunpolls
```

    ## # A tibble: 57 × 9
    ##    Question     Start   End     Pollster Population Support `Republican Support`
    ##    <chr>        <chr>   <chr>   <chr>    <chr>        <dbl>                <dbl>
    ##  1 age-21       2/20/18 2/23/18 CNN/SSRS Registere…      72                   61
    ##  2 age-21       2/27/18 2/28/18 NPR/Ips… Adults          82                   72
    ##  3 age-21       3/1/18  3/4/18  Rasmuss… Adults          67                   59
    ##  4 age-21       2/22/18 2/26/18 Harris … Registere…      84                   77
    ##  5 age-21       3/3/18  3/5/18  Quinnip… Registere…      78                   63
    ##  6 age-21       3/4/18  3/6/18  YouGov   Registere…      72                   65
    ##  7 age-21       3/1/18  3/5/18  Morning… Registere…      76                   72
    ##  8 arm-teachers 2/23/18 2/25/18 YouGov/… Registere…      41                   69
    ##  9 arm-teachers 2/20/18 2/23/18 CBS News Adults          44                   68
    ## 10 arm-teachers 2/27/18 2/28/18 Rasmuss… Adults          43                   71
    ## # ℹ 47 more rows
    ## # ℹ 2 more variables: `Democratic Support` <dbl>, URL <chr>

``` r
gunpolls
```

    ## # A tibble: 57 × 9
    ##    Question     Start   End     Pollster Population Support `Republican Support`
    ##    <chr>        <chr>   <chr>   <chr>    <chr>        <dbl>                <dbl>
    ##  1 age-21       2/20/18 2/23/18 CNN/SSRS Registere…      72                   61
    ##  2 age-21       2/27/18 2/28/18 NPR/Ips… Adults          82                   72
    ##  3 age-21       3/1/18  3/4/18  Rasmuss… Adults          67                   59
    ##  4 age-21       2/22/18 2/26/18 Harris … Registere…      84                   77
    ##  5 age-21       3/3/18  3/5/18  Quinnip… Registere…      78                   63
    ##  6 age-21       3/4/18  3/6/18  YouGov   Registere…      72                   65
    ##  7 age-21       3/1/18  3/5/18  Morning… Registere…      76                   72
    ##  8 arm-teachers 2/23/18 2/25/18 YouGov/… Registere…      41                   69
    ##  9 arm-teachers 2/20/18 2/23/18 CBS News Adults          44                   68
    ## 10 arm-teachers 2/27/18 2/28/18 Rasmuss… Adults          43                   71
    ## # ℹ 47 more rows
    ## # ℹ 2 more variables: `Democratic Support` <dbl>, URL <chr>

This contains a number of columns that we might not be interested in.
Using `select`, we can select only the columns we are interested in:

``` r
select(gunpolls, Population, Support, Pollster)
```

    ## # A tibble: 57 × 3
    ##    Population        Support Pollster          
    ##    <chr>               <dbl> <chr>             
    ##  1 Registered Voters      72 CNN/SSRS          
    ##  2 Adults                 82 NPR/Ipsos         
    ##  3 Adults                 67 Rasmussen         
    ##  4 Registered Voters      84 Harris Interactive
    ##  5 Registered Voters      78 Quinnipiac        
    ##  6 Registered Voters      72 YouGov            
    ##  7 Registered Voters      76 Morning Consult   
    ##  8 Registered Voters      41 YouGov/Huffpost   
    ##  9 Adults                 44 CBS News          
    ## 10 Adults                 43 Rasmussen         
    ## # ℹ 47 more rows

You can also specify a range of columns, for example all columns from
Question to Support:

``` r
select(gunpolls, Question:Support)
```

    ## # A tibble: 57 × 6
    ##    Question     Start   End     Pollster           Population        Support
    ##    <chr>        <chr>   <chr>   <chr>              <chr>               <dbl>
    ##  1 age-21       2/20/18 2/23/18 CNN/SSRS           Registered Voters      72
    ##  2 age-21       2/27/18 2/28/18 NPR/Ipsos          Adults                 82
    ##  3 age-21       3/1/18  3/4/18  Rasmussen          Adults                 67
    ##  4 age-21       2/22/18 2/26/18 Harris Interactive Registered Voters      84
    ##  5 age-21       3/3/18  3/5/18  Quinnipiac         Registered Voters      78
    ##  6 age-21       3/4/18  3/6/18  YouGov             Registered Voters      72
    ##  7 age-21       3/1/18  3/5/18  Morning Consult    Registered Voters      76
    ##  8 arm-teachers 2/23/18 2/25/18 YouGov/Huffpost    Registered Voters      41
    ##  9 arm-teachers 2/20/18 2/23/18 CBS News           Adults                 44
    ## 10 arm-teachers 2/27/18 2/28/18 Rasmussen          Adults                 43
    ## # ℹ 47 more rows

Finally, it is also possible to drop columns by placing a minus sign in
front of the column name. For example, this will drop the URL column and
keep all other columns:

``` r
select(gunpolls, -URL)
```

    ## # A tibble: 57 × 8
    ##    Question     Start   End     Pollster Population Support `Republican Support`
    ##    <chr>        <chr>   <chr>   <chr>    <chr>        <dbl>                <dbl>
    ##  1 age-21       2/20/18 2/23/18 CNN/SSRS Registere…      72                   61
    ##  2 age-21       2/27/18 2/28/18 NPR/Ips… Adults          82                   72
    ##  3 age-21       3/1/18  3/4/18  Rasmuss… Adults          67                   59
    ##  4 age-21       2/22/18 2/26/18 Harris … Registere…      84                   77
    ##  5 age-21       3/3/18  3/5/18  Quinnip… Registere…      78                   63
    ##  6 age-21       3/4/18  3/6/18  YouGov   Registere…      72                   65
    ##  7 age-21       3/1/18  3/5/18  Morning… Registere…      76                   72
    ##  8 arm-teachers 2/23/18 2/25/18 YouGov/… Registere…      41                   69
    ##  9 arm-teachers 2/20/18 2/23/18 CBS News Adults          44                   68
    ## 10 arm-teachers 2/27/18 2/28/18 Rasmuss… Adults          43                   71
    ## # ℹ 47 more rows
    ## # ℹ 1 more variable: `Democratic Support` <dbl>

### Renaming and non-standard names

In R, it is easiest if a column name does not contain any spaces or
other special characters. To select such columns, you need to use
‘backticks’ around the name (`` `like this` ``). Because this is
inconvenient, is is often better to rename such columns so they no
longer contain a space. Note that instead of a space, you can use an
underscore (`_`) if desired.

In R, you can use the `rename` function to change the name of one or
more variables:

``` r
rename(gunpolls, rep = `Republican Support`, dem = `Democratic Support`)
```

    ## # A tibble: 57 × 9
    ##    Question     Start   End     Pollster    Population Support   rep   dem URL  
    ##    <chr>        <chr>   <chr>   <chr>       <chr>        <dbl> <dbl> <dbl> <chr>
    ##  1 age-21       2/20/18 2/23/18 CNN/SSRS    Registere…      72    61    86 http…
    ##  2 age-21       2/27/18 2/28/18 NPR/Ipsos   Adults          82    72    92 http…
    ##  3 age-21       3/1/18  3/4/18  Rasmussen   Adults          67    59    76 http…
    ##  4 age-21       2/22/18 2/26/18 Harris Int… Registere…      84    77    92 http…
    ##  5 age-21       3/3/18  3/5/18  Quinnipiac  Registere…      78    63    93 http…
    ##  6 age-21       3/4/18  3/6/18  YouGov      Registere…      72    65    80 http…
    ##  7 age-21       3/1/18  3/5/18  Morning Co… Registere…      76    72    86 http…
    ##  8 arm-teachers 2/23/18 2/25/18 YouGov/Huf… Registere…      41    69    20 http…
    ##  9 arm-teachers 2/20/18 2/23/18 CBS News    Adults          44    68    20 http…
    ## 10 arm-teachers 2/27/18 2/28/18 Rasmussen   Adults          43    71    24 http…
    ## # ℹ 47 more rows

Very often, a first step in data cleaning is renaming some columns and
dropping others. This can be combined in a single step by renaming in
the `select` function:

``` r
select(gunpolls, Question, rep = `Republican Support`, dem = `Democratic Support`)
```

    ## # A tibble: 57 × 3
    ##    Question       rep   dem
    ##    <chr>        <dbl> <dbl>
    ##  1 age-21          61    86
    ##  2 age-21          72    92
    ##  3 age-21          59    76
    ##  4 age-21          77    92
    ##  5 age-21          63    93
    ##  6 age-21          65    80
    ##  7 age-21          72    86
    ##  8 arm-teachers    69    20
    ##  9 arm-teachers    68    20
    ## 10 arm-teachers    71    24
    ## # ℹ 47 more rows

Note the difference between the two functions: `rename` keeps all
variables that are not mentioned, while `select` only keeps the
variables that you selected.

### Assigning results to objects

In the examples above, the result of the select or rename was not
assigned to an object. This means that the results are printed on the
screen, but not remembered. In other words, the gunpolls object will
contain the same data after running the command.

To store the results of select or rename (or any other function), you
need to *assign* it to an object and give it a name. This can be a new
name, in which case a *copy* of the object will be made, so both objects
can be used later. After running the code below, both the full
`gunpolls` object (with all columns), and the `gunpolls_clean` object
will be remembered by R, so you can choose to continue analysing either.
This is most useful if you want to do some analyses on the subset of the
data, but also need to do other analyses on a different subset later.

``` r
gunpolls_clean <- select(gunpolls, Question, rep = `Republican Support`, dem = `Democratic Support`)
gunpolls_clean
```

    ## # A tibble: 57 × 3
    ##    Question       rep   dem
    ##    <chr>        <dbl> <dbl>
    ##  1 age-21          61    86
    ##  2 age-21          72    92
    ##  3 age-21          59    76
    ##  4 age-21          77    92
    ##  5 age-21          63    93
    ##  6 age-21          65    80
    ##  7 age-21          72    86
    ##  8 arm-teachers    69    20
    ##  9 arm-teachers    68    20
    ## 10 arm-teachers    71    24
    ## # ℹ 47 more rows

If you assign it to the same name, it will overwrite the data:

``` r
gunpolls <- select(gunpolls, Question, rep = `Republican Support`, dem = `Democratic Support`)
gunpolls
```

    ## # A tibble: 57 × 3
    ##    Question       rep   dem
    ##    <chr>        <dbl> <dbl>
    ##  1 age-21          61    86
    ##  2 age-21          72    92
    ##  3 age-21          59    76
    ##  4 age-21          77    92
    ##  5 age-21          63    93
    ##  6 age-21          65    80
    ##  7 age-21          72    86
    ##  8 arm-teachers    69    20
    ##  9 arm-teachers    68    20
    ## 10 arm-teachers    71    24
    ## # ℹ 47 more rows

This is useful if you will not need to data you discarded. To summarize:

``` r
some_function(data)          # <-- print on screen and forget
data2 <- some_function(data) # <-- create a new object and keep both
data2 <- some_function(data) # <-- overwrite the old object
```

### Exercise

Using the gun polls data from above, rename the `Republican Support` and
`Democratic Support` columns to `rep_support` and `dem_support`, and
select only the Question, Pollster, and republicat/democratic support
columns. Assign the result to the `gunpolls` object

``` r
url <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/poll-quiz-guns/guns-polls.csv"
gunpolls <- read_csv(url)
___

gunpolls  # prints the result on screen
```
