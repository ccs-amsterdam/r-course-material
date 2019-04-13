Scraping the Guardian from R
================
Wouter van Atteveldt & Kasper Welbers
April 2019

-   [The Guardian API](#the-guardian-api)
-   [Querying the API](#querying-the-api)
-   [Querying longer time spans](#querying-longer-time-spans)

The Guardian API
================

The Guardian (newspaper) has a very nice API that let's you download news content, and there is an R package `guardianR` that allows you to easily access this.

First, install GuardianR from CRAN as normal and get an API key from <https://open-platform.theguardian.com/access/>. Then replace the 'test' key below with your actual key:

``` r
key = "test"
```

Querying the API
================

Sending a single query to the API is simple. Let's query the news on the 'backstop' in the week before Brexit was supposed to happen. Note, by default the body (full text) is returned as factor, so we convert it to text and also create a column with the html stripped:

``` r
library(GuardianR)
library(tidyverse)
news = get_guardian("backstop", from.date="2019-03-23", to.date="2019-03-29", api.key = key) %>%
  as_tibble %>% mutate(body = as.character(body), date=as.Date(webPublicationDate), 
                       text=str_remove_all(body, "<[^>]+>"))
news %>% select(webUrl, publication, headline, date, body) %>% mutate(len=str_length(body))
```

As you can see, this includes the metadata (url, headline, date) and full body of the article. Just because we can, here is a wordcloud:

``` r
library(quanteda)
news %>% corpus() %>% dfm(remove_punct=T, remove=stopwords("english")) %>% textplot_wordcloud(max_words=50)
```

For more information on the query syntax and possibilities, see <https://open-platform.theguardian.com/documentation/>. Note that (at the time of writing) the `guardianR` package is somewhat limited, so to search for a specific tag you need to integrate it in your query manually like so:

``` r
news_pol = get_guardian("backstop&tag=politics/politics", from.date="2019-03-23", to.date="2019-03-29", api.key = key)
print(str_c("# of articles total: ", nrow(news), "; # of articles in politics tag: ", nrow(news_pol)))
```

Querying longer time spans
==========================

With `GuardianR`, you can only query one month at a time. To query a longer time frame, you can use a for loop like so:

``` r
library(lubridate)
results = list()
months = seq(as.Date("2019-01-01"), by = "month", length = 3) 
for (i in seq_along(months)) {
  from = months[i]
  message(str_c("Querying: ", i, ": ", from))
  # calculate last day of month
  to = from
  month(to) = month(to) + 1
  to = to - 1
  # query
  news = get_guardian("backstop", from.date=from, to.date=to, api.key = key)
  # store in list 
  results[[as.character(from)]] = news
}
# combine all results and postpr
results = bind_rows(results)
print(str_c("Retrieved ", nrow(results), " articles"))
```

Note that because `guardianR` returns factors for most fields, you get warning messages because on combining factors it changes them into character colunms when the factor levels differ. These warning messages are generally safe to ignore.
