R tidyverse: dplyr
================
Kasper Welbers & Wouter van Attevedlt
2018-09

-   [This tutorial](#this-tutorial)
    -   [Exercise](#exercise)
    -   [About library()](#about-library)
    -   [Working with data.frames using dplyr](#working-with-data.frames-using-dplyr)
        -   [From data.frame to tibble](#from-data.frame-to-tibble)
        -   [subsetting with filter() and select()](#subsetting-with-filter-and-select)
        -   [adding or transforming variables with mutate()](#adding-or-transforming-variables-with-mutate)
        -   [aggregating with summarize() and group\_by()](#aggregating-with-summarize-and-group_by)
    -   [Working with Pipes](#working-with-pipes)

This tutorial
=============

The goal of this tutorial is to get you acquainted with the [Tidyverse](https://www.tidyverse.org/). This is a recent movement, that is well on its way in changing how many people are doing data science in R. Speaking broadly, the Tidyverse is a collection of packages that have been designed around a singular and clearly defined set of principles about what data should look like and how we should work with it. It comes with a nice introduction in the [R for Data Science](http://r4ds.had.co.nz/) book, for which the digital version is available for free. In this part of the tutorial, we'll focus on working with data.frames using the `dplyr` package.

You have already had to use `install.packages()` and `library()` in earlier tutorials. To jog your memory, `install.packages()` is used to download and install the package (one-time gig) and `library()` is used to make the functions from this package available for use (required each session that you use the package).

``` r
install.packages('dplyr')
```

``` r
library(dplyr)
```

Exercise
--------

This document contains a tutorial, and there is an excercise that you can find and complete in the separate **R\_tidyverse\_1\_practise.Rmd** file. You need to open this file in RStudio.

If you want to learn more about the Tidyverse, the free, online book [R for Data Science](http://r4ds.had.co.nz/) offers an excellent introduction and overview.

About library()
---------------

Now that you've become more acquainted with functions, this is a good time to explain a bit about what happens when you use `library()`. If you run `library(dplyr)`, you should have received a message (in red). Possibly, this messages has concerned you somewhat, because it's given in red, and red often means trouble. However, in this case the message is simply red because it is deemed important to know, so let's actually read it.

The first part says "Attaching packages: 'dplyr'". Practically speaking, this means that all the functions offered in the `dplyr` package can now be used. For the sake of completeness, it should be noted that this is not strictly necessary. You can also directly use a function from a package by typing `package_name::function_name`. For example, to use quanteda's `dfm()` function, we could directly have used `quanteda::dfm`. Still, it is often good practice to use `library()`. This doesn't only make code less verbose, it also states more clearly what packages your code relies on.

Now, what happens if the package contains functions with names that already exist? In the red message, you should also have seen the lines: "The following objects are masked from \[a certain package\]". This means that the listed functions indeed have names that overlap with names that already exist in the standard packages included in R, such as `base` and `stats`, or in other packages that you have 'attached' using `library()`.

Often, this is not a problem, but if a function suddenly doesn't do what you think it should, it could be that you have 'masked' (say, overwritten) it with a function from another package. In this case, if you want to use the function from one specific package, you can use the aforementioned `package_name::function_name` syntax.

If you have functions with the same name, they will also often have the same documentation page. For example, if we ask for the documentation page for the `filter()` function after running `library(dplyr)`, we will get a list with all the packages that have this documentation page.

``` r
?filter
```

Here we see that the function exists both in `dplyr` and `stats`, and we can click on the links to view the documentation page that we were looking for.

Working with data.frames using dplyr
------------------------------------

We will now demonstrate some of the common functions for working with data.frames in dplyr.

### From data.frame to tibble

First, we will show how to convert a data.frame to a special data.frame called a *tibble*, or *tbl*. This is a central object for working with data in the Tidyverse. It has several advantages over regular data.frames in terms of efficiency, speed, features, and the fact that it provides more useful information if you view it in your console. Still, it is essentially a data.frame, so what you learned last week still applies.

Here, we first obtain data by reading a csv file directly from a location on the internet. We then convert it to a tibble with the `as_data_frame()` function, and view it in the console.

``` r
url = "https://raw.githubusercontent.com/fivethirtyeight/data/master/poll-quiz-guns/guns-polls.csv"
d = read.csv(url)
d = as_data_frame(d)
d
```

We can see that the tibble is simply a data.frame. Conveniently, only the first ten rows are shown (which is faster and less messy), and if the columns don't fit they are not printed. The remaining rows and columns are printed at the bottom. For each column the data type is also mentioned (<int> stands for integer, which is a *numeric* value; <fctr> stands for *factor*). Recall that if you want to browse through your data, you can click on the name of the data.frame (d) in the top-right window "Environment" tab.

The data that we're using is a collection of polls, from different pollsters, about gun control in the US.

### subsetting with filter() and select()

The `filter()` and `select()` functions are the `dplyr` alternative to the `subset()` function. With `filter()`, you can create a subset of a selection of rows, whereas `select()` is used to create a subset of columns. We'll first look at the documentation for the `filter()` function. Since the name `filter` is also used in the standard `stats` package, you will have to select the `dplyr` entry from the list.

``` r
?filter
?select
```

The first argument, called `.data`, is the *tibble*. All other arguments are expressions to make selections. The documentation contains some links for useful filter functions and variants of the filter function. If the `...` notation is still confusing, the examples at the bottom provide a helping hand. Let's use the function to select only the cases (polls) for the `Question` "age-21" (should minimum purchase age be raised to 21?).

``` r
age21 = filter(d, Question == 'age-21')
age21
```

Moving on to the `select()` function, we will no longer discuss each documentation page. Select is used to select specific columns, and offers several convenient ways to do so. Firstly, we can simply name the columns that we want to retrieve them in that particular order.

``` r
select(age21, Population, Support, Pollster)
```

Secondly, we can immediately rename column by using named arguments.

``` r
select(age21, date = End, Pollster)
```

Thirdly, there are nice special selection functions such as `starts_with()` and `ends_with()` to look for column names that start/end with a given piece of text. This is very common in data, where there are often related variables such as sub questions (V1.a, V1.b, etc.) or categories (medium.NYT, medium.Guardian, etc.).

``` r
select(age21, Pollster, ends_with("Support"))
```

Finally, note that the documentation for `select()` also mentions `rename()` as an alternative. Unlike select, `rename()` only renames columns without removing unselected columns.

``` r
rename(age21, start_date = Start, end_date = End)
```

### adding or transforming variables with mutate()

The mutate function makes it easy to create new variables or to modify existing ones. For those more familiar with SPSS, this is what you would do with compute and recode.

If you look at the documentation page, you see that mutate works similarly to `filter()` and `select()`, in the sense that the first argument is the *tibble*, and then any number of additional arguments can be given to perform mutations. The mutations themselves are named arguments, in which you can provide any calculations using the existing columns.

Here we'll first create some variables and then look at the variables (using the `select` function to focus on the changes). Specifically, we'll make a column for the absolute difference between the support scores for republicans and democrats, as a measure of how much they disagree.

``` r
d = mutate(d, party_diff = abs(Republican.Support - Democratic.Support))
select(d, Question, Pollster, party_diff)
```

To transform (recode) a variable in the same column, you can simply use an existing name in `mutate()` to overwrite it.

A useful trick is that you can delete a column by assigning `NULL`. This is sometimes more convenient than using select.

``` r
mutate(d, Question = NULL, Start=NULL)
```

### aggregating with summarize() and group\_by()

The `summarize` function let's you summarize columns with summary statistics, such as *count*, *sum*, *mean* and *standard deviation*. This can be combined with `group_by()` to get summary statistics per group. This is more commonly referred to as aggregation, and is an absolute must in your data analytics toolbox.

Similar to `mutate()`, you must provide named arguments in which the summary is calculated. Importantly, the outcome of the calculation has to be a single value. Also see the **Usefull functions** section in the documentation for a list of functions that do this. We'll start by calculating the overall mean, standard deviation and number of observations for support. (Note that this is only an example, since it actually doesn't make sense to add the different polling questions in the data together.)

``` r
summarize(d, M = mean(Support), SD = sd(Support), N = n())
```

This shows that the mean support is 67.77, with a standard deviation of 16.04. As noted, however, it doesn't really make sense with this data to add the different polling questions together. Instead, it would be much more useful to get these scores per question. For this, we can first use `group_by()`.

``` r
dg = group_by(d, Question)
summarize(dg, M = mean(Support), SD = sd(Support), N = n())
```

We can just as easily group by multiple variables.

``` r
dg = group_by(d, Question, Population)
summarize(dg, M = mean(Support), SD = sd(Support))
```

Working with Pipes
------------------

You've now learned some of the most useful functions, but there is one additional trick in the Tidyverse approach that makes working with these functions much easier. Perhaps while browsing the documentation of the `dplyr` functions, you have noted that in the examples they often use this strange `%>%` notation. This is used to **pipe** functions together.

Put simply, pipes take the output of a function, and directly use that output as the input for the `.data` argument in the next function. As you have seen, all the `dplyr` functions that we discussed have in common that the first argument is a *tibble*, and all functions return a *tibble*. This is intentional, and allows us to pipe all the functions together.

To demonstrate this, we will first perform a simple analysis without using piping, and then show how to write this using pipes.

``` r
ds = d
ds = filter(d, Population == 'Registered Voters')            
ds = mutate(ds, party_diff = abs(Republican.Support - Democratic.Support))   
ds = group_by(ds, Question)                                   
ds = summarize(ds, M = mean(party_diff), SD = sd(party_diff), N = n()) 
ds
```

Let's not waste an opportunity to interpret some result. What we see here is the average absolute difference in support for statements between republicans and democrats. Most notably, we see that there is not much disagreement for the matter of background checks and mental health (here you can't see the actual support scores, but let's hope they agree wisely). In contrast, there is much more disagreement on issues such as arming teachers and banning assault weapons.

Moving on, we'll now perform the exact same analysis in pipe style.

``` r
d %>%
  filter(Population == 'Registered Voters') %>%
  mutate(party_diff = abs(Republican.Support - Democratic.Support)) %>%
  group_by(Question) %>%                                   
  summarize(M = mean(party_diff), SD = sd(party_diff), N = n()) 
```

The nice thing about pipes is that it makes it really clear what you are doing. Also, it doesn't require making many intermediate objects (such as `ds`). If applied right, piping allows you to make nicely contained pieces of code to perform specific parts of your analysis from raw input straight to results. Combined with other parts of the Tidyverse, this also includes visualization.
