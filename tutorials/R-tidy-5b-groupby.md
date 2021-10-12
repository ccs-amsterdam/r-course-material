R Tidyverse: Data Summarization with group\_by, summarize, and mutate
================
Kasper Welbers, Wouter van Atteveldt & Philipp Masur
2021-10

-   [Data Summarization](#data-summarization)
-   [Simple data summarization](#simple-data-summarization)
    -   [Grouping rows](#grouping-rows)
    -   [Summarizing](#summarizing)
    -   [Using mutate with group\_by](#using-mutate-with-group_by)
    -   [Ungrouping](#ungrouping)
-   [Multiple grouping variables](#multiple-grouping-variables)
-   [Missing values](#missing-values)

# Data Summarization

The functions used in the earlier part on data preparation worked on
individual rows. Sometimes, you need to compute properties of groups of
rows (cases). This is called aggregation (or summarization) and in
tidyverse uses the `group_by` function followed by either `summarize` or
`mutate`.

# Simple data summarization

First, let’s fire up tidyverse and load the gun polls data used in the
earlier example:

``` r
library(tidyverse)
url <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/poll-quiz-guns/guns-polls.csv"
d <- read_csv(url) %>% 
  select(-URL) %>% 
  rename(Rep = `Republican Support`, Dem = `Democratic Support`)
d
```

## Grouping rows

Now, we can use the group\_by function to group by, for example,
pollster:

``` r
d %>% 
  group_by(Question)
```

As you can see, the data itself didn’t actually change yet, it merely
recorded (at the top) that we are now grouping by Question, and that
there are 8 groups (different questions) in total.

## Summarizing

To summarize, you follow the group\_by with a call to `summarize`.
Summarize has a syntax that is similar to mutate:
`summarize(column = calculation, ...)`. The crucial difference, however,
is that you always need to use a function in the calculation, and that
function needs to compute a single summary value given a vector of
values. Very common summarization functions are sum, mean, and sd
(standard deviation).

For example, the following computes the average support per question
(and sorts by descending support):

``` r
d %>% 
  group_by(Question) %>%                    # group by "Questions"
  summarize(Support = mean(Support)) %>%    # average "Support" per group
  arrange(-Support)                         # sort based on "Support"
```

As you can see, summarize drastically changes the shape of the data.
There are now rows equal to the number of groups (8), and the only
columns left are the grouping variables and the summarized values.

You can also compute summaries of multiple values, and even do ad hoc
calculations:

``` r
d %>% 
  group_by(Question) %>% 
  summarize(Dem = mean(Dem), 
            Rep = mean(Rep), 
            diff = mean(Dem-Rep)) %>% 
  arrange(-diff)
```

So, Democrats are more in favor of all proposed gun laws except arming
teachers.

You can also compute multiple summaries of a single value. Another
useful function is `n()` (without arguments), which simply counts the
values in each group. For example, the following gives the count, mean,
and standard deviation of the support:

``` r
d %>% 
  group_by(Question) %>% 
  summarize(n = n(),
            mean = mean(Support), 
            sd = sd(Support))
```

Note: As you can see, one of the values has a missing value (NA) for
standard deviation. Why?

## Using mutate with group\_by

The examples above all reduce the number of cases to the number of
groups. Another option is to use mutate after a group\_by, which allows
you to add summary values to the rows themselves.

For example, suppose we wish to see whether a certain poll has a
different prediction from the average polling of that question. We can
group\_by question and then use mutate to calculate the average support:

``` r
d2 <- d %>% 
  group_by(Question) %>%
  mutate(avg_support = mean(Support), 
         diff = Support - avg_support)
d2
```

As you can see, where summarize reduces the rows and columns to the
groups and summaries, mutate adds a new column which is identical for
all rows within a group.

## Ungrouping

Finally, you can use `ungroup` to get rid of any groupings.

For example, the data produced by the example above is still grouped by
Question as mutate does not remove grouping information. So, if we want
to compute the overall standard deviation of the difference we could
ungroup and then summarize:

``` r
d2 %>% 
  ungroup() %>% 
  summarize(diff = sd(diff))
```

(of course, running `sd(d2$diff))` would yield the same result.)

If you run the same command without the ungroup, what would the result
be? Why?

# Multiple grouping variables

The above examples all used a single grouping variable, but you can also
group by multiple columns. For example, I could compute average support
per question and per population:

``` r
d %>% 
  group_by(Question, Population) %>% 
  summarize(Support = mean(Support))
```

This results in a data set with one row per unique group,
i.e. combination of Question and Population, and with separate columns
for each grouping column and the summary values.

As you can see from the example above, the resulting data set is still
grouped by, but only by `Question`. Keeping the groups intact after
summarization would not be useful, as you would never want to compute a
summary of the same groups: each of the old groups is now a single row.
Thus, while mutate keeps the grouping information intact, *summarize
drops the outermost grouping column*, in this case Population.

This allows you to compute the the (macro-)average support per question:
(i.e. the mean of the summaries per population)

``` r
d %>% 
  group_by(Question, Population) %>% 
  summarize(Support = mean(Support)) %>% 
  mutate(avg_support = mean(Support))
```

Can you find a way to add the micro-average as well (i.e. the mean of
the individual polls)?

# Missing values

Summary functions in R by default return `NA` if any of the values to be
summarized are `NA`:

``` r
mean(c(3,4,NA,6))
```

As a result, if you summarize over rows that contain a missing value, it
will set the summary value to NA. Let’s first use `ifelse` to introduce
a NA value: we set Support to NA for any CBS News polls:

Note: Ifelse takes 3 values:
`ifelse(test, value-if-true, value-if-false)`, which will set each row
according to the test. In this case, we test whether Pollster equals
CBS, and if true, set support to NA, otherwise set support to support
(i.e. keep it unchanged)

``` r
d2 <- d %>% 
  mutate(Support = ifelse(Pollster == "CBS News", NA, Support))
```

Now, if we take the mean support per question it will return NA for any
questions on which CBS was part of the set:

``` r
d2 %>% 
  group_by(Question) %>% 
  summarize(Support = mean(Support))
```

While this is a very ‘correct’ way to treat missing values, in many
cases we simply want to ignore this. So, we add `na.rm=T` to the mean
function:

``` r
d2 %>% 
  group_by(Question) %>% 
  summarize(Support = mean(Support, na.rm = T))
```
