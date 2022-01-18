R text analysis: quanteda
================
Kasper Welbers, Wouter van Atteveldt & Philipp Masur
2021-10

-   [Introduction](#introduction)
    -   [The quanteda package](#the-quanteda-package)
-   [Step 1: Importing text and creating a quanteda
    corpus](#step-1-importing-text-and-creating-a-quanteda-corpus)
    -   [From CSV files](#from-csv-files)
    -   [From text (or word/pdf) files](#from-text-or-wordpdf-files)
-   [Step 2: Creating the DTM (or DFM)](#step-2-creating-the-dtm-or-dfm)
    -   [Preprocessing/cleaning DTMs](#preprocessingcleaning-dtms)
    -   [Filtering the DTM](#filtering-the-dtm)
-   [Step 3: Analysis](#step-3-analysis)
    -   [Word frequencies and
        wordclouds](#word-frequencies-and-wordclouds)
    -   [Compare corpora](#compare-corpora)
    -   [Keyword-in-context](#keyword-in-context)
    -   [Dictionary search](#dictionary-search)
    -   [Creating good dictionaries](#creating-good-dictionaries)

# Introduction

In this tutorial you will learn how to perform text analysis using the
quanteda package. In the [R Basics: getting
started](R_basics_1_getting_started.md) tutorial we introduced some of
the techniques from this tutorial as a light introduction to R. In this
and the following tutorials, the goal is to get more understanding of
what actually happens ‘under the hood’ and which choices can be made,
and to become more confident and proficient in using quanteda for text
analysis.

## The quanteda package

The [quanteda package](https://quanteda.io/) is an extensive text
analysis suite for R. It covers everything you need to perform a variety
of automatic text analysis techniques, and features clear and extensive
documentation. Here we’ll focus on the main preparatory steps for text
analysis, and on learning how to browse the quanteda documentation. The
documentation for each function can also be found
[here](https://quanteda.io/reference/index.html).

For a more detailed explanation of the steps discussed here, you can
read the paper [Text Analysis in
R](http://vanatteveldt.com/p/welbers-text-r.pdf) (Welbers, van Atteveldt
& Benoit, 2017).

``` r
library(quanteda)
library(quanteda.textplots)
library(quanteda.textstats)
```

# Step 1: Importing text and creating a quanteda corpus

The first step is getting text into R in a proper format. stored in a
variety of formats, from plain text and CSV files to HTML and PDF, and
with different ‘encodings’. There are various packages for reading these
file formats, and there is also the convenient
[readtext](https://cran.r-project.org/web/packages/readtext/vignettes/readtext_vignette.html)
that is specialized for reading texts from a variety of formats.

## From CSV files

For this tutorial, we will be importing text from a csv. For
convenience, we’re using a csv that’s available online, but the process
is the same for a csv file on your own computer. The data consists of
the State of the Union speeches of US presidents, with each document
(i.e. row in the csv) being a paragraph. The data will be imported as a
data.frame.

``` r
library(tidyverse)
url <- 'https://bit.ly/2QoqUQS'
d <- read_csv(url)
head(d)   ## view first 6 rows
```

    ## # A tibble: 6 × 5
    ##   paragraph date       President         Party text                             
    ##       <dbl> <date>     <chr>             <chr> <chr>                            
    ## 1         1 1790-01-08 George Washington Other I embrace with great satisfactio…
    ## 2         2 1790-01-08 George Washington Other In resuming your consultations f…
    ## 3         3 1790-01-08 George Washington Other Among the many interesting objec…
    ## 4         4 1790-01-08 George Washington Other A free people ought not only to …
    ## 5         5 1790-01-08 George Washington Other The proper establishment of the …
    ## 6         6 1790-01-08 George Washington Other There was reason to hope that th…

We can now create a quanteda corpus with the `corpus()` function. If you
want to learn more about this function, recall that you can use the
question mark to look at the documentation.

``` r
?corpus
```

Here you see that for a data.frame, we need to specify which column
contains the text field. Also, the text column must be a character
vector.

``` r
corp <- corpus(d, text_field = 'text')  ## create the corpus
corp
```

    ## Corpus consisting of 23,469 documents and 4 docvars.
    ## text1 :
    ## "I embrace with great satisfaction the opportunity which now ..."
    ## 
    ## text2 :
    ## "In resuming your consultations for the general good you can ..."
    ## 
    ## text3 :
    ## "Among the many interesting objects which will engage your at..."
    ## 
    ## text4 :
    ## "A free people ought not only to be armed, but disciplined; t..."
    ## 
    ## text5 :
    ## "The proper establishment of the troops which may be deemed i..."
    ## 
    ## text6 :
    ## "There was reason to hope that the pacific measures adopted w..."
    ## 
    ## [ reached max_ndoc ... 23,463 more documents ]

## From text (or word/pdf) files

Rather than a csv file, your texts might be stored as separate files,
e.g. as .txt, .pdf, or .docx files. You can quite easily read these as
well with the `readtext` function from the `readtext` package. You might
have to install that package first with:

``` r
install.packages("readtext")
```

You can then call the readtext function on a particular file, or on a
folder or zip archive of files directly.

``` r
library(readtext)
url <- "https://github.com/ccs-amsterdam/r-course-material/blob/master/data/files.zip?raw=true"
texts <- readtext(url)
texts
```

    ## readtext object consisting of 2 documents and 0 docvars.
    ## # Description: df [2 × 2]
    ##   doc_id        text               
    ##   <chr>         <chr>              
    ## 1 document.docx "\"This is a \"..."
    ## 2 pdf_file.pdf  "\"This is a \"..."

As you can see, it automatically downloaded and unzipped the files, and
converted the MS Word and PDF files into plain text.

I read them from an online source here, but you can also read them from
your hard drive by specifying the path:

``` r
texts <- reattext("c:/path/to/files")
texts <- reattext("/Users/me/Documents/files")
```

You can convert the texts directly into a corpus object as above:

``` r
corp2 <- corpus(texts)
corp2
```

    ## Corpus consisting of 2 documents.
    ## document.docx :
    ## "This is a word document"
    ## 
    ## pdf_file.pdf :
    ## "This is a PDF file"

# Step 2: Creating the DTM (or DFM)

Many text analysis techniques only use the frequencies of words in
documents. This is also called the bag-of-words assumption, because
texts are then treated as bags of individual words. Despite ignoring
much relevant information in the order of words and syntax, this
approach has proven to be very powerfull and efficient.

The standard format for representing a bag-of-words is as a
`document-term matrix` (DTM). This is a matrix in which rows are
documents, columns are terms, and cells indicate how often each term
occured in each document. We’ll first create a small example DTM from a
few lines of text. Here we use quanteda’s `dfm()` function, which stands
for `document-feature matrix` (DFM), which is a more general form of a
DTM.

``` r
# An example data set
text <-  c(d1 = "Cats are awesome!",
           d2 = "We need more cats!",
           d3 = "This is a soliloquy about a cat.")

# Tokenise text
text2 <- tokens(text)
text2
```

    ## Tokens consisting of 3 documents.
    ## d1 :
    ## [1] "Cats"    "are"     "awesome" "!"      
    ## 
    ## d2 :
    ## [1] "We"   "need" "more" "cats" "!"   
    ## 
    ## d3 :
    ## [1] "This"      "is"        "a"         "soliloquy" "about"     "a"        
    ## [7] "cat"       "."

``` r
# Construct the document-feature matrix based on the tokenised text
dtm <- dfm(text2)
dtm
```

    ## Document-feature matrix of: 3 documents, 14 features (61.90% sparse) and 0 docvars.
    ##     features
    ## docs cats are awesome ! we need more this is a
    ##   d1    1   1       1 1  0    0    0    0  0 0
    ##   d2    1   0       0 1  1    1    1    0  0 0
    ##   d3    0   0       0 0  0    0    0    1  1 2
    ## [ reached max_nfeat ... 4 more features ]

Here you see, for instance, that the word `are` only occurs in the first
document. In this matrix format, we can perform calculations with texts,
like analyzing different sentiments of frames regarding cats, or the
computing the similarity between the third sentence and the first two
sentences.

## Preprocessing/cleaning DTMs

However, directly converting a text to a DTM is a bit crude. Note, for
instance, that the words `Cats`, `cats`, and `cat` are given different
columns. In this DTM, “Cats” and “awesome” are as different as “Cats”
and “cats”, but for many types of analysis we would be more interested
in the fact that both texts are about felines, and not about the
specific word that is used. Also, for performance it can be useful (or
even necessary) to use fewer columns, and to ignore less interesting
words such as `is` or very rare words such as `soliloquy`.

This can be achieved by using additional `preprocessing` steps. In the
next example, we’ll again create the DTM, but this time we make all text
lowercase, ignore stopwords and punctuation, and perform `stemming`.
Simply put, stemming removes some parts at the ends of words to ignore
different forms of the same word, such as singular versus plural (“gun”
or “gun-s”) and different verb forms (“walk”,“walk-ing”,“walk-s”)

``` r
text2 <- text |>
  tokens(remove_punct = T, remove_numbers = T, remove_symbols = T) |>   ## tokenize, removing unnecessary noise
  tokens_tolower() |>                                                   ## normalize
  tokens_remove(stopwords('en')) |>                                     ## remove stopwords (English)
  tokens_wordstem()                                                      ## stemming
text2
```

    ## Tokens consisting of 3 documents.
    ## d1 :
    ## [1] "cat"    "awesom"
    ## 
    ## d2 :
    ## [1] "need" "cat" 
    ## 
    ## d3 :
    ## [1] "soliloquy" "cat"

``` r
dtm <- dfm(text2)
dtm
```

    ## Document-feature matrix of: 3 documents, 4 features (50.00% sparse) and 0 docvars.
    ##     features
    ## docs cat awesom need soliloquy
    ##   d1   1      1    0         0
    ##   d2   1      0    1         0
    ##   d3   1      0    0         1

By now you should be able to understand better how the arguments in this
function work. The `tolower` argument determines whether texts are
(`TRUE`) or aren’t (`FALSE`) converted to lowercase. `stem` determines
whether stemming is (`TRUE`) or isn’t (`FALSE`) used. The remove
argument is a bit more tricky. If you look at the documentation for the
dfm function (`?dfm`) you’ll see that `remove` can be used to give “a
pattern of user-supplied features to ignore”. In this case, we actually
used another function, `stopwords()`, to get a list of english
stopwords. You can see for yourself.

``` r
stopwords('en')
```

    ##   [1] "i"          "me"         "my"         "myself"     "we"        
    ##   [6] "our"        "ours"       "ourselves"  "you"        "your"      
    ##  [11] "yours"      "yourself"   "yourselves" "he"         "him"       
    ##  [16] "his"        "himself"    "she"        "her"        "hers"      
    ##  [21] "herself"    "it"         "its"        "itself"     "they"      
    ##  [26] "them"       "their"      "theirs"     "themselves" "what"      
    ##  [31] "which"      "who"        "whom"       "this"       "that"      
    ##  [36] "these"      "those"      "am"         "is"         "are"       
    ##  [41] "was"        "were"       "be"         "been"       "being"     
    ##  [46] "have"       "has"        "had"        "having"     "do"        
    ##  [51] "does"       "did"        "doing"      "would"      "should"    
    ##  [56] "could"      "ought"      "i'm"        "you're"     "he's"      
    ##  [61] "she's"      "it's"       "we're"      "they're"    "i've"      
    ##  [66] "you've"     "we've"      "they've"    "i'd"        "you'd"     
    ##  [71] "he'd"       "she'd"      "we'd"       "they'd"     "i'll"      
    ##  [76] "you'll"     "he'll"      "she'll"     "we'll"      "they'll"   
    ##  [81] "isn't"      "aren't"     "wasn't"     "weren't"    "hasn't"    
    ##  [86] "haven't"    "hadn't"     "doesn't"    "don't"      "didn't"    
    ##  [91] "won't"      "wouldn't"   "shan't"     "shouldn't"  "can't"     
    ##  [96] "cannot"     "couldn't"   "mustn't"    "let's"      "that's"    
    ## [101] "who's"      "what's"     "here's"     "there's"    "when's"    
    ## [106] "where's"    "why's"      "how's"      "a"          "an"        
    ## [111] "the"        "and"        "but"        "if"         "or"        
    ## [116] "because"    "as"         "until"      "while"      "of"        
    ## [121] "at"         "by"         "for"        "with"       "about"     
    ## [126] "against"    "between"    "into"       "through"    "during"    
    ## [131] "before"     "after"      "above"      "below"      "to"        
    ## [136] "from"       "up"         "down"       "in"         "out"       
    ## [141] "on"         "off"        "over"       "under"      "again"     
    ## [146] "further"    "then"       "once"       "here"       "there"     
    ## [151] "when"       "where"      "why"        "how"        "all"       
    ## [156] "any"        "both"       "each"       "few"        "more"      
    ## [161] "most"       "other"      "some"       "such"       "no"        
    ## [166] "nor"        "not"        "only"       "own"        "same"      
    ## [171] "so"         "than"       "too"        "very"       "will"

This list of words is thus passed to the `remove` argument in the
`dfm()` to ignore these words. If you are using texts in another
language, make sure to specify the language, such as stopwords(‘nl’) for
Dutch or stopwords(‘de’) for German.

There are various alternative preprocessing techniques, including more
advanced techniques that are not implemented in quanteda. Whether, when
and how to use these techniques is a broad topic that we won’t cover
today. For more details about preprocessing you can read the [Text
Analysis in R](http://vanatteveldt.com/p/welbers-text-r.pdf) paper cited
above.

## Filtering the DTM

For this tutorial, we’ll use the State of the Union speeches. We already
created the corpus above. We can now pass this corpus to the `dfm()`
function and set the preprocessing parameters.

``` r
dtm <- corp |>
  tokens(remove_punct = T, remove_numbers = T, remove_symbols = T) |>   
  tokens_tolower() |>                                                    
  tokens_remove(stopwords('en')) |>                                     
  tokens_wordstem() |>
  dfm()
dtm
```

    ## Document-feature matrix of: 23,469 documents, 16,032 features (99.78% sparse) and 4 docvars.
    ##        features
    ## docs    embrac great satisfact opportun now present congratul favor prospect
    ##   text1      1     1         1        1   1       2         1     1        1
    ##   text2      0     0         0        0   0       1         0     0        0
    ##   text3      0     0         0        0   0       0         0     0        0
    ##   text4      0     0         0        0   0       0         0     0        0
    ##   text5      0     0         0        0   0       0         0     0        0
    ##   text6      0     0         0        0   0       0         0     0        0
    ##        features
    ## docs    public
    ##   text1      1
    ##   text2      0
    ##   text3      0
    ##   text4      0
    ##   text5      0
    ##   text6      0
    ## [ reached max_ndoc ... 23,463 more documents, reached max_nfeat ... 16,022 more features ]

This dtm has 23,469 documents and 20,429 features (i.e. terms), and no
longer shows the actual matrix because it simply wouldn’t fit. Depending
on the type of analysis that you want to conduct, we might not need this
many words, or might actually run into computational limitations.

Luckily, many of these 20K features are not that informative. The
distribution of term frequencies tends to have a very long tail, with
many words occuring only once or a few times in our corpus. For many
types of bag-of-words analysis it would not harm to remove these words,
and it might actually improve results.

We can use the `dfm_trim` function to remove columns based on criteria
specified in the arguments. Here we say that we want to remove all terms
for which the frequency (i.e. the sum value of the column in the DTM) is
below 10.

``` r
dtm <- dfm_trim(dtm, min_termfreq = 10)
dtm
```

    ## Document-feature matrix of: 23,469 documents, 5,027 features (99.33% sparse) and 4 docvars.
    ##        features
    ## docs    embrac great satisfact opportun now present congratul favor prospect
    ##   text1      1     1         1        1   1       2         1     1        1
    ##   text2      0     0         0        0   0       1         0     0        0
    ##   text3      0     0         0        0   0       0         0     0        0
    ##   text4      0     0         0        0   0       0         0     0        0
    ##   text5      0     0         0        0   0       0         0     0        0
    ##   text6      0     0         0        0   0       0         0     0        0
    ##        features
    ## docs    public
    ##   text1      1
    ##   text2      0
    ##   text3      0
    ##   text4      0
    ##   text5      0
    ##   text6      0
    ## [ reached max_ndoc ... 23,463 more documents, reached max_nfeat ... 5,017 more features ]

Now we have about 5000 features left. See `?dfm_trim` for more options.

# Step 3: Analysis

Using the dtm we can now employ various techniques. You’ve already seen
some of them in the introduction tutorial, but by now you should be able
to understand more about the R syntax, and understand how to tinker with
different parameters.

## Word frequencies and wordclouds

Get most frequent words in corpus.

``` r
textplot_wordcloud(dtm, max_words = 50)     ## top 50 (most frequent) words
textplot_wordcloud(dtm, max_words = 50, color = c('blue','red')) ## change colors
textstat_frequency(dtm, n = 10)             ## view the frequencies 
```

    ##     feature frequency rank docfreq group
    ## 1     state      9234    1    5580   all
    ## 2    govern      8581    2    5553   all
    ## 3      year      7250    3    4934   all
    ## 4    nation      6733    4    4847   all
    ## 5  congress      5689    5    4494   all
    ## 6      unit      5223    6    3715   all
    ## 7       can      4731    7    3628   all
    ## 8   countri      4664    8    3612   all
    ## 9     peopl      4477    9    3388   all
    ## 10     upon      4168   10    3004   all

You can also inspect a subcorpus. For example, looking only at Obama
speeches. To subset the DTM we can use quanteda’s `dtm_subset()`, but we
can also use the more general R subsetting techniques (as discussed last
week). Here we’ll use the latter for illustration.

With `docvars(dtm)` we get a data.frame with the document variables.
With `docvars(dtm)$President`, we get the character vector with
president names. Thus, with `docvars(dtm)$President == 'Barack Obama'`
we look for all documents where the president was Obama. To make this
more explicit, we store the logical vector, that shows which documents
are ‘TRUE’, as is\_obama. We then use this to select these rows from the
DTM.

``` r
is_obama <- docvars(dtm)$President == 'Barack Obama' 
obama_dtm <- dtm[is_obama,]
textplot_wordcloud(obama_dtm, max_words = 25)
```

## Compare corpora

Compare word frequencies between two subcorpora. Here we (again) first
use a comparison to get the is\_obama vector. We then use this in the
`textstat_keyness()` function to indicate that we want to compare the
Obama documents (where is\_obama is TRUE) to all other documents (where
is\_obama is FALSE).

``` r
is_obama <- docvars(dtm)$President == 'Barack Obama' 
ts <- textstat_keyness(dtm, is_obama)
head(ts, 20)    ## view first 20 results
```

    ##       feature      chi2 p n_target n_reference
    ## 1         job 1973.4887 0      203         626
    ## 2         get 1229.2753 0      121         355
    ## 3         kid  621.0179 0       31          34
    ## 4      colleg  590.3294 0       57         160
    ## 5     tonight  507.9058 0       82         400
    ## 6        know  489.3740 0      108         695
    ## 7  small-busi  483.5821 0       14           3
    ## 8     america  452.2741 0      170        1644
    ## 9      afghan  430.1750 0       17          11
    ## 10 republican  403.2612 0       41         121
    ## 11   american  368.1350 0      245        3385
    ## 12   laughter  355.2143 0       28          60
    ## 13    student  343.7875 0       41         144
    ## 14      clean  343.5098 0       35         103
    ## 15      innov  341.3723 0       27          58
    ## 16   trillion  326.7499 0       16          16
    ## 17       folk  320.3036 0       14          11
    ## 18       help  308.5411 0      126        1289
    ## 19     invest  296.6455 0       72         501
    ## 20    deficit  296.5389 0       56         315

We can visualize these results, stored under the name `ts`, by using the
textplot\_keyness function

``` r
textplot_keyness(ts)
```

## Keyword-in-context

As seen in the first tutorial, a keyword-in-context listing shows a
given keyword in the context of its use. This is a good help for
interpreting words from a wordcloud or keyness plot.

Since a DTM only knows word frequencies, the `kwic()` function requires
a tokenized corpus object as input.

``` r
k <- kwic(tokens(corp), 'freedom', window = 7)
head(k, 10)    ## only view first 10 results
```

    ## Keyword-in-context with 10 matches.                                                                              
    ##   [text126, 62]            without harmony as far as consists with | freedom |
    ##   [text357, 84]                 a wide spread for the blessings of | freedom |
    ##   [text466, 84]       commerce of the United States its legitimate | freedom |
    ##   [text481, 89]          of cheaper materials and subsistence, the | freedom |
    ##   [text483, 23]            payment of the public debt whenever the | freedom |
    ##   [text626, 32]           its progress a force proportioned to its | freedom |
    ##   [text626, 46]                  these States, the guardian of the | freedom |
    ##   [text707, 98]                  over the purity of elections, the | freedom |
    ##  [text739, 152] important circumstance connected with it with that | freedom |
    ##   [text790, 75]               will acquire new force and a greater | freedom |
    ##                                          
    ##  of sentiment its dignity may be lost    
    ##  and equal laws.                         
    ##  . The instructions to our ministers with
    ##  of labor from taxation with us,         
    ##  and safety of our commerce shall be     
    ##  , and that the union of these           
    ##  and safety of all and of each           
    ##  of speech and of the press,             
    ##  and candor which a regard for the       
    ##  of action within its proper sphere.

The `kwic()` function can also be used to focus an analysis on a
specific search term. You can use the output of the kwic function to
create a new DTM, in which only the words within the shown window are
included in the DTM. With the following code, a DTM is created that only
contains words that occur within 10 words from `terror*` (terrorism,
terrorist, terror, etc.).

``` r
terror <- kwic(tokens(corp), 'terror*')
terror_corp <- corpus(terror)
terror_dtm <- terror_corp %>%
  tokens(remove_punct = T, remove_numbers = T, remove_symbols = T) %>%   
  tokens_tolower %>%                                                    
  tokens_remove(stopwords('en')) %>%                                     
  tokens_wordstem %>%
  dfm
```

Now you can focus an analysis on whether and how Presidents talk about
`terror*`.

``` r
textplot_wordcloud(terror_dtm, max_words = 50)     ## top 50 (most frequent) words
```

## Dictionary search

You can perform a basic dictionary search. In terms of query options
this is less advanced than AmCAT, but quanteda offers more ways to
analyse the dictionary results. Also, it supports the use of existing
dictionaries, for instance for sentiment analysis (but mostly for
english dictionaries).

An convenient way of using dictionaries is to make a DTM with the
columns representing dictionary terms.

``` r
dict <- dictionary(list(terrorism = 'terror*',
                       economy = c('econom*', 'tax*', 'job*'),
                       military = c('army','navy','military','airforce','soldier'),
                       freedom = c('freedom','liberty')))
dict_dtm <- dfm_lookup(dtm, dict, exclusive=TRUE)
dict_dtm 
```

    ## Document-feature matrix of: 23,469 documents, 4 features (95.55% sparse) and 4 docvars.
    ##        features
    ## docs    terrorism economy military freedom
    ##   text1         0       0        0       0
    ##   text2         0       0        0       0
    ##   text3         0       0        0       0
    ##   text4         0       0        0       0
    ##   text5         0       1        1       0
    ##   text6         0       0        0       0
    ## [ reached max_ndoc ... 23,463 more documents ]

The “4 features” are the four entries in our dictionary. Now you can
perform all the analyses with dictionaries.

``` r
textplot_wordcloud(dict_dtm)
```

``` r
tk <- textstat_keyness(dict_dtm, docvars(dict_dtm)$President == 'Barack Obama')
textplot_keyness(tk)
```

You can also convert the dtm to a data frame to get counts of each
concept per document (which you can then match with e.g. survey data)

``` r
df <- convert(dict_dtm, to="data.frame")
head(df)
```

    ##   doc_id terrorism economy military freedom
    ## 1  text1         0       0        0       0
    ## 2  text2         0       0        0       0
    ## 3  text3         0       0        0       0
    ## 4  text4         0       0        0       0
    ## 5  text5         0       1        1       0
    ## 6  text6         0       0        0       0

## Creating good dictionaries

A good dictionary means that all documents that match the dictionary are
indeed about or contain the desired concept, and that all documents that
contain the concept are matched.

To check this, you can manually annotate or code a sample of documents
and compare the score with the dictionary hits.

You can also apply the keyword-in-context function to a dictionary to
quickly check a set of matches and see if they make sense:

``` r
kwic(corp, dict$terrorism)
```

    ## Keyword-in-context with 259 matches.                                                                             
    ##     [text735, 80]                , will henceforth lose their |   terror    |
    ##   [text1433, 236]              has disarmed revolution of its |   terrors   |
    ##    [text1614, 86]                     which it has spread its |   terrors   |
    ##    [text3087, 62]                    are a source of constant |   terror    |
    ##    [text4388, 29]                  general insecurity, by the |   terror    |
    ##   [text4987, 102]             enough were committed to spread |   terror    |
    ##     [text6032, 9]                    Puritan, Amphitrite, and |   Terror    |
    ##     [text6177, 9]       the double-turreted monitors Puritan, |   Terror    |
    ##    [text6590, 41]                  been the cause of constant |   terror    |
    ##    [text7489, 28]            , and the coast-defense monitors |   Terror    |
    ##   [text9223, 142]                    . The peace of tyrannous |   terror    |
    ##  [text10929, 300]                   in saving from the German |   terror    |
    ##   [text10975, 98]                        , with its blood and |   terror    |
    ##   [text11289, 15]             dealing with other countries by |   terror    |
    ##  [text12376, 123]         prevailing mental attitude with the |   terror    |
    ##   [text12680, 34]                         only in the hope of | terrorizing |
    ##   [text12933, 44]                  having been crushed by the |   terror    |
    ##   [text12949, 13]                of the Nazi-Fascist reign of |   terror    |
    ##   [text13095, 44]                  having been crushed by the |   terror    |
    ##   [text13133, 13]                of the Nazi-Fascist reign of |   terror    |
    ##   [text13152, 13]                of the Nazi-Fascist reign of |   terror    |
    ##   [text13155, 33]                 the end of the Nazi-Fascist |   terror    |
    ##   [text14343, 41]                    unlimited; a world where |   terror    |
    ##   [text15116, 34]                         world but an Age of |   Terror    |
    ##   [text15723, 31]                   of science instead of its |   terrors   |
    ##   [text15822, 26]                is increasing his tactics of |   terror    |
    ##   [text16341, 37]                       the South. Attack and |   terror    |
    ##   [text16350, 48]         elections without violence, without |   terror    |
    ##   [text16361, 42]               they can amidst the uncertain |   terrors   |
    ##   [text16532, 28]                        the use of force and |   terror    |
    ##   [text16537, 30]                 And this means reducing the |  terrorism  |
    ##   [text16857, 50]                      deafened by noise, and | terrorized  |
    ##   [text17844, 44]                          , the riots, urban |  terrorism  |
    ##   [text20109, 17]                captive, innocent victims of |  terrorism  |
    ##   [text20109, 49]               two acts one of international |  terrorism  |
    ##   [text20788, 43]               region of both repression and |  terrorism  |
    ##   [text20991, 45]               Toward those who would export |  terrorism  |
    ##  [text21150, 102]         peace in Lebanon by state-sponsored |  terrorism  |
    ##  [text21150, 132]        legislative proposals to help combat |  terrorism  |
    ##   [text21238, 35]            and provides bases for Communist | terrorists  |
    ##   [text21252, 31]               Seeing another girl freeze in |   terror    |
    ##   [text21259, 98]             increase in espionage and state |   terror    |
    ##  [text21265, 160]                  from the prison of nuclear |   terror    |
    ##  [text21288, 247]                        nor will we yield to |  terrorist  |
    ##   [text21309, 81]         of both totalitarianism and nuclear |   terror    |
    ##   [text21349, 22]                    a future free of nuclear |   terror    |
    ##   [text21484, 54] through tragic and despicable environmental |  terrorism  |
    ##   [text21651, 16]             against the violent crime which | terrorizes  |
    ##   [text21733, 46]             cripple the world's cities with |   terror    |
    ##    [text21734, 8]            , we secured indictments against | terrorists  |
    ##   [text21772, 20]                     in the United States of |  terrorist  |
    ##   [text21772, 64]                   a global effort to combat |  terrorism  |
    ##   [text21772, 75]                      future to be marred by |   terror    |
    ##   [text21841, 15]            strengthen our hand in combating | terrorists  |
    ##   [text21841, 42]                 this country will hunt down | terrorists  |
    ##    [text21842, 7]               this week, another horrendous |  terrorist  |
    ##   [text21842, 67]                         go forward. But the | terrorists  |
    ##   [text21931, 17]                            . Think of them: |  terrorism  |
    ##   [text21939, 34]             can intensify the fight against | terrorists  |
    ##   [text22036, 92]                drug traffickers and to stop | terrorists  |
    ##   [text22037, 40]                       will help us to fight |  terrorism  |
    ##   [text22040, 58]          conflicts that fuel fanaticism and |   terror    |
    ##   [text22052, 74]                    axis of new threats from | terrorists  |
    ##   [text22105, 19]                      and the outlaw states, | terrorists  |
    ##   [text22107, 36]                         a weapon of war and |   terror    |
    ##   [text22135, 16]                   to destroy its weapons of |   terror    |
    ##   [text22152, 33]                     woman called" the stark |   terror    |
    ##   [text22215, 24]             dangers from outlaw nations and |  terrorism  |
    ##   [text22215, 50]                Usama bin Ladin's network of |   terror    |
    ##    [text22216, 6]                        We must work to keep | terrorists  |
    ##   [text22228, 21]                      we pursue peace, fight |  terrorism  |
    ##   [text22259, 16]             march of technology from giving | terrorists  |
    ##   [text22259, 54]                    can also make weapons of |   terror    |
    ##    [text22339, 6]       When Slobodan Milosevic unleashed his |   terror    |
    ##   [text22341, 45]              , the narcotraffickers and the | terrorists  |
    ##   [text22436, 29]                    certain. They range from | terrorists  |
    ##    [text22449, 8]          Afghanistan are now allies against |   terror    |
    ##   [text22451, 16]             coalition partners, hundreds of | terrorists  |
    ##   [text22451, 28]                tens of thousands of trained | terrorists  |
    ##   [text22451, 65]                   so long as nations harbor | terrorists  |
    ##   [text22452, 10]             to prevent regimes that sponsor |   terror    |
    ##    [text22453, 4]                                  Our war on |   terror    |
    ##   [text22453, 50]                        we stop now, leaving |   terror    |
    ##   [text22453, 54]             leaving terror camps intact and |  terrorist  |
    ##   [text22459, 49]                   the world of thousands of | terrorists  |
    ##   [text22459, 53]      of terrorists, destroyed Afghanistan's |  terrorist  |
    ##   [text22460, 12]                       our Embassy in Kabul. | Terrorists  |
    ##   [text22460, 25]                      at Guantanamo Bay. And |  terrorist  |
    ##   [text22462, 64]                      are winning the war on |   terror    |
    ##   [text22465, 18]                      there, our war against |   terror    |
    ##   [text22466, 26]                         , we will shut down |  terrorist  |
    ##   [text22466, 30]               down terrorist camps, disrupt |  terrorist  |
    ##   [text22466, 35]                  terrorist plans, and bring | terrorists  |
    ##   [text22466, 46]                       , we must prevent the | terrorists  |
    ##    [text22467, 6]                    Our military has put the |   terror    |
    ##   [text22467, 27]                        a dozen countries. A |  terrorist  |
    ##   [text22468, 34]                    armed forces to go after |  terrorist  |
    ##   [text22468, 56]              the Bosnian Government, seized | terrorists  |
    ##   [text22468, 83]            weapons and the establishment of |  terrorist  |
    ##   [text22469, 14]                  our call and eliminate the |  terrorist  |
    ##   [text22469, 36]                     is now cracking down on |   terror    |
    ##   [text22469, 58]                        timid in the face of |   terror    |
    ##    [text22471, 8]           pursues these weapons and exports |   terror    |
    ##   [text22472, 12]               toward America and to support |   terror    |
    ##    [text22473, 6]                 States like these and their |  terrorist  |
    ##   [text22473, 45]                 could provide these arms to | terrorists  |
    ##   [text22474, 10]                  with our coalition to deny | terrorists  |
    ##   [text22494, 68]                  applied to our war against |  terrorism  |
    ##   [text22506, 48]                     world beyond the war on |   terror    |
    ##   [text22507, 80]              demonstrate that the forces of |   terror    |
    ##   [text22515, 21]        countries have uncovered and stopped |  terrorist  |
    ##    [text22516, 4]                             Our war against |   terror    |
    ##   [text22517, 10]                        danger in the war on |   terror    |
    ##   [text22517, 45]                 such weapons for blackmail, |   terror    |
    ##   [text22517, 60]                    or sell those weapons to |  terrorist  |
    ##   [text22527, 30]                       job. After recession, |  terrorist  |
    ##   [text22555, 33]           the manmade evil of international |  terrorism  |
    ##   [text22556, 16]                       news about the war on |   terror    |
    ##  [text22557, 102]                 , more than 3,000 suspected | terrorists  |
    ##    [text22558, 4]                                 We have the | terrorists  |
    ##   [text22558, 21]                             One by one, the | terrorists  |
    ##   [text22561, 23]                    to track and disrupt the | terrorists  |
    ##   [text22561, 68]                     of Defense to develop a |  Terrorist  |
    ##   [text22563, 24]                gain the ultimate weapons of |   terror    |
    ##   [text22566, 29]              mass destruction, and supports |   terror    |
    ##   [text22568, 41]                    aggression, with ties to |  terrorism  |
    ##   [text22578, 68]            Saddam Hussein aids and protects | terrorists  |
    ##   [text22578, 90]                    of his hidden weapons to | terrorists  |
    ##   [text22579, 27]                 lethal viruses, and shadowy |  terrorist  |
    ##   [text22580, 17]                   imminent. Since when have | terrorists  |
    ##   [text22583, 90]                          , and its links to |  terrorist  |
    ##    [text22593, 7]               part of the offensive against |   terror    |
    ##   [text22593, 19]             regimes that harbor and support | terrorists  |
    ##   [text22596, 62]                    , confront the allies of |   terror    |
    ##   [text22602, 24]                         world in the war on |   terror    |
    ##   [text22603, 12]      and intelligence officers are tracking |  terrorist  |
    ##   [text22605, 34]              to the dangerous illusion that | terrorists  |
    ##   [text22607, 80]                          , and Baghdad. The | terrorists  |
    ##   [text22608, 53]           better share information to track | terrorists  |
    ##   [text22608, 97]             even more important for hunting | terrorists  |
    ##   [text22609, 15]                       expire next year. The |  terrorist  |
    ##    [text22610, 8]                on the offensive against the | terrorists  |
    ##   [text22610, 51]                  brought the capture of the |  terrorist  |
    ##  [text22610, 126]                       , we will bring these | terrorists  |
    ##  [text22611, 109]                 free and proud and fighting |   terror    |
    ##   [text22613, 40]                  killers, joined by foreign | terrorists  |
    ##   [text22620, 45]                          and win the war on |   terror    |
    ##   [text22621, 19]                           at all. They view |  terrorism  |
    ##   [text22621, 71]                        was not settled. The | terrorists  |
    ##  [text22621, 110]                      with legal papers. The | terrorists  |
    ##   [text22627, 25]             have come through recession and |  terrorist  |
    ##   [text22666, 12]                    commitment of the war on |   terror    |
    ##  [text22667, 112]               captured or detained Al Qaida | terrorists  |
    ##   [text22678, 97]                  border to drug dealers and | terrorists  |
    ##   [text22696, 41]               focused the FBI on preventing |  terrorism  |
    ##   [text22696, 52]            intelligence agencies, broken up |   terror    |
    ##   [text22697, 30]                    continuing. The Al Qaida |   terror    |
    ##   [text22697, 58]         governments that sponsor and harbor | terrorists  |
    ##   [text22697, 91]                      is still the target of | terrorists  |
    ##   [text22698, 47]               be the recruiting grounds for |   terror    |
    ##   [text22698, 51]                        for terror, and that |   terror    |
    ##   [text22698, 74]                     the rise of tyranny and |   terror    |
    ##   [text22698, 97]                         and that is why the |  terrorist  |
    ##   [text22701, 73]             help the Palestinian people end |   terror    |
    ##   [text22702, 29]                  fight the common threat of |   terror    |
    ##   [text22703, 18]             regimes that continue to harbor | terrorists  |
    ##   [text22703, 39]                       Lebanon to be used by | terrorists  |
    ##   [text22703, 75]                      to end all support for |   terror    |
    ##   [text22703, 93]            world's primary state sponsor of |   terror    |
    ##  [text22703, 141]                     and end its support for |   terror    |
    ##   [text22704, 35]                         front in the war on |   terror    |
    ##   [text22704, 41]                          , which is why the | terrorists  |
    ##   [text22704, 58]               women in uniform are fighting | terrorists  |
    ##   [text22704, 89]                          ally in the war on |   terror    |
    ##    [text22708, 2]                                         The | terrorists  |
    ##   [text22708, 19]                          attack it. Yet the | terrorists  |
    ##   [text22711, 83]             because that would embolden the | terrorists  |
    ##   [text22713, 55]                 be on the frontline against |   terror    |
    ##   [text22717, 76]          our country. Dictatorships shelter | terrorists  |
    ##  [text22717, 112]                  and join the fight against |   terror    |
    ##   [text22718, 60]                   And third, we're striking |  terrorist  |
    ##  [text22721, 107]                  and despair are sources of |  terrorism  |
    ##   [text22722, 33]                     been kept informed. The |  terrorist  |
    ##   [text22722, 39]     surveillance program has helped prevent |  terrorist  |
    ##   [text22731, 46]                   faith into an ideology of |   terror    |
    ##   [text22731, 50]                        of terror and death. | Terrorists  |
    ##   [text22732, 35]                  challenge us directly, the | terrorists  |
    ##   [text22732, 65]                        a bound captive, the | terrorists  |
    ##   [text22734, 60]             remain on the offensive against |   terror    |
    ##   [text22735, 19]            a National Assembly are fighting |   terror    |
    ##   [text22736, 66]             been relentless in shutting off |  terrorist  |
    ##    [text22741, 4]                       Our offensive against |   terror    |
    ##   [text22741, 19]                      only way to defeat the | terrorists  |
    ##   [text22742, 53]                      Israel, disarm, reject |  terrorism  |
    ##   [text22743, 32]             regime in that country sponsors | terrorists  |
    ##   [text22746, 10]             remain on the offensive against |  terrorism  |
    ##   [text22747, 83]                       - I have authorized a |  terrorist  |
    ##   [text22748, 10]                    - from the disruption of |   terror    |
    ##    [text22791, 5]                   Every success against the | terrorists  |
    ##    [text22793, 4]                                  The war on |   terror    |
    ##   [text22793, 71]                       council on the war on |   terror    |
    ##   [text22810, 79]            drug smugglers and criminals and | terrorists  |
    ##   [text22811, 47]                   to hostile regimes and to | terrorists  |
    ##   [text22817, 42]                    felt the sorrow that the | terrorists  |
    ##   [text22817, 84]                       a glimpse of what the | terrorists  |
    ##   [text22818, 48]                           to win the war on |   terror    |
    ##   [text22819, 45]                          long over. For the | terrorists  |
    ##   [text22820, 70]                  broke up a Southeast Asian |   terror    |
    ##  [text22820, 143]                  their lives to finding the | terrorists  |
    ##    [text22821, 6]                          In the mind of the | terrorists  |
    ##   [text22822, 36]                     country. By killing and | terrorizing |
    ##   [text22822, 79]                  this warning from the late |  terrorist  |
    ##   [text22823, 74]                 which is funding and arming | terrorists  |
    ##   [text22826, 58]                         kill us. What every |  terrorist  |
    ##   [text22827, 72]            people of Afghanistan defied the | terrorists  |
    ##   [text22828, 43]             the Cedar Revolution. Hizballah | terrorists  |
    ##   [text22830, 66]                          ally in the war on |   terror    |
    ##   [text22831, 97]                    city by chasing down the | terrorists  |
    ##  [text22831, 115]                    Province, where Al Qaida | terrorists  |
    ##  [text22831, 144]                     with orders to find the | terrorists  |
    ##   [text22853, 30]            that is confronting violence and |   terror    |
    ##  [text22856, 104]                   where they will fight the | terrorists  |
    ##  [text22884, 109]                    of liberty is opposed by | terrorists  |
    ##   [text22885, 13]                    taken the fight to these | terrorists  |
    ##   [text22886, 15]                       the 21st century. The | terrorists  |
    ##   [text22886, 33]                          Yet in this war on |   terror    |
    ##   [text22886, 64]             their own destinies will reject |   terror    |
    ##   [text22886, 77]                         And that is why the | terrorists  |
    ##    [text22887, 5]                                In Iraq, the | terrorists  |
    ##   [text22887, 94]                   strongholds, and deny the | terrorists  |
    ##   [text22888, 47]             neighborhoods, clearing out the | terrorists  |
    ##   [text22889, 64]               citizens who are fighting the | terrorists  |
    ##   [text22890, 51]                  A year later, high-profile |  terrorist  |
    ##   [text22893, 50]                      working, but among the | terrorists  |
    ##   [text22899, 72]                     , a partner in fighting |   terror    |
    ##   [text22900, 17]                   strengthen Iran, and give | terrorists  |
    ##   [text22901, 31]   President who recognizes that confronting |   terror    |
    ##   [text22902, 57]               in Iraq, supporting Hizballah | terrorists  |
    ##   [text22903, 87]                    , cease your support for |   terror    |
    ##  [text22904, 115]                       and night to stop the | terrorists  |
    ##   [text22905, 37]                   is the ability to monitor |  terrorist  |
    ##   [text22905, 50]                        need to know who the | terrorists  |
    ##  [text22905, 103]                      , our ability to track |  terrorist  |
    ##   [text22977, 33]                    because I will not allow | terrorists  |
    ##   [text22980, 59]            and certain justice for captured | terrorists  |
    ##   [text22982, 36]                     the 21st century - from |  terrorism  |
    ##  [text22997, 133]                      fall into the hands of | terrorists  |
    ##   [text23065, 22]                    renewed our focus on the | terrorists  |
    ##   [text23170, 61]                      fall into the hands of | terrorists  |
    ##   [text23302, 99]               detention, and prosecution of | terrorists  |
    ##   [text23361, 99]                       who take the fight to | terrorists  |
    ##  [text23361, 126]            take direct action against those | terrorists  |
    ##   [text23393, 84]                       not: our resolve that | terrorists  |
    ##   [text23394, 34]                     Bay. Because we counter |  terrorism  |
    ##   [text23452, 77]                  that rejects the agenda of |  terrorist  |
    ##  [text23453, 102]                      fought, not those that | terrorists  |
    ##    [text23454, 9]         we actively and aggressively pursue |  terrorist  |
    ##   [text23457, 27]                future free of dictatorship, |   terror    |
    ##   [text23459, 20]               eyed about Iran's support for |  terrorist  |
    ##                                              
    ##  . Fortifications in those quarters          
    ##  . Not withstanding the strong               
    ##  . Not with standing this                    
    ##  and annoyance to the inhabitants            
    ##  of confiscation, and the                    
    ##  among those whose political action          
    ##  have been launched on the                   
    ##  , and Amphitrite, contracted                
    ##  to the settlers of Arizona                  
    ##  , Puritan, Amphitrite,                      
    ##  , the peace of craven                       
    ##  and whom we must not                        
    ##  , is a painful object                       
    ##  and force, and is                           
    ##  and despair of five years                   
    ##  our people and disrupting our               
    ##  of Nazi domination, the                     
    ##  in Europe.                                  
    ##  of Nazi domination, the                     
    ##  in Europe.                                  
    ##  in Europe.                                  
    ##  in Europe, and also                         
    ##  and slavery are deliberately administered   
    ##  .                                           
    ##  ." Specifically, I                          
    ##  - where our own efforts                     
    ##  increased, spurred and encouraged           
    ##  , and without fear.                         
    ##  of war.                                     
    ##  to settle political questions.              
    ##  and the armed attacks which                 
    ##  by crime?                                   
    ##  and burnings of the 1960s                   
    ##  and anarchy. Also at                        
    ##  and one of military aggression-present      
    ##  . We have respected ideological             
    ##  and subversion in the Caribbean             
    ##  . We have seen this                         
    ##  . And I will be                             
    ##  attacking neighboring states. Support       
    ##  before an out-of-control school bus         
    ##  remains great. This is                      
    ##  . America met one historic                  
    ##  blackmail.                                  
    ##  .                                           
    ##  . Reduction of strategic offensive          
    ##  , he is dead wrong                          
    ##  our people and which tears                  
    ##  . As the world's greatest                   
    ##  and sanctions against those who             
    ##  organizations that threaten to disrupt      
    ##  . We cannot permit the                      
    ##  and fear and paralysis.                     
    ##  , whether they strike at                    
    ##  and bring them to justice                   
    ##  act in Israel killed 19                     
    ##  represent the past, not                     
    ##  , the spread of weapons                     
    ##  and organized criminals at home             
    ##  before they act and hold                    
    ##  . We have no more                           
    ##  . We are the world's                        
    ##  , international criminals, and              
    ##  , and organized criminals seeking           
    ##  . The Biological Weapons Convention         
    ##  and the missiles to deliver                 
    ##  of penniless, helpless old                  
    ##  . We will defend our                        
    ##  . The bombing of our                        
    ##  from disrupting computer networks.          
    ##  , increase our strength,                    
    ##  and potentially hostile nations the         
    ##  easier to conceal and easier                
    ##  on Kosovo, Captain John                     
    ##  and the organized criminals who             
    ##  who threaten with bombs to                  
    ##  . We'll be partners in                      
    ##  have been arrested. Yet                     
    ##  are still at large.                         
    ##  , freedom is at risk                        
    ##  from threatening America or our             
    ##  is well begun, but                          
    ##  camps intact and terrorist states           
    ##  states unchecked, our sense                 
    ##  , destroyed Afghanistan's terrorist training
    ##  training camps, saved a                     
    ##  who once occupied Afghanistan now           
    ##  leaders who urged followers to              
    ##  . The men and women                         
    ##  is only beginning. Most                     
    ##  camps, disrupt terrorist plans              
    ##  plans, and bring terrorists                 
    ##  to justice. And second                      
    ##  and regimes who seek chemical               
    ##  training camps of Afghanistan out           
    ##  underworld, including groups like           
    ##  cells that have executed an                 
    ##  who were plotting to bomb                   
    ##  camps in Somalia.                           
    ##  parasites who threaten their countries      
    ##  , and I admire the                          
    ##  . And make no mistake                       
    ##  , while an unelected few                    
    ##  . The Iraqi regime has                      
    ##  allies constitute an axis of                
    ##  , giving them the means                     
    ##  and their state sponsors the                
    ##  .                                           
    ##  .                                           
    ##  cannot stop the momentum of                 
    ##  conspiracies targeting the Embassy in       
    ##  is a contest of will                        
    ##  , the gravest danger facing                 
    ##  , and mass murder.                          
    ##  allies, who would use                       
    ##  attacks, corporate scandals,                
    ##  .                                           
    ##  . There's never a day                       
    ##  have been arrested in many                  
    ##  on the run. We're                           
    ##  are learning the meaning of                 
    ##  . The FBI is improving                      
    ##  Threat Integration Center, to               
    ##  . Once again, this                          
    ##  . We also see Iranian                       
    ##  , with great potential wealth               
    ##  , including members of Al                   
    ##  or help them develop their                  
    ##  networks are not easily contained           
    ##  and tyrants announced their intentions      
    ##  groups.                                     
    ##  , we are also confronting                   
    ##  and could supply them with                  
    ##  , and expect a higher                       
    ##  . By bringing hope to                       
    ##  threats; analysts are examining             
    ##  are not plotting and outlaw                 
    ##  continue to plot against America            
    ##  , to disrupt their cells                    
    ##  .                                           
    ##  threat will not expire on                   
    ##  who started this war.                       
    ##  Hambali, who was a                          
    ##  to justice.                                 
    ##  , and America is honored                    
    ##  , are a serious,                            
    ##  .                                           
    ##  more as a crime,                            
    ##  were still training and plotting            
    ##  and their supporters declared war           
    ##  attack and corporate scandals and           
    ##  , and I thank the                           
    ##  . In the next 4                             
    ##  .                                           
    ##  , begun to reform our                       
    ##  cells across the country,                   
    ##  network that attacked our country           
    ##  , but their number has                      
    ##  who want to kill many                       
    ##  , and that terror will                      
    ##  will stalk America and other                
    ##  and replace hatred with hope                
    ##  Zarqawi recently declared war on            
    ##  and build the institutions of               
    ##  , while we encourage a                      
    ##  and pursue weapons of mass                  
    ##  who seek to destroy every                   
    ##  and open the door to                        
    ##  , pursuing nuclear weapons while            
    ##  . And to the Iranian                        
    ##  , which is why the                          
    ##  have chosen to make a                       
    ##  in Iraq so we do                            
    ##  , inspire democratic reformers from         
    ##  and insurgents are violently opposed        
    ##  ' most powerful myth is                     
    ##  and make them believe they                  
    ##  . She wrote,"                               
    ##  , and feed resentment and                   
    ##  . Every step toward freedom                 
    ##  targets while we train Iraqi                
    ##  and organized crime and human               
    ##  surveillance program has helped prevent     
    ##  attacks. It remains essential               
    ##  and death. Terrorists like                  
    ##  like bin Laden are serious                  
    ##  have chosen the weapon of                   
    ##  hope these horrors will break               
    ##  networks. We have killed                    
    ##  while building the institutions of          
    ##  infiltration, clearing out insurgent        
    ##  involves more than military action          
    ##  is to defeat their dark                     
    ##  , and work for lasting                      
    ##  in the Palestinian territories and          
    ##  here at home. The                           
    ##  surveillance program to aggressively pursue 
    ##  networks, to victory in                     
    ##  is a reminder of the                        
    ##  we fight today is a                         
    ##  , made up of leaders                        
    ##  . We'll enforce our immigration             
    ##  who could cause huge disruptions            
    ##  can cause. We've had                        
    ##  intend for us, unless                       
    ##  , we must take the                          
    ##  , life since 9/                             
    ##  cell grooming operatives for attacks        
    ##  and stopping them.                          
    ##  , this war began well                       
    ##  Americans, they want to                     
    ##  Zarqawi:" We will                           
    ##  like Hizballah, a group                     
    ##  fears most is human freedom                 
    ##  and elected a democratic legislature        
    ##  , with support from Syria                   
    ##  .                                           
    ##  , insurgents, and the                       
    ##  have gathered and local forces              
    ##  and clear them out.                         
    ##  and fighting drug traffickers.              
    ##  and train the Afghan Army                   
    ##  and extremists, evil men                    
    ##  and extremists. We will                     
    ##  oppose every principle of humanity          
    ##  , there is one thing                        
    ##  and refuse to live in                       
    ##  are fighting to deny this                   
    ##  and extremists are fighting to              
    ##  sanctuary anywhere in the country           
    ##  , and staying behind to                     
    ##  . The Government in Baghdad                 
    ##  attacks are down, civilian                  
    ##  there is no doubt.                          
    ##  , and a source of                           
    ##  a base from which to                        
    ##  is essential to achieving a                 
    ##  in Lebanon, and backing                     
    ##  abroad. But above all                       
    ##  from carrying out their plans               
    ##  communications. To protect America          
    ##  are talking to, what                        
    ##  threats would be weakened and               
    ##  to plot against the American                
    ##  . Because living our values                 
    ##  to nuclear proliferation, from              
    ##  .                                           
    ##  who threaten our Nation.                    
    ##  .                                           
    ##  remains consistent with our laws            
    ##  , as we have in                             
    ##  who pose the gravest threat                 
    ##  do not launch attacks against               
    ##  not just through intelligence and           
    ##  networks. Here at home                      
    ##  prefer from us: large-scale                 
    ##  networks through more targeted efforts      
    ##  , and fear. As                              
    ##  organizations like Hizballah, which
