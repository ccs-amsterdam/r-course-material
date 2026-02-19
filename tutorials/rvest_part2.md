Web Scraping with RVest, part 2
================
Kasper Welbers & Wouter van Atteveldt
2026-02

- [Scraping with RVest, part 2](#scraping-with-rvest-part-2)
  - [Websites with dynamic rendering](#websites-with-dynamic-rendering)
  - [Websites don’t like bots](#websites-dont-like-bots)
- [Dealing with dynamic rendering](#dealing-with-dynamic-rendering)
- [Setting your scraper’s name tag](#setting-your-scrapers-name-tag)
  - [Pretend to be a browser](#pretend-to-be-a-browser)
  - [Pretend to be a known bot (or ‘like’
    one)](#pretend-to-be-a-known-bot-or-like-one)

# Scraping with RVest, part 2

In the first part of this tutorial we introduced the `rvest` package. We
showed you how to read HTML code from websites with `read_html()`, and
then parse it with `html_element()` (among others). This is a powerful
technique, that allows you to extract data from many websites.

However, once you head out into the real world, you’ll notice that for
many websites you will not actually *get* the HTML code. Or at least,
not the HTML code that you’ll see in your browser when you use the
*inspect* tool. There are two major reasons for this:

### Websites with dynamic rendering

Many websites today use a lot of javascript for fancy interactive stuff.
These websites often do not send you the HTML source code, but basically
send you a piece of javascript that your browser needs to run to
generate the HTML itself. We also call this *dynamic rendering* as
opposed to *static rendering* where you receive the static HTML code
directly.

To scrape these types of websites, we need something that knows how to
perform this dynamic rendering. In other words, we need a web browser!
Luckily, there are some nice tools to let you remote control a web
browser via R. One of these tools is even directly integrated into
*rvest*!! So that’s one thing we’ll show you in this part 2.

Also, if you’re just interested in scraping some metadata, it’s
sometimes possible to tell a website you’re a bot to get a more
bot-friendly version. This ties in to the next point, which deals with
being transparent about being a bot.

### Websites don’t like bots

Many websites do not like having scraper bots all over the place. They
use their bandwidth and CPU, take their data, and don’t really give
anything in return. If you’re a decent bot with good intentions (and
complicated, vague copyright exceptions for non-commercial academic
research) this is morally defensible, but it’s always a grey area. Alas,
this grey area has become several shades darker with the number of bots
that is around today, including AI agents that are directly undermining
the business model of these websites. So many websites are now much
stricter on bot detection.

So what can you do? How can you convince the website that you’re a good
bot? Preferably without having to call them, because they won’t pick up
the phone anyway. Granted, your options are limited, but you can for
instance say: “Hey, please treat me like I’m Twitterbot/1.0, even though
I’m actually not! Here’s my contact info if you want me to stop”. Some
websites will then sends you a minimal version of the webpage that
includes things like a title, image and short description (basically the
thumbnail stuff that you see when someone shares a link on social
media).

Off course, you could also solve this problem by being even more sneaky.
If you use the aforementioned **remotely controlled browser** approach,
you could make it very hard to distinguish you from a normal user, and
there are even ways to get past the “are you human?” tests. But off
course, here you’ll find yourself on increasingly thin ethical ice. So
we’ll leave this back-alley avenue as an exercise to readers that have
reliable moral compasses.

# Dealing with dynamic rendering

In part one we initially had the example of scraping IMDB. Alas, that
example stopped working because they now have a website with dynamic
rendering. The following code throws an error.

``` r
library(rvest)

page <- read_html('https://www.imdb.com/name/nm0000195/')

## This won't even work anymore
page |>
  html_element('head meta[name="description"]') |>
  html_attr('content')
```

But it works with a veeeeery small change to the code: using
`read_html_live()` instead of `read_html()`. The first time this will
prompt you to install the `chromote` package, and you also need to have
installed Chrome. (after installing it, you might have to restart R to
make it work).

``` r
page <- read_html_live('https://www.imdb.com/name/nm0000195/')

page |>
  html_element('head meta[name="description"]') |>
  html_attr('content')
```

If you got this to work, it means that you succesfully used a *headless*
browser. That is, you started a browser in the background, and opened
the website there. It then opened the website like you would see it in
your regular browser. This is slower than regular `read_html`, but it
handles all the nasty javascript stuff. \## Managing your browser
session

You can also open a window into this sneaky headless browser like so:

``` r
page$view()
```

This should open a weird tab in Chrome where you can see This is useful,
because sometimes you need to take a few steps before you can scrape the
data. For instance, you might first have to click a button to accept
cookies, or log in.

You **could** manually do this in the view tab you opened, but the cool
kids write code. For instance, here is how you would click on the
“accept” button of the “select your preferences” banner (that should
have showed up on your first visit to IMDB). It works like
`html_element`, in that we provide a css selector for the button to
click.

``` r
page$click('button[data-testid="accept-button"]')
```

And that’s all there is to it! Be warned that using `read_html_live` is
a bit slower, and heavier for your computer. This is because you’re no
longer just getting the HTML source code, but everything on the website,
like images and style documents. But if you need to scrape a website
that uses dynamic rendering, or where you need to perform some
interactions before you can start scraping, this is a relatively
painless way to achieve it!

# Setting your scraper’s name tag

One thing that often trips up people trying to scrape websites, is that
they don’t specify their *User Agent*. Whenever your browser interacts
with a website, you usually provide a user agent that tells the website
things about you, like what operating system and browser you use. You
can see it
[here](https://www.whatismybrowser.com/detect/what-is-my-user-agent/).

Your user agent will be something like:

`Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36`

The user agent tells the website what kind of system you have, so they
can give you a suitable version of the website (e.g. mobile or desktop
version). The website scans your user agent for keywords, and based on
that determine what version of the website you get to see.

However, when you send HTTP requests via R, your user agent is usually
empty. This effectively tells websites that you’re a bot, and they might
immediately block you for it. Luckily, you can tell R to use any user
agent you want! There are two useful options:

## Pretend to be a browser

You could pretend to be a browser by using a common user agent (like
your own, or the one I show above). This is sometimes enough to give you
access.

Setting a user agent in `rvest` is pretty easy. Instead of calling
`read_html` directly, we use `session`. In session we then specify the
URL we want to visit, and the user agent we want to use. We can then
call read_html (without setting a new url!)

Note that creating the user agent requires the `httr` package. Since
this package is used under-the-hood by rvest, you should already have it
installed. So we can use `httr::user_agent("your user agent string")`.

``` r
url = "https://www.tiktok.com/@vdnews.tv/video/7597020638548675873"
ua = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36"

session(url, httr::user_agent(ua)) |>
  read_html()
```

    ## {html_document}
    ## <html lang="en">
    ## [1] <head>\n<meta charset="UTF-8">\n<meta name="viewport" content="width=devi ...
    ## [2] <body style="margin: 0">\n     <svg style="position:absolute;width:0;heig ...

## Pretend to be a known bot (or ‘like’ one)

The user agent is also used by common bots to tell websites what they’re
there for (kind of like how Mafiosi wear recognizable hats). Google uses
`Googlebot`, X (still) uses `Twitterbot`, etc.

Some websites present different content to these bots, because this is
easier for both the bot and website. The Twitterbot only scrapes
metadata, like the title, description and an image. This is what allows
X/Twitter to show a nice link and thumbnail when you share a link.
Websites want X/Twitter to do this, so they happily make this as fast
and easy as possible, by disabling things that complicate scraping, like
dynamic rendering and cookie banners.

So if you are only interested in scraping metadata (which is often very
usefull, especially for social media posts), you could consider
pretending to be *Twitterbot*. Or if you don’t want to lie, you could
say that you are **like** twitterbot, with a user agent such as
`Twitterbot/1.0 (Researcher; yourname@email.com)`. This way you’re being
very transparent that you’re not actually Twitterbot, but they often
don’t notice and just treat you like Twitterbot.

An example where this works is Tiktok.

``` r
url <- "https://www.tiktok.com/@vdnews.tv/video/7597020638548675873"
ua <- "Twitterbot (University teaching example)"

session(url, httr::user_agent(ua)) |>
  read_html() |>
  html_elements('head meta[property="og:description"]') |>
  html_attr('content')
```

    ## [1] "19.1K likes, 86 comments. â€œUn video diventato virale mostra un agente dellâ€™Immigration and Customs Enforcement (ICE) scivolare su una superficie ghiacciata mentre partecipa a unâ€™operazione a Minneapolis, Minnesota, il 11 gennaio 2026. Nel video, lâ€™agente perde lâ€™equilibrio e cade davanti a osservatori e manifestanti, attirando subito lâ€™attenzione degli utenti sui social media per la sua incongruenza rispetto al contesto generalmente teso delle proteste. La diffusione della clip arriva in un periodo di forte mobilitazione pubblica a Minneapolis dopo che, pochi giorni prima, un agente ICE aveva ucciso a colpi dâ€™arma da fuoco Renee Nicole Good, una donna di 37 anni, durante un raid di immigrazione. La sparatoria ha scatenato manifestazioni e critiche a livello nazionale sulla tattica e la legittimitÃ  delle azioni federali della polizia dellâ€™immigrazione.â€\u009d"

Try removing ‘Twitterbot’ and you’ll see that you are no longer able to
get the description.
