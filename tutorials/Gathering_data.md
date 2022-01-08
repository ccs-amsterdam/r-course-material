Gathering data into R
================
Kasper Welbers & Wouter van Atteveldt
January 8, 2021

-   [Tabular data formats](#tabular-data-formats)
    -   [CSV files](#csv-files)
    -   [Excel files](#excel-files)
    -   [SPSS files](#spss-files)
    -   [Stata files](#stata-files)
-   [Hierachical file formats](#hierachical-file-formats)
    -   [Working with hierarchical data in
        R](#working-with-hierarchical-data-in-r)
    -   [JSON](#json)
    -   [XML](#xml)
    -   [HTML (sort of)](#html-sort-of)
-   [APIs](#apis)
    -   [Google trends](#google-trends)
    -   [Yahoo stock exchange data](#yahoo-stock-exchange-data)
    -   [Example: CBS](#example-cbs)
-   [Web scraping](#web-scraping)

# Tabular data formats

## CSV files

CSV stands for comma-separated values. It’s a simple and widely used
format for storing tabular (i.e. data in rows and columns) data. The
nice thing about CSV is that it’s essentially a plain text file. The
different rows of the tabular data are indicated by different lines in
the text file. The different columns are indicated by the use of a
“delimiter character” (often a comma or semicolon) that splits the lines
into column.

The advantage of this format is that it can be imported by virtually any
software that uses tabular data (e.g., Excel, SPSS, R, Stata). Because
it’s so simple, it holds few surprises. In comparison, if tabular data
is stored as an Excel file, there might be Excel specific data that goes
beyond a simple data table (e.g., formulas, muliple sheets).
Accordingly, CSV is often the

That being said, there is sadly no universal standard for what a CSV
file looks like. The name “commma-separated values” refers to a comma
being used as a delimiter, but this can also be a semicolon, or a tab.
Also, CSV files require a “quotation character” (often a double quote)
in case the data contains texts. For example, if the delimiter character
is a comma, and a column contains the name “Trump, Donald”, it needs to
be clear that this comma is part of the text and not to be interpreted
as a delimiter. Another important settings is whether a dot or a comma
is used as the decimal point.

Luckily, the diversity of such settings in CSV files is limited today.
The `readr` package (which is part of the tidyverse) therefore has 3
general flavours and 1 more versatile function.

-   `read_csv` is the default with a comma separator and dot for decimal
    point. This is often what you need.
-   `read_csv2` uses a semicolon (;) separator with comma for decimal
    point.
-   `read_tsv` uses tabs as separator (tsv stands for tab-separated
    values). (`read_csv`, `read_csv2`, `read_tsv`). If you encounter a
    CSV
-   `read_delim` lets you specify the delimiter and quotation character,
    and some other settings.

Naturally, this is all properly documented:

``` r
library(tidyverse)
?read_csv
```

You can read CSV files with the function from your local device by
giving the location on your computer as the first argument. If you have
trouble finding the right way to specify the location, you can also use
the files browser in the bottom-right corner in Rstudio. If you click on
a .csv file, you can get an import window that also uses `readr`.

Conveniently, you can also read CSV files directly from the internet.
For example, the data used by fivethirtyeight.com is published as csv
files. Simply speaking, if you have a URL that point directly to a .csv
file, you can directly download and read it into R.

``` r
url = 'https://projects.fivethirtyeight.com/trump-approval-data/approval_polllist.csv'
d = read_csv(url)
```

Note that read_csv immediately tells you how it parsed the data (and
warns you if it notices that things went badly).

``` r
d
```

### A word of caution

Be very carefull with opening CSV files in Excel. Excel if will often
try to guess how the CSV files should be parsed, and this can often go
(partially) wrong. Even if you only open it and then save it, it might
still have messed up your data.

If you want to import CSV files into Excel to work with them in Excel,
make sure to properly import the file. If you only want to have a look
before loading the data into R, DO NOT OVERWRITE the original CSV.

## Excel files

Excel files also contain tabular data, but they are more complicated
than CSV files. Excel files can for instance contain formulas, table
decorations, visualizations, and multiple sheets.

If the data that you need is only available as an Excel file, there are
two general approaches you could take. One is to simply open the file in
Excel, and then save/export it as a CSV file. This gives you full
control, but sometimes it’s not practical. If data is very large it
might crash Excel, or you might have to open many files, or you might
simply not have Excel on your computer. The alternative is to use one of
the packages for importing Excel files, such as `openxlsx`.

## SPSS files

Similar to Excel files, SPSS files contain tabular data but with some
SPSS specific decorations. For instance, in SPSS a column for an ordinal
variable might consist of numbers with values labels (This is similar,
but not identical to `factors` in R). Also, SPSS columns have a separate
variable name and variable label. The variable name is often short but
nonsensical (e.g., V1 for question 1 in a survey) and the variable label
is often an elaborate description (e.g., “Question 1: In what year were
you born?”). There is also the issue of how missing values are
indicated.

This can make it difficult to import a SPSS file into R. Just like in
Excel, you can first export the SPSS file as a CSV file, but this might
also require you to rename some columns and recode values.

Luckily, there is also the `haven` package (which is also designed by
the main author of the tidyverse) for importing SPSS data. This package
imports the data with the SPSS information on labels intact, and
provides functions for properly converting the SPSS data into a more
regular tibble in R. This is described in the [conversion
semantics](https://cran.r-project.org/web/packages/haven/vignettes/semantics.html)

## Stata files

Similar to SPSS, Stata data can be imported into R, but you’ll need to
consider some conversion steps. Our suggestion here is the same as for
SPSS, and luckily, the `haven` package also supports Stata.

# Hierachical file formats

`Hierarchical file formats` is not an official name for the following
types of formats, but it describes an important difference. The tabular
data formats described above have rows and columns, and each cell
(generally) only contains a single value. But data can also be nested
(i.e. values within values).

For example, consider social media data. A Facebook post can have
multiple comments. In a hierarchical format, we can then have one entry
with the data at the post level (e.g., message, links, likes, shares)
and within this entry there can be a list with the comment level data.

Note that this type of data can be stored in a tabular format. If there
are multiple comments for one post, we could use a long format in which
each row in the data one comment. However, this would require the data
at the post level to be duplicated for each row, which for large
datasets can be problematic (and require more bandwidth to share). This
is why an hierarchical format is often used to publish this data.

## Working with hierarchical data in R

Before we discuss some of the format for importing hierarchical/nested
data, we’ll first have a look at how to unnest this data into a proper
tibble.

If you import hierachical data, it is typically represented in R as a
list with lists. Here we create an example of a single (social media)
post, with two nested comments.

``` r
post = list(
  post_id = 1,
  post_text = "This is a social media post",
  post_likes = 4,
  comments = list(
    list(
      comment_id = 1,
      comment_text = "this is a comment"
    ),
    list(
      comment_id = 2,
      comment_likes = 1,
      comment_text = "this is another comment"
    )
  )
)
```

This data is not very convenient to work with

``` r
post$post_text
post$comments[[1]]$comment_text
post$comments[[2]]$comment_text
```

Instead, it is easier to first `unnest` the data. And as always,
tidyverse has thought of that and offers help (though it still requires
carefull work) First, let’s make it into a tibble.

``` r
pt = as_tibble(post)
pt
```

Now we have a tibble with 2 rows (because the comments column has two
values). We see that the comments column has a nested list (Please note
how cool it is that tibbles allow you to have nested lists!!). For the
first row the comment has a list of length \[2\], and for the second row
the length is 3. This is because in the second comment we included a
`likes = 1` value.

With the `unnest` function, we can unnest this list column. We can also
determine whether we want to unnest the column to a long or wide format
with `unest_longer` and `unnest_wider`. In this case we’ll make it
wider, since the nested list only contains variables for each comment.

``` r
unnest_wider(pt, comments)
```

Nice and tidy!

Of course, this was relatively easy, but if you understand the basics,
then you should be able apply this approach to more complex nested data.
One problem that you’ll often encounter is that nested columns might
have the the same names as higher level column. For example, in our
example, we used “post_text” and “comment_text”, but this could very
well both have been labeled “text”. In that case you’ll need to use the
`names_repair` argument in `unnest` to tell R how you want to deal with
duplicate column names.

## JSON

JSON (Javascript Object Notation) is a widely used file format. In
particular, it is very common as a format for exchanging data via an
API.

To show what it looks like, we can make a JSON string from our nested
list created above. With toJSON we convert the list to JSON. The
`pretty` argument is not necessary, but makes it easier to read the JSON
string (it adds the indentation).

``` r
library(jsonlite)
j = toJSON(post, pretty = T)
cat(j)
```

If you imported a JSON file into R, you can similarly use the fromJSON
function to go from JSON to a nested list. By default, the fromJSON
function from jsonlite tries to simplify nested lists to a data.frame.
This can be convenient if it works, but if you want to use the tidyverse
approach its best to disable this features by setting
`simplifyDataFrame` to FALSE

``` r
fromJSON(j, simplifyDataFrame = F)
```

fromJSON can also be used to read a file directly from the internet.

``` r
d = fromJSON("https://api.github.com/users/hadley/repos")
as_tibble(d)
```

## XML

XML is similar to JSON, but it is less popular. The main reason for this
is that XML is harder to parse.

The `XML` package can be used to parse XML files. While there is an
`xmlToDataFrame` function, this won’t work well for most XML files, so
you’re better of using `xmlParse`, which imports the data as a (nested)
list. You can then proceed to tidy it.

You can also use the `rvest` package for webscraping to parse XML files.
This is convenient if you only want to extract specific information from
the XML file.

## HTML (sort of)

HTML is not really used to publish data, but it is good to realize that
it is also hierarchically organized. If you have data in HTML format
(e.g., on a webpage), you can extract it with the `rvest` package. This
is basically what web scraping is all about, as discussed below.

# APIs

Another way to get data is via an API (an
`application programming interface`). This is an interface for
communication between (parts of) computer programs. In the context of
data gathering, API often more specifically refers to an interface
between a client and a server. For instance, the newspaper The Guardian
has an API that people can use to search and download their news
content. In this case The Guardian has a server with an API, and clients
can get an access key (for free) that they can use to access the data.

The great thing about APIs is that it can give you easy access to data.
The problem of APIs is that you are entirely dependent on the access
that the provider gives you [Freelon,
2018](https://osf.io/preprints/socarxiv/56f4q). If you are interested in
the data from a certain party (e.g., a medium, a social media platform,
a government institution), a good place to start is by looking if they
have a (good) API.

If an API exists, another thing to look for is if there is already an R
package that provides bindings for working with the API. While you can
write these yourself, it requires some knowledge of API protocols and
even then can take quite some time to figure out. For many usefull APIs
there are already R packages, so please do use them.

## Google trends

Google trends data can be pretty cool if you want to get a decent proxy
of what people were interested in over time. It tells you the relative
frequency that people searched for certain terms. Conveniently, Google
trends has an API, and the `gtrends` package provides bindings for this
API.

``` r
library(gtrendsR)
```

Now we can for instance look for when people searched for ‘covid’. In
addition, we distinguish between the Netherlands (NL) and the United
States (US), and we’ll look from the start of 2020 till the end of 2021.

``` r
trend = gtrends('covid', geo=c("NL","US"), time = '2020-01-01 2021-12-31')
plot(trend)
```

Note that the y-axis only tells something about the relative frequency
of searches. It is an index, where the day with the highest number of
searches is 100, and the day with the lowest number of searches is 0.
But Google trends won’t tell you the actual frequency at 0 or 100. For
certain types of questions that’s OK, but it showcases an important
limitation of APIs. You’ll be entirely dependent on what information the
organization behind the API is willing to provide you with.

The `trend` data can also be extracted as a tibble.

``` r
as_tibble(trend$interest_over_time)
```

Note that `hits` has these weird `<1` values. A good R lesson here is
that the column is now a character (`<chr>`) type, so if you want to
plot this data yourself, or do some sort of statistical analysis, you’d
first have to replace these values with actual numbers (0 or 1) and
convert the column to numeric.

``` r
as_tibble(trend$interest_over_time) %>%
  mutate(hits = as.numeric(ifelse(hits == '<1', 0, hits)))
```

There’s some other fun stuff as well, such as related queries.

``` r
as_tibble(trend$related_queries)
```

## Yahoo stock exchange data

If you’re into studying markets, it would be convenient to directly read
stock market data into R. `Yahoo` has an API for getting this data, and
the `quantmod` package provides bindings for working with this API.

``` r
library(quantmod)
```

In this example, we’ll first use the symbol TSLA to get the Tesla Inc
stock data. For other organizations, you can search [the Yahoo finance
page](https://finance.yahoo.com). For reference, [ticker
symbols](https://en.wikipedia.org/wiki/Ticker_symbol) are simply unique
company identifiers.

``` r
start_date = as.Date('2010-07-01')
end_date = as.Date('2021-12-31')
tesla = getSymbols('TSLA', from=start_date, to=end_date, src='yahoo', auto.assign = F)
```

The output is a special type of data frame for time series analysis,
because often you’d want to use time series to analyse this data. For
instance, you could link it to other time series to see if changes in
stocks are related to certain developments in society.

For now, let’s just have a look at the data. The `candleChart` function
from the quantmod package is designed to quickly inspect the overall
developments in the stock market over time.

``` r
candleChart(tesla)
```

You could also transform it to a `tibble`, so that you can use all the
tidyverse stuff that you know and love. Here `as_tibble(tesla)` turns
the data into a tibble, but to get the date from the time series object
we need to use `index(tesla`). With `bind_cols` we then simply bind the
`date = index(tesla)` column and the `as_tibble(tesla)` tibble into a
single tibble.

``` r
bind_cols(date = index(tesla), as_tibble(tesla))
```

## Example: CBS

Some providers of open data (such as government institutions) provide
APIs to access their datasets. And moreover, some of them also provide R
packages for using these APIs.

How this works really depends on the package. Here we provide an example
of the Dutch CBS (central agency for statistics).

``` r
library(cbsodataR)
d = cbs_get_data("80030NED") %>% 
  cbs_add_date_column() %>% 
  cbs_add_label_columns() %>%
  filter(CentraleDecentraleProductie_label=="Totaal centrale/decentrale productie") %>% 
  select(date=Perioden_Date, source=Energiedragers_label, elec=ElektriciteitMWh_2)  

head(d)
```

This sort of API access is great for accessing vast ranges of data. If
you have a certain source that you’re interested in, and you invest some
time into learning how to use their R package (or write your own API
bindings), it becomes easy to use their data.

``` r
# filter and translate energy sources
sources = c(coal="Steenkool", 
            oil="Stookolie", 
            gas="Aardgas", 
            biomass="Biomassa", 
            nuclear="Kernenergie", 
            solar="Zonnestroom", 
            wind="Windenergie", 
            water="Waterkracht")
d = d %>% filter(source %in% sources) %>% mutate(source=names(sources)[match(source, sources)])
d = d %>% group_by(date) %>% mutate(perc = elec / sum(elec))

# plot 
library(RColorBrewer)
colors = c(brewer.pal(5, "Reds")[3:5], brewer.pal(3, "Purples")[2:3], brewer.pal(5, "Greens")[3:5])
ggplot(d, aes(x=date, y=perc*100, fill=fct_relevel(source, names(sources)))) + geom_area() +
  scale_fill_manual(name="Source", values=colors)
```

# Web scraping

Web scraping is a technique for extracting information from websites.
You essentially write an algorithm that systematically crawls through a
website and copies selected information.

The nice thing about web scrapers is that they are highly versatile. If
you find a website with usefull information, but this information is not
made available for download and no API is provided, you can often still
get it with a webscraper. With few acceptions, any data that you would
be able to collect manually from a website, you can (and should)
automate with a scraper.

The sad thing about web scrapers is that they can take some time to
build, and it also requires some time to learn how to build proper
webscrapers. Covering this topic is out of the scope of this tutorial,
but there are good resources available for learning how to build web
scrapers. In our experience the Python programming language is more
convenient for building scrapers, but with the `rvest` package (for
ha-rvest-ing data) it is certainly possible to do webscraping in R. It
is also a good way to learn about webscraping (and basic HTML), and the
skills are easily transferable to Python.

Since this is a pretty big topic, we have a separate tutorial on [web
scraping in R](https://www.youtube.com/watch?v=9GR26Y4z_v4).
