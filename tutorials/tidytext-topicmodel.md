Topic modeling with Tidy Text
================
Wouter van Atteveldt
2022-10

- <a href="#introduction" id="toc-introduction">Introduction</a>
- <a href="#1-creating-a-dtm" id="toc-1-creating-a-dtm">(1) Creating a
  DTM</a>
- <a href="#2-running-the-topic-model"
  id="toc-2-running-the-topic-model">(2) Running the topic model</a>
- <a href="#3-inspecting-and-analysing-the-results"
  id="toc-3-inspecting-and-analysing-the-results">(3) Inspecting and
  analysing the results</a>
  - <a href="#word-topic-probabilities"
    id="toc-word-topic-probabilities">Word-topic probabilities</a>
  - <a href="#topics-per-document" id="toc-topics-per-document">Topics per
    document</a>
  - <a href="#topics-in-their-original-context"
    id="toc-topics-in-their-original-context">Topics in their original
    context</a>

# Introduction

LDA, which stands for Latent Dirichlet Allocation, is one of the most
popular approaches for probabilistic topic modeling. The goal of topic
modeling is to automatically assign topics to documents without
requiring human supervision. Although the idea of an algorithm figuring
out topics might sound close to magical (mostly because people have too
high expectations of what these ‘topics’ are), and the mathematics might
be a bit challenging, it is actually really simple fit an LDA topic
model in R.

A good first step towards understanding what topic models are and how
they can be useful, is to simply play around with them, so that’s what
we’ll do here. For more information, see also the material on my 2019
[GESIS topic modeling
workshop](https://github.com/vanatteveldt/gesis-topic-models).

The process of topic modeling is:

1.  Clean up your corpus and create a DTM or document-term matrix
2.  Fit the topic model
3.  Validate and analyze the resulting model

# (1) Creating a DTM

We use the State of the Union speeches, and we split them per paragraph
assuming that these are somewhat consistent in their topic.

Note: For more information on basic tidytext usage, see [our tidytext
tutorial](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/tidytext.md)
and/or the [official tidytext
tutorial](https://www.tidytextmining.com/).

``` r
library(sotu)
library(tidyverse)
library(tidytext)
sotu_paragraphs = add_column(sotu_meta, text=sotu_text) |> 
  as_tibble() |>
  filter(year > 1945) |>
  unnest_tokens(text, text, token='paragraphs') |>
  mutate(doc_id=row_number())
```

Next, we create a token list and do some light cleaning:

``` r
sotu_tokens = sotu_paragraphs |> 
  unnest_tokens(word, text)
sotu_tokens_clean = sotu_tokens |> 
  anti_join(tidytext::stop_words) |>
  group_by(word) |>
  filter(n() > 10,
         !str_detect(word, "[^a-z]")) |>
  ungroup()
print(glue::glue("{length(unique(sotu_tokens_clean$word))} unique words in ",
                 "{length(unique(sotu_tokens_clean$doc_id))} documents"))
```

Now we can create a document-term matrix. This essentially a (sparse)
matrix showing how often each term (column) occurs in each document
(row):

``` r
dtm = sotu_tokens_clean |> 
  group_by(doc_id, word) |>
  summarize(n=n()) |>
  cast_dtm(doc_id, word, n)
```

We can inspect a corner of the dtm by casting it to a regular (dense)
matrix:

``` r
as.matrix(dtm[1:5, 1:5])
```

# (2) Running the topic model

We can now fit the topic model from the dtm using the `LDA` function in
the topicmodels package. Note that we use `set.seed` to create a
reproducible setup since topic modeling is deterministic. Note also that
we set a relatively low alpha parameter, see our [understanding
alpha](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/understanding_alpha.md)
handout for more information.

``` r
library(topicmodels)
set.seed(123)
m = LDA(dtm, method = "Gibbs", k = 10,  control = list(alpha = 0.1))
```

# (3) Inspecting and analysing the results

Now that we have run the model, we can use the `terms` function to check
the top terms:

``` r
terms(m, 5)
```

So, we can see some pretty clear clusters, e.g. about health care and
the military.

## Word-topic probabilities

To extract how strongly each word is associated with each topic, we can
use the `tidy` function, which turns statistical modeling results
(e.g. `m`) into tidy tables.

``` r
# You might have to run install.packages("reshape2")
words = tidy(m)
head(words)
```

This allows us to e.g. plot a word cloud for each topic:

``` r
library(ggwordcloud)
words |> 
  group_by(topic) |>
  slice_max(beta, n=25) |>
  ggplot() + 
  geom_text_wordcloud(aes(label=term, size=beta)) +
  facet_wrap(vars(topic), nrow=2)
```

We can also compare the words in two topics by computing the log
difference in their betas. For example, to compare the energy (10) and
economy (8) topics and see which word is most typical in that topic
compared to the other topic:

``` r
words |> filter(topic %in% c(8, 10)) |>
  pivot_wider(names_from=topic, values_from=beta) |>
  filter(`8`>.001 | `10` > .001) |>
  mutate(log_ratio = log2(`8`/`10`)) |>
  slice_max(abs(log_ratio), n=20) |>
  ggplot() + geom_col(aes(x=log_ratio, y=fct_reorder(term, log_ratio)))
```

## Topics per document

Similary to above, we can also extract to topics per document:

``` r
topics = tidy(m, matrix='gamma')
```

We can join this back with the original metadata (note that we convert
doc_id to character here since DTM row names are always character
values):

``` r
meta = sotu_paragraphs |> 
  mutate(document=as.character(doc_id)) |>
  select(document, year, president, party)
topics = tidy(m, matrix='gamma') |> inner_join(meta)
head(topics)
```

Now, we can e.g. compare topic usage per party:

``` r
topics |> 
  group_by(party, topic) |> 
  summarize(gamma=mean(gamma)) |> 
  ggplot() + geom_col(aes(x=gamma, y=as.factor(topic), fill=party), position=position_dodge())  +
  scale_fill_manual(values=list(Democratic='#5555ff', Republican='#ff5555'))
```

So, it seems that democrats prefer topic 9 (trade) and 5 (jobs), while
republicans prefer topics 6 (law and order) and 2 (american values).

## Topics in their original context

Finally, we can use `augment` to extract the topic assignment for each
word in each document:

``` r
assignments = augment(m, data=dtm)
head(assignments)
```

We can join this back with the original data frame to get the meta data
per document (converting the doc_id column to character since row names
are always characters, hence the dtm always has textual document ids)

``` r
assignments = augment(m, data=dtm) |> 
  mutate(doc_id=as.numeric(document)) |> 
  select(doc_id, word=term, topic=.topic)
assignments = left_join(sotu_tokens, assignments)
head(assignments)
```

This can be used to inspect topic usage within documents using the
[tokenbrowser](https://github.com/kasperwelbers/tokenbrowser) package
developed by Kasper Welbers:

``` r
library(tokenbrowser)
meta = select(assignments, doc_id, year, president, party)
categorical_browser(assignments, meta=meta, category=as.factor(assignments$topic),  token_col="word") |>
  browseURL()
```
