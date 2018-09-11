R basics: commands, objects, and functions
================
Kasper Welbers & Wouter van Atteveldt
2018-09

-   [Commands](#commands)
-   [Data are stored in objects](#data-are-stored-in-objects)
-   [Functions](#functions)
    -   [Optional arguments](#optional-arguments)

This tutorial gives a very brief overview of the basics of dealing with R. It follows [chapter 4 of the R for Data Science book](http://r4ds.had.co.nz/workflow-basics.html).

Commands
========

In R, every line of code generally contains a command or instruction for the computer to do or calculate something (formally, such commands are often called *statements*). In its simplest form, you can ask R to do simple sums, such as 2+2:

``` r
2+2
```

    ## [1] 4

(note that the line `## [1] 4` is the output of this command: a single value `4`)

You can type and execute such a command directly in the console (the bottom left pane in RStudio). You can also combine multiple commands in a `script` in the top left pane. If there is no top-left pane, create a new script using the top menu \[File -&gt; new File -&gt; R Script\]. In a script, you can execute a command by placing the cursor on that line and pressing Control+Enter. You can also execute multiple commands, or parts of a command, by selecting text and pressing Control+Enter.

Data are stored in objects
==========================

All data in R are stored in *objects*.
Simply put, an object is a piece of information that you give a name. You can also say that you assign a value (the information) to an object (your name). For example, you can store the output of a calculation in an object `x`:

``` r
x = 2+3
```

In many online examples and the R4DS book you will see that `x <- 2+3` is used instead. This is the traditional way of assigning values in R, and is equivalent to using `=`. You can choose which one you prefer.

``` r
x <- 2+3  # exactly the same as x = 2+3
```

To see the current value of `x`, simply execute a line containing only the name of the object:

``` r
x
```

    ## [1] 5

You can also see your objects in the top-right 'Environment' pane in RStudio.

In this case, `x` is a simple number, but an object can also be a multi-million row dataset or the result of a statistical model. In fact, all data used in R will be stored as objects, so you will be giving names to a lot of objects that you load or create. Keep in mind that these names are always your choice: R doesn't care whether the objects is called `x`, `pete`, or `his_holiness`. However, it is smart to use names that are descriptive and not too long. In general, use nouns for object names, and separate multiple words with underscores (e.g. `gop_candidates`).

Functions
=========

99% of what you do in R will involve *functions*. Functions are essentially commands or instructions that tell R do do something. In most cases, a function needs certain *parameters* or *arguments* that specify what it is you want to do.

In general, you call a function with:

``` r
result = function(argument1, argument2, ...)
```

A function is always called by the name of the function followed by the arguments between parentheses. In most cases, the result of calling the function is then stored in an object (in this case, `result`)

For example, the function `c` *c*ombines multiple values into a single object:

``` r
x = c(1,3,5)
```

Now, we can use the `mean` function to calculate the mean of these numbers:

``` r
m = mean(x)
m
```

    ## [1] 3

To learn more about what a function does, you can look it up in the 'Help' pane in the bottom right, or call `?function` in R:

``` r
?mean
```

Optional arguments
------------------

The function calls above all used the arguments to specify *what* the function needs to operate on: the values 1, 2, and 3; and the object `x`. Many functions also use optional arguments that control *how* the function works. For example, suppose we have a range of numbers that also contains a missing value (`NA` in R, for 'not available'):

``` r
x = c(1, 3, NA, 5)
```

Now, if we call the `mean` function, R will say that the mean is unknown, since the third value is unknown:

``` r
mean(x)
```

    ## [1] NA

This is statistically a very correct answer, but not very useful. So, we would like R to ignore the missing value when calculating the mean. Fortunately, the mean function has an optional argument `na.rm` (remove NAs) that you can set to TRUE to tell mean to ignore the NAs:

``` r
mean(x, na.rm=TRUE)
```

    ## [1] 3

In most cases, you specify the 'what' arguments by just listing them between the parentheses, and the options by using their name like above. Note that you can shorten TRUE (and FALSE) to T (and F):

``` r
mean(x, na.rm=T) # same as above
```
