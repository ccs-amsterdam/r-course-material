URL metadata scraper
================
Kasper Welbers & Wouter van Atteveldt
2026-02

- [Why scrape URL metadata](#why-scrape-url-metadata)
- [The basic set up](#the-basic-set-up)
- [Getting metadata for multiple
  urls](#getting-metadata-for-multiple-urls)

# Why scrape URL metadata

In our Rvest tutorials, we explain how you can scrape websites. This is
a great, flexible data gathering technique, but it has the downside that
it takes quite some time to build scrapers for different websites.

Sometimes, all you need for a given URL is to get a general idea of what
kind of webpage it is. For example, if you run a data donation study,
you might get a whole bunch of URLs for different websites, that can
potentially tell you what type of content a person consumed. Or maybe
you use a database like Mediacloud, where you can search for news
articles, but only download the URLs.

To get more information about each URL, we could build a simple scraper
that just targets the metadata. Many web pages include meta tags that
tell you things like the title, description, author and publication
date, and even links to multimedia content. This is why applications
like Instagram and Whatsapp can automatically show a thumbnail image
with a title whenever you share a URL. So in this tutorial we’ll show
you how to build a simple scraper that works for most web pages that
provide this metadata. I say ‘most’ websites, because sometimes they
have some protection mechanisms that make it more difficult.

# The basic set up

We’ll first create two functions:

- `get_html(url)` reads the HTML code from a given URL.
- `get_meta(html)` extracts metadata from this HTML code

In the `get_html` function we make a request to the URL with a user
agent that mentions “twitterbot”. This way we basically ask the website
to show us what it would show to twitterbot, which is a well known bot
that collects metadata.

``` r
get_html <- function(url) {
  ua <- "Twitterbot (Research Metadata Scraper)"
  
  session(url, httr::user_agent(ua)) |>
    read_html() 
}
```

In the `get_meta` function we extract the metadata that we’re interested
in. You can usually find this in the
<head>

tag of the HTML code. In this example, we’ll specifically get the meta
tags where the property attribute starts with (`^=`) `og:`. These are
tags for the Open Graph Protocol, which is used by many social media
platforms to show the link thumbnails, and therefore widely supported.

We’ll return the contents of the tags as a list, and name them based on
the `og:` tag.

``` r
get_meta <- function(html) {
  og <- html |>
    html_elements('head meta[property^="og:"]')
  
  propnames <- og |> html_attr('property')
  content <- og |> html_attr('content')
  
  l <- as.list(content)
  names(l) <- propnames
  
  l  
}
```

Here’s an example for a Tiktok url

``` r
url = 'https://www.tiktok.com/@vdnews.tv/video/7597020638548675873'
get_html(url) |> get_meta()
```

    ## $`og:type`
    ## [1] "website"
    ## 
    ## $`og:site_name`
    ## [1] "TikTok"
    ## 
    ## $`og:url`
    ## [1] "https://www.tiktok.com/@vdnews.tv/video/7597020638548675873"
    ## 
    ## $`og:image`
    ## [1] "https://p19-common-sign-useastred.tiktokcdn-eu.com/tos-useast2a-i-4864-euttp/oAGWauMARyJpBIABC4APBhU4ig0ARhAiKuicE~tplv-photomode-video-share-card:1200:630:20.jpeg?dr=10375&refresh_token=32d6b048&x-expires=1803038400&x-signature=xK6zRzP8uZt5%2FRQ59ssllHzkbFk%3D&t=4d5b0474&ps=13740610&shp=55bbe6a9&shcp=9dfa7f7f&idc=useast2b&ftpl=1"
    ## 
    ## $`og:title`
    ## [1] "TikTok Â· VDnews"
    ## 
    ## $`og:description`
    ## [1] "19.1K likes, 86 comments. â€œUn video diventato virale mostra un agente dellâ€™Immigration and Customs Enforcement (ICE) scivolare su una superficie ghiacciata mentre partecipa a unâ€™operazione a Minneapolis, Minnesota, il 11 gennaio 2026. Nel video, lâ€™agente perde lâ€™equilibrio e cade davanti a osservatori e manifestanti, attirando subito lâ€™attenzione degli utenti sui social media per la sua incongruenza rispetto al contesto generalmente teso delle proteste. La diffusione della clip arriva in un periodo di forte mobilitazione pubblica a Minneapolis dopo che, pochi giorni prima, un agente ICE aveva ucciso a colpi dâ€™arma da fuoco Renee Nicole Good, una donna di 37 anni, durante un raid di immigrazione. La sparatoria ha scatenato manifestazioni e critiche a livello nazionale sulla tattica e la legittimitÃ  delle azioni federali della polizia dellâ€™immigrazione.â€\u009d"

# Getting metadata for multiple urls

Now let’s put this into a loop. We’ll use the map function from the
`purrr` package.

To make this easier, we’ll first make a single function that takes a url
and returns the metadata. This is just a really light wrapper around our
two prior functions.

``` r
library(purrr)

get_url_meta <- function(url) {
  url |> get_html() |> get_meta()
}

urls <- c(
  'https://www.tiktok.com/@vdnews.tv/video/7597020638548675873',
  'https://www.nytimes.com/2026/01/28/us/politics/minneapolis-ice-states.html'
)

meta_list <- map(urls, get_url_meta) 
```

Now that we have a list of named lists, we can bind them together into a
tibble

``` r
library(tidyverse)
bind_rows(meta_list)
```

| og:type | og:site_name | og:url | og:image | og:title | og:description | og:image:alt |
|:---|:---|:---|:---|:---|:---|:---|
| website | TikTok | <https://www.tiktok.com/@vdnews.tv/video/7597020638548675873> | <https://p19-common-sign-useastred.tiktokcdn-eu.com/tos-useast2a-i-4864-euttp/oAGWauMARyJpBIABC4APBhU4ig0ARhAiKuicE~tplv-photomode-video-share-card:1200:630:20.jpeg?dr=10375&refresh_token=32d6b048&x-expires=1803038400&x-signature=xK6zRzP8uZt5%2FRQ59ssllHzkbFk%3D&t=4d5b0474&ps=13740610&shp=55bbe6a9&shcp=9dfa7f7f&idc=useast2b&ftpl=1> | TikTok Â· VDnews | 19.1K likes, 86 comments. â€œUn video diventato virale mostra un agente dellâ€™Immigration and Customs Enforcement (ICE) scivolare su una superficie ghiacciata mentre partecipa a unâ€™operazione a Minneapolis, Minnesota, il 11 gennaio 2026. Nel video, lâ€™agente perde lâ€™equilibrio e cade davanti a osservatori e manifestanti, attirando subito lâ€™attenzione degli utenti sui social media per la sua incongruenza rispetto al contesto generalmente teso delle proteste. La diffusione della clip arriva in un periodo di forte mobilitazione pubblica a Minneapolis dopo che, pochi giorni prima, un agente ICE aveva ucciso a colpi dâ€™arma da fuoco Renee Nicole Good, una donna di 37 anni, durante un raid di immigrazione. La sparatoria ha scatenato manifestazioni e critiche a livello nazionale sulla tattica e la legittimitÃ  delle azioni federali della polizia dellâ€™immigrazione.â€ | NA |
| article | NA | <https://www.nytimes.com/2026/01/28/us/politics/minneapolis-ice-states.html> | <https://static01.nyt.com/images/2026/01/25/multimedia/25nat-ice-legislatures-hp/25nat-ice-legislatures-vkqg-facebookJumbo.jpg> | As Minneapolis Rages, Legislators Move to Restrict ICE in Their States | Efforts to curtail federal law enforcement tactics began last year, but with the deaths of Alex Pretti and Renee Good, Democratic lawmakers are pushing harder. |  |
