Dictionaries with Tidy Text
================
Wouter van Atteveldt
2022-10

-   [Introduction](#introduction)
-   [Lexical Sentiment Analysis with
    Tidytext](#lexical-sentiment-analysis-with-tidytext)
-   [Inspecting dictionary hits](#inspecting-dictionary-hits)
-   [More complicated dictionaries](#more-complicated-dictionaries)

# Introduction

Dictionaries are a very transparent and useful tool for automatic
content analysis. At its simplest, a dictionary is a list of terms, of
lexicons, with a specific meaning attached to each term. For example, a
sentiment lexicon can contain a list of positive and negative words. The
computer then counts the total number of negative and positive words per
document, giving an indication of the sentiment of the document.

This can be expanded by also using wildcards, boolean, phrase and
proximity conditions: wildcards such as `immig*` would match all words
starting with or containing a certain term; boolean conditions allow you
to specify that specific combinations of words must occur; while phrase
and proximity conditions specify that words need to occur next to or
near each other.

Whatever type of dictionary is used, it is vital that the dictionary is
validated in the context of its use: does the occurrence of the
specified terms indeed imply that the desired theoretical concept is
present? The most common approach to validation is *gold standard*
validation: human expert coding is used to code a subset of documents,
and the computer output is validated against this (presumed) gold
standard.

# Lexical Sentiment Analysis with Tidytext

The easiest setup for dictionary analysis is finding exact matches with
an existing word list or lexicon. For example, there are various
sentiment lexicons that assign a positive or negative label to words.

For example, the
[textdata](https://cran.r-project.org/web/packages/textdata/textdata.pdf)
package contains a number of lexica, including the NRC emotion lexicon:

``` r
library(textdata)
nrc = lexicon_nrc()
head(nrc)
```

Using the various `join` functions, it is easy to match this lexicon to
a token list. For example, let’s see which emotional terms occur in te
state of the union speeches:

Note: For more information on basic tidytext usage, see [our tidytext
tutorial](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/tidytext.md)
and/or the [official tidytext
tutorial](https://www.tidytextmining.com/).

``` r
library(sotu)
library(tidyverse)
library(tidytext)
sotu_texts = add_column(sotu_meta, text=sotu_text) |> 
  as_tibble() 
sotu_tokens = sotu_texts |> unnest_tokens(word, text)
head(sotu_tokens)
```

Since both the `nrc` and `sotu_tokens` data frames contain the word
column, we can directly join them and e.g. compute the total emotion per
year:

``` r
sotu_emotions = left_join(sotu_tokens, nrc) |>
  group_by(year, sentiment) |>
  summarize(n=n())  |> 
  mutate(p=n / sum(n)) |>
  ungroup() |>
  filter(!is.na(sentiment)) 
head(sotu_emotions)
```

Note the use of `left_join` to preserve unmatched tokens, which we can
then use to compute the percentage of words `p` that matched the
lexicon.

So, how did emotions change over time?

``` r
library(ggridges)
ggplot(sotu_emotions) +
  geom_ridgeline(aes(x=year, y=sentiment, height=p/max(p), fill=sentiment)) +
  theme_ridges() + guides(fill="none")
```

# Inspecting dictionary hits

Using the `tokenbrowser` package developed by Kasper Welbers, we can
inspect the hits in their original context.

(Note that due to an unfortunate bug, this package requires the document
id column is called `doc_id`)

``` r
library(tokenbrowser)
hits = left_join(sotu_tokens, nrc)  |> 
  rename(doc_id=X)
meta = select(sotu_texts, doc_id=X, year, president, party)
categorical_browser(hits, meta=meta, category=hits$sentiment, token_col="word") |>
  browseURL()
```

Note also that some words are repeated since the join will duplicate the
rows if a word matched multiple categories.

# More complicated dictionaries

For more complicated dictionaries, you can use the boolydict package. At
the time of writing, this package needs to be installed from github
rather than from CRAN:

(Note: This might need rtools to build, hopefully it will work on
non-linux computers!)

``` r
remotes::install_github('kasperwelbers/boolydict')
```

Now, we can create a dictionary containing e.g. boolean and wildcard
terms. For example, we can create a (very naive) dictionary for Islamic
terrorism and immigration from Islamic countries:

``` r
library(boolydict)
dictionary = tribble(
  ~label, ~string,
  'islam_terror', '(musl* OR islam*) AND terror*',
  'islam_immig', '(musl* OR islam*) AND immig*',
)
```

Now, we can use the `dict_add` function to add a column for each
dictionary label, using `by_label` to create separate columns, and
settings `fill=0` for words that did not match:

``` r
hits = sotu_tokens |> 
  dict_add(dictionary, text_col = 'word', context_col = 'X', by_label='label', fill = 0) |>
  as_tibble()
hits |> arrange(-islam_immig) |> head()
```

So, how did mentions of Islam-related terrorism and immigration change
over time?

``` r
hits |> 
  select(year, islam_immig, islam_terror) |>
  pivot_longer(-year) |>
  group_by(year, name) |> summarize(value=sum(value)) |>
  ggplot() + geom_line(aes(x=year, y=value, color=name), alpha=.6)
```

Unsurprisingly, both concepts only really became salient after 2000.
