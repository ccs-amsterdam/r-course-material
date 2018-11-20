R for text analysis: Combining media and real-world data
================
Wouter van Atteveldt & Kasper Welbers
2018-11

-   [Introduction](#introduction)
-   [Data](#data)
    -   [Newspaper data](#newspaper-data)
    -   [Polling data](#polling-data)
-   [Combining polling data and media data](#combining-polling-data-and-media-data)
    -   [Computing the poll date for each news date](#computing-the-poll-date-for-each-news-date)
    -   [Joining the series](#joining-the-series)

Introduction
============

In principe, combining media data with real-world data such as polling data or economic indicatores is not difficult: assuming that both data sets have a 'date' variable they can simply be joined together.

What makes it more difficult is that often the two series are not properly aligned. For example, most newspapers publish daily except Sunday, while surveys are often held irregularly and stock markets are usually closed on Saturdays.

For this tutorial, we will assume that we are investigating a non-reciprocal media effect, i.e. that the media can affect the polling numbers, but not the other way around. Note that this is in most cases not really true, as e.g. positive polling numbers can also lead to more favourable media coverage.

In an ideal world, where both media publications and polls are simple time points, one could assume the media can affect all polls after the publication date, (and for the reverse effect, the polls can affect all media published after the poll date).

In reality, of course, polls take time to conduct (and news items take time to make and publish, especially for traditional newspapers), and events can overlap and/or occur simulatenously. In such cases, one should always make the assumptions that make it more difficult for your presumed effects, to make sure that you don't find an effect where there is none.

An example situation is shown in the figure below, with news items on all days except Sunday and polls published on Thursday and Sunday:

``` r
plot(0, xlim=c(1,6), ylim=c(1,2), axes=F, xlab="", ylab="")
axis(side = 1, labels = c("Wed", "Thu", "Fri", "Sat", "Sun", "Mon"), at=1:6, tick=F)
axis(side = 2 , labels = c("Media", "Polls"), at=c(1.25, 1.75), tick = F)
points(x=c(1,2,3,4,6), y=rep(1.25,5))
points(x=c(2,5), y=rep(1.75,2))
d=.01; M = 1.25 + d; P=1.75 -d; 
arrows((1:4)+d, rep(M, 4), c(2, 5,5,5)-d, rep(P,4))
arrows(c(2,2,2, 5)+d, rep(P, 4), c(2,3,4,6)-d, rep(M,4), lty=c(3,2,2,2))
arrows((1:4+d), rep(M, 4), c(2,3,4,6)-2*d, rep(M, 4), col="grey", length=.1)
arrows((1:2+d), rep(P, 2), c(2,5)-2*d, rep(P, 2), col="grey", length=.1)
```

The solid arrows indicate which media days could influence which polls: Wednesday's news can affect Thursday's polls, and Thursday's through Saturday's news can affect Sundays polls. The dashed arrows indicate which news days can be affected by which polls. How to interpret the dotted arrow depends on the specifics of the poll. If you know that the poll is published after the news item has been made, you can keep it out. If both poll and news item are published during the day, you don't know which was first, and it's possible the news item is in fact a reaction to the poll. Keeping with the principle of making it as difficult as possible to confirm your own hypothesis, if you are investigating the effect of the media you should probably assume that the poll can affect that day's news, and not the other way around.

Finally, the grey lines are the 'autocorrelations' present in most time series: To predict today's polls (or news, stockmarket, or weather), often yesterday's polls are the best predictor. You can include the autogression as a *control* variable, or take the change in polling. To decide which is best, include it as a control variable first. If the autocorrelation is almost 1, take the difference instead,

Note: the considerations above are a very simple (or even simplistic) first approach at doing time series analysis. There are whole graduate-level courses taught just about time series analysis (not to mention books with more equations than we like reading) To learn more, you can start by looking at some of the resources below:

-   [R Task view on time series analysis](https://cran.r-project.org/web/views/TimeSeries.html)
-   [An older tutorial on VAR and ARIMA in R](https://github.com/vanatteveldt/learningr/blob/master/7_timeseries.md)
-   An atricle introducing time series analysis to social scientists: Vliegenthart, R. (2014). Moving up. Applying aggregate level time series analysis in the study of media coverage. Quality & quantity, 48(5), 2427-2445.

Data
====

For this tutorial, we will see whether immigration coverage had a positive effect on Trump's poll ratings in the 2016 elections.

Newspaper data
--------------

I use the rtimes API for the NYTimes, which only returns the headline, URL, and metadata for each article, but can be used for simple cases as this. Note that you need to have the NYTIMES\_AS\_KEY environment variable set to run this code. You can request a key (and learn more about the API) at <http://developer.nytimes.com/>

``` r
library(rtimes)
library(tidyverse)
#Sys.setenv(NYTIMES_AS_KEY="secret_code")
 
result = as_search(q = "immigration", begin_date = "20161001", end_date = '20161108', all_results = T)
articles = result$data 
```

As a first step, we aggregate the data per day:

``` r
media = articles %>% mutate(date=as.Date(pub_date)) %>% group_by(date) %>% summarize(n=n())
```

Since we use a search query that returns articles, this series does not include days without articles. If needed, this can be remedied by joining with a series of all dates created with the `seq.date` function:

``` r
all_days = data.frame(date=seq.Date(as.Date("2016-10-01"), as.Date("2016-11-08"), by=1))
media = left_join(all_days, media) %>% mutate(n=ifelse(is.na(n), 0, n))
```

Note that if you have a source that e.g. does not publish on Sunday, you might want to remove Sundays from the series using the `weekdates` function.

Polling data
------------

For the polling data, we take the ABC news as (re)published by 538, taking only the now-cast, raw numbers and the end date. For the difference between the poll types and results, see [their methodology page](https://fivethirtyeight.com/features/a-users-guide-to-fivethirtyeights-2016-general-election-forecast/).

We take the start date here since news can potentially influence polls until the end date, and we can be sure that the polls were not published before the end date. One could argue we should take the start date, as individuals who have aready responded can no longer be influenced by news published later. If you have access to raw survey results, you can see the actual date each individual answered the poll, which would give more precise results.

``` r
url = "http://projects.fivethirtyeight.com/general-model/president_general_polls_2016.csv"
polls = read_csv(url) 
polls = polls %>% filter(type=="now-cast", pollster=="ABC News/Washington Post") %>% select(date=enddate, trump=rawpoll_trump)
polls = polls %>% mutate(date=as.Date(date, format="%m/%d/%Y")) %>% arrange(date)
polls = polls %>% filter(date >= "2016-09-30")
```

Combining polling data and media data
=====================================

Now that we have media data and polling data, we can combine them. Not all days have polls, especially in the earlier period. As explained above, we want to 'assign' all days between two polling dates to that date.

Computing the poll date for each news date
------------------------------------------

The way to do this in R is to join the two data sets and create a new "poll date" variable that is at first only non-missing for dates with a poll. The easiest way to achieve this is to create the extra date column before we join:

``` r
polls2 = polls %>% select(date) %>% mutate(poll_date=date)
media = left_join(media, polls2)
head(media, 15)
```

Now, we want to fill in all missing values to the top, i.e. each poll date should taking the value from the next non-missing date using the tidyverse `fill` function:

``` r
media = media %>% fill(poll_date, .direction = "up")
```

Finally, we can aggregate the media data per poll date, for example taking the mean daily number of articles about migration for each `poll_date`:

``` r
media_aggregated = media %>% na.omit %>% group_by(poll_date) %>% summarize(n=mean(n)) %>% rename(date=poll_date)
```

Joining the series
------------------

Now we can join the series.

Before we proceed, let's also add the lagged (previous) poll and change in poll (differenced poll) as columns so we can control or differentiate as needed: (we do this now because the first value would otherwise be dropped by the join)

``` r
polls = polls %>% mutate(lagtrump = lag(polls$trump), difftrump=trump-lagtrump)
```

Now, we are ready to join with the media data:

``` r
combined = inner_join(media_aggregated, polls)
```

So, does immigration news forecast a change in polling for trump?

``` r
cor.test(combined$n, combined$difftrump)
```

Apparently, it does not: the correlation is almost zero and not significant. This can be due to may things, from the oversimple measurement using only the word immigration; the use of aggregate polls rather than individual panel survey results; or simply because immigration in the end was not the deciding issue.

To find a better answer we can improve any of these things, but hopefully this tutorial gave a good first overview of the techniques and considerations for combinining media data and real world data for a quantitative study of media effects.
