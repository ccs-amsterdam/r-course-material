Using Pretrained Embedding Vectors
================
Wouter van Atteveldt
2024-01

- [Introduction](#introduction)
- [Data](#data)
- [Embeddings](#embeddings)
- [Finding similar words](#finding-similar-words)
- [Coherence](#coherence)

# Introduction

This tutorial will show you how to use pre-trained embedding vectors to
find similar words as well as the pairwise similarity of groups of
words.

# Data

The pre-trained vectors are theoretically independent of our corpus.
However, since these vector files tend to be quite large, we first
define a corpus so we can immediately filter the vectors on words that
actually occur in the corpus.

For this example, let’s use all State of the Union speeches since 1945:

``` r
library(sotu)
library(tidyverse)
docs = sotu_meta |>
  as_tibble() |>
  add_column(text=sotu_text) |>
  filter(year > 1945)
```

And create a tidytext format tibble:

``` r
library(tidytext)
tokens = docs |> 
  unnest_tokens("word", "text")
```

# Embeddings

Now, let’s download the pre-trained embeddings. Since this takes a
while, we only do it if the file does not exist yet:

``` r
library(here)
embeddings_file = here("cc.en.300.bin")
if (!file.exists(embeddings_file)) {
  url = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.en.300.bin.gz"
  options(timeout=4300)  # assuming 1Mb/s
  gzfile = str_c(embeddings_file, ".gz")
  download.file(paste0(url), destfile = gzfile )
  R.utils::gunzip(gzfile) # Install R.utils if needed
}
```

Now, we can use `fastTextR` to extract the embeddings, keeping only
words that occur in both the model and our corpus (to save time and
memory)

``` r
library(fastTextR)
ft_model = ft_load(embeddings_file)
to_extract = intersect(tokens$word, ft_words(ft_model))
vectors <- fastTextR::ft_word_vectors(ft_model, to_extract)
```

To make it easier to calculate with, we normalize all vectors to unit
length. Since cosine distance is the normalized inner product, that
means that if all vectors are normalized we can use simply matrix
multiplication to compute distances.

``` r
vectors <- vectors / sqrt(rowSums(vectors^2))
```

# Finding similar words

Now, we can use those vectors to find e.g. the closest words to the word
“health”:

``` r
similarities <- vectors %*% vectors["health",] |>
  as.data.frame() |>
  rownames_to_column("word") |>
  as_tibble() |>
  rename(similarity=V1) |>
  arrange(-similarity)
head(similarities)
```

# Coherence

We can also see how similar these words are to each other (pairwise):

``` r
words = similarities |> 
  slice_max(similarity, n=100) |>
  pull(word)
v <- vectors[words,]
pairwise <- v %*% t(v) |>
  tibble::as_tibble(rownames="word1") |>
  tidyr::pivot_longer(-word1, names_to="word2", values_to="similarity") |>
  dplyr::filter(word2 > word1) |>
  dplyr::arrange(-similarity) 
head(pairwise)
```

And we can visualize this as a word graph:

``` r
library(tidygraph)
library(ggraph)
freqs = tokens |> count(word, sort=T) |> filter(word %in% words)
g <- tbl_graph(nodes=freqs, edges=pairwise, directed = FALSE) |>
  activate(edges) |>
   filter(similarity > .4) |>
  activate(nodes) |>
    mutate(cluster = as.factor(group_fast_greedy(weights=similarity)))  |>
  arrange(-n)

ggraph(g, layout='kk') + 
  geom_edge_link(aes(edge_width=similarity, edge_alpha=similarity), color='grey') + 
  geom_node_text(aes(label=word, size=n, color=cluster), check_overlap=TRUE) + 
  scale_edge_width_continuous(range=c(.5, 2)) + 
  scale_size_continuous(range=c(2, 6)) + 
  theme_void() + theme(legend.position="none")
```

![](img/unnamed-chunk-8-1.png)<!-- -->
