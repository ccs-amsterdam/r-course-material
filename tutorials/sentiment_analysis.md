R text analysis: sentiment analysis and context searches
================
Wouter van Atteveldt & Kasper Welbers
2018-11

-   [Introduction](#introduction)
-   [Getting a DTM](#getting-a-dtm)
-   [Dictionary-based Sentiment analysis](#dictionary-based-sentiment-analysis)
    -   [Obtaining a dictionary](#obtaining-a-dictionary)
    -   [Creating a quanteda dictionary from a word list](#creating-a-quanteda-dictionary-from-a-word-list)
    -   [Applying a quanteda dictionary](#applying-a-quanteda-dictionary)
    -   [Validating a dictionary](#validating-a-dictionary)
    -   [Improving a dictionary](#improving-a-dictionary)
-   [Corpustools](#corpustools)
    -   [Highlighting dictionary hits](#highlighting-dictionary-hits)
    -   [Limiting the dtm to search context](#limiting-the-dtm-to-search-context)

Introduction
============

Some of the most important questions about text have to do with *sentiment* (or *tone*): Is a text in general positive or negate? Are actors described as likable and succesful? Is the economy doing well or poorly? Is an issue framed as good or bad? Is an actor in favour of or against a certain policy proposal?

*Caveat*: In this tutorial, we will use dictionary methods to do sentiment analysis. This method is very successful for some tasks such as deciding whether a review is positive or negative. In other cases, however, one should be more careful about assuming dictionary analyses are valid. Especially in political communication, sentiment can mean one of multiple things, and many texts contain multiple statements with opposing sentiment.

For more information and critical perspectives on dictionary based sentiment analysis in political communication, see e.g. the references below:

-   Soroka, S., Young, L., & Balmas, M. (2015). Bad news or mad news? sentiment scoring of negativity, fear, and anger in news content. The ANNALS of the American Academy of Political and Social Science, 659 (1), 108–121.
-   González-Bailón, S., & Paltoglou, G. (2015). Signals of public opinion in online communication: A comparison of methods and data sources. The ANNALS of the American Academy of Political and Social Science, 659(1), 95-107.
-   Barberá, P., Boydstun, A., Linn, S., McMahon, R., & Nagler, J. (2016, August). Methodological challenges in estimating tone: Application to news coverage of the US economy. In Meeting of the Midwest Political Science Association, Chicago, IL.

For this tutorial, the main lessons of these papers are that you should always validate to make sure your results are valid for your task and domain. It is always a good idea to adapt a lexicon (dictionary) to your domain/task by inspecting (the context of) the most common words. Depending on resources, using crowd coding and/or machine learning can also be a better option than a purely lexical (dictionary-based) approach.

Getting a DTM
=============

The main primitive for dictionary analysis is the document-term matrix (DTM). For more information on creating a DTM from a vector (column) of text, see the [tutorial on basic text analysis with quanteda](R_texrt_3_quanteda.md). For this tutorial, it is important to make sure that the preprocessing options (especially stemming) match those in the dictionary: if the dictionary entries are not stemmed, but the text is, they will not match. In case of doubt, it's probably best to skip stemming altogether.

For this example, we'll download a corpus of UK immigration news from Github. For easier re-use, we will save just the data frame with texts as an RDS file locally:

``` r
download.file("https://github.com/quanteda/quanteda.corpora/raw/master/data/data_corpus_immigrationnews.rda", destfile="immigration.rda")
```

``` r
load("immigration.rda")
```

NOTE: when downloading data from the internet, it's often a good idea to cache remote downloads like this to a local file, and set `eval=F` on the chunk that downloads the file. That way, it's clear where the file came from, but it doesn't re-download it every time you knit the document.

Now, we can create a dtm as normal:

``` r
library(quanteda)
dtm = data_corpus_immigrationnews %>% dfm(remove=stopwords("english"), remove_punct=T) %>% dfm_trim(min_docfreq=10)
dtm
```

And when we have a dtm, we might as well make a word cloud to make sure that the results make some sense:

``` r
textplot_wordcloud(dtm, max_words=100)
```

Dictionary-based Sentiment analysis
===================================

Obtaining a dictionary
----------------------

To do a dictionary-based sentiment analysis, we can use the `dfm_lookup` method to apply an existing dictionary to a dfm. There are many existing dictionaries that can be downloaded from the Internet.

For easy use, the package `SentimentAnalysis` contains 3 dictionaries: `DictionaryGI` is a general sentiment dictionary based on The General Inquirer, and `DictionaryHE` and `DictionaryLM` are dictionaries of finance-specific words presented by Henry (2008) and Loughran & McDonald (2011) respectively. The package `qdapDictionaries` also contains a number of interesting dictionaries, including a list of `positive.words` and `negative.words` from the sentiment dictionary of Hu & Liu (2004), and specific lists for `strong.words`, `weak.words`, `power.words` and `submit.words` from the Harvard IV dictionary.

You can inspect the lists and their origins from each package by loading it and getting the help:

``` r
library(SentimentAnalysis)
?DictionaryGI
names(DictionaryGI)
head(DictionaryGI$negative)

library(qdapDictionaries)
?weak.words
head(weak.words)
```

You can also download many dictionaries as CSV. For example, the VADER lexicon is specifically made for analysing social media and includes important words such as "lol" and "meh" that are not present in most standard dictionaries:

``` r
library(tidyverse)
url = "https://raw.githubusercontent.com/cjhutto/vaderSentiment/master/vaderSentiment/vader_lexicon.txt"
# note: the command below gives warning messages due to the details column, these can be safely ignored
vader = read_delim(url, col_names=c("word","sentiment", "details"),  col_types="cdc",  delim="\t")
head(vader)
```

Which dictionary you should use depends on your task and research question. For example, for investigating finance/business/economic news it is probably best to use a finance-specific dictionary. If you have specific theory about appearing strong or weak it is probably best to use the word list for these traits. Again, make sure that your choices for preprocessing match your analysis strategy: if you want to use e.g. the emoticons in the VADER dictionary, you should not strip them from your d

In all cases, it is important to validate that you are actually measuring what you think you are measuring.

Creating a quanteda dictionary from a word list
-----------------------------------------------

You can apply the dictionaries listed above using dfm\_lookup. The dictionaries from `SentimentAnalysis` can be directly turned into a quanteda dictionary:

``` r
GI_dict = dictionary(DictionaryGI)
```

For the word lists, you can compose a dictionary e.g. of positive and negative terms: (and similarly e.g. for weak words and strong words, or any list of words you find online)

``` r
HL_dict = dictionary(list(positive=positive.words, negative=negation.words))
```

You can also create a dictionary from a data frame based on the value of a sentiment column:

``` r
vader_pos = vader$word[vader$sentiment > 0]
vader_neg = vader$word[vader$sentiment < 0]
Vader_dict = dictionary(list(positive=vader_pos, negative=vader_neg))
```

Applying a quanteda dictionary
------------------------------

Now that we have a dtm and a dictionary, applying it is relatively simple by using the `dfm_lookup` function. To use the result in further analysis, we convert to a data frame and change it in to a tibble. The last step is purely optional, but it makes working with it within tidyverse slightly easier:

``` r
result = dtm %>% dfm_lookup(GI_dict) %>% convert(to = "data.frame") %>% as_tibble
result
```

We can also add the total word length if we want to normalize for the length of documents. We use the `ntoken` function, where a `token` is a fancy linguistic term for a word:

``` r
result = result %>% mutate(length=ntoken(dtm))
```

Now, we probably want to compute some sort of overall sentiment score. We can make various choices here, but a common one is to subtract the negative count from the positive count and divide by either the total number of words or by the number of sentiment words. We can also compute a measure of subjectivity to get an idea of how much sentiment is expressed in total:

``` r
result = result %>% mutate(sentiment1=(positive - negative) / (positive + negative))
result = result %>% mutate(sentiment2=(positive - negative) / length)
result = result %>% mutate(subjectivity=(positive + negative) / length)
result
```

These scores can be seen as a measurement of sentiment/subjectivity per document. For a substantive analysis, you can join this back to your metadata/docvars and e.g. compute sentiment per source, actor, or over time.

Validating a dictionary
-----------------------

To get an overall quantitative measure of the validity of a dictionary, you should manually code a random sample of documents and compare the coding with the dictionary results. This can (and should) be reported in the methods section of a paper using a sentiment dictionary.

You can create a random sample from the original data frame using the sample function:

``` r
sample_ids = sample(docnames(dtm), size=50)
```

``` r
docs = data_corpus_immigrationnews$documents 
docs = docs %>% mutate(document=rownames(docs)) %>% as_tibble()
docs %>% filter(document %in% sample_ids) %>% mutate(manual_sentiment="") %>% write_csv("to_code.csv")
```

Then, you can open the result in excel, code the documents by filling in the sentiment column, and read the result back in and combine with your results above. Note that I rename the columns and turn the document identifier into a character column to facilitate matching it:

``` r
validation = read_csv("to_code.csv") %>% inner_join(result)
```

Now let's see if my (admittedly completely random) manual coding matches the sentiment score. We can do a correlation:

``` r
cor.test(validation$manual_sentiment, validation$sentiment1)
```

We can also get a 'confusion matrix' if we create a nominal value from the sentiment using the `cut` function:

``` r
validation = validation %>% 
  mutate(sent_nom = cut(sentiment1, breaks=c(-1, -0.1, 0.1, 1), labels=c("-", "0", "+")))
cm = table(validation$manual_sentiment, validation$sent_nom)
cm
```

This shows the amount of errors in each category. For example, 13 documents were classified as positive ("+") but manually coded as negative (-1). Total accuracy is the sum of the diagonal of this matrix (3+1+13=17) divided by total sample size (50), or 34%

``` r
sum(diag(cm)) / sum(cm)
```

Improving a dictionary
----------------------

To improve a sentiment dictionary, it is important to see which words in the dictionary are driving the results. The easiest way to do this is to use `textstat_frequency` function and then using the tidyverse filter function together with the `%in%` operator to select only rows where the feature is in the dictionary:

``` r
textstat_frequency(dtm) %>% as_tibble() %>% filter(feature %in% HL_dict$positive)
```

As you can see, the most frequent 'positive' words found are 'like' and 'work'. Now, it's possible that these are actually used in a positive sense ("I like you", "It works really well"), but it is equally possible that they are used neutrally, especially the word "like".

To find out, the easiest method is to get a keyword-in-context list for the term:

``` r
head(kwic(data_corpus_immigrationnews, "like"))
```

From this, it seems that the word `like` here is not used as a positive verb, but rather as a neutral preposition. To remove it from the list of positive words, we can use the `setdiff` (difference between two sets) function:

``` r
positive.cleaned = setdiff(positive.words, c("like", "work"))
HL_dict2 = dictionary(list(positive=positive.cleaned, negative=negation.words))
```

To check, look at the top positive words that are now found:

``` r
freqs %>% filter(feature %in% HL_dict2$positive)
```

This seems like a lot of work for each word, but even just checking the top 25 words can have a very strong effect on validity since these words often drive a large part of the outcomes.

Similarly, you can check for missing words by inspecting the top words not matched by any of the terms (using `!` to negate the condition)

``` r
sent.words = c(HL_dict$positive, HL_dict$negative)
freqs %>% filter(!feature %in% sent.words) %>% View
```

By piping the result to View, it is easy to scroll through the results in rstudio. Note that this does not work in a Rmd file since View cannot be used in a static document!

Scroll through the most frequent words, and if you find a word that might be positive or negative check using `kwic` whether it is indeed (generally) used that way, and then add it to the dictionary similar to above, but using the combination function `c` rather than `setdiff`.

Corpustools
===========

Corpustools is a package developed at VU Amsterdam to provide functionality that is not possible with document-term matrices. Here, we will be using two features of corpustools: highlighting dictionary hits and doing a windowed search. First, install corpustools (if needed), load it, and transform the quanteda corpus into a corpustools tcorpus object:

``` r
install.packages("corpustools")
```

``` r
library(corpustools)
library(corpustools)
t = create_tcorpus(data_corpus_immigrationnews$documents, text_colum="texts", doc_column="id")
```

Highlighting dictionary hits
----------------------------

For validation, it can be very useful to inspect dictionary hits within the original text. This is possible with the corpustools `browse_text` function. First, we create a new sentiment variable using the GI\_dict created above:

``` r
t$code_dictionary(GI_dict, column = 'lsd15')
t$set('sentiment', 1, subset = lsd15 %in% c('positive','neg_negative'))
t$set('sentiment', -1, subset = lsd15 %in% c('negative','neg_positive'))
```

Now, we can browse the texts:

``` r
browse_texts(t, scale='sentiment')
```

This opens a selection of texts, with positive words indicated in green, and negative words in red.

Limiting the dtm to search context
----------------------------------

In many cases, you want to look only at the words immediately surrounding your search term. Especially in political text, many articles will mention e.g. both Clinton and Trump, and often contain text about events and strategy as well as issues. So, to understand the sentiment or frames about an actor or issue, you want to keep only the words surrounding the name of the actor or issue.

This technique is useful for all forms of dictionary analysis, for example to see how a certain issue or person is described or framed, or to see what issue a party is associated with; but especially for sentiment analysis it can help find sentiment that is actually related to a specific actor or issue.

For this tutorial, we limit the tcorpus to words occurring within 10 words of 'ukip':

``` r
t$subset_query("ukip", window=10)
```

Note that corpustools works slightly different from most other R packages by using a more 'object oriented' approach. So, `t$subset_query` applies the method `subset_query` to the `t` object, and changes the object in-place rather than returning the changed object.

The last step is to convert the tcorpus back to a regular dtm object. We can then use the methods from quanteda to clean it by removing infrequent words, stopwords, lowercasing it, and removing all words that contain anything apart from letters (e.g. punctuation, numbers). Note that the last step is done using a regular expression, see for example [regexone.com](https://regexone.com/) for a gentle introduction.

``` r
dtm_ukip = t$dfm(feature='token') %>% dfm_trim(min_docfreq=10) %>% dfm_remove(stopwords('english')) %>% 
  dfm_tolower %>% dfm_remove("[^a-z]", valuetype="regex")
```

Now let's have a look at the top words:

``` r
head(textstat_frequency(dtm_ukip))
```

As you can see, ukip is (not surprisingly) the most frequent word, followed by party and Farage (the name of the UKIP leader). You can now use this dtm in a sentiment analysis, and e.g. compare sentiment for the context around different actors or issues.
