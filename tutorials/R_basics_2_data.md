R basics: Data
================
Kasper Welbers & Wouter van Atteveldt
2018-09-03

-   [This tutorial](#this-tutorial)
    -   [Structure of this lab exercise](#structure-of-this-lab-exercise)
-   [Data types](#data-types)
    -   [Numeric](#numeric)
    -   [Character](#character)
    -   [Factor](#factor)
    -   [Logical](#logical)
        -   [Comparisons](#comparisons)
        -   [Logical operators](#logical-operators)
    -   [Date](#date)
-   [Data structures](#data-structures)
    -   [Vector](#vector)
        -   [Selecting elements](#selecting-elements)
    -   [Data.frame](#data.frame)
        -   [Selecting rows, columns and elements](#selecting-rows-columns-and-elements)
        -   [Subsetting, adding and modifying data](#subsetting-adding-and-modifying-data)
    -   [Matrix](#matrix)
    -   [List](#list)

This tutorial
=============

In the first tutorial you immediately started using advanced features in R, utilizing specialized packages for obtaining data and performing text analysis. For many purposes, you can use R purely as a way to get stuff done with these kinds of convenient packages. Many of these packages also contain detailed instructions, often called vignettes, that show you step-by-step how to use them.

However, data science is not always smooth sailing. You will often find yourself willing to do something specific that is not directly supported by a package, or you have to work with data that first needs to be cleaned and prepared in order to use a certain function. It is therefore important to learn some of the basics for working with data in R.

In this week's lab you will learn about the most basic R data types and structures. You can consider these as the main building blocks for working with R data. Learning about these basics might be less exciting compared to using the advanced features, but in the long run it will save you time and frustration.

Structure of this lab exercise
------------------------------

This week's lab consists of two parts:

-   Data types
-   Data structures

Each parts has an assignment, that you can find and complete in the separate **Lab\_week2\_assignment\_template.Rmd** file on Canvas. You need to open this file in RStudio.

If you want to learn more about the basics of R in addition to this lab tutorial, we recommend taking one of the many (free) online introductions, such as the ones offered at [DataCamp](https://www.datacamp.com/courses/free-introduction-to-r/) or [Code School](http://tryr.codeschool.com/). Also, a good way to jog your memory after learning the basics, is to grab some of the [nice cheatsheets](https://www.rstudio.com/resources/cheatsheets/) collected on the RStudio website. For the basics of R, the cheatsheet [Base R](http://github.com/rstudio/cheatsheets/raw/master/base-r.pdf) is particularly usefull.

Data types
==========

Data types concern the different types that single values in data can have. The most basic data types in R are:

-   numeric (numbers)
-   character (text)
-   factor (categorical data)
-   logical (True or False)

In addition, we will discuss how to work with dates:

-   Date (calendar dates) or POSIXlt (calendar dates and times).

Numeric
-------

Numbers. As simple as is gets. You can use them to do the math you know and love.

``` r
x = 5      ## assign a number to the name x
class(x)   ## view the class of the value assigned to x

x + 3
x / 2
log(x)
sqrt(x)
```

For those who have experience with low-level programming languages, it is nice to know that you do not need to think about different types for representing numbers (int, double, float, etc.).

Character
---------

Textual data, either as single characters, entire words, or even full texts. R supports various ways to manipulate texts, but in this course we won't use them. Still, you will often have textual data in your dataset, so be sure to know how to recognize it.

``` r
x = "Some text"  ## assign text to the name x
class(x)         ## view the class of the value assigned to x
```

It's important to recognize the distinction between names (x) and character values ("Some text").

Naturally, you cannot perform math with character data. Using the wrong data type will generally yield an error, as seen here.

``` r
sum(x)
```

It's import to recognize these types of errors, because they are terribly common. You might have imported data in which a column that's supposed to contain numbers accidentally contains a word, in which case R will consider the column to be column of character values.

Note that you can express a number as a character value, e.g., "1", "999", but not a text as a numerical value. If it is possible to convert a value to a different type, you can do so with the **as** method:

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

R has decent built-in support for working with character values, but for more advanced techniques for working with **strings** (essentially, how texts are represented in computers) it is recommended to use a dedicated packages such as [stringr](https://github.com/rstudio/cheatsheets/raw/master/strings.pdf).

Factor
------

The *factor* data type is the stuff many R nightmares are made of, but it's easy to deal with if you take a minute to understand it. Technically, a *factor* in R is a series of labeled numbers. This is particularly usefull if you have a categorical variable, such as education level (in surveys) or medium type (in content analysis). If you are familiar with SPSS, this is comparable to using *value labels*.

To demonstrate how factors work, we have to use a sequence of values, called a *vector*. We will discuss vectors in more detail below. For now, just see that we combine multiple values in a particular order by putting them between parentheses with a *c* in front. Also, Note that despite the somewhat similar name, *factors* and *vectors* are different things).

``` r
x = c('De Volkskrant','De Volkskrant','NRC Handelsblad',
      'De Volkskrant','NRC Handelsblad','Trouw')
x
```

We now have a sequence of character values. What's special about these character values, is that the same values are often repeated. In this case, it's best to think as each unique value ("De Volkskrant", "NRC Handelsblad", "Trouw") as a label. This is a typical job for the *factor* type, so let's transform the character type vector to a factor type.

``` r
x = factor(x)
x
```

Two things have changed. Firstly, you see that there is now a line that says "levels: ...", in which the three unique labels are shown. Secondly, the quotes have disappeared. This is because it's no longer a character value.

Behind the scenes, x is now a sequence of numbers, where each number points to a label

``` r
as.numeric(x) ## show the numbers: 1 for De Volkskrant, 2 for NRC and 3 for Trouw
levels(x)     ## show the levels / labels. 
```

If this confuses you, you're still perfectly healthy. The benefits of factors become more apparent later on when you start working with certain types of analysis, visualizations, and when you use very large data (numeric values require less memory than character values).

You might think: well, until then, I don't really see why I should use factors, so I'll keep it simple by sticking to characters. This is a valid strategy, except that R tends to force factors upon you, for example when you import data or make a data.frame, and R thinks that your character column is better of as a factor. There are ways to ask R not to do this, but really, you're better of just accepting factors. It's better on the long run.

Still, if you ever run into trouble with factors and really prefer to use character values, you can simply convert them into "character" type, using **as.character()**

``` r
as.character(x)
```

Logical
-------

The *logical* data type only has two values: **TRUE** and **FALSE** (which can be abbreviated to **T** and **F**). You will not often encounter logical values in your data, but you will use them in many operations such as subsetting and transforming data, as you will see when we discuss data structures. Understanding a bit about logical values will help you understand how these operations work.

For now, we will focus on how logical values result from comparisons, and how logical operators can be used.

### Comparisons

The most common way in which you will get logical values in R is as the results of a **comparison** between two values or two vectors. There are 6 types of comparissons, which use operators that you are probably already familiar with:

| operator  | meaning                         |
|-----------|---------------------------------|
| x &lt; y  | x is smaller than y             |
| x &gt; y  | x is larger than y              |
| x &lt;= y | x is smaller than or equal to y |
| x &gt;= y | x is larger than or equal to y  |
| x == y    | x equals y                      |
| x != y    | x does not equal y              |

The outcome of a comparison of two values is a logical value.

``` r
5 < 10
5 < 2
```

The outcome of a comparison of two vectors is a logical vector. For example, let's assume that we have the average math grade's for 5 students in year 1 and year 2, and we look-up whether their grade went down (i.e. grade in year 1 was higher than year 2). Here we see that only for the first student the grade went down (from 6 in year 1 to 5 in year 2), so only the first value is TRUE.

``` r
grade_year_1 = c(6,6,7,7,4)
grade_year_2 = c(5,6,8,7,6)
grade_year_1 > grade_year_2    
```

If we compare a vector to a single value, each value of the vector will be compared to that value. As you will see shortly, this is a core mechanic behind selecting and subsetting data. In the following example, we will look-up which participants for our hypothetical drinking study are at least 18 years old.

``` r
age = c(17,34,12,20,12,25,30,14,33)
age >= 18
```

Finally, while not strictly a comparison, there is another common operator that creates a logical value or vector.

| operator | meaning                           |
|----------|-----------------------------------|
| x %in% y | the value(s) in x also exist in y |

This is for instance usefull if you want to look for multiple values. For example, let's select select `Bob` and `Carol` from our list of names.

``` r
name = c('Alice','Bob','Carol','Dave','Eve')
name %in% c('Bob', 'Carol')
```

### Logical operators

Given a logical value (or vector), we can use the logic operators & (AND), | (OR) and ! (NOT). In the following table, x and y are both logical values.

| operator | meaning | outcome                                        |
|----------|---------|------------------------------------------------|
| x & y    | x AND y | only TRUE if both x and y are TRUE             |
| x | y    | x OR y  | only TRUE if either x or y, or both are TRUE.  |
| !x       | NOT x   | the opposite if x, so only TRUE if x is FALSE. |

You can play with the following code to try it out (results not shown in this document).

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

Date
----

Date is not one of the basic data types in R, but in social scientific research we often work with calendar dates and times. This requires a special data type, because there are many limitations or complications if we try to express dates and times as character or numeric values. Two of the most common date classes in native R (i.e. not requiring additional packages) are *Date*, which only handles calendar dates, and *POSIXlt*, that handles both calendar dates and times.

In this tutorial we will only demonstrate how to use *POSIXlt*, but the general approach for working with dates and times in R is the same for different date types (and is actually similar in other programming languages as well). You can do most things that you need with only two functions: *strptime* and *strftime*

-   strptime (**str**ing **p**arse **time**) creates a date/time value from a character value
-   strftime (**str**ing **f**ormat **time**) extracts parts of a date/time from a date/time value.

For both functions, you need to know how to specify the *format*. Essentially, this is a string (character value) that contains the date format, using special placeholders to indicate specific parts of the date. These placeholders are always a percentage symbol **%** followed by a letter. The most commonly used placeholders are:

| placeholder | date part                                               |
|-------------|---------------------------------------------------------|
| %Y          | year with century (2010, 2011, etc.)                    |
| %m          | month as a decimal number (01, 02, 03, ..., 10, 11, 12) |
| %d          | day as a decimal number (01, 02, 03, ..., 28, 29, 30)   |
| %H          | hour as a decimal (00, 01, 02, ..., 21, 22, 23)         |
| %M          | minute as a decimal (00, 01, 02, ..., 57, 58, 59)       |
| %S          | seconds as a decimal (00, 01, 02, ..., 57, 58, 59)      |

Using these placeholders, we can describe various date formats. Here we show how to use this together with the **strptime** function to **parse** a date from character type to a date (POSIXlt) type. We will explain more about functions below. For now, just note that the first argument passed to **strptime()** is the date, and the second argument is the format.

``` r
strptime('2010-01-01 20:00:00', format = '%Y-%m-%d %H:%M:%S')
strptime('01/01/2010', format = '%m/%d/%Y')
strptime('2010 any 01 format 01 goes', format = '%Y any %m format %d goes')
```

With the **strftime()** function we can use the same format strings to extract specific parts from a date/time value. Here, we first create a POSIXlt date with strptime, and then use strftime to extract parts. Note that all parts are returned as a character value, even if they are single numbers.

``` r
x = strptime('2010-06-01 20:00:00', format = '%Y-%m-%d %H:%M:%S')
strftime(x, '%Y')
strftime(x, '%Y week %W')
strftime(x, 'Today is a %A')  ## language of weekday depends on your locale settings
```

You can find a full list of format placeholders in the documentation of the **strptime** function, which you can access by putting a questionmark in front of the function name and running it as code. The help page should open in your bottom-right window in RStudio.

``` r
?strptime
```

For reference, if you feel the urge to master date and time operations, there is also the excellent **lubridate** package. Usage is explained in detail in this (free online) [chapter from "R for Data Science"](http://r4ds.had.co.nz/dates-and-times.html). You can also download the cheatsheet [here](https://github.com/rstudio/cheatsheets/raw/master/lubridate.pdf).

Data structures
===============

In SPSS or Excel, data is always organized in a rectancular data frame, with cells arranged in rows and columns. Typically, the rows then represent cases (e.g., repondents, participants, newspaper articles) and columns represent variables (e.g., age, gender, date, medium). For most analyses, this is also the recommended data format in R, using the *data.frame* structure. However, an important difference is that in R it is possible, and often usefull, to combine different formats. Also, to understand how a *data.frame* in R works, it is usefull to understand that a *data.frame* is a collection of *vectors*, and thus it is usefull to understand how *vectors* work.

Here we will first briefly discuss *vectors*, and then quickly move on to *data.frames*. In addition, we will mention *matrices* and *lists* on a good-to-know-about basis.

Vector
------

The concept of a vector might be confusing from a social science background, because we rarely use the term in the context of statistics (well, not consciously at least). We won't address why R calls them vectors and how this relates to vector algebra, but only how you most commonly use them.

A vector in R is a **sequence** of **one or more values** of the **same data type** From a social science background, it is very similar to what we often call a **variable**.

You can declare a vector in R with c(...), where between the parentheses you enter the elements, separated with commas. The number of elements is called the length of the vector. A vector can have any of the data types discussed above (numeric, character, factor, logical, Date).

``` r
v1 = c(1, 2, 10, 15)    ## a numeric vector of length 4
v2 = c("a", "b", "b")   ## a character vector of length 3
v3 = 1:10               ## a numeric vector of length 10 with the values 1 to 10. 
```

If you combine data types in the same vector, R will generally use the broadest data type for the entire vector. For example, we saw earlier that a number can be expressed as a character value, but a text cannot be expressed as a numerical. Accordingly, if we combine both types in a vector, R will convert the numerical values to character values.

``` r
c(1, 2, "c")            ## becomes a character vector of length 3
```

Since vectors can only have one type, we can perform type specific operations with them. In many ways, we can work with them in the same way as we can work with single values. In fact, single values are actually just vectors of length 1. For example, if we have a vector of numeric type, also called a numeric vector, we can perform calculations.

``` r
x = c( 1, 2, 3, 4, 5)
y = c(10,20,30,40,50)
x + y     ## for 2 vectors of same size calculations are pairwise (1 + 10, 2 + 20, etc.)
x + 10    ## for a vector and single value, the value is repeated (1 + 10, 2 + 10, etc.)
```

### Selecting elements

There are two common ways to select a specific element or a range of elements from a vector. One is to give the indices (positions) of the elements in square brackets after the vector name. Note that the indices themselves are given as a numeric vector.

``` r
x = c('a','b','c','d','e','f','g')  
x[5]            ## select the fifth element
x[c(1,3)]       ## select the first and third elements
x[2:5]          ## select elements two to five
```

If you select with indices, the specific order of the indices is used, and you can also repeat indices. This can for instance be used to sort data.

``` r
x[5:1]          ## select elements in positions 5 to 1
x[c(5,5,5)]     ## select the element in position 5 multiple times
```

You can also use negative indices to select everything except the specified elements.

``` r
x[-5]            ## select every element except the fifth
x[-c(1,3)]       ## select every element other than the first and third
```

The second way to select values is to use a logical vector. The logical vector has to be of the same length, and all values for which the logical vector is TRUE will be selected.

``` r
x[c(TRUE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE)]
```

This is where your hard thinking about logical vectors pays off. As we have seen above, you can create logical vectors by using comparisons. Accordingly, we can use comparisons to select values.

``` r
age = c(17,34,12,20,12,25,30,14,33)

selection = age >= 18   ## comparison creates logical vector
age[selection]          ## selects values using logical vector

age[age >= 18]          ## same, but less verbose (recommended) 
```

Data.frame
----------

A *data.frame* is essentially a collection of vectors with the same length, tied together as columns. To create the *data.frame*, we use the **data.frame()** function. We enter the vectors in the format: `column_name = vector`. Here we create a data.frame for data from a fictional experiment.

``` r
d = data.frame(id =        1:10,
               condition = c('E', 'E', 'C', 'C', 'C', 'E', 'E', 'E', 'C', 'C'),
               gender =    c('M', 'M', 'F', 'M', 'F', 'F', 'F', 'M', 'M', 'F'),
               age =       c( 17,  19,  22,  18,  16,  21,  18,  17,  26,  18),
               score_t1 =  c(8.0, 6.0, 7.5, 6.8, 8.0, 6.4, 6.0, 3.2, 7.3, 6.8),
               score_t2 =  c(8.3, 6.4, 7.7, 6.3, 7.5, 6.4, 6.2, 3.6, 7.0, 6.5))
d
```

|   id| condition | gender |  age|  score\_t1|  score\_t2|
|----:|:----------|:-------|----:|----------:|----------:|
|    1| E         | M      |   17|        8.0|        8.3|
|    2| E         | M      |   19|        6.0|        6.4|
|    3| C         | F      |   22|        7.5|        7.7|
|    4| C         | M      |   18|        6.8|        6.3|
|    5| C         | F      |   16|        8.0|        7.5|
|    6| E         | F      |   21|        6.4|        6.4|
|    7| E         | F      |   18|        6.0|        6.2|
|    8| E         | M      |   17|        3.2|        3.6|
|    9| C         | M      |   26|        7.3|        7.0|
|   10| C         | F      |   18|        6.8|        6.5|

Now, the data structure clearly implies that there is a relation between the elements in the *column vectors*. In other words, that each row represents a *case*. In our example, these cases are participants, and the columns represent:

-   the participant **id**.
-   the experimental **condition** (E = experimental condition, C = control group)
-   demographic variables: **gender** and **age**.
-   test scores before and after the experimental condition: **score\_t1** and **score\_t2**

### Selecting rows, columns and elements

Since data.frames have both rows and columns, we need to use both to select data. Similar to selection in vectors, we use the square brackets. The difference is that for data.frames the square brackets have two parts, separated by a comma. Assuming our data.frame is called `d`, we can select with:

| syntax   | meaning                                  |
|----------|------------------------------------------|
| d\[i,j\] | select rows (i) and columns (j)          |
| d\[i, \] | select only rows (i) and use all columns |
| d\[ ,j\] | select only columns (i) and use all rows |

Selection for rows (i) and columns (j) works identical to selection in vectors. You can use either a numeric vector with indices, or a logical vector. Accordingly, you can also use comparisons.

In addition, there are two special ways to select columns. One is that j can be a character vector with column names. The other uses the dollar sign ($).

| syntax               | meaning                                         |
|----------------------|-------------------------------------------------|
| d\[ ,c("c1", "c2")\] | select the columns with the names "c1" and "c2" |
| d$id                 | select the column named id                      |

#### selecting columns

Let's put this to practice, starting with columns:

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

As mentioned, you can also use a logical vector to select columns. For now, we'll leave it up to your imagination when this might be usefull.

#### selecting rows

Selecting rows is practically identical to selecting elements from vectors, and it conveniently returns a data.frame with all columns and their matched positions intact.

``` r
d[1:5,]    ## select first 5 rows
```

A very usefull additional trick is that you can use all the columns to make comparisons. For example, we can use the gender column to look up all elements for which the value is "M" (male), and use this to select rows.

``` r
## step-by-step example     
selection = d$gender == "M" ## look up elements in d$gender of which value is "M"    
selection                   ## see that this is a logical vector
d[selection, ]              ## use logical vector to select rows

d[d$gender == "M", ]        ## recommended style 
```

You can combine this with the logical operators to make a selection using multiple columns.

``` r
d[d$gender == "F" & d$age == 21, ]    ## 21 year old female participant(s)
d[d$score_t1 < d$score_t2,]           ## participants that scored higher after the condition
```

#### selecting rows and columns

We can combine row and column selection. This works just like you'd expect it to, so there's little to add here. Do note, however, that you can combine the different selection methods.

``` r
d[d$gender == "F", "score_t1"]    ## get the score_t1 column for female participants
d[d$gender == "F",]$score_t1      ## identical, but first subset data.frame, then select column
d$score_t1[d$gender == "F"]       ## identical, but first select column vector, then subset vector
```

### Subsetting, adding and modifying data

With the selection techniques you already learned how to create a subset of the data. Now, you can assign this subset to a new name.

``` r
experimental_group = d[d$condition == "E",]
experimental_group

demographics = d[, c('id','gender','age')]
demographics
```

You can add a column by 'selecting' a non-existing column and assigning a vector to it. If this is a single value, the value will be repeated for the entire column. For example, we'll add a dummy variable for `male`, which we'll first set to 0.

``` r
d$male = 0
d
```

Now, if we want to change this value to 1 for all the male participants, we can simply use selection to get this column for male participants only, and then assign 1 to this selection.

``` r
d$male[d$gender == "M"] = 1
d
```

Finally, note that you can also perform a calculation with your current columns, and assign this to a new column, or overwrite an existing column. For example, let's say that we actually needed to have our scores on a scale from 1 to 100. We can simply multiply the columns by 10.

``` r
d$score_t1 = d$score_t1 * 10
d$score_t2 = d$score_t2 * 10
d
```

Matrix
------

We will not discuss the matrix data structure in-dept here, because most of the time you will likely be working with data.frames. Still, it is good to have a rough idea of what a matrix is, and for some purposes you simply can't beat a matrix.

A matrix is similar to a data.frame in that it is a collection of vectors of the same length. The difference is that in a matrix all these vectors have to be of the same data type. This is less flexible than a data.frame, but it opens up interesting posibilities (hooray for matrix algebra).

That being said, if you encounter a matrix and have no specific purpose for it, you can force it into a data.frame with the `as.data.frame()` function.

List
----

Lists are very flexible data structures, that can basically contain everything. You can have a list that contains vectors and data.frames of different sizes, and even lists that contain lists (that contain lists that contain lists...). This makes lists common for complex and nested data. At this point, knowing about lists is above all important for cases where you need to get your data out of a list.

We'll focus on the two main ways to select data in a list. One is to use the dollar sign. The other is to give the index (position) in double square brackets `[[ ]]`. Using the dollar sign is only possible if the values in the list are `named`, so it's good to now about both.

Here we make a list where the first two values (10 and 20) are named (a and b), and the third value (30) doesn't have a name. We can select a and b with the dollar sign, but for the third value we need to give the position,

``` r
l = list(a = 10, b = 20, 30)
l$a        ## first element by name
l[[1]]     ## first element by position
l[[3]]     ## third element by position
```

If a list contains lists, you need to keep digging.

``` r
l = list(l2 = list(l3 = list(a = 'finally!')))
l$l2$l3$a
```
