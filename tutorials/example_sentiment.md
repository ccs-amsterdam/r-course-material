Reproducing ‘The validity of Sentiment Analysis’
================
Wouter van Atteveldt & Mariken van der Velden
January 2021

  - [Introduction](#introduction)
  - [Data](#data)
      - [Preprocessing](#preprocessing)
  - [Analysis](#analysis)
      - [Dictionaries](#dictionaries)
      - [Machine learning](#machine-learning)
      - [A closer look at performance](#a-closer-look-at-performance)

# Introduction

Together with Mariken van der Velden and Mark Boukes I recently
published an article titled [The validity of Sentiment
Analysis](https://raw.githubusercontent.com/vanatteveldt/ecosent/master/report/atteveldt_sentiment.pdf)/
Although all used scripts and data are available on the [github
page](https://github.com/vanatteveldt/ecosent), it uses both Python and
R, and the Machine Learning parts are entirely in Python. Note that you
don’t need to read Dutch to be able to follow or reproduce the example,
although of course it can help for inspecting the data and doing error
analysis.

In this document I will reproduce some of the analyses from that paper,
namely the quanteda-based Dutch dictionaries and the classical machine
learning. Note that the outcome will not be identical as both
preprocessing and ML implementation will be different, but the outcomes
are comparable.

# Data

``` r
library(tidyverse)
url = "https://raw.githubusercontent.com/vanatteveldt/ecosent/master/data/intermediate/sentences_ml.csv"
d = read_csv(url) %>% select(doc_id=id, text=headline, gold, sentiment=value)
head(d)
```

| doc\_id | text                                                  | gold  | sentiment |
| ------: | :---------------------------------------------------- | :---- | --------: |
|   10007 | Rabobank voorspelt flinke stijging hypotheekrente     | FALSE |         0 |
|   10027 | D66 wil reserves provincies aanspreken voor groei     | FALSE |         0 |
|   10037 | UWV: dit jaar meer banen                              | FALSE |         1 |
|   10059 | Proosten op geslaagde beursgang Bols                  | FALSE |         1 |
|   10099 | Helft werknemers gaat na 65ste met pensioen           | FALSE |         0 |
|   10101 | Europa groeit voorzichtig dankzij lage energieprijzen | FALSE |         1 |

This dataset contains Dutch newspaper headlines of articles mentioning
the economy. The `sentiment` column is a manual coding of whether the
tone about the state of the economy, i.e. whether according to the
headlne one would conclude the economy is doing well or not.

``` r
table(d$gold, d$sentiment) %>%  addmargins()
```

| /     |  \-1 |    0 |    1 |  Sum |
| :---- | ---: | ---: | ---: | ---: |
| FALSE | 1972 | 2673 | 1393 | 6038 |
| TRUE  |   99 |  112 |   73 |  284 |
| Sum   | 2071 | 2785 | 1466 | 6322 |

In total, there are 6,322 headlines, split into 6038 headlines in the
training set (`gold=FALSE`) and 284 in the test/evaluation set. The
neutral category is overrepresented at the expense of the positive
category in the training data, and to a lesser extent in the test data.

## Preprocessing

Let’s use updpipe to lemmatize the headlines. This package can parse
various languages, and will automatically download the needed language
models. Acutally, the original data already contained lemmatized text,
but that was done with a different parser, and it is nice to see how to
do it within R.

Note that I call `udpipe` on the data frame, which expects it to have a
`doc_id` and `text` column, similar to e.g. quanteda. You can also call
it on a character column or vector directly (e.g. `udpipe(d$text)`), but
then the document id will not be preserved. Also note that I set
`parser="none"`, which disables the syntactic parsing, making it a bit
quicker to compute.

``` r
tokens = udpipe(d, "dutch", parser="none")
```

Now, this takes a couple of minutes to tokenize, so normally I would
want to store the results in an intermediate file. Note: there are more
advanced ways to ‘cache’ results like this built into R, but I decided
the example below is nice because it is a generally useful pattern, and
shows how you can save and load data and use an `if / else` structure.

``` r
library(udpipe)
if (file.exists("tokens.rds")) {
  tokens = readRDS("tokens.rds")
} else {
  tokens = udpipe(d, "dutch", parser="none")
  saveRDS(tokens, "tokens.rds")
}
```

In either case, the results are a data frame with one row per file:

``` r
tokens = as_tibble(tokens) %>% select(doc_id, token, start, lemma, upos)
tokens %>% filter(doc_id == 10007)
```

| doc\_id | token          | start | lemma          | upos |
| :------ | :------------- | ----: | :------------- | :--- |
| 10007   | Rabobank       |     1 | Rabobank       | NOUN |
| 10007   | voorspelt      |    10 | voorspellen    | VERB |
| 10007   | flinke         |    20 | flink          | ADJ  |
| 10007   | stijging       |    27 | stijging       | NOUN |
| 10007   | hypotheekrente |    36 | hypotheekrente | NOUN |

This shows the output for one headline (*Rabobank voorspelt flinke
stijging hypotheekrente*, Rabobank predicts steep increase \[of\]
mortgage-interest), correctly tagging e.g. predict as a verb and
lemmatizing it to its infinitive form.

Now, let’s recombine the lemmata per sentence and join it with our
original dataframe:

``` r
lemmatized = tokens %>% arrange(doc_id, start)  %>% 
  group_by(doc_id) %>% summarize(lemmatized=str_c(lemma, collapse=" ")) %>% 
  mutate(doc_id = as.numeric(doc_id))
head(lemmatized)
```

| doc\_id | lemmatized                                           |
| ------: | :--------------------------------------------------- |
|   10007 | Rabobank voorspellen flink stijging hypotheekrente   |
|   10027 | d66 willen reserve provincie aanspreken voor groei   |
|   10037 | Uwv : dit jaar veel banen                            |
|   10059 | Proost op slaagen beursgang Bol                      |
|   10099 | helft werknemer gaan na 65 met pensioen              |
|   10101 | Europa groeien voorzichtig dankzij laag energieprijs |

And join back with original data:

``` r
d = inner_join(d, lemmatized)
head(d)
```

| doc\_id | text                                                  | gold  | sentiment | lemmatized                                           |
| ------: | :---------------------------------------------------- | :---- | --------: | :--------------------------------------------------- |
|   10007 | Rabobank voorspelt flinke stijging hypotheekrente     | FALSE |         0 | Rabobank voorspellen flink stijging hypotheekrente   |
|   10027 | D66 wil reserves provincies aanspreken voor groei     | FALSE |         0 | d66 willen reserve provincie aanspreken voor groei   |
|   10037 | UWV: dit jaar meer banen                              | FALSE |         1 | Uwv : dit jaar veel banen                            |
|   10059 | Proosten op geslaagde beursgang Bols                  | FALSE |         1 | Proost op slaagen beursgang Bol                      |
|   10099 | Helft werknemers gaat na 65ste met pensioen           | FALSE |         0 | helft werknemer gaan na 65 met pensioen              |
|   10101 | Europa groeit voorzichtig dankzij lage energieprijzen | FALSE |         1 | Europa groeien voorzichtig dankzij laag energieprijs |

# Analysis

First, we make a document-term-matrix from the lemmatized texts:

``` r
library(quanteda)
dfm = d %>% select(doc_id, text=lemmatized, gold, sentiment) %>% corpus %>% 
  dfm(remove_punct=T) %>% dfm_trim(min_docfreq = 10)
train = dfm_subset(dfm, gold==FALSE)
gold = dfm_subset(dfm, gold==TRUE)
```

## Dictionaries

Let’s try to download and apply the NRC dictionary for Dutch: ([original
code](https://github.com/vanatteveldt/ecosent/blob/master/src/data-processing/11_apply_dictionaries_quanteda.R)).
First, we download the dictionary and turn it into a quanteda
dictionary:

``` r
url = "https://raw.githubusercontent.com/vanatteveldt/ecosent/master/data/raw/dictionaries/NRC-Emotion-Lexicon-v0.92-In105Languages-Nov2017Translations.csv"
nrc = read_csv(url) %>% select(term = `Dutch (nl)`, Positive, Negative, Fear, Trust) %>% filter(term != 'NO TRANSLATION')
dict = dictionary(list(positive = nrc$term[nrc$Positive==1],
                       negative = nrc$term[nrc$Negative==1],
                       fear = nrc$term[nrc$Fear==1],
                       trust = nrc$term[nrc$Trust==1]))
```

Next, we apply to the gold standard data and compute sentiment

``` r
dict_result = gold %>% dfm_lookup(dict) %>% convert(to="data.frame") %>% as_tibble() %>% 
  mutate(score = (positive + trust) - (negative+fear), 
         dict_sentiment=sign(score),
         doc_id=as.numeric(doc_id))
head(dict_result)
```

| doc\_id | positive | negative | fear | trust | score | dict\_sentiment |
| ------: | -------: | -------: | ---: | ----: | ----: | --------------: |
|   10273 |        1 |        1 |    0 |     0 |     0 |               0 |
|   10367 |        1 |        0 |    0 |     0 |     1 |               1 |
|   10881 |        1 |        0 |    0 |     0 |     1 |               1 |
|   11191 |        0 |        0 |    0 |     0 |     0 |               0 |
|   11745 |        0 |        2 |    0 |     0 |   \-2 |             \-1 |
|   12255 |        0 |        0 |    0 |     0 |     0 |               0 |

Now, we can join with the original sentiment score:

``` r
dict_result = d %>% select(doc_id, actual=sentiment) %>% right_join(dict_result)
acc = mean(dict_result$actual == dict_result$dict_sentiment)
print(str_c("NRC Accuracy: ", round(acc, 2)))
```

    ## [1] "NRC Accuracy: 0.45"

## Machine learning

Now we can use `quanteda.textmodels` to create a classifier:

``` r
library(quanteda.textmodels)
m = textmodel_nb(train, docvars(train)$sentiment)
```

And test it against the gold standard data:

``` r
pred = tibble(predicted=predict(m, gold), actual=docvars(gold)$sentiment)
acc = mean(pred$predicted == pred$actual)
print(str_c("Accuracy: ", round(acc, 2)))
```

    ## [1] "Accuracy: 0.58"

## A closer look at performance

To get the per-class precision, recall, and F1 scores (as in table 2
from the article), you can use the confusion matrix function from the
caret package:

``` r
caret::confusionMatrix(as.factor(pred$predicted), as.factor(pred$actual), mode="prec_recall")
```

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction -1  0  1
    ##         -1 64 34 17
    ##         0  21 61 16
    ##         1  14 17 40
    ## 
    ## Overall Statistics
    ##                                          
    ##                Accuracy : 0.581          
    ##                  95% CI : (0.5212, 0.639)
    ##     No Information Rate : 0.3944         
    ##     P-Value [Acc > NIR] : 1.672e-10      
    ##                                          
    ##                   Kappa : 0.3637         
    ##                                          
    ##  Mcnemar's Test P-Value : 0.3349         
    ## 
    ## Statistics by Class:
    ## 
    ##                      Class: -1 Class: 0 Class: 1
    ## Precision               0.5565   0.6224   0.5634
    ## Recall                  0.6465   0.5446   0.5479
    ## F1                      0.5981   0.5810   0.5556
    ## Prevalence              0.3486   0.3944   0.2570
    ## Detection Rate          0.2254   0.2148   0.1408
    ## Detection Prevalence    0.4049   0.3451   0.2500
    ## Balanced Accuracy       0.6854   0.6648   0.7005
