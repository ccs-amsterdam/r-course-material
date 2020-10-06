R basics: data and functions
================
Kasper Welbers & Wouter van Atteveldt
2018-09

  - [This tutorial](#this-tutorial)
  - [Data types](#data-types)
      - [Numeric](#numeric)
      - [Character](#character)
      - [Additional types](#additional-types)
  - [Data structures](#data-structures)
      - [Vector](#vector)
      - [Data.frame](#data.frame)
      - [Other common data structures](#other-common-data-structures)
  - [Functions](#functions)
      - [What is a function?](#what-is-a-function)
      - [Using functions](#using-functions)
      - [Functions with multiple
        arguments](#functions-with-multiple-arguments)
  - [Additional instructions](#additional-instructions)
      - [Additional data types](#additional-data-types)
      - [Comparisons](#comparisons)
      - [Logical operators](#logical-operators)
      - [Methods, generic functions and the three dot
        ellipsis](#methods-generic-functions-and-the-three-dot-ellipsis)
  - [Further reading](#further-reading)

# This tutorial

In the first tutorial you immediately started using advanced features in
R, utilizing specialized packages for performing text analysis. For many
purposes, you can use R purely as a way to get stuff done with these
kinds of convenient packages. Many of these packages also contain
detailed instructions, often called vignettes, that show you
step-by-step how to use them.

However, data science is not always smooth sailing. You will often find
yourself willing to do something specific that is not directly supported
by a package, or you have to work with data that first needs to be
cleaned and prepared in order to use a certain function. It is therefore
important to learn some of the basics.

In this week’s lab you will learn about basic R data types, data
structures and functions. You can consider these as the main building
blocks for working with R data. Learning about these basics might be
less exciting compared to using the advanced features, but in the long
run it will save you time and frustration. An additional R Markdown file
is available in the course material for practicing with data types, data
structures and functions.

# Data types

Data types concern the different types that single values in data can
have. The most basic data types in R are:

  - numeric (numbers)
  - character (text)
  - factor (categorical data)
  - logical (True or False)

In addition, there are special types for data such as date/time values.

  - Date (calendar dates) or POSIXlt (calendar dates and times).

## Numeric

Numbers. As simple as is gets. You can use them to do the math you know
and love.

``` r
x = 5      ## assign a number to the name x
class(x)   ## view the class of the value assigned to x

x + 3
x / 2
log(x)     ## logarithm
sqrt(x)    ## square root
```

For those who have experience with low-level programming languages, it
is nice to know that you do not need to think about different types for
representing numbers (int, double, float, etc.).

## Character

Textual data, either as single characters, entire words, or even full
texts.

``` r
x = "Some text"  ## assign text to the name x
class(x)         ## view the class of the value assigned to x
```

It’s important to recognize the distinction between names and character
values. In the above example, x is the name to which the text “some
text” has been assigned. Whether a word is a name or a character value
is indicated with quotes.

``` r
x       ## get value assigned to the name x
"x"     ## the text "x"
```

Naturally, you cannot perform math with character data. Using the wrong
data type will generally yield an error, as seen here.

``` r
sum(x)
```

It’s import to recognize these types of errors, because they are
terribly common. You might have imported data in which a column that’s
supposed to contain numbers accidentally contains a word, in which case
R will consider the column to be column of character values.

Note that you can express a number as a character value, e.g., “1”,
“999”, but not a text as a numerical value. If it is possible to
convert a value to a different type, you can do so with the **as**
method:

``` r
x = "999"
x = as.numeric(x)     ## converts character to numeric
x

y = 999
y = as.character(y)   ## converts numeric to character
y

z = "nein nein nein"
z = as.numeric(z)     ## tries to convert character to numeric, but fails 
z
```

R has decent built-in support for working with character values, but for
more advanced techniques for working with **strings** it is recommended
to use a dedicated package such as
[stringr](https://github.com/rstudio/cheatsheets/raw/master/strings.pdf).

## Additional types

Additional instructions for working with factors, logical and date type
values are included at the bottom of this document. But for now we’ll
first move on to data structures.

# Data structures

In SPSS or Excel, data is always organized in a rectancular data frame,
with cells arranged in rows and columns. Typically, the rows then
represent cases (e.g., repondents, participants, newspaper articles) and
columns represent variables (e.g., age, gender, date, medium). For most
analyses, this is also the recommended data format in R, using the
*data.frame* structure. However, an important difference is that in R it
is possible, and often usefull, to combine different formats. Also, to
understand how a *data.frame* in R works, it is usefull to understand
that a *data.frame* is a collection of *vectors*, and thus it is usefull
to understand how *vectors* work.

Here we will first briefly discuss *vectors*, and then quickly move on
to *data.frames*. In addition, we will mention *matrices* and *lists* on
a good-to-know-about basis.

## Vector

The concept of a vector might be confusing from a social science
background, because we rarely use the term in the context of statistics
(well, not consciously at least). We won’t address why R calls them
vectors and how this relates to vector algebra, but only how you most
commonly use them.

A vector in R is a **sequence** of **one or more values** of the **same
data type** From a social science background, it is very similar to what
we often call a **variable**.

You can declare a vector in R with c(…), where between the parentheses
you enter the elements, separated with commas. The number of elements is
called the length of the vector. A vector can have any of the data types
discussed above (numeric, character, factor, logical, Date).

``` r
v1 = c(1, 2, 10, 15)    ## a numeric vector of length 4
v2 = c("a", "b", "b")   ## a character vector of length 3
v3 = 1:10               ## a numeric vector of length 10 with the values 1 to 10. 
```

If you combine data types in the same vector, R will generally use the
broadest data type for the entire vector. For example, we saw earlier
that a number can be expressed as a character value, but a text cannot
be expressed as a numerical. Accordingly, if we combine both types in a
vector, R will convert the numerical values to character values.

``` r
c(1, 2, "c")            ## becomes a character vector of length 3
```

Since vectors can only have one type, we can perform type specific
operations with them. In many ways, we can work with them in the same
way as we can work with single values. In fact, single values are
actually just vectors of length 1. For example, if we have a vector of
numeric type, also called a numeric vector, we can perform calculations.

``` r
x = c( 1, 2, 3, 4, 5)
y = c(10,20,30,40,50)
x + y     ## for 2 vectors of same size calculations are pairwise (1 + 10, 2 + 20, etc.)
x + 10    ## for a vector and single value, the value is repeated (1 + 10, 2 + 10, etc.)
```

### Selecting elements

There are two common ways to select a specific element or a range of
elements from a vector. One is to give the indices (positions) of the
elements in square brackets after the vector name. Note that the indices
themselves are given as a numeric vector.

``` r
x = c('a','b','c','d','e','f','g')  
x[5]            ## select the fifth element
x[c(1,3)]       ## select the first and third elements
x[2:5]          ## select elements two to five
```

If you select with indices, the specific order of the indices is used,
and you can also repeat indices. This can for instance be used to sort
data.

``` r
x[5:1]          ## select elements in positions 5 to 1
x[c(5,5,5)]     ## select the element in position 5 multiple times
```

You can also use negative indices to select everything except the
specified elements.

``` r
x[-5]            ## select every element except the fifth
x[-c(1,3)]       ## select every element other than the first and third
```

The second way to select values is to use a **logical vector**. More
information about logical vectors is given at the bottom of this
document, but for now you only need to understand that a logical vector
only has te valus FALSE and TRUE.

If you use a logical vector to select values of avector, it has to be of
the same length. All values for which the logical vector is TRUE will
then be selected. In this example the first three values are TRUE, and
so the first three values are selected from the vector x

``` r
x[c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)]
```

Now, you might be thinking: how is this usefull? Indeed, you will never
use this in practice, but if you understand this, it helps you
understand how you can use **comparison** so select values. Comparisons
are also explained in more detail at hte bottom of this document. For
now, you only need to understand that you can compare values to create
logical vector.

For example, we can compare all values in vector to a single value. Here
we create a vector called **age**, and we compare the values of this
vector to the value 18. We use **==**, which means *equals*.

``` r
age = c(17,34,18,20,12,25,30,14,33)
age == 18
```

We can also use **\>** for a *greater than* comparison, or **\>=** for a
*greater than or equal* comparison.

``` r
age >= 18
```

Now, we can use the logical vector (TRUE / FALSE) to select values.

``` r
selection = age >= 18   ## comparison creates logical vector
age[selection]          ## selects values using logical vector
```

It is not necessary to first give the logical vector a name as we do
here with **selection**. We can directly use the comparison to select
value.

``` r
age[age >= 18]          ## same, but less verbose (recommended) 
```

## Data.frame

A *data.frame* is essentially a collection of vectors with the same
length, tied together as columns. To create the *data.frame*, we use the
**data.frame()** function. We enter the vectors in the format:
`column_name = vector`. Here we create a data.frame for data from a
fictional experiment.

``` r
d = data.frame(id =        1:10,
               condition = c('E', 'E', 'C', 'C', 'C', 'E', 'E', 'E', 'C', 'C'),
               gender =    c('M', 'M', 'F', 'M', 'F', 'F', 'F', 'M', 'M', 'F'),
               age =       c( 17,  19,  22,  18,  16,  21,  18,  17,  26,  18),
               score_t1 =  c(8.0, 6.0, 7.5, 6.8, 8.0, 6.4, 6.0, 3.2, 7.3, 6.8),
               score_t2 =  c(8.3, 6.4, 7.7, 6.3, 7.5, 6.4, 6.2, 3.6, 7.0, 6.5))
d
```

    ##    id condition gender age score_t1 score_t2
    ## 1   1         E      M  17      8.0      8.3
    ## 2   2         E      M  19      6.0      6.4
    ## 3   3         C      F  22      7.5      7.7
    ## 4   4         C      M  18      6.8      6.3
    ## 5   5         C      F  16      8.0      7.5
    ## 6   6         E      F  21      6.4      6.4
    ## 7   7         E      F  18      6.0      6.2
    ## 8   8         E      M  17      3.2      3.6
    ## 9   9         C      M  26      7.3      7.0
    ## 10 10         C      F  18      6.8      6.5

Now, the data structure clearly implies that there is a relation between
the elements in the *column vectors*. In other words, that each row
represents a *case*. In our example, these cases are participants, and
the columns represent:

  - the participant **id**.
  - the experimental **condition** (E = experimental condition, C =
    control group)
  - demographic variables: **gender** and **age**.
  - test scores before and after the experimental condition:
    **score\_t1** and **score\_t2**

### Selecting rows, columns and elements

Since data.frames have both rows and columns, we need to use both to
select data. Similar to selection in vectors, we use the square
brackets. The difference is that for data.frames the square brackets
have two parts, separated by a comma. Assuming our data.frame is called
`d`, we can select with:

| syntax   | meaning                                  |
| -------- | ---------------------------------------- |
| d\[i,j\] | select rows (i) and columns (j)          |
| d\[i, \] | select only rows (i) and use all columns |
| d\[ ,j\] | select only columns (j) and use all rows |

Selection for rows (i) and columns (j) works identical to selection in
vectors. You can use either a numeric vector with indices, or a logical
vector. Accordingly, you can also use comparisons.

In addition, there are two special ways to select columns. One is that j
can be a character vector with column names. The other uses the dollar
sign ($).

| syntax               | meaning                                         |
| -------------------- | ----------------------------------------------- |
| d\[ ,c(“c1”, “c2”)\] | select the columns with the names “c1” and “c2” |
| d$id                 | select the column named id                      |

#### selecting columns

Let’s put this to practice, starting with columns:

``` r
## selecting a single column returns a vector
d[,1]             ## select the first column by index 
d[,"id"]          ## select the id column by name
d$id              ## select the id column using the dollar sign

## selecting multiple columns returns a data.frame
d[,1:2]           ## select the first two columns by indices
d[,c("id","age")] ## select the "id" and "age" columns by name
d[,-1]            ## select every column except for the first  
```

As mentioned, you can also use a logical vector to select columns. For
now, we’ll leave it up to your imagination when this might be usefull.

#### selecting rows

Selecting rows is practically identical to selecting elements from
vectors, and it conveniently returns a data.frame with all columns and
their matched positions intact.

``` r
d[1:5,]    ## select first 5 rows
```

A very usefull additional trick is that you can use all the columns to
make comparisons. For example, we can use the gender column to look up
all elements for which the value is “M” (male), and use this to select
rows.

``` r
d[d$gender == "M", ]       
```

You can combine this with the logical operators to make a selection
using multiple columns. Logical operators are explained in detail at the
bottom of this document. For now, you only need to understand that we
can use the **&** (AND) operator to say that we want two comparisons to
be TRUE (d$gender == “F” AND d$age == 21).

``` r
d[d$gender == "F" & d$age == 21, ]    ## 21 year old female participant(s)
d[d$score_t1 < d$score_t2,]           ## participants that scored higher after the condition
```

#### selecting rows and columns

We can combine row and column selection. This works just like you’d
expect it to, so there’s little to add here. Do note, however, that you
can combine the different selection methods.

``` r
d[d$gender == "F", "score_t1"]    ## get the score_t1 column for female participants
d[d$gender == "F",]$score_t1      ## identical, but first subset data.frame, then select column
d$score_t1[d$gender == "F"]       ## identical, but first select column vector, then subset vector
```

### Subsetting, adding and modifying data

With the selection techniques you already learned how to create a subset
of the data. Now, you can assign this subset to a new name.

``` r
experimental_group = d[d$condition == "E",]
experimental_group

demographics = d[, c('id','gender','age')]
demographics
```

You can add a column by ‘selecting’ a non-existing column and assigning
a vector to it. If this is a single value, the value will be repeated
for the entire column. For example, we’ll add a dummy variable for
`male`, which we’ll first set to 0.

``` r
d$male = 0
d
```

Now, if we want to change this value to 1 for all the male participants,
we can simply use selection to get this column for male participants
only, and then assign 1 to this selection.

``` r
d$male[d$gender == "M"] = 1
d
```

Finally, note that you can also perform a calculation with your current
columns, and assign this to a new column, or overwrite an existing
column. For example, let’s say that we actually needed to have our
scores on a scale from 1 to 100. We can simply multiply the columns by
10.

``` r
d$score_t1 = d$score_t1 * 10
d$score_t2 = d$score_t2 * 10
d
```

## Other common data structures

There are other common data structures, such as the `matrix` and `list`.
Packages can also provide new classes for organizing and manipulating
data, such as quanteda’s document-feature matrix (dfm).

# Functions

Where data types and structures concern how data is respresented in R,
functions are the tools that you use to read, create, manage,
manipulate, analyze and visualize data.

## What is a function?

There are many correct and formal ways to define what functions are, but
for the sake of simplicity we will focus on an informal description of
how you can think of functions in R:

  - A function has the form: `output = function_name(argument1,
    argument2, ...)`
      - **function\_name** is a name to indicate which function you want
        to use. It is followed by parentheses.
      - **arguments** are the input of the function, and are inserted
        within the parentheses. Arguments can be any R object, such as
        numbers, strings, vectors and data.frames. Multiple arguments
        can be given, separated by commas.
      - **output** is anything that is returned by the function, such as
        vectors, data.frames or the results of a statistical analysis.
        Some functions do not have output, but produce a visualization
        or write data to disk.
  - The purpose of a function is to make it easy to perform a (large)
    set of (complex) operations. This is crucial, because
      - It makes code easier to understand. You don’t need to see the
        operations, just the name of the function that performs them
      - You don’t need to understand the operations, just how to use the
        function

For example, say that you need to calculate the square root of a number.
This is a very common thing to do in statistical analysis, but it
actually requires a quite complicated set of operations to perform. This
is when you want to use a function, in this case the `sqrt` (square
root) function.

``` r
sqrt(5)
```

In this example, the function name is `sqrt`. The input is the single
argument `5`. If you run this code, it produces the output `2.236068`.
Currently, R will simply print this output in your Console, but as you
learned before, we can assign this output to a name.

``` r
square_root = sqrt(5)
```

This simple process of input -\> function -\> output is essentially how
you work with R most of the times. You have data in some form. You
provide this data as input to a function, and R generates output. You
can assign the output to a name to use it in the next steps, or the
output is a table with results or a visualization that you want to
interpret.

## Using functions

Above you saw the simple function `sqrt()`, that given a single number
as input returned a single number as output. As you have also seen in
the first week, functions can have multiple arguments as input. Recall
the following function from the `quanteda` package. You don’t have to
run the code this time, just try to recognize the arguments.

``` r
dfm(x = "some text", tolower = TRUE, stem=TRUE)
```

This function, with the name `dfm`, is given several arguments here:
`x`, `tolower` and `stem`. Given this input, many operations are
performed behind the scenes to create a document-term matrix.

By now we hope you have realized just how broad the use of functions is.
The *R syntax* for performing basic mathematical operations such as
`sqrt()` is essentially the same as the syntax for creating a
document-term matrix, performing advances statistical analysis or
creating powerfull visualizations. Accordingly, if you understand this
syntax, you can do almost anything in R.

The many R packages that you can install are mostly just collections of
functions (some also provide new **classes**, which we’ll save for
later). We will now show how you can learn how to use each function by
knowing how to view and interpret it’s documentation page.

### Viewing and interpreting function documentation

You can access the documentation of a function by typing a question mark
in front of the function name, and running the line of code. Let’s do
this to view the documentation of the `sqrt()` function

``` r
?sqrt
```

If you run this in RStudio, the help page will pop-up in the
bottom-right corner, under the *Help* tab page. Sometimes, if the name
of a documentation page is used in multiple packages, you will first
receive a list of these packages from which you will have to select the
page.

For the `sqrt()` function, the help page has the **title**
“Miscellaneous Mathematical Functions”. Just below the title, you see
the **Description**, in which the author of a function briefly describes
what the function is for. Here we see that there are two functions that
are grouped under “Miscellaneous Mathematical Functions”, the `abs()`
function for computing the absolute value of a number `x`, and the
`sqrt()` function for the square root.

Under description, the **Usage** is shown. This is simply the name of
the function or functions, and the possible arguments that you can use.
Here the Usage is extremely simple: both functions only take one
argument named `x`. In a minute, we’ll discuss functions with multiple
arguments.

Below usage, the **Arguments** section explains how to use each
argument. Here, the only argument is `x`, and it is explained that x is
“a numeric or complex vector or array”. For now, let’s focus only on
the case of a numeric vector. It appears that in addition to giving a
single value like above (recall that in R this is actually a vector of
length 1) we can give a vector with multiple numbers.

``` r
sqrt(c(1,2,3,4,5))
```

There are more parts to the documentation that we’ll ignore for now.
Notable parts to look into for yourself are **Details**, that provides
more information, and the **Examples** section at the very bottom, which
is a great starting point to see a function in action.

## Functions with multiple arguments

Now, let’s move to a function with multiple arguments. We’ll again look
at the `dfm()` function from the `quanteda` package. To access this
function, we first run `library(quanteda)`, to tell R that we want to be
able to access the functions in this package. Note that you have to have
the package installed as well. This should still be the case from a
prior tutorial, but if you changed computers, you will have to run the
line `install.packages('quanteda')` first.

``` r
library(quanteda)
?dfm
```

First note that the title and description nicely summarize what this
function is for: creating a document-feature matrix. Now, when we look
at the **Usage** section, we see that there are multiple arguments given
between the parentheses, and all these arguments are explained in the
**Arguments** section.

An important part of the usage syntax, that we haven’t seen in the
`sqrt()` function, is that all arguments other than `x` have a value
assigned to them, in the form `argument = value`. The argument `tolower`
has the value `TRUE`, `stem` has the value `FALSE`, etc.

These are the default values for these argument, that are used if the
user does not specify them. This way, We can use the `dfm()` function
with the default settings by only entering the `x` argument.

``` r
example_texts = c("Some example text", "Some more text")
dfm(example_texts)
```

If we run this line of code, it returns a matrix with the frequencies of
each word for each text. Note that the word “Some” in both texts has
been made lowercase, because the `tolower` argument (that is described
as “convert all features to lowercase”) is `TRUE` by default.

Arguments that don’t have a default value, such as `x` in the `dfm()`
function, are mandatory. Running the following line of code will give
the error `argument "x" is missing, with no default`.

``` r
dfm()
```

It is often the case that in addition to the mandatory arguments you
want to specify some specific other arguments. For this, there are two
ways to *pass* arguments to a function.

  - Use the same order in which they are specified in **Usage**
  - Pass the arguments with their respective names

To demonstrate passing by order, let’s run the `dfm()` function again,
but this time with input for `tolower` and `stem`.

``` r
dfm(example_texts, TRUE, TRUE)
```

In the output we see that the word “example” has been `stemmed` to
“examp”, because we have set the `stem` argument to `TRUE`. The words
are still made lowercase, since we passed `TRUE` to `tolower`, which was
also the default value.

Passing by order is annoying if you want to specify only one particular
argument. In the current example, we had to explicitly pass TRUE to
`tolower` even though this was already the default. More importantly,
this can become confusing and cause mistakes if you pass many arguments.
Therefore, it is often recommended to pass values by name. Here we use
this to only change `stem` to `TRUE`.

``` r
dfm(x = example_texts, stem = TRUE)
```

Overall, passing by name is more explicit and safe, but it can be
needlessly verbose to specify all names, such as `x = example_texts` in
the example. Thus, we can combine both approaches, passing the arguments
to the left (i.e. the first, and often mandatory, arguments) by order,
and arguments further to the right by name.

``` r
dfm(example_texts, stem=TRUE)
```

Whatever approach you prefer, try to be consistent, and take into
account whether your code will still be easy to interpret for others
that you share it with, or for yourself in the future. A good general
rule is to pass mandatory arguments (such as `x` in the `dfm` function)
without a name, but all the optional arguments (that have a default,
such as `tolower` and `stem`) by name.

# Additional instructions

Here we provide several additional instructions about data types,
structures and functions. There are all very usefull to know about, but
a bit more hard to chew. Prioritize understanding the former part, but
by all means, do study these a additional instructions.

## Additional data types

### Factor

A *factor* in R is a series of labeled numbers. This is usefull if you
have a categorical variable, such as education level (in surveys) or
medium type (in content analysis). If you are familiar with SPSS, this
is comparable to using *value labels*.

``` r
x = c('De Volkskrant','De Volkskrant','NRC Handelsblad',
      'De Volkskrant','NRC Handelsblad','Trouw')
x
```

We now have a sequence of character values. What’s special about these
character values, is that the same values are often repeated. In this
case, it’s best to think as each unique value (“De Volkskrant”, “NRC
Handelsblad”, “Trouw”) as a label. This is a typical job for the
*factor* type, so let’s transform the character type vector to a factor
type.

``` r
x = factor(x)
x
```

Two things have changed. Firstly, you see that there is now a line that
says “levels: …”, in which the three unique labels are shown. Secondly,
the quotes have disappeared. This is because it’s no longer a character
value.

Behind the scenes, x is now a sequence of numbers, where each number
points to a label

``` r
as.numeric(x) ## show the numbers: 1 for De Volkskrant, 2 for NRC and 3 for Trouw
levels(x)     ## show the levels / labels. 
```

If this confuses you, you’re still perfectly healthy. The benefits of
factors become more apparent later on when you start working with
certain types of analysis, visualizations, and when you use very large
data (numeric values require less memory than character values).

You might have concluded that factors are only a hassle, and you’ll
simply stick to character values. This is a valid strategy, except that
R tends to force factors on you, for example when you import data or
make a data.frame, and R thinks that your character column is better of
as a factor. There are ways to ask R not to do this, but really, you’re
better of just accepting factors. It’s better on the long run.

Still, if you ever run into trouble with factors and really prefer to
use character values, you can simply convert them into “character” type,
using **as.character()**

``` r
as.character(x)
```

### Logical

The *logical* data type only has two values: **TRUE** and **FALSE**
(which can be abbreviated to **T** and **F**). You will not often
encounter logical values in your data, but you will use them in many
operations such as subsetting and transforming data, as you will see
when we discuss data structures. Understanding a bit about logical
values will help you understand how these operations work.

For now, we will focus on how logical values result from comparisons,
and how logical operators can be used.

### Date

Date is not one of the basic data types in R, but in social scientific
research we often work with calendar dates and times. This requires a
special data type, because there are many limitations or complications
if we try to express dates and times as character or numeric values. Two
of the most common date classes in native R (i.e. not requiring
additional packages) are *Date*, which only handles calendar dates, and
*POSIXlt*, that handles both calendar dates and times.

In this tutorial we will only demonstrate how to use *POSIXlt*, but the
general approach for working with dates and times in R is the same for
different date types (and is actually similar in other programming
languages as well). You can do most things that you need with only two
functions: *strptime* and *strftime*

  - strptime (**str**ing **p**arse **time**) creates a date/time value
    from a character value
  - strftime (**str**ing **f**ormat **time**) extracts parts of a
    date/time from a date/time value.

For both functions, you need to know how to specify the *format*.
Essentially, this is a string (character value) that contains the date
format, using special placeholders to indicate specific parts of the
date. These placeholders are always a percentage symbol **%** followed
by a letter. The most commonly used placeholders are:

| placeholder | date part                                             |
| ----------- | ----------------------------------------------------- |
| %Y          | year with century (2010, 2011, etc.)                  |
| %m          | month as a decimal number (01, 02, 03, …, 10, 11, 12) |
| %d          | day as a decimal number (01, 02, 03, …, 28, 29, 30)   |
| %H          | hour as a decimal (00, 01, 02, …, 21, 22, 23)         |
| %M          | minute as a decimal (00, 01, 02, …, 57, 58, 59)       |
| %S          | seconds as a decimal (00, 01, 02, …, 57, 58, 59)      |

Using these placeholders, we can describe various date formats. Here we
show how to use this together with the **strptime** function to
**parse** a date from character type to a date (POSIXlt) type. We will
explain more about functions below. For now, just note that the first
argument passed to **strptime()** is the date, and the second argument
is the format.

``` r
strptime('2010-01-01 20:00:00', format = '%Y-%m-%d %H:%M:%S')
strptime('01/01/2010', format = '%m/%d/%Y')
strptime('2010 any 01 format 01 goes', format = '%Y any %m format %d goes')
```

With the **strftime()** function we can use the same format strings to
extract specific parts from a date/time value. Here, we first create a
POSIXlt date with strptime, and then use strftime to extract parts. Note
that all parts are returned as a character value, even if they are
single numbers.

``` r
x = strptime('2010-06-01 20:00:00', format = '%Y-%m-%d %H:%M:%S')
strftime(x, '%Y')
strftime(x, '%Y week %W')
strftime(x, 'Today is a %A')  ## language of weekday depends on your locale settings
```

You can find a full list of format placeholders in the documentation of
the **strptime** function, which you can access by putting a
questionmark in front of the function name and running it as code. The
help page should open in your bottom-right window in RStudio.

``` r
?strptime
```

For reference, if you feel the urge to master date and time operations,
there is also the excellent **lubridate** package. Usage is explained in
detail in this (free online) [chapter from “R for Data
Science”](http://r4ds.had.co.nz/dates-and-times.html). You can also
download the cheatsheet
[here](https://github.com/rstudio/cheatsheets/raw/master/lubridate.pdf).

## Comparisons

The most common way in which you will get logical values in R is as the
results of a **comparison** between two values or two vectors. There are
6 types of comparissons, which use operators that you are probably
already familiar with:

| operator | meaning                         |
| -------- | ------------------------------- |
| x \< y   | x is smaller than y             |
| x \> y   | x is larger than y              |
| x \<= y  | x is smaller than or equal to y |
| x \>= y  | x is larger than or equal to y  |
| x == y   | x equals y                      |
| x \!= y  | x does not equal y              |

The outcome of a comparison of two values is a logical value.

``` r
5 < 10
5 < 2
```

The outcome of a comparison of two vectors is a logical vector. For
example, let’s assume that we have the average math grade’s for 5
students in year 1 and year 2, and we look-up whether their grade went
down (i.e. grade in year 1 was higher than year 2). Here we see that
only for the first student the grade went down (from 6 in year 1 to 5 in
year 2), so only the first value is TRUE.

``` r
grade_year_1 = c(6,6,7,7,4)
grade_year_2 = c(5,6,8,7,6)
grade_year_1 > grade_year_2    
```

If we compare a vector to a single value, each value of the vector will
be compared to that value. As you will see shortly, this is a core
mechanic behind selecting and subsetting data. In the following example,
we will look-up which participants for our hypothetical drinking study
are at least 18 years old.

``` r
age = c(17,34,12,20,12,25,30,14,33)
age >= 18
```

Finally, while not strictly a comparison, there is another common
operator that creates a logical value or vector.

| operator | meaning                           |
| -------- | --------------------------------- |
| x %in% y | the value(s) in x also exist in y |

This is for instance usefull if you want to look for multiple values.
For example, let’s select select `Bob` and `Carol` from our list of
names.

``` r
name = c('Alice','Bob','Carol','Dave','Eve')
name %in% c('Bob', 'Carol')
```

## Logical operators

Given a logical value (or vector), we can use the logic operators &
(AND), | (OR) and \! (NOT). In the following table, x and y are both
logical values.

| operator | meaning | outcome                                        |
| -------- | ------- | ---------------------------------------------- |
| x & y    | x AND y | only TRUE if both x and y are TRUE             |
| x | y    | x OR y  | only TRUE if either x or y, or both are TRUE.  |
| \!x      | NOT x   | the opposite if x, so only TRUE if x is FALSE. |

You can play with the following code to try it out (results not shown in
this document).

``` r
TRUE & TRUE        ## is TRUE
TRUE & FALSE       ## is FALSE
FALSE & FALSE      ## is FALSE

TRUE | TRUE        ## is TRUE
TRUE | FALSE       ## is TRUE
FALSE | FALSE      ## is FALSE

!TRUE              ## NOT TRUE, so is FALSE
!FALSE             ## NOT FALSE, so is TRUE

TRUE & !FALSE      ## !FALSE == TRUE, so you get TRUE & TRUE
TRUE & (!TRUE | TRUE) ## !TRUE | TRUE == FALSE  | TRUE == TRUE, so you get TRUE & TRUE 

a = c(T, T, F, F, F, T)
b = c(T, F, F, F, T, T) 
a & b              ## 6 pairwise comparisons: T & T, T & F, F & F, F & F, F & T, T & T) 
```

## Methods, generic functions and the three dot ellipsis

### A note about ‘methods’ and ‘generic functions’

Some functions are *generic functions*, that use different *methods*
depending on the input that they are used with. Ignoring technicalities,
there’s one thing you currently need to know about them, because you
will need it to interpret their documentation pages.

A method is a function that is associated with a specific object. For
example, subsetting a `vector` works differently from subsetting a
`data.frame` or `matrix`. Still, it is convenient to only have one
function called `subset()` that can be used on all these kinds of input.
In R, the `subset()` functions is therefore a *generic function*, that
will behave differently depending on the kind of input.

The type of input to the `subset()` function therefore also determines
what type of arguments can be used. You can see this in the
documentation page.

``` r
?subset
```

In the description we see that `subset()` can be used on vectors,
matrices or data.frames. The **Usage** section therefore contains
different versions, for different *S3 methods* (ignore “S3” for now)
that are associated with different kinds of input. The general form is
`subset(x, ...)`, which shows that subset always requires an argument
`x`, and in the **Arguments** we see that `x` is the “object to be
subsetted”. We then see three methods: default, ‘matrix’ and
‘data.frame’.

  - The default will be used if `x` is neither a `matrix` or
    `data.frame` (for instance a `vector`). In this case the only
    argument is *subset*, which is the expression (e.g., `x > 10`) used
    to make a selection.
  - If the input is a ‘matrix’, there are two additional arguments:
    *select* and *drop*. It makes sense that these are not available for
    vectors, because they are both only relevant if there are multiple
    columns. That is, *select* is used for selecting columns, and *drop*
    can be used to have subset return a `vector` (instead of a `matrix`)
    if only one row or column remains after subsetting.
  - If the input is a ‘data.frame’, the same arguments are used as for
    ‘matrix’ (but internally the method works differently)

### The special case of the three dot ellipsis

A special type of argument that you’ll often encounter in function
documentation is the three dot ellipsis (`...`). This is used to pass
any number of named or unnamed arguments. A good example of how this is
used, is in the `data.frame()` function. In a previous tutorial you saw
that you can use this function to create a data.frame from vectors,
where names are used as column names. Now, you will see that these are
actually just *named arguments*.

``` r
?data.frame
data.frame(x = 1:5, y = c('a','b','c','d','e'))
```

As an additional example, consider the `sum()` function. Here the `...`
is used for “numeric or complex or logical vector”. This means that we
can add any number of arguments with numbers in them, and they will all
be added up.

``` r
?sum
sum(1, 2, 3, c(1,2,3))
```

To clarify, if we want to set any of the other arguments, such as
`na.rm` in `sum()`, we can do so by referring to them by name. By
default, `sum()` returns NA (R’s way of saying “missing”) if any NA is
present. As noted in the documentation, we can ignore the NA values by
setting `na.rm` to `TRUE`

``` r
sum(1,2,NA)
sum(1,2,NA, na.rm = T)
?dfm
```

Finally, a way in which the three dot ellipsis is also often used, is to
pass arguments on to another function that is used within the function.
If you look back at the documentation for the `dfm()` function, you’ll
see in the explanation of `...`: “additional arguments passed to tokens;
not used when x is a dfm”. In this case, you can see which arguments
these are by looking at the documentation of the `tokens` function. Here
you see that you could also pass the argument `remove_numbers = TRUE` to
`dfm()`.

# Further reading

If you want to learn more about the basics of R, we recommend:

  - [The (free online) R for Data Science
    book](http://r4ds.had.co.nz/functions.html)
  - Taking one of the many (free) online introductions, such as the ones
    offered at
    [DataCamp](https://www.datacamp.com/courses/free-introduction-to-r/)
    or [Code School](http://tryr.codeschool.com/).

Also, it could be nice to grab some of the
[cheatsheets](https://www.rstudio.com/resources/cheatsheets/) collected
on the RStudio website. For the basics of R, the cheatsheet [Base
R](http://github.com/rstudio/cheatsheets/raw/master/base-r.pdf) is
particularly usefull.
