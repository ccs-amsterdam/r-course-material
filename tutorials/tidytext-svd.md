Creating your own Word Embedding Vectors
================
Wouter van Atteveldt
2024-01

- [Data](#data)
  - [Data cleaning](#data-cleaning)
- [Word frequency analysis](#word-frequency-analysis)
- [Skipgram probabilities](#skipgram-probabilities)
- [Collocations (Word associations)](#collocations-word-associations)
- [Word embedding vectors using SVD](#word-embedding-vectors-using-svd)
  - [Finding semantically similar
    words](#finding-semantically-similar-words)

For this tutorial we will create our own word embedding vectors by
reducing the dimensionality of the skipgram-word matrix.

Note This tutorial mostly follows
<https://juliasilge.com/blog/tidy-word-vectors/>, with some updated
scripts (including the data collection).

# Data

In order to get decent word embeddings, we need a relatively large
corpus. A large open dataset is the HackerNews corpus, which consists of
millions of posts to hackernews, mostly about computing and software.
This corpus is available from HuggingFace, where we can download it with
the link below:

``` r
library(tidyverse)
library(here)
library(arrow)
url = "https://huggingface.co/datasets/jkeisling/hacker-news-corpus-2007-2022/resolve/refs%2Fconvert%2Fparquet/default/partial-train/0000.parquet"
fn = here("hackernews.parquet")
if (!file.exists(fn)) download.file(url, fn)
hackernews_raw = read_parquet(fn) |>
  select(by, timestamp, title, text)
```

## Data cleaning

If you have a look at the dataset, you can see it has numerous encoding
and HTML issues. Let’s fix some of these using regular expressions.

Note that we take a very small subset of the data here, as computing the
skipgram co-occurrences will take a lot of memory. You should probably
start with this small subset to see if you understand the code, and then
run a larger data set (e.g. 100k posts) depending on your computer if
you want to see useful output.

``` r
hackernews = arrow::read_parquet(fn) |> 
  head(n=10000) |> 
  mutate(title = na_if(title, ""),
         text = coalesce(title, text)) %>%
  select(-title) %>%
  mutate(text = str_replace_all(text, "&quot;|&#x2F;", "'"),   
         text = str_replace_all(text, "&#x2F;", "/"),           
         text = str_replace_all(text, "&#x27;", "'"),           
         text = str_replace_all(text, "<a(.*?)>", " "),      
         text = str_replace_all(text, "&gt;|&lt;", " "),       
         text = str_replace_all(text, "<[^>]*>", " "), 
         postID = row_number()) |>
  select(postID, by, timestamp, text)
```

# Word frequency analysis

What are the most used (non-stop) words on HackerNews?

First, let’s convert to a token list:

``` r
library(tidytext)
library(tidyverse)
tokens <- hackernews |> 
  unnest_tokens(word, text) |> 
  anti_join(stop_words)
```

And then count what percentage of the total each type is:

``` r
unigram_probs <- tokens |>
  count(word, sort = TRUE) |>
  mutate(p = n / sum(n))
unigram_probs
```

# Skipgram probabilities

Next, let’s compute skipgrams as the contexts around each word. We do
this by first unnesting to ngrams, and then unnesting each ngram so each
word x context pair becomes a row:

``` r
skipgrams <- hackernews |>
  unnest_tokens(ngram, text, token = "ngrams", n = 8) |>
  mutate(ngramID = row_number()) |>
  unite(skipgramID, postID, ngramID) |>
  unnest_tokens(word, ngram)
```

Now, let’s inner join the skipgrams *with itself* on the skipgram id, to
generate all word pairs within each skipgram,  
and compute how often each word pair occurs:

``` r
min_n = nrow(hackernews) * .001
skipgram_probs <- 
  inner_join(select(skipgrams, skipgramID, word1=word),
                 select(skipgrams, skipgramID, word2=word),
                 relationship = "many-to-many") |>
  group_by(word1, word2) |>
  summarize(n=length(unique(skipgramID)), .groups = "drop") |>
  filter(n >= min_n)|>
  mutate(p = n / sum(n)) |>
  arrange(-p)
skipgram_probs
```

# Collocations (Word associations)

The list above showed mostly very common terms, as these also co-occur
the most frequently.

So, let’s compute which words occur together more often than expected
based on their overall frequencies, also known as ‘collocations’:

``` r
normalized_prob <- skipgram_probs |>
  inner_join(select(unigram_probs, word1 = word, p1 = p)) |>
  inner_join(select(unigram_probs, word2 = word, p2 = p)) |>
  mutate(p_together = p / p1 / p2) |>
  arrange(-p_together)
filter(normalized_prob, n > 100)
```

# Word embedding vectors using SVD

Now, we can compute the word embedding vectors using SVD. This is not
how the ‘state of the art’ embedding vectors are computed – these
generally use some neural network – but the general idea of
dimensionality reduction is the same.

Note that The R built-in svd function can only deal with dense matrices.
Since most words do not co-occur with most other words, this is a very
inefficient representation. So, we will use the `irlba` package to do a
sparse matrix SVD:

``` r
pmi_matrix <- normalized_prob |>
  mutate(pmi = log10(p_together)) |>
  cast_sparse(word1, word2, pmi) 
svd <- irlba::irlba(pmi_matrix, nv=128, maxit = 1e3)
```

We can extract the `U` matrix from this, which represent the word
embedding vectors:

``` r
word_vectors <- svd$u
rownames(word_vectors) <- rownames(pmi_matrix)
dim(word_vectors)
```

## Finding semantically similar words

Now that we have the word vectors, we can query this for e.g. similar
words by computing the inner product of a target vector with all other
vectors, essentially computing an unnormalized cosine distance or
correlation.

``` r
scores <- word_vectors %*% word_vectors["linux",]
tibble(token = rownames(scores), similarity=scores[,1]) |>
  arrange(-similarity)
```

(Note, these results probably only makes sense with a reasonably sized
corpus)
