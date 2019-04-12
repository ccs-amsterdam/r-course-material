---
title: "Supervised Text Classification"
author: "Wouter van Atteveldt & Kasper Welbers"
date: "April 2019"
output: html_document
---

```{r, echo=F, message=F}
knitr::opts_chunk$set(warning=FALSE, message=FALSE)
library(printr)
```

# Data

For machine learning, we need annotated training data. Fortunately, there are many review data files available for free. A corpus of movie reviews is included in the `quanteda.corpora` package, which you need to install from github directly:

```{r, eval=F}
if (!require("devtools")) install.packages("devtools")
devtools::install_github("quanteda/quanteda.corpora")
```

Now we can get the data:

```{r}
reviews = quanteda.corpora::data_corpus_movies
reviews
head(docvars(reviews))
```

Note: if you have trouble with `install_github`, you can also download and load the data directly from github:

```{r, eval=F}
download.file("https://github.com/quanteda/quanteda.corpora/blob/master/data/data_corpus_movies.rda?raw=true", "reviews.rda")
load("reviews.rda")
reviews = data_corpus_movies
```

# Preparing the data

To prepare the data, we need to create matrices for the training and test data.
First we split the data:

```{r}
library(tidyverse)
trainset = sample(docnames(c_reviews), 1500)
testset = setdiff(docnames(c_reviews), trainset)
```

Now, we create the two dfms:

```{r}
dfm_training <- c_reviews %>% corpus_subset(docnames(c_reviews) %in% trainset) %>%
    dfm(stem = TRUE) %>% dfm_select(min_nchar = 2) %>% dfm_trim(min_docfreq=10)

dfm_test

textmodel_nb()

# get test set (documents not in id_train)
dfmat_test <- corpus_subset(corp_movies, !id_numeric %in% id_train) %>%
    dfm(stem = TRUE)


```


