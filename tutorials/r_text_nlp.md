NLP Processing in R
================
Wouter van Atteveldt & Kasper Welbers
2019-04

For text analysis it is often useful to POS tag and lemmatize your text,
especially with non-English data. Lemmatizing generally works much
better than stemming, especially for a richly inflected language such as
German or French. Part-of-Speech (POS) tags identify the type of word
(noun, verb, etc) so it can be used to e.g. analyse only the verbs
(actions) or adjectives (descriptions). Finally, you can often
automatically extract named entities such as people or organizations,
making it easy to e.g. generate a list of actors in a corpus,

There are two packages that do this that are both easy to use and
support multiple languages: `spacyr` and `udpipe`. This handout will
review both packages and show how they can be used to analyse text and
convert the results to a tcorpus and/or dfm.

# Spacyr

Spacy is a python package with processing models for a number of
different languages, which makes it attractive to use if you need
e.g. French or German lemmatizing.

## Installing spacy(r)

Since it is natively made in python, it uses the `reticulate` package to
communicate between python and R. Fortunately, installing it has become
a lot easier by using `miniconda`, basically a prepackaged python
environment that can be installed directly from R. According to the
documentation, on Windows you need to run R as administrator to be able
to install spacyr from R.

To install spacy and spacyr, first install the package as usual, and
then use spacyr to download and install spacy in the miniconda
environment:

``` r
install.packages("spacyr")
library(spacyr)
spacy_install()
```

If asked whether to install miniconda, just answer yes.

## Using spacyr

Before using spacyr, you initialize it with the name of the language
model you want to use. By default, the English model is installed and
will be used if you don’t specify another option:

``` r
library(spacyr)
spacy_initialize()
```

If all is well, this should give a informational message that it found
the environment and successfully initialized spacy. You are now ready to
use spacy for parsing an English sentence:

``` r
txt = c("Spacy was successfully installed", "Is'nt it miraculous?")
tokens = spacy_parse(txt)
tokens
```

This yields a dataset with one word on each row, and the columns
containing the original word (`token`), it’s lemma (i.e. dictionary
stem, so the lemma of ‘was’ is (to) ‘be’) and it’s part of speech tag
(`pos`, so adverb, verb, proper name, etc.). The final column identifies
named entities, i.e. persons, organizations, and locations.

As a slightly bigger example, this lists all the most common adjectives
in the two inaugural speeches of Obama:

``` r
library(quanteda)
library(tidyverse)
docvars(data_corpus_inaugural)
speeches = data_corpus_inaugural %>% convert(to="data.frame") %>% filter(President == "Obama") %>% pull(text)
tokens = spacy_parse(speeches) 
tokens %>% filter(pos == "ADJ") %>% group_by(lemma) %>% summarize(n=n()) %>% arrange(desc(n)) %>% head()
```

As the tokens are just a data frame, it is quite easy to use tidyverse
to inspect and manipulate the outcome. There are also some built-in
functions to help deal with multi-word entities or noun phrases:

``` r
entities = entity_extract(tokens)
head(entities)
```

As you can see, this ‘merges’ words that form a name together such as
‘Justice Roberts’. You can also consolidate these so they the original
tokens are replaced by the new merged token:

``` r
tokens %>% filter(str_detect(token, "Justice|Roberts"))
tokens2 = entity_consolidate(tokens)
tokens2 %>% filter(str_detect(token, "Justice|Roberts"))
```

A similar function pair exists to deal with noun phrases, but this
requires you to enable noun phrase parsing in the original parse call:
(you could enable dependency parsing in a similar fashion with
`dependency=T`)

``` r
tokens = spacy_parse(speeches, nounphrase = T) 
nps = nounphrase_extract(tokens)
head(nps)
```

As you can see, this detects a phrase such as *president Carter* as well
as *fellow Americans*.

## Using spacy output in quanteda

Spacyr was developed by the same people that made quanteda, so as you
can guess they collaborate quite well. In fact, the data frame returned
by spacyr can be directly used in most quanteda functions. Note that the
`dfm` function itself does not accept a tokens data frame, but there is
an as.tokens function that
does:

``` r
tokens %>% as.tokens(include_pos="pos", use_lemma=TRUE) %>% dfm() %>% textplot_wordcloud()
```

## Finalizing spacy

Spacyr keeps a python process running, which can consume quite a lot of
memory. When you are done with spacy (but want to continue with R), you
can finalize spacy:

``` r
spacy_finalize()
```

This saves some memory and allows you to re-initialize it, i.e. with a
different language model.

## Loading and using other languages

By default, other language models are not included with spacy. You can
download these models using the built-in download function, for example
for German:

``` r
spacy_download_langmodel("de")
```

To use it, initialize spacy with this model (note that you need to
finalize an existing session before you can do this):

``` r
spacy_initialize("de")
spacy_parse("Ich bin ein Berliner")
```

Note that if you prefer to install spacy yourself rather than use the
`miniconda`, you can pass the virtual environment location to the
initialize and download functions. We would recommend just using the
miniconda environment though unless for some reason that doesn’t work.

See <https://spacy.io/usage/models> for an overview of available
languages.

# UDPipe

`udpipe` is an R package that is quite similar to spacy in many regards.
It is slightly easier to install (but doesn’t collaborate as well with
quanteda) and both should be comparable in performance.

What is nice about UDPipe is that you can directly call it after
installing it, and if you use a language for which the model is not
already install it will automatically download the language model.

So, we can simply call udpipe directly:

``` r
library(udpipe)
txt = c("UDPipe was successfully installed as well", "It doesn't even need to be initialized")
tokens = udpipe(txt, "english", parser="none") %>% as_tibble()
tokens %>% select(doc_id, token_id:xpos)
```

Or with german
text:

``` r
udpipe("Ich bin ein Berliner", "german", parser="none") %>%  select(doc_id, token_id:xpos)
```

As you can see, the output is very similar to spacy’s output, although
confusingly they use different naming conventions. The `xpos` column
will depend on the language model, but the `upos` (universal
part-of-speech) will be the same for all languages.

Note that we specified `parser="none"` to disable dependency parsing,
which would make it quite a lot slower.

## Using udpipe output in quanteda

To use udpipe output in quanteda, you need to first convert it into a
list of tokens per document:

``` r
tokens = udpipe(speeches, "english", parser="none")
tokenlist = split(tokens$lemma, tokens$doc_id)
names(tokenlist)
head(tokenlist$doc1)
```

Now, you can use `as.tokens` and proceed as above:

``` r
tokenlist %>% as.tokens() %>% dfm() %>% textplot_wordcloud()
```

Note that we used the lemma above. We can also add the POS tags to the
text so we get the same output as
quanteda:

``` r
split(str_c(tokens$lemma, tokens$upos, sep = "/"), tokens$doc_id) %>% as.tokens() %>% tokens_select("*/NOUN") %>% dfm() %>% textplot_wordcloud()
```

Of course,for udpipe as well as for spacy we can also do filtering or
other operations on the tokens data frame before converting it to a
quanteda object:

``` r
nouns = tokens %>% filter(upos == "NOUN")
split(nouns$lemma, nouns$doc_id) %>% as.tokens() %>% dfm() %>% textplot_wordcloud()
```
