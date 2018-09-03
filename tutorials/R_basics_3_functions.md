R basics: Functions
================
Kasper Welbers & Wouter van Atteveldt
2017

-   [This tutorial](#this-tutorial)
    -   [Structure of this lab exercise](#structure-of-this-lab-exercise)
-   [Functions in R](#functions-in-r)
    -   [What are functions](#what-are-functions)
    -   [Using functions](#using-functions)
        -   [Viewing and interpreting function documentation](#viewing-and-interpreting-function-documentation)
        -   [Understanding multi-argument functions](#understanding-multi-argument-functions)
        -   [A small note about 'methods' and 'generic functions'](#a-small-note-about-methods-and-generic-functions)
        -   [The special case of the three dot ellipsis](#the-special-case-of-the-three-dot-ellipsis)
-   [Using packages: data.frames in the Tidyverse](#using-packages-data.frames-in-the-tidyverse)
    -   [About library()](#about-library)
    -   [Working with data.frames using dplyr](#working-with-data.frames-using-dplyr)
        -   [From data.frame to tibble](#from-data.frame-to-tibble)
        -   [subsetting with filter() and select()](#subsetting-with-filter-and-select)
        -   [adding or transforming variables with mutate()](#adding-or-transforming-variables-with-mutate)
        -   [aggregating with summarize() and group\_by()](#aggregating-with-summarize-and-group_by)
    -   [Working with Pipes](#working-with-pipes)

This tutorial
=============

Last week you learned about the basic data types and structures in R. This week, we'll first delve into **Functions**, as the main vehicle for performing operations in R. You'll learn how to use functions, and how to get more functions by installing and using packages. As you will see, all functions are in fact created equal (i.e. they work in the same way), so by learning how to use them, you immediately gain access to countless new techniques.

The second goal of this week is to get you acquainted with the [Tidyverse](https://www.tidyverse.org/). This is a recent movement, that is well on its way in changing how many people are doing data science in R. Speaking broadly, the Tidyverse is a collection of packages that have been designed around a singular and clearly defined set of principles about what data should look like and how we should work with it. It comes with a nice introduction in the [R for Data Science](http://r4ds.had.co.nz/) book, for which the digital version is available for free.

Structure of this lab exercise
------------------------------

This week's lab consists of two parts:

-   Functions in R
-   Using packages: data.frames in the Tidyverse

Each parts has an assignment, that you can find and complete in the separate **Lab\_week3\_assignment\_template.Rmd** file on Canvas. You need to open this file in RStudio.

If, after this introduction, you want to learn about *functions*, and in particular want to learn how to build your own functions (which opens up a whole world of possibilities), we recommend [this blog post](https://www.datacamp.com/community/tutorials/functions-in-r-a-tutorial) from DataCamp. If you want to learn more about `dplyr` and the Tidyverse, the free, online book [R for Data Science](http://r4ds.had.co.nz/) is your loyal companion.

Functions in R
==============

What are functions
------------------

There are many correct and formal ways to define what functions are, but for the sake of simplicity we will ignore formalities and instead focus on an informal description of how you can think of functions in R:

-   A function has the form: `output = function_name(argument1, argument2, ...)`
    -   **function\_name** is a name to indicate which function you want to use. It is followed by parentheses.
    -   **arguments** are the input of the function, and are inserted within the parentheses. Arguments can be any R object, such as numbers, strings, vectors and data.frames. Multiple arguments can be given, separated by commas.
    -   **output** is anything that is returned by the function, such as vectors, data.frames, visualizations or the results of a statistical analysis.
-   The purpose of a function is to make it easy to perform a (large) set of (complex) operations. This is crucial, because
    -   It makes code easier to understand. You don't need to see the operations, just the name of the function that performs them
    -   You don't need to develop or even understand the operations, just how to use the function

For example, say that you need to calculate the square root of a number. This is a very common thing to do in statistical analysis, but it actually requires a quite complicated set of operations to perform. This is when you want to use a function, in this case the `sqrt` (square root) function.

``` r
sqrt(5)
```

In this example, the function name is `sqrt`. The input is the single argument `5`. If you run this code, it produces the output `2.236068`. Currently, R will simply print this output in your Console, but as you learned before, we can assign this output to a name.

``` r
square_root = sqrt(5)
```

This simple process of input -&gt; function -&gt; output is essentially how you work with R most of the times. You have data in some form. You provide this data as input to a function, and R generates output. You can assign the output to a name to use it in the next steps, or sometimes the output is a visualization or statistical model that you want to interpret.

Using functions
---------------

Above you saw the simple function `sqrt()`, that given a single number as input returned a single number. As you have also seen in the first week, functions can have multiple arguments as input. Recall the following function from the Rfacebook package that you used in week 1. You don't have to run the code this time (this requires first opening the Rfacebook package and assigning the token), just try to recognize the arguments.

``` r
d = getPage(page = 'greenpeace.international', token = token, 
            n = Inf, since = '2017-01-01', until = '2017-12-31')
```

This function, with the name `getPage`, is given several arguments here: `page`, `token`, `n`, `since`, and `until`. Given this input, a huge amount of operations is performed to collect the data that you requested from Facebook and to return the data as an object in R.

By now we hope you have realized just how broad the use of functions is. The *R syntax* for performing basic mathematical operations such as `sqrt()` is essentially the same as the syntax for collecting data from Facebook. Accordingly, if you understand this syntax, you can do almost anything in R. Indeed, the many R packages that you can install are mostly just collections of functions (some also provide new **classes**, which we'll save for later). We will now show how you can learn how to use each function by knowing how to view and interpret it's documentation page.

### Viewing and interpreting function documentation

You can access the documentation of a function by typing a question mark in front of the function name, and running the line of code. Let's do this to view the documentation of the `sqrt()` function

``` r
?sqrt
```

If you run this in RStudio, the help page will pop-up in the bottom-right corner, under the *Help* tab page. Sometimes, if the name of a documentation page is used in multiple packages, you will first receive a list of these packages from which you will have to select the page.

For the `sqrt()` function, the help page has the **title** "Miscellaneous Mathematical Functions". Just below the title, you see the **Description**, in which the author of a function briefly describes what the function is for. Here we see that there are two functions that are grouped under "Miscellaneous Mathematical Functions", the `abs()` function for computing the absolute value of a number `x`, and the `sqrt()` function for the square root.

Under description, the **Usage** is shown. This is simply the name of the function or functions, and the possible arguments that you can use. Here the Usage is extremely simple: both functions only take one argument named `x`. In a minute, we'll discuss functions with multiple arguments.

Below usage, the **Arguments** section explains how to use each argument. Here, the only argument is `x`, and it is explained that x is "a numeric or complex vector or array". For now, let's focus only on the case of a numeric vector. It appears that in addition to giving a single value like above (recall that in R this is actually a vector of length 1) we can give a vector with multiple numbers.

``` r
sqrt(c(1,2,3,4,5))
```

There are more parts to the documentation that we'll ignore for now. Notable parts to look into for yourself are **Details**, that provides more information, and the **Examples** section at the very bottom, which is a great starting point to see a function in action.

### Understanding multi-argument functions

Now, let's move to a function with multiple arguments. We'll look at the `dfm()` function from the `quanteda` package. To access this function, we first run `library(quanteda)`, to tell R that we want to be able to access the functions in this package. Note that you have to have the package installed as well. This should still be the case from week 1, but if you changed computers, you will have to run the line `install.packages('quanteda')` first.

``` r
library(quanteda)
?dfm
```

First note that the title and description nicely summarize what this function is for: creating a document-feature matrix. Now, when we look at the **Usage** section, we see that there are multiple arguments given between the parentheses, and all these arguments are explained in the **Arguments** section.

An important part of the usage syntax, that we haven't seen in the `sqrt()` function, is that all arguments other than `x` have a value assigned to them, in the form `argument = value`. The argument `tolower` has the value `TRUE`, `stem` has the value `FALSE`, etc.

These are the default values for these argument, that are used if the user does not specify them. This way, I can use the `dfm()` function with the default settings by only entering the `x` argument.

``` r
example_texts = c("Some example text", "Some more text")
dfm(example_texts)
```

If we run this line of code, it returns a matrix with the frequencies of each word for each text. Note that the word "Some" in both texts has been made lowercase, because the `tolower` argument (that is described as "convert all features to lowercase") is `TRUE` by default.

Arguments that don't have a default value, such as `x` in the `dfm()` function, are mandatory. Running the following line of code will give the error `argument "x" is missing, with no default`.

``` r
dfm()
```

It is often the case that in addition to the mandatory arguments you want to specify some specific other arguments. For this, there are two ways to *pass* arguments to a function.

-   Use the same order in which they are specified in **Usage**
-   Pass the arguments with their respective names

To demonstrate passing by order, let's run the `dfm()` function again, but this time with input for `tolower` and `stem`.

``` r
dfm(example_texts, TRUE, TRUE)
```

In the output we see that the word "example" has been `stemmed` to "examp", because we have set the `stem` argument to `TRUE`. The words are still made lowercase, since we passed `TRUE` to `tolower`, which was also the default value.

Passing by order is annoying if you want to specify only one particular argument. In the current example, we had to explicitly pass TRUE to `tolower` even though this was already the default. More importantly, this can become confusing and cause mistakes if you pass many arguments. Therefore, it is often recommended to pass values by name. Here we use this to only change `stem` to `TRUE`.

``` r
dfm(x = example_texts, stem = TRUE)
```

Overall, passing by name is more explicit and safe, but it can be needlessly verbose to specify all names, such as `x = example_texts` in the example. Thus, we can combine both approaches, passing the arguments to the left (i.e. the first, and often mandatory, arguments) by order, and arguments further to the right by name.

``` r
dfm(example_texts, stem=TRUE)
```

As a warning, note that you can also pass arguments by name first, and then further to the right pass arguments by order. We recommend NOT to do this, since it is confusing and hardly ever useful.

### A small note about 'methods' and 'generic functions'

Some functions are *generic functions*, that use different *methods* depending on the input that they are used with. Ignoring technicalities, there's one thing you currently need to know about them, because you will need it to interpret their documentation pages.

A method is a function that is associated with a specific object. For example, subsetting a `vector` works differently from subsetting a `data.frame` or `matrix`. Still, it is convenient to only have one function called `subset()` that can be used on all these kinds of input. In R, the `subset()` functions is therefore a *generic function*, that will behave differently depending on the kind of input.

The type of input to the `subset()` function therefore affects what type of arguments can be used. You can see this in the documentation page.

``` r
?subset
```

In the description we see that `subset()` can be used on vectors, matrices or data.frames. The **Usage** section therefore contains different versions, for different *S3 methods* (ignore "S3" for now) that are associated with different kinds of input. The general form is `subset(x, ...)`, which shows that subset always requires an argument `x`, and in the **Arguments** we see that `x` is the "object to be subsetted". We then see three methods: default, 'matrix' and 'data.frame'.

-   The default will be used if `x` is neither a `matrix` or `data.frame`, but merely a `vector`. In this case the only argument is *subset*, which is the expression (e.g., the comparison `x > 10`) used to make a selection.
-   If the input is a 'matrix', there are two additional arguments: *select* and *drop*. It makes sense that these are not available for vectors, because they are both only relevant if there are multiple columns. That is, *select* is used for selecting columns, and *drop* can be used to have subset return a `vector` (instead of a `matrix`) if only one row or column remains after subsetting.
-   If the input is a 'data.frame', the same arguments are used as for 'matrix' (but internally the method works differently)

### The special case of the three dot ellipsis

A special type of argument that you'll often encounter in function documentation is the three dot ellipsis (`...`). This is used to pass any number of named or unnamed arguments. A good example of how this is used, is in the `data.frame()` function. Last week you saw that you can use this function to create a data.frame from vectors, where names are used as column names. Now, you will see that these are actually just names arguments.

``` r
?data.frame
data.frame(x = 1:5, y = c('a','b','c','d','e'))
```

As an additional example, consider the `sum()` function. Here the `...` is used for "numeric or complex or logical vector". This means that we can add any number of arguments with numbers in them, and they will all be added up.

``` r
?sum
sum(1, 2, 3, c(1,2,3))
```

To clarify, if we want to set any of the other arguments, such as `na.rm` in `sum()`, we can do so by referring to them by name. By default, `sum()` returns NA (R's way of saying "missing") if any NA is present. As noted in the documentation, we can ignore the NA values by setting `na.rm` to `TRUE`

``` r
sum(1,2,NA)
sum(1,2,NA, na.rm = T)
?dfm
```

Finally, a way in which the three dot ellipsis is also often used, is to pass arguments on to another function that is used within the function. If you look back at the documentation for the `dfm()` function, you'll see in the explanation of `...`: "additional arguments passed to tokens; not used when x is a dfm". In this case, you can see which arguments these are by looking at the documentation of the `tokens` function. Here you see that you could also pass the argument `remove_numbers = TRUE` to `dfm()`.

Using packages: data.frames in the Tidyverse
============================================

We'll now make a start at getting you acquainted with the Tidyverse. Specifically, we'll focus on working with data.frames using the `dplyr` package. In addition, we'll use this as a lesson in working with packages. As we discuss several functions from both packages, we heartily recommend you to check out their documentation pages (even if we do not explicitly do so in this document) to train yourself in learning how to use functions.

You have already had to use `install.packages()` and `library()` in earlier tutorials. To jog your memory, `install.packages()` is used to download and install the package (one-time gig) and `library()` is used to make the functions from this package available for use (required each session that you use the package).

``` r
install.packages('dplyr')
```

``` r
library(dplyr)
```

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
