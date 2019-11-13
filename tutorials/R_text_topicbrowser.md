Creating a topic browser in R
================
Kasper Welbers & Wouter van Atteveldt
November 2019

Introduction
============

Interpreting topic models can be hard. We can look at the top terms per topic to get an idea of what latent topic underlies their co-occurences, but as people tend to be really good at finding patterns when the look hard enough, it is easy to draw wrong conclusions. An excellent paper on the matter is @@@ by @@@.

A great technique for interpreting and validating topic models is to create a full text browser in which we can see how the individual words in documents are assigned to topics. In this document we demonstrate how this browser can easily be created with the `corpustools` package. In addition, we'll show how the `udpipe` package can be used to apply advanced NLP preprocessing without the hassle of external dependencies.

Note on corpustools version
---------------------------

This feature has only very recently been implemented in corpustools (in fact, we implemented it for this very workshop). We'll push the new version to CRAN soon, but for now you'll have to install the development version using `devtools`.

``` r
devtools::install_github('kasperwelbers/corpustools')
```

``` r
library(corpustools)
```

A brief introduction to corpustools
===================================

The corpustools package is similar to quanteda in the sense that it provides various features for preprocessing and analyzing text. The main difference is that `corpustools` is designed for working with tokenized texts in a tokenlist format.

It's best to just show it. Here we create a tcorpus (tokenized corpus) of a demo dataset of paragraphs in state of the union speeches from George Bush and Barack Obama. We also apply some basic preprocessing.

``` r
tc = create_tcorpus(sotu_texts, doc_col='id', split_sentences=T)
tc$preprocess(use_stemming = T, remove_stopwords = T, min_docfreq = 10)

head(tc$tokens, 10)
```

| doc\_id   |  sentence|  token\_id| token      | feature |
|:----------|---------:|----------:|:-----------|:--------|
| 111541965 |         1|          1| It         | NA      |
| 111541965 |         1|          2| is         | NA      |
| 111541965 |         1|          3| our        | NA      |
| 111541965 |         1|          4| unfinished | NA      |
| 111541965 |         1|          5| task       | task    |
| 111541965 |         1|          6| to         | NA      |
| 111541965 |         1|          7| restore    | restor  |
| 111541965 |         1|          8| the        | NA      |
| 111541965 |         1|          9| basic      | basic   |
| 111541965 |         1|         10| bargain    | NA      |

The tokenlist is a data.table in which each row is a token. The preprocessed token is given in the separate `feature` column. For all stopwords and features with min\_docfreq &lt; 10, an NA value is given to indicate that this token is filtered out. However, while we would typically not use these NA values in our analysis, we do keep the original position of the token in our tokenlist.

This has a clear tradeoff. One the one hand, it requires much more memory to preserve the full textual information this way. As such, the `corpustools` package is much less memory efficient compared to `quanteda`, and not suitable for very large corpora. On the other hand, keeping all tokens in their original order provides a bridge between the original texts and bag-of-words style analyses.

In this tutorial, we'll focus on how this can be used to annotate the token data with the topic assignments of an LDA model. We can then recreate the original texts and visualize the topics in the contexts of the original documents. The key corpustools feature here is the `browse_texts` function, which can paste the words in a tCorpus back together with several ways to color words based on annotations. As an example, let's perform a quick-and-dirty query search and highlight the results.

``` r
tc$code_features(c('Terrorism# terroris* OR <terror attack*>',
                   'Education# school* teach* educat*',
                   'Economy# econom* bank* job*'))
browse_texts(tc, category='code')
```

The output is not shown in this document because it is a rather large HTML file. If you are working in R studio, it should by default open in the Viewer in the bottom-right window.

Using udpipe for NLP preprocessing
==================================

Another reason for the focus on the tokenlist format in `corpustools` is that allows us to work with the results of NLP parsers. This data can be imported, but we also provide a convenient wrapper for using the `udpipe` package directly in the `create_tcorpus` function.

UDpipe is one of the major pipelines for NLP preprocessing. One of the nice things about UDpipe is that the `udpipe` package let's us run UDpipe in R without complicated external dependencies. Also, UDpipe supports a pretty long range of languages (though the supported features and accuracy varies strongly, depending on available training data).

In `corpustools` we wrote a thin wrapper that automatically downloads the model for a given language the first time it is used. In addition, a persistent cache is kept for the most recent (by default 3) inputs to create\_tcorpus, which makes it easier to parse many documents across sessions, and overall makes it nicer to work with (this is stil very fresh \[so let me know if you run into issues\], since I wrote it on the train to this workshop).

Here we parse the state of the union speeches with the english-ewt model. If you don't know the name of a model for the language that your data is in, simply type the language and you'll get suggestions if there are models available.

``` r
tc = create_tcorpus(sotu_texts, doc_column = 'id', udpipe_model='english-ewt')
```

These are the columns that we're interested in:

``` r
head(tc$tokens[,c('doc_id','sentence','token','lemma','POS')], 10)
```

| doc\_id   |  sentence| token      | lemma      | POS  |
|:----------|---------:|:-----------|:-----------|:-----|
| 111541965 |         1| It         | it         | PRON |
| 111541965 |         1| is         | be         | AUX  |
| 111541965 |         1| our        | we         | PRON |
| 111541965 |         1| unfinished | unfinished | ADJ  |
| 111541965 |         1| task       | task       | NOUN |
| 111541965 |         1| to         | to         | PART |
| 111541965 |         1| restore    | restore    | VERB |
| 111541965 |         1| the        | the        | DET  |
| 111541965 |         1| basic      | basic      | ADJ  |
| 111541965 |         1| bargain    | bargain    | NOUN |

There are two nice things of using NLP preprocessing for topic modeling:

-   Using lemma disregards the differences between word forms that your often not interested in (singular/plural, verb conjugations). It does so more accurately than stemmen, and especially for highly inflected languages
-   We can use part-of-speech (POS) tags to focus only on certain types of words.

For this example we'll only use nouns, proper names and verbs that occur in at least 10 documents.

``` r
tc$feature_subset(column = 'lemma', new_column = 'feature', 
                  min_docfreq = 10, subset = POS %in% c('NOUN','PROPN','VERB'))
```

Fitting an LDA topic model in corpustools
=========================================

For fitting an LDA topic model in `corpustools` we also use the `topicmodels` package. However, instead of creating a DTM and using the LDA function (see earlier tutorial on LDA in R), the tCorpus has a method `lda_fit`. This method wraps the LDA function, and also gives the same output, but in addition, it adds the 'wordassignments' of the last iteration to the tCorpus.

``` r
m = tc$lda_fit('feature', create_feature = 'topic', K = 5, alpha = 0.001)
```

So now the tokenlist has a column with the topic number.

``` r
head(tc$tokens[,c('doc_id','sentence','token','lemma','POS','feature','topic')], 10)
```

| doc\_id   |  sentence| token      | lemma      | POS  | feature |  topic|
|:----------|---------:|:-----------|:-----------|:-----|:--------|------:|
| 111541965 |         1| It         | it         | PRON | NA      |     NA|
| 111541965 |         1| is         | be         | AUX  | NA      |     NA|
| 111541965 |         1| our        | we         | PRON | NA      |     NA|
| 111541965 |         1| unfinished | unfinished | ADJ  | NA      |     NA|
| 111541965 |         1| task       | task       | NOUN | task    |      5|
| 111541965 |         1| to         | to         | PART | NA      |     NA|
| 111541965 |         1| restore    | restore    | VERB | restore |      5|
| 111541965 |         1| the        | the        | DET  | NA      |     NA|
| 111541965 |         1| basic      | basic      | ADJ  | NA      |     NA|
| 111541965 |         1| bargain    | bargain    | NOUN | NA      |     NA|

The tCorpus also has a function for looking at the top terms for a given feature or document variable. Here we can use this to look at the top words per topic. Instead of ranking by absolute frequency (which mainly shows common terms) we rank by the Chi2 value for the relative frequency of a term in a topic compared to the corpus in general.

``` r
top_features(tc, 'feature', group_by = 'topic', rank_by = 'chi2')
```

|  topic| 1         | 2      | 3         | 4         | 5        | 6        | 7           | 8      | 9        | 10      |
|------:|:----------|:-------|:----------|:----------|:---------|:---------|:------------|:-------|:---------|:--------|
|      1| woman     | man    | people    | Iraq      | country  | freedom  | serve       | come   | have     | nation  |
|      2| terrorist | Al     | Qaida     | weapon    | terror   | regime   | Afghanistan | threat | ally     | war     |
|      3| tax       | health | care      | insurance | coverage | Medicare | retirement  | pay    | economy  | family  |
|      4| energy    | job    | oil       | make      | business | trade    | technology  | year   | Congress | gas     |
|      5| school    | child  | education | student   | math     | life     | help        | year   | ask      | teacher |

Now, finally we get to the main purpose of this document. We can now use the topic annotations to create a text browser where different topics are highlighted, and can be navigated with the category filter.

``` r
url = browse_texts(tc, category='topic', top_nav=1)
```

The browser is actually an HTML / javascript file. By default it is stored in the temporary folder, but you can also store it if you want to keep or distribute it. The output of browse\_texts is the url to the file. You can also open the browser in your webbrowser. The convenient browseURL function in R open any url in your default browser.

``` r
browseURL(url)
```
