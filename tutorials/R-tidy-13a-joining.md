13a\_joining\_data
================
Kasper Welbers, Wouter van Atteveldt & Philipp Masur
2021-10

-   [Joining data](#joining-data)
    -   [Data](#data)
    -   [Downloading and preparing the
        data](#downloading-and-preparing-the-data)
-   [Simplest case: `inner_join`](#simplest-case-inner_join)
-   [Specifying columns](#specifying-columns)
-   [Left and right joins](#left-and-right-joins)

# Joining data

In many cases, you need to combine data from multiple data sources. For
example, you can combine a sentiment analysis of tweets with metadata
about the tweets; or data on election results with data about the
candidates ideological positions or details on the races.

This tutorial will teach you the `inner_join` and other `_join` commands
used to combine two data sets on shared columns. See [R4DS Chapter 13:
Relational Data](http://r4ds.had.co.nz/relational-data.html) for more
information and examples.

## Data

For this tutorial, we will look at data describing the US presidential
primaries. These data can be downloaded from the [Houston Data
Visualisation github
page](https://github.com/houstondatavis/data-jam-august-2016), who in
turn got it from
[Kaggle](https://www.kaggle.com/benhamner/2016-us-election).

In the CSV folder on the github, you can find (among others)

-   `primary_results.csv` Number of votes in the primary per county per
    candidate
-   `primary_schedule.csv` Dates of each primary per state and per party
-   `county_facts.csv` Information about the counties and states,
    including population, ethnicity, age, etc.

For many research questions, we need to be able to combine the data from
these files. For example, we might want to know if Clinton did better in
counties or states with more women (needing results and facts), or how
Trump’s performance evolved over time (requiring results and calendar).

## Downloading and preparing the data

Before we start, let’s download the three data files:

``` r
library(tidyverse)
csv_folder_url <- "https://raw.githubusercontent.com/houstondatavis/data-jam-august-2016/master/csv"
results <- read_csv(paste(csv_folder_url, "primary_results.csv", sep = "/"))
facts <- read_csv(paste(csv_folder_url, "county_facts.csv", sep = "/"))
schedule  <- read_csv(paste(csv_folder_url, "primary_schedule.csv", sep = "/"))
```

Note: I use `paste` to join the base url with the filenames, using a `/`
as a `sep`arator.

Have a look at all three data sets. Before we proceed, there are some
things we want to do. First, the `facts` data frame is really large,
with 54 columns. Let’s select a couple interesting ones to work with:

``` r
facts_subset <- facts %>% 
  select(area_name, 
         population = Pop_2014_count, 
         pop_change = Pop_change_pct, 
         over65 = Age_over_65_pct, 
         female = Sex_female_pct, 
         white = Race_white_pct, 
         college = Pop_college_grad_pct, 
         income = Income_per_capita)
```

Next, the schedule dates are now a character (textual) field rather than
date, so let’s fix that using the `as.Date` function, specifying the
dates to be formatted as month/day/year:

``` r
schedule <- schedule %>% 
  mutate(date = as.Date(date, format="%m/%d/%y"))
```

Last, let’s create a data set with per-state (rather than per-country)
election results using `group_by` and `summarize`:

``` r
results_state <- results %>% 
  group_by(state, party, candidate) %>% 
  summarize(votes = sum(votes))
results_state
```

Note: see [R-tidy-5-transformations](R-tidy-5-transformation.md) if you
are unsure about the transformations above!

# Simplest case: `inner_join`

The basic command for joining data in R is the `inner join`. It takes
two data frames and joins it on any variable that occurs in both. It
results in a new data frame with the information in both frames joined
together. For example, this adds the dates to all primary results (per
state)

``` r
inner_join(results_state, schedule)
```

# Specifying columns

By default, joining is performed with all shared columns as joining
*keys*. If this is not correct, you can specify the joining key with the
`by=` option. A common use case is if the variable names are not the
same, for example the state in the `facts` data is coded as `area_name`:

``` r
inner_join(results_state, facts_subset, by = c("state" = "area_name"))
```

# Left and right joins

As seen above, `inner_join` keeps only rows that occur in both data
sets: the county-level facts are (silently) dropped because their names
don’t occur in the state results.

Sometimes this is undesirable. For example, suppose we have data on
candidate age, but not on all candidates:

``` r
age <- tibble(candidate = c("Hillary Clinton", "Bernie Sanders", "Donald Trump"), 
              age = c(70, 77, 72))
age
```

Now, if we would do an `inner_join` with the election results it would
drop all other candidates (since they do not occur in the age dataset):

``` r
inner_join(results_state, age)
```

You can prevent this from occurring by using `left_join`, which always
keeps all rows in the first dataset:

``` r
left_join(results_state, age)
```

As you can see, Ben Carson and others are still in the data, with
missing values (NA) in their age column. Left join keeps all rows in the
first data sets, but drops rows in the second data set that don’t occur
in the first. Right join does the opposite, keeping all rows in the
second data set but potentially dropping rows in the first. Finally,
`full_join` keeps all rows that occur in either data set.
