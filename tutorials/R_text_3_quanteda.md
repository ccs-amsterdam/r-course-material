R text analysis: quanteda
================
Kasper Welbers & Wouter van Atteveldt
2019-1

-   [Introduction](#introduction)
    -   [The quanteda package](#the-quanteda-package)
-   [Step 1: Importing text and creating a quanteda corpus](#step-1-importing-text-and-creating-a-quanteda-corpus)
    -   [From CSV files](#from-csv-files)
    -   [From text (or word/pdf) files](#from-text-or-wordpdf-files)
-   [Step 2: Creating the DTM (or DFM)](#step-2-creating-the-dtm-or-dfm)
    -   [Preprocessing/cleaning DTMs](#preprocessingcleaning-dtms)
    -   [Filtering the DTM](#filtering-the-dtm)
    -   [NLP Preprocessing with UDPipe](#nlp-preprocessing-with-udpipe)
-   [Step 3: Analysis](#step-3-analysis)
    -   [Word frequencies and wordclouds](#word-frequencies-and-wordclouds)
    -   [Compare corpora](#compare-corpora)
    -   [Keyword-in-context](#keyword-in-context)
    -   [Dictionary search](#dictionary-search)
    -   [Creating good dictionaries](#creating-good-dictionaries)

Introduction
============

In this tutorial you will learn how to perform text analysis using the quanteda package. In the [R Basics: getting started](R_basics_1_getting_started.md) tutorial we introduced some of the techniques from this tutorial as a light introduction to R. In this and the following tutorials, the goal is to get more understanding of what actually happens 'under the hood' and which choices can be made, and to become more confident and proficient in using quanteda for text analysis.

The quanteda package
--------------------

The [quanteda package](https://quanteda.io/) is an extensive text analysis suite for R. It covers everything you need to perform a variety of automatic text analysis techniques, and features clear and extensive documentation. Here we'll focus on the main preparatory steps for text analysis, and on learning how to browse the quanteda documentation. The documentation for each function can also be found [here](https://quanteda.io/reference/index.html).

For a more detailed explanation of the steps discussed here, you can read the paper [Text Analysis in R](http://vanatteveldt.com/p/welbers-text-r.pdf) (Welbers, van Atteveldt & Benoit, 2017).

``` r
library(quanteda)
```

Step 1: Importing text and creating a quanteda corpus
=====================================================

The first step is getting text into R in a proper format. stored in a variety of formats, from plain text and CSV files to HTML and PDF, and with different 'encodings'. There are various packages for reading these file formats, and there is also the convenient [readtext](https://cran.r-project.org/web/packages/readtext/vignettes/readtext_vignette.html) that is specialized for reading texts from a variety of formats.

From CSV files
--------------

For this tutorial, we will be importing text from a csv. For convenience, we're using a csv that's available online, but the process is the same for a csv file on your own computer. The data consists of the State of the Union speeches of US presidents, with each document (i.e. row in the csv) being a paragraph. The data will be imported as a data.frame.

``` r
library(readr)
url = 'https://bit.ly/2QoqUQS'
d = read_csv(url)
head(d)   ## view first 6 rows
```

We can now create a quanteda corpus with the `corpus()` function. If you want to learn more about this function, recall that you can use the question mark to look at the documentation.

``` r
?corpus
```

Here you see that for a data.frame, we need to specify which column contains the text field. Also, the text column must be a character vector.

``` r
corp = corpus(d, text_field = 'text')  ## create the corpus
corp
```

From text (or word/pdf) files
-----------------------------

Rather than a csv file, your texts might be stored as separate files, e.g. as .txt, .pdf, or .docx files. You can quite easily read these as well with the `readtext` function from the `readtext` package. You might have to install that package first with:

``` r
install.packages(readtext)
```

You can then call the readtext function on a particular file, or on a folder or zip archive of files directly.

``` r
library(readtext)
url = "https://github.com/ccs-amsterdam/r-course-material/blob/master/data/files.zip?raw=true"
texts = readtext(url)
texts
```

As you can see, it automatically downloaded and unzipped the files, and converted the MS Word and PDF files into plain text.

I read them from an online source here, but you can also read them from your hard drive by specifying the path:

``` r
texts = readtext("c:/path/to/files")
texts = readtext("/Users/me/Documents/files")
```

You can convert the texts directly into a corpus object as above:

``` r
corp2 = corpus(texts)
corp2
```

Step 2: Creating the DTM (or DFM)
=================================

Many text analysis techniques only use the frequencies of words in documents. This is also called the bag-of-words assumption, because texts are then treated as bags of individual words. Despite ignoring much relevant information in the order of words and syntax, this approach has proven to be very powerfull and efficient.

The standard format for representing a bag-of-words is as a `document-term matrix` (DTM). This is a matrix in which rows are documents, columns are terms, and cells indicate how often each term occured in each document. We'll first create a small example DTM from a few lines of text. Here we use quanteda's `dfm()` function, which stands for `document-feature matrix` (DFM), which is a more general form of a DTM.

``` r
text <-  c(d1 = "Cats are awesome!",
           d2 = "We need more cats!",
           d3 = "This is a soliloquy about a cat.")

dtm <- dfm(text, tolower=F)
dtm
```

Here you see, for instance, that the word `soliloquy` only occurs in the third document. In this matrix format, we can perform calculations with texts, like analyzing different sentiments of frames regarding cats, or the computing the similarity betwee the third sentence and the first two sentences.

Preprocessing/cleaning DTMs
---------------------------

However, directly converting a text to a DTM is a bit crude. Note, for instance, that the words `Cats`, `cats`, and `cat` are given different columns. In this DTM, "Cats" and "awesome" are as different as "Cats" and "cats", but for many types of analysis we would be more interested in the fact that both texts are about felines, and not about the specific word that is used. Also, for performance it can be useful (or even necessary) to use fewer columns, and to ignore less interesting words such as `is` or very rare words such as `soliloquy`.

This can be achieved by using additional `preprocessing` steps. In the next example, we'll again create the DTM, but this time we make all text lowercase, ignore stopwords and punctuation, and perform `stemming`. Simply put, stemming removes some parts at the ends of words to ignore different forms of the same word, such as singular versus plural ("gun" or "gun-s") and different verb forms ("walk","walk-ing","walk-s")

``` r
dtm = dfm(text, tolower=T, remove = stopwords('en'), stem = T, remove_punct=T)
dtm
```

By now you should be able to understand better how the arguments in this function work. The `tolower` argument determines whether texts are (TRUE) or aren't (FALSE) converted to lowercase. `stem` determines whether stemming is (TRUE) or isn't (FALSE) used. The remove argument is a bit more tricky. If you look at the documentation for the dfm function (`?dfm`) you'll see that `remove` can be used to give "a pattern of user-supplied features to ignore". In this case, we actually used another function, `stopwords()`, to get a list of english stopwords. You can see for yourself.

``` r
stopwords('en')
```

This list of words is thus passed to the `remove` argument in the `dfm()` to ignore these words. If you are using texts in another language, make sure to specify the language, such as stopwords('nl') for Dutch or stopwords('de') for German.

There are various alternative preprocessing techniques, including more advanced techniques that are not implemented in quanteda. Whether, when and how to use these techniques is a broad topic that we won't cover today. For more details about preprocessing you can read the [Text Analysis in R](http://vanatteveldt.com/p/welbers-text-r.pdf) paper cited above.

Filtering the DTM
-----------------

For this tutorial, we'll use the State of the Union speeches. We already created the corpus above. We can now pass this corpus to the `dfm()` function and set the preprocessing parameters.

``` r
dtm = dfm(corp, tolower=T, stem=T, remove=stopwords('en'), remove_punct=T)
dtm
```

This dtm has 23,469 documents and 20,429 features (i.e. terms), and no longer shows the actual matrix because it simply wouldn't fit. Depending on the type of analysis that you want to conduct, we might not need this many words, or might actually run into computational limitations.

Luckily, many of these 20K features are not that informative. The distribution of term frequencies tends to have a very long tail, with many words occuring only once or a few times in our corpus. For many types of bag-of-words analysis it would not harm to remove these words, and it might actually improve results.

We can use the `dfm_trim` function to remove columns based on criteria specified in the arguments. Here we say that we want to remove all terms for which the frequency (i.e. the sum value of the column in the DTM) is below 10.

``` r
dtm  = dfm_trim(dtm, min_termfreq = 10)
dtm
```

Now we have about 5000 features left. See `?dfm_trim` for more options.

NLP Preprocessing with UDPipe
-----------------------------

In many cases, especially for languages with a richer morphology than English, it can be useful to use tools from computational linguistics to preprocess the data. In particular, *lemmatization* often works better for stemming, and *Part of Speech tagging* can be a great way to select e.g. only the names or verbs in a document.

`udpipe` is an R package that can do many preprocessing steps for a variety of languages including English, French, German and Dutch. If you call it for a language you have not previously used, it will automatically download the language model.

For this example, we will use a very short text, as it can take (very) long to process large amounts of text.

``` r
small_text = c("Pelosi says Trump is welcome to testify in impeachment inquiry, if he chooses", "House speaker pushes back against president’s accusations that process is stacked against him as Schumer echoes her suggestion")
small_corpus = corpus(small_text)
```

Now, let's lemmatize and tag this corpus:

``` r
library(tidyverse)
library(udpipe)
tokens = udpipe(texts(small_corpus), "english", parser="none")
tokens %>% as_tibble() %>% select(token_id:xpos)
```

As you can see, 'is' is lemmatized to 'be', and Pelosi and Trump are both recognized as proper nouns (names).

We can create a dfm of all lemmata, assinging to udpipe tokens to the corpus and proceeding as normal:

``` r
small_corpus$tokens <-  as.tokens(split(tokens$lemma, tokens$doc_id))
d = dfm(small_corpus, remove=stopwords("english"), remove_punct=T)
textplot_wordcloud(d, min_count = 1)
```

**Update: This doesn't work anymore in the most recent quanteda version. We're trying to find a direct replacement, but in the meantime you can use:**

```r
d = document_term_frequencies(tokens, "doc_id", "lemma") %>% document_term_matrix() %>% as.dfm() 
# and if desired do additional processing with dfm_remove, dfm_trim etc:
d = dfm_remove(d, stopwords('en'))
```

More interesting, however, is to e.g. select only the verbs: Note that here I skip the corpus steps to show how you can also work directly with the texts and tokens:

``` r
tokens = udpipe(small_text, "english", parser="none")
d = tokens %>% filter(upos == "VERB") %>% 
  with(split(lemma, doc_id)) %>% as.tokens() %>% 
  dfm(remove=stopwords("german")) %>% 
textplot_wordcloud(d, min_count=1)
```

Of course, this is more meaningful if you run it on a larger text.

Step 3: Analysis
================

Using the dtm we can now employ various techniques. You've already seen some of them in the introduction tutorial, but by now you should be able to understand more about the R syntax, and understand how to tinker with different parameters.

Word frequencies and wordclouds
-------------------------------

Get most frequent words in corpus.

``` r
textplot_wordcloud(dtm, max_words = 50)     ## top 50 (most frequent) words
textplot_wordcloud(dtm, max_words = 50, color = c('blue','red')) ## change colors
textstat_frequency(dtm, n = 10)             ## view the frequencies 
```

You can also inspect a subcorpus. For example, looking only at Obama speeches. To subset the DTM we can use quanteda's `dtm_subset()`, but we can also use the more general R subsetting techniques (as discussed last week). Here we'll use the latter for illustration.

With `docvars(dtm)` we get a data.frame with the document variables. With `docvars(dtm)$President`, we get the character vector with president names. Thus, with `docvars(dtm)$President == 'Barack Obama'` we look for all documents where the president was Obama. To make this more explicit, we store the logical vector, that shows which documents are 'TRUE', as is\_obama. We then use this to select these rows from the DTM.

``` r
is_obama = docvars(dtm)$President == 'Barack Obama' 
obama_dtm = dtm[is_obama,]
textplot_wordcloud(obama_dtm, max_words = 25)
```

Compare corpora
---------------

Compare word frequencies between two subcorpora. Here we (again) first use a comparison to get the is\_obama vector. We then use this in the `textstat_keyness()` function to indicate that we want to compare the Obama documents (where is\_obama is TRUE) to all other documents (where is\_obama is FALSE).

``` r
is_obama = docvars(dtm)$President == 'Barack Obama' 
ts = textstat_keyness(dtm, is_obama)
head(ts, 20)    ## view first 20 results
```

We can visualize these results, stored under the name `ts`, by using the textplot\_keyness function

``` r
textplot_keyness(ts)
```

Keyword-in-context
------------------

As seen in the first tutorial, a keyword-in-context listing shows a given keyword in the context of its use. This is a good help for interpreting words from a wordcloud or keyness plot.

Since a DTM only knows word frequencies, the `kwic()` function requires the corpus object as input.

``` r
k = kwic(corp, 'freedom', window = 7)
head(k, 10)    ## only view first 10 results
```

The `kwic()` function can also be used to focus an analysis on a specific search term. You can use the output of the kwic function to create a new DTM, in which only the words within the shown window are included in the DTM. With the following code, a DTM is created that only contains words that occur within 10 words from `terror*` (terrorism, terrorist, terror, etc.).

``` r
terror = kwic(corp, 'terror*')
terror_corp = corpus(terror)
terror_dtm = dfm(terror_corp, tolower=T, remove=stopwords('en'), stem=T, remove_punct=T)
```

Now you can focus an analysis on whether and how Presidents talk about `terror*`.

``` r
textplot_wordcloud(terror_dtm, max_words = 50)     ## top 50 (most frequent) words
```

Dictionary search
-----------------

You can perform a basic dictionary search. In terms of query options this is less advanced than AmCAT, but quanteda offers more ways to analyse the dictionary results. Also, it supports the use of existing dictionaries, for instance for sentiment analysis (but mostly for english dictionaries).

An convenient way of using dictionaries is to make a DTM with the columns representing dictionary terms.

``` r
dict = dictionary(list(terrorism = 'terror*',
                       economy = c('econom*', 'tax*', 'job*'),
                       military = c('army','navy','military','airforce','soldier'),
                       freedom = c('freedom','liberty')))
dict_dtm = dfm_lookup(dtm, dict, exclusive=TRUE)
dict_dtm 
```

The "4 features" are the four entries in our dictionary. Now you can perform all the analyses with dictionaries.

``` r
textplot_wordcloud(dict_dtm)
```

``` r
tk = textstat_keyness(dict_dtm, docvars(dict_dtm)$President == 'Barack Obama')
textplot_keyness(tk)
```

You can also convert the dtm to a data frame to get counts of each concept per document (which you can then match with e.g. survey data)

``` r
df = convert(dict_dtm, to="data.frame")
head(df)
```

Creating good dictionaries
--------------------------

A good dictionary means that all documents that match the dictionary are indeed about or contain the desired concept, and that all documents that contain the concept are matched.

To check this, you can manually annotate or code a sample of documents and compare the score with the dictionary hits.

You can also apply the keyword-in-context function to a dictionary to quickly check a set of matches and see if they make sense:

``` r
kwic(corp, dict$terrorism)
```
