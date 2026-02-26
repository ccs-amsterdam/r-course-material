# Using embeddings in R


“You shall know a word by the company it keeps” (Firth, 1957)

The goal of this tutorial is to gain a better understanding of what
embeddings are, and how you can compute static or contextual embeddings
in R.

Although it does not showcase any applications of embeddings, the most
prominent direct usecase is probably clustering: which words or
documents have similar meanings based on their embeddings?

You can do this directly, but not that topic modeling techniques
(vanialla LDA, Structural Topic Models or BERTopic) provide packages to
do this in an efficient and robust manner. For that reason, the goal of
this tutorial is more to gain insight into how embeddings work rather
than for direct applications.

The tutorial is divided into three parts. First, we will have a look at
the Document-Term-Matrix (DTM) as a representation of meaning, and show
how this DTM can be directly clustered to provide a form of topic
modeling. Next, we look at **static embeddings**, i.e. embeddings where
one word (e.g. *party*) always has the same embedding, regardless of
context. The final section uses transformer-based models (BERT and GPT)
to derive **contextual embeddings**, i.e. where ‘party’ has a different
embedding when used in the meaning of political parties than as
celebration.

# Projecting a DTM to fewer dimensions

Using `tidytext`, we can `unnest` texts into words and store them in a
(long) one word per row format. If we count the frequency per document
per word, we have a DTM in long format, which we can `pivot_wider` to
show the traditional DTM format:

``` r
library(tidyverse)
library(tidytext)

texts = c("The party competed in the election",
           "The Conservative Party: victory in the election",
           "They threw a fantastic party after the election",
           "It was a brilliant and fantastic victory party")


dtm_long <- tibble(doc_id=1:4, text=texts) |>
  unnest_tokens(output="word", input="text") |>
  group_by(doc_id, word) |>
  summarize(n=n(), .groups = "drop")

dtm <- pivot_wider(dtm_long, names_from="word", values_from=n, values_fill=0)
```

In this dtm, we can say that the *meaning* of document 1 for the
computer is the vector
`c(1, 1, 1, 1, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)`, and that the
*meaning* of election is `c(1, 1, 1, 0)`. With ‘meaning’ or
representation we mean here that this is all the computer knows of that
document and that word. If the computer only has this dtm to go by,
`brilliant` and `it` are essentially identical words because they occur
in exactly the same documents.

Spatially, we can think of words as being in a 4-dimensional space as
each word is represented by four numbers. If we could draw in 4d we
could plot this directly, but we can also group the first and second
pair of documents together and then display the words as vectors in a
two-dimensional space:

``` r
dtm_long |> 
  filter(word %in% c("election", "party", "conservative", "fantastic")) |>
  mutate(label=if_else(doc_id <= 2, "P", "C")) |>
  group_by(word, label) |> 
  summarize(n=n()) |>
  pivot_wider(names_from="label", values_from=n, values_fill=0)  |>
  ggplot(aes(x=C, y=P, label=word, color=word)) + geom_label(hjust=0)  + 
  geom_segment(aes(x=0, y=0, xend=C, yend=P),
               arrow = arrow(length = unit(0.15, "cm"))) +
  xlim(0, 2.5) +
  ylim(0, 2.1) + theme_minimal()+theme(legend.position="none")
```

![](embeddings_files/figure-commonmark/unnamed-chunk-2-1.png)

In this space, *election* and *party* are clearly closer to each other
than *conservative* and *fantastic*. Since the absolute frequency of a
word is generally less interesting than its distribution over different
documents or context, we ofte look at the *angle* between vectors to
express proximity. Moreover, we often use `cosine` as a measure of
similarity, since the cosine of two perpendicular vectors (like
*conservative* and *fantastic*) is 0, while the cosine of two vectors
that are pointing in the same general direction (like *election* and
*party*) is close to one.

To calculate cosine, we can use the fact that the inner product between
two vectors of length one is the same as the cosine. In other words, if
we first *normalize* the vectors so they have length one, we can sum the
product of each dimension to get the cosine:

``` r
election = c(1,2)
party = c(2,2)
# per Pythagoras, the length of a vector is the square root of the sum of its squared values:
election_normalized = election / sqrt(sum(election^2))
party_normalized = party / sqrt(sum(party^2))
# Now, we can take the inner product by taking the sum of the product of the respective dimensions:
sum(election_normalized * party_normalized)
```

    [1] 0.9486833

## Clustering of words

We can use the logic above to find similarities between words in the
“four-dimensional” space, i.e. which words occur in similar documents?

``` r
#' Function to calculate cosine similarity between rows of a matrix
cosine_sim_rows <- function(M) {
  # Step 1: normalize by dividing each row by its Euclidean length
  M_norm <- M / sqrt(rowSums(M^2))
  # Step 2: cosine = inner products of normalized vector pairs = matrix times transposed matrix
  M_norm %*% t(M_norm)
}
  
similarities <- dtm |>
  select(-any_of(stopwords::stopwords("en"))) |>
  select(-doc_id) |>
  as.matrix() |> 
  t() |> # transpose because we want column (word) similarity
  cosine_sim_rows() 

library(ggcorrplot)
ggcorrplot(similarities, show.diag = F, lab=T)
```

![](embeddings_files/figure-commonmark/unnamed-chunk-4-1.png)

(note that instead of ggocrrplot, we could also transform to a tibble,
pivot_longer, and use geom_tile plus geom_text)

Finally, we could *cluster* the words together to find out groups of
words (‘topics’) which occur in similar documents. For the sake of this
example we use a simple built-in hierarchical cluster model. If we would
use SVD here this would be a latent semantic analysis, and LDA topic
modeling does something similar with a more sophisticated model.

``` r
clustering <- hclust(as.dist(1 - similarities), 
                     method = "average") 

d <- ggdendro::dendro_data(clustering)

clusters <- cutree(clustering, k=3)
clusters <- tibble(label = names(clusters), cluster = as.factor(clusters) )

ggplot() +
  geom_segment(data = d$segments,
               aes(x = x, y = y, xend = xend, yend = yend)) +
  geom_text(data = inner_join(d$labels, clusters),
            aes(x = x, y = y - 0.02, label = label, 
                color=cluster),
            angle = 45, hjust = 1) +
  coord_cartesian(clip = "off") +
  ylab("Cosine distance") + 
  theme_minimal() +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        plot.margin = margin(20, 20, 40, 20),
        legend.position = "none"
  )
```

![](embeddings_files/figure-commonmark/unnamed-chunk-5-1.png)

# Fits like a GloVe: Static pre-trained word embeddings

The example above showed how we could represent words and documents in a
high-dimensional vectors space based on their occurrence within our
four-sentence ‘corpus’. We could use the same logic to analyze larger
text collections, and of course the many topic modeling papers out there
show that this is a useful strategy.

In the end, however, the representation of the meaning of each word
remains dependent on the data we feed into the model. R doesn’t ‘know’
that brilliant and fantastic are similar words, it can only observe that
they occur in similar documents.

Assuming that many word meanings are fairly universal, it would make
sense to use as large a text collection as possible to learn which words
are similar. In fact, this is exactly what Mikolov and others at Google
did in 2013 by estimating vector representations of words on a (very)
large text collection. Although their techniques use a neural network
approach rather than the simple clustering shown above, the idea is the
same: words that occur in similar contexts get a similar representation
vector. This vector is called an **embedding** as it embeds a word in a
relatively low-dimensional space.

The nice thing of these embedding vectors is that the training is
non-trivial, the result is a simple matrix of (e.g. 300-dimensional)
vectors for the most frequent words in the English (or another)
language, and we can just download these vectors:

``` r
library(fastTextR)
if (!file.exists(here::here("cc.en.300.bin"))) {
  url = "https://dl.fbaipublicfiles.com/fasttext/vectors-crawl/cc.en.300.bin.gz"
  options(timeout=4300)  # assuming 1Mb/s
  download.file(url, destfile = here::here("cc.en.300.bin.gz"))
  R.utils::gunzip(here::here("cc.en.300.bin"))
}
model <- ft_load(here::here("cc.en.300.bin"))
```

Let’s look at the vectors for some words related to political and
celebratory parties:

``` r
words <- c("party", "election", "ballot", "parliament", "government",
           "minister", "candidate", "campaign", "coalition", "opposition",
           "conservative", "labour", "liberal", "republican", "democrat",
           "birthday", "celebration", "dance", "music",
           "drinks", "friends", "fun", "cake", "gifts",
           "invite", "crowd", "club", "loud", "festival")
embeddings <- ft_word_vectors(model, words) |>
  as_tibble(rownames = "word")
embeddings
```

    # A tibble: 29 × 301
       word          V1       V2       V3       V4       V5       V6     V7       V8
       <chr>      <dbl>    <dbl>    <dbl>    <dbl>    <dbl>    <dbl>  <dbl>    <dbl>
     1 party   -9.45e-6  0.0356  -0.0394   0.0567  -0.0403   0.133   0.122  -0.0648 
     2 electi… -7.56e-2  0.0319   0.0717   0.0223  -0.0961   0.0330  0.0377 -0.00884
     3 ballot  -2.00e-1  0.0723   0.0522   0.0648  -0.128    0.0463  0.0988 -0.0544 
     4 parlia… -2.36e-2  0.00642 -0.00136  0.0149  -0.00287 -0.00658 0.0308  0.0321 
     5 govern… -6.30e-2 -0.00161  0.0489   0.00417 -0.0461   0.0278  0.0696  0.00870
     6 minist… -6.98e-3 -0.0136  -0.0180  -0.00469 -0.0263  -0.00440 0.0305  0.0175 
     7 candid… -2.11e-2  0.00985  0.00418  0.0206  -0.0905   0.0297  0.0266 -0.0391 
     8 campai… -4.13e-2 -0.0108   0.0672   0.0271  -0.0259   0.0981  0.0293 -0.0386 
     9 coalit… -6.62e-2 -0.0414   0.00448  0.00640 -0.0165  -0.0237  0.0564 -0.0130 
    10 opposi… -3.07e-2  0.00816 -0.00406  0.0138  -0.0396  -0.0265  0.0416 -0.0218 
    # ℹ 19 more rows
    # ℹ 292 more variables: V9 <dbl>, V10 <dbl>, V11 <dbl>, V12 <dbl>, V13 <dbl>,
    #   V14 <dbl>, V15 <dbl>, V16 <dbl>, V17 <dbl>, V18 <dbl>, V19 <dbl>,
    #   V20 <dbl>, V21 <dbl>, V22 <dbl>, V23 <dbl>, V24 <dbl>, V25 <dbl>,
    #   V26 <dbl>, V27 <dbl>, V28 <dbl>, V29 <dbl>, V30 <dbl>, V31 <dbl>,
    #   V32 <dbl>, V33 <dbl>, V34 <dbl>, V35 <dbl>, V36 <dbl>, V37 <dbl>,
    #   V38 <dbl>, V39 <dbl>, V40 <dbl>, V41 <dbl>, V42 <dbl>, V43 <dbl>, …

As you can see, each word is represented by a 300-length vector that (to
some degree) captures the general meaning of that word. So, we would
expect the vector of election to be closer to parliament than to cake.
Since party can be used in both contexts, it should be somewhat close to
both election/ballot and cake:

``` r
embeddings |> 
  filter(word %in% c("election", "ballot", "party", "cake")) |>
  column_to_rownames("word") |>
  as.matrix() |> 
  cosine_sim_rows()
```

                 party    election    ballot        cake
    party    1.0000000 0.391208066 0.2469661 0.330701401
    election 0.3912081 1.000000000 0.5853658 0.002492018
    ballot   0.2469661 0.585365754 1.0000000 0.065723700
    cake     0.3307014 0.002492018 0.0657237 1.000000000

As you can see here, the meaning of ‘party’ is in a sense the average
between its meaning in the political and celebratory senses. To make
this even more clear, let’s plot the position of these words in a two
dimensional space.

For this, we first compute the similarities between all word pairs.
Then, we place all words in a two-dimensional space using
multidimensional scaling – the favorite tool of political scientists to
produce the “political compass” plots one sees in the memes. We then
extract the two dimensions for each word from the `mds` object, and plot
it using ggplot:

``` r
similarities <- embeddings |> 
    column_to_rownames("word") |>
  as.matrix() |> 
  cosine_sim_rows()

D <- as.dist(1 - similarities)
mds <- cmdscale(D, k = 2)

words_2d <- tibble(
  word = rownames(mds),
  dim1 = mds[,1],
  dim2 = mds[,2]
)

ggplot(words_2d, aes(dim1, dim2, label = word, 
                     color=(word == "party"))) +
  geom_point() +
  geom_text(vjust = -0.4) +  
  coord_equal() +
  theme_minimal() + 
  theme(legend.position="none") 
```

![](embeddings_files/figure-commonmark/unnamed-chunk-9-1.png)

As you can see, all the political words are on the left, while the
celebratory words are on the right - with party right in the middle. I
leave interpreting the second dimension to the reader, but apparently
conservatives are to friends as campaigns are to birthdays.

# Embeddings, transform! Contextual embeddings from BERT and GPT

The previous section used pre-trained embedding vectors to represent the
meaning of words in a static way: a *party* is a *party*, regardless of
whether it’s a celebration or a political organization. Although such
`static` embeddings are actually still the starting point of powerful
models like BERT and ChatGPT, we can use the more sophisticated
technology of these models to represent the **contextual** meaning of a
word.

These models, generally termed *transformers*, were sparked by a paper
called *Attention is all you need*, again from Google. Essentially,
these models use multiple hidden layers in a complex neural network to
progressively *transform* the input embeddings to a contextual
representation of their meaning, using so-called *attention layers* to
model which words form the relevant context in which to understand each
other word: if the attention layer says the word “political” is
important for the word “party” in this sentence, the embedding vector
for party in that sentence is moved closer to that of political.

Although at a technical level these models are quite hard to fully
understand, for this tutorial it suffices to know that these layers
capture more and more of the semantics and pragmatics of a word as used
in the text. In normal use of these models, we would then use these
representations to perform a specific task: generally supervised machine
learning in BERT and next word prediction in GPT. However, we can also
access the representation from these models directly, extracting the
contextualized ‘meaning’ of a word or document according to these
models.

To do this in practice we have two basic choices: ‘encoder’ models like
BERT or ‘decoder’ models like GPT.

## Extracting contextual embeddings with BERT

We can use BERT or a similar ‘encoder’ model to embed our words or
sentences. You can generally run these models on your own computer
(provided you have a decent graphical card or a lot of patience). This
has the advantage of keeping both your data and your credit card details
to yourself. The downside is that you need a somehwat beefy computer and
it can be a bit of a pain to set up, especially as most R packages for
this actually call python in the backend, which makes especially
installing them more complicated.

The most used package is probably the `text` package, which you can
install with the following commands:

``` r
 install.packages("text")
text::textrpp_install()
```

Then, initialize the library with:

``` r
library(text)
textrpp_initialize()
```

Now, let’s use a basic BERT model to embed the four sentences we used
earlier:

``` r
doc_emb <- textEmbed(
  texts,
  model = "bert-base-uncased"
)
doc_emb$texts$texts 
```

    # A tibble: 4 × 769
      id_texts Dim1_texts Dim2_texts Dim3_texts Dim4_texts Dim5_texts Dim6_texts
         <int>      <dbl>      <dbl>      <dbl>      <dbl>      <dbl>      <dbl>
    1        1    -0.529     -0.952     -0.0484     0.294      -0.494      0.733
    2        2    -0.822     -0.774     -0.0612    -0.111      -0.381      0.513
    3        3     0.103     -0.513      0.330      0.0442     -0.606     -0.236
    4        4     0.0607    -0.0807     0.389     -0.0696     -0.706     -0.122
    # ℹ 762 more variables: Dim7_texts <dbl>, Dim8_texts <dbl>, Dim9_texts <dbl>,
    #   Dim10_texts <dbl>, Dim11_texts <dbl>, Dim12_texts <dbl>, Dim13_texts <dbl>,
    #   Dim14_texts <dbl>, Dim15_texts <dbl>, Dim16_texts <dbl>, Dim17_texts <dbl>,
    #   Dim18_texts <dbl>, Dim19_texts <dbl>, Dim20_texts <dbl>, Dim21_texts <dbl>,
    #   Dim22_texts <dbl>, Dim23_texts <dbl>, Dim24_texts <dbl>, Dim25_texts <dbl>,
    #   Dim26_texts <dbl>, Dim27_texts <dbl>, Dim28_texts <dbl>, Dim29_texts <dbl>,
    #   Dim30_texts <dbl>, Dim31_texts <dbl>, Dim32_texts <dbl>, …

As you can see, each text is now represented in a 768-dimensional vector
space, representing the overall meaning of that text.

We can now use similar code to before to see which documents are most
similar:

``` r
doc_emb$texts$texts |>
  column_to_rownames("id_texts") |>
  as.matrix() |>
  cosine_sim_rows()  |>
  magrittr::set_rownames(texts)
```

                                                            1         2         3
    The party competed in the election              1.0000000 0.7918405 0.7189585
    The Conservative Party: victory in the election 0.7918405 1.0000000 0.6002274
    They threw a fantastic party after the election 0.7189585 0.6002274 1.0000000
    It was a brilliant and fantastic victory party  0.6057888 0.5165817 0.8537553
                                                            4
    The party competed in the election              0.6057888
    The Conservative Party: victory in the election 0.5165817
    They threw a fantastic party after the election 0.8537553
    It was a brilliant and fantastic victory party  1.0000000

As you can see, the first two documents and the last two documents are
the most similar pairs, with document three (which talks about a
celebratory party after a political victory) being in the middle.

## Extracting contextual word embeddings with BERT

Instead of document embeddings, we can also extract contextual word
embeddings directly. To make the representation of ‘party’ clearer,
let’s add a fifth sentence to the set:

``` r
texts2 <- c(texts,
  "The political organization held a celebration"
)
word_emb <- textEmbed(
  texts2,
  model = "bert-base-uncased",
  aggregation_from_tokens_to_texts = NULL
)
word_emb$tokens$texts[[1]]
```

    # A tibble: 8 × 770
      tokens     id    Dim1    Dim2     Dim3    Dim4    Dim5    Dim6    Dim7    Dim8
      <chr>   <int>   <dbl>   <dbl>    <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
    1 [CLS]       1 -0.867  -1.10   -0.422   -0.468  -0.876   0.563   0.362   0.118 
    2 the         1 -0.615  -1.51   -0.197    0.531  -0.684   0.989  -0.517   0.0817
    3 party       1 -0.415  -0.667   0.390    0.944  -0.268   0.834  -0.357  -0.752 
    4 compet…     1 -0.594  -0.682   0.00947  0.527  -0.672   1.15    0.405  -0.393 
    5 in          1 -1.19   -1.60   -0.168   -0.0537 -1.14    0.629  -0.432   0.503 
    6 the         1 -0.495  -1.40   -0.106    0.425  -0.619   0.938  -0.447   0.321 
    7 electi…     1 -0.0844 -0.662   0.139    0.404   0.373   0.782   0.526   0.398 
    8 [SEP]       1  0.0296  0.0175 -0.0324   0.0405 -0.0652 -0.0266 -0.0508 -0.0675
    # ℹ 760 more variables: Dim9 <dbl>, Dim10 <dbl>, Dim11 <dbl>, Dim12 <dbl>,
    #   Dim13 <dbl>, Dim14 <dbl>, Dim15 <dbl>, Dim16 <dbl>, Dim17 <dbl>,
    #   Dim18 <dbl>, Dim19 <dbl>, Dim20 <dbl>, Dim21 <dbl>, Dim22 <dbl>,
    #   Dim23 <dbl>, Dim24 <dbl>, Dim25 <dbl>, Dim26 <dbl>, Dim27 <dbl>,
    #   Dim28 <dbl>, Dim29 <dbl>, Dim30 <dbl>, Dim31 <dbl>, Dim32 <dbl>,
    #   Dim33 <dbl>, Dim34 <dbl>, Dim35 <dbl>, Dim36 <dbl>, Dim37 <dbl>,
    #   Dim38 <dbl>, Dim39 <dbl>, Dim40 <dbl>, Dim41 <dbl>, Dim42 <dbl>, …

The table above shows the rerpresentation of each word (or *token*) in
the first sentence, and in fact the representation of the whole sentence
in the first example is the exact (column-wise) average of the
representation of the separate words.

Now, let’s extract the representation of *party* in sentences one and
four, as well as the representation fo the words *organization* and
*celebration* in the newly added fifth sentence:

``` r
party_emb <- list_rbind(word_emb$tokens$texts) |>
  filter(tokens == "party" & id %in% c(1,4) | 
         tokens %in% c("organization", "celebration") & id==5)
party_emb
```

    # A tibble: 4 × 770
      tokens      id   Dim1   Dim2   Dim3   Dim4   Dim5   Dim6    Dim7   Dim8   Dim9
      <chr>    <int>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>   <dbl>  <dbl>  <dbl>
    1 party        1 -0.415 -0.667 0.390   0.944 -0.268 0.834  -0.357  -0.752 -1.13 
    2 party        4 -0.656 -0.108 0.198  -0.379 -1.33  0.0924 -0.720   0.247 -0.656
    3 organiz…     5  0.381 -0.686 0.0177 -0.315 -0.432 0.251  -0.0348 -0.241 -0.548
    4 celebra…     5 -1.07  -1.15  0.0617 -0.197 -0.722 0.110  -0.273   0.306 -0.587
    # ℹ 759 more variables: Dim10 <dbl>, Dim11 <dbl>, Dim12 <dbl>, Dim13 <dbl>,
    #   Dim14 <dbl>, Dim15 <dbl>, Dim16 <dbl>, Dim17 <dbl>, Dim18 <dbl>,
    #   Dim19 <dbl>, Dim20 <dbl>, Dim21 <dbl>, Dim22 <dbl>, Dim23 <dbl>,
    #   Dim24 <dbl>, Dim25 <dbl>, Dim26 <dbl>, Dim27 <dbl>, Dim28 <dbl>,
    #   Dim29 <dbl>, Dim30 <dbl>, Dim31 <dbl>, Dim32 <dbl>, Dim33 <dbl>,
    #   Dim34 <dbl>, Dim35 <dbl>, Dim36 <dbl>, Dim37 <dbl>, Dim38 <dbl>,
    #   Dim39 <dbl>, Dim40 <dbl>, Dim41 <dbl>, Dim42 <dbl>, Dim43 <dbl>, …

As you can see, party in the first sentence now has a different
embedding from party in the fourth sentence: a political party is not
(always) a celebration!

Now, let’s see how each usage of party relates to the meaning of the
words organization and celebration:

``` r
party_sim <- party_emb |>
  unite("word", id, tokens) |>
  column_to_rownames("word") |>
  as.matrix() |> 
  cosine_sim_rows()

ggcorrplot::ggcorrplot(party_sim, show.diag = FALSE, lab=TRUE, show.legend = FALSE) 
```

![](embeddings_files/figure-commonmark/unnamed-chunk-16-1.png)

This shows very clearly that the two uses of ‘party’ have quite
different meanings, with a relatively low similarity between `1_party`
and `4_party`. Moverover, party in the first sentence is most similar to
*organization* in the last sentence, while party in the fourth sentence
most closely resembles *celebration*

Finally, we can represent this graphically, e.g. using the same
multidimensional scaling employed above:

``` r
as.dist(1 - party_sim) |>
  cmdscale(k = 2) |> 
  as_tibble(rownames="word", .name_repair=~c("d1", "d2")) |>
  ggplot(aes(d1, d2, label=word)) + 
  geom_label() + 
  theme_minimal() + 
  xlim(c(-.4, .4)) +   
  ylim(c(-.4, .4))
```

![](embeddings_files/figure-commonmark/unnamed-chunk-17-1.png)

This neatly shows a primary dimension on the x-axis which celebrates the
political from the celebratory, with the vector from celebration to
organization being quite similar to the vector between the two usages of
party.
