Gathering news articles using Media Cloud and Paperboy
================
Kasper Welbers & Emma Diel
2024-06

- [Introduction](#introduction)
- [Using Media Cloud](#using-media-cloud)
  - [Searching articles](#searching-articles)
    - [Downloading articles](#downloading-articles)
  - [Reading Media Cloud data into R](#reading-media-cloud-data-into-r)
- [Scraping more data with paperboy](#scraping-more-data-with-paperboy)
  - [Scraping all your data and evaluating how well it
    worked](#scraping-all-your-data-and-evaluating-how-well-it-worked)
    - [Sidenote: batch it up if doing it in 1 go takes to
      long](#sidenote-batch-it-up-if-doing-it-in-1-go-takes-to-long)

## Introduction

Media Cloud is an open source platform for media analysis, that allows
you to search news from a huge range of international news outlets.
Although you will not get the full articles (which also wouldn’t be
legal), you will get headlines and usefull metadata. Furthermore, since
you also receive the URLs, you can look up the articles, and scrape more
informationn if (legally) available.

In this brief tutorial we first show you how to use Media Cloud, and
then use the paperboy R package to (try to) scrape more data.

# Using Media Cloud

Media cloud is very straightforward to use. To get started, visit the
[website](https://search.mediacloud.org/), and create a (free) user
account.

Once you’re logged in, click the big “search now” button (or
[this](https://search.mediacloud.org/search)) link).

## Searching articles

On the search page you can enter search phrases using the simplified
form, but you can also use advanced mode if you understand boolean
queries (remember practical 3!). There is also a detailed
[guide](https://search.mediacloud.org/) for what query features are
supported.

One *very important* thing to notice is the *select collections* button
in step 2. By default you’ll search in the `United States - National`
collection, but there are many different collections, including other
countries (e.g., `Netherlands - National`).

### Downloading articles

Once you’ve conducted a search, you’ll see several results below, like
`Attention over Time`, `Total Attention` and `Sample Content`. The one
we’re most interested in right now is `Total Attention`, where you can
also find the `DOWNLOAD ALL URLS` button. Click this button to start the
download (it might take a few second or more if you have a lot of
results).

You should now have a new CSV file in your downloads folder.

Next you can set up the search query. You can include or exclude certain
words, as well as decide on the time frame. After you click on search,
the website will generate several documents. Under the heading of “Total
Attention” you will find a button to download a csv with the URLs. The
website will also give you a selection of random articles from the
search. Make sure that these articles really reflect what you are
looking for or whether the search query needs to be refined

## Reading Media Cloud data into R

Reading the Media Cloud data into R is very straightforward. We’ll again
use the `read_csv` function (like we did in the practicals). We’ll use
the tidyverse package for some quick data cleaning (this package also
includes the read_csv function).

``` r
library(tidyverse)
d <- read_csv("~/Downloads/mc-onlinenews-mediacloud-20240604134941-content.csv")
```

(make sure to replace the file name with location and filename on your
computer, or use the data import wizard, as we did in the practicals.)

If you did everything right, you should now have the data in R. Remember
that you can view the data by clicking on the name in the Environment
tab (top-right) use using `View(d)`.

# Scraping more data with paperboy

The paperboy package provides an easy function to *try* to scrape a news
article from a URL. We say *try*, because whether it works depends on
two things:

- The data might be behind a paywall, in which case we can’t get it
  (without paying for it).
- Paperboy doesn’t know every news website on the planet. If you’re
  trying to scrape data from a website that it doesn’t know, it will try
  a generic approach. Whether this works depends on whether the website
  uses a common, standard layout

If you cannot scrape more information for the articles that you want to
use for your project assignment, don’t worry! You could perhaps do the
analysis using only the headlines. If this really doesn’t work for your
RQ, consult your supervisor. And make sure to write down your
experiences for the ‘reflection’ part of the assignment. Figuring out
what data is available and clean is also a part of doing research!

Luckily, trying whether you can scrape the data doesn’t take much time.
You just need to install the paperboy package, and use 1 function. Note
that to install paperboy you need the `remotes` package. So if you get
an error saying “there is no package called ‘remotes’”, make sure to
install it first.

``` r
remotes::install_github('JBGruber/paperboy')
library(paperboy)
```

We’ll first try scraping just a sample of the data. We’ll pick the first
10 rows from our data, and then scrape the URLs for these rows.

``` r
samp = head(d, 40)
scraped_data = pb_deliver(samp$url)
```

If you’re lucky, the `scraped_data` is a dataframe with 10 news
articles, that now has both a `headline` and `text` column. It could be
that you have a few articles less, if some of them could not be found.
Also, it could be that you don’t have the `text` for all articles.

## Scraping all your data and evaluating how well it worked

Once you have everything figured out, you can try downloading all the
data. In case you run into any error, you might try setting the
`ignore_fails` argument to TRUE to be a bit more lenient.

``` r
all_data = pb_deliver(d$url, ignore_fails = T)
```

When you have your results, it’s always good to quickly check how much
you’re missing compared to your original data. First, you can just look
at the total number of articles in your scraped data compared to the
Media Cloud URL data.

``` r
nrow(all_data)
nrow(d)
```

Or directly as a percentage:

``` r
100 * nrow(all_data) / nrow(d)
```

But don’t forget to also check whether the scraped data actually has the
`text`! To do this, we first check whether the value in the `text`
column is missing (NA) or whether its just an empty string (““)

``` r
text_missing = is.na(all_data$text) | all_data$text == ""
```

Now we can count how often it’s NOT missing (! means NOT)

``` r
sum(!text_missing)
```

And we can again compare this to the total number of URLs we tried to
scrape

``` r
100 * sum(!text_missing) / nrow(d)
```

### Sidenote: batch it up if doing it in 1 go takes to long

If you have a LOT of data, you might want to do the scraping in batches.
A simple approach would be to directly slice the data.

``` r
batch1 = d$url[1:500,]
batch2 = d$url[501:1000,]
## etc.
```
