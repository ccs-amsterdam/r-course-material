Tidytext basics
================
Wouter van Atteveldt
2022-10

- [Introduction: A Tidy Text Format](#introduction-a-tidy-text-format)
- [Motivating Example](#motivating-example)
- [Importing text into R](#importing-text-into-r)
  - [CSV files](#csv-files)
  - [Text, word, or PDF files](#text-word-or-pdf-files)
- [Tokenizing text](#tokenizing-text)
- [Cleaning text](#cleaning-text)
  - [Stop word removal](#stop-word-removal)
  - [Trimming overly (in)frequent
    words](#trimming-overly-infrequent-words)
- [Analyzing and visualizing texts](#analyzing-and-visualizing-texts)
  - [Word frequencies and word
    clouds](#word-frequencies-and-word-clouds)
  - [Corpus comparison](#corpus-comparison)
- [Where next?](#where-next)

# Introduction: A Tidy Text Format

Tidytext is a package for working with textual data. It’s core data
format is a regular data frame (tibble) where each row is a word. This
allows you to perform most text-related operations, such as stopword
removal, text cleaning, or corpus analysis using regular tidyverse data
transformation operations.

For example, given a list of words you could `anti_join` with a stopword
list, then `group_by` word and `filter` out rare words, and finally
`summarize` word frequencies and use `ggplot` to create a word cloud.
All functions mentioned in this paragraph are regular tidyverse
functions, so the good news is: if you are already familiar with the
tidyverse, you are 99% of the way to being able to use tidytext.

In this tutorial, we will take you through four steps that are common to
text analysis regardless of the exact package: (1) importing the raw
text; (2) tokenizing it into separate words; (3) cleaning it; and (4)
and analyzing and visualizing the results.

# Motivating Example

As a motivation example that shows how you can use existing tidyverse
functions for text analysis, the code below imports the american State
of the Union speeches and shows a word cloud of Obama’s speeches:

``` r
library(tidytext)
library(tidyverse)
library(ggwordcloud)
library(stopwords)
library(sotu)
sotu = add_column(sotu_meta, text=sotu_text) |> 
  as_tibble() |>
  rename(doc_id=X)
obama_n  = sotu |>
  filter(president == "Barack Obama") |> 
  unnest_tokens(word, text) |>
  group_by(word) |> 
  summarize(n = n()) 
obama_n_cleaned = obama_n |>
  filter(n >= 10, 
         !word %in% stopwords(), 
         str_length(word) >= 2) |>
  arrange(-n) |>
  slice_head(n=200) 
ggplot(obama_n_cleaned) + 
  geom_text_wordcloud(aes(label=word, size=n, color=n)) +
   theme_void()
```

The parts of this code will be explained in the sections below, but I
would also encourage you to view the results of each step and see if you
understand what’s going on!

# Importing text into R

With importing text we mean retrieving text from some external storage
and reading it into R as a character (text) vector, usually as a
charactar column in a data frame also containing metadata (date, source,
etc). How to do this of course depends on where your texts are stored,
so we will consider two common use cases: CSV files and text (or word,
pdf) files. For scraping texts directly from web pages, check out [our
scraping
tutorial](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/rvest.md)

## CSV files

For reading CSV files, no special functions are needed: `read_csv`
automatically reads textual columns as character data. For example, the
code below imports the US state of the union speeches from a csv file
hosted on the internet.

``` r
library(tidyverse)
sotu <- read_csv('https://github.com/ccs-amsterdam/r-course-material/blob/master/miscellaneous/sotu_per_paragraph.csv?raw=true')
head(sotu)   ## view first 6 rows
```

If your CSV file is on your computer, simply substitute it’s file
location for the URL in the example.

## Text, word, or PDF files

Another very common use case is to have a folder with different files on
your computer, e.g. word, PDF, or txt files. The `readtext` packages
offers a very convenient function to import many different file formats
in a single call:

``` r
library(readtext)
texts <- readtext("https://github.com/ccs-amsterdam/r-course-material/blob/master/data/files.zip?raw=true")
texts
```

The example above imports a zip file hosted on this internet, which
contained a Word and PDF file. As you can see, it automatically
downloaded and unzipped the files, and converted the MS Word and PDF
files into plain text.

If the files are on your computer, you can import them by specifying the
path:

``` r
texts <- readtext("c:/path/to/files")
texts <- readtext("/Users/me/Documents/files")
```

See
[?readtext](https://www.rdocumentation.org/packages/readtext/versions/0.81/topics/readtext)
for more information. The function can automatically read subfolders and
store the folder and file names in meta data fields. If can handle text,
json, csv, html, xml, pdf, odt, docx and rtf files.

# Tokenizing text

In natural language processing, *tokens* are a fancy term for words, and
*tokenization* is the process of converting text strings into separate
words. This sounds trivial (e.g. just split by space or interpunction),
but it’s not. For example, in the sentence before `e.g.` should be one
word, but `it's` should probably be two (it, \[i\]s). Also, languages
such as Chinese or Japanese do not mark word boundaries using
whitespace.

So, while you could tokenize English text yourself using
e.g. `str_split` and `unnest_longer`, it is better to use the
`unnest_tokens` function for this, which uses the
[tokenizers](https://cran.r-project.org/web/packages/tokenizers/vignettes/introduction-to-tokenizers.html)
package that can deal with most common use cases.

For example, the code below tokenizes three very different texts:

``` r
library(tidytext)
library(tokenizers)
library(tidytext)
texts = tribble(
  ~text, ~author,
  "古池蛙飛び込む水の音", 'Matsuo Bashō',
  "The Power of the Doctor: Jodie Whittaker's dr. Who finale", "Guardian",
  "Our open access #css textbook is published! @damian0604 @carlosarcila https://cssbook.net", "vanatteveldt")
            
texts |> unnest_tokens(word, text, to_lower=F, strip_punct=F)
```

What do the `to_lower` and `strip_punct` arguments do?

# Cleaning text

Before analysing text, it is generally a good idea to first ‘clean it’
with some common steps, such as removing stop words, very rare words,
dealing with multi-word phrases (e.g. “New York”), etc.

As stated above, these steps can be performed on the tidy text ‘token
list’ format using regular tidyverse functions. To show why they are
needed, consider the top words in the US state of the union speeches:

``` r
library(tidyverse)
library(tidytext)
library(sotu)
sotu = add_column(sotu_meta, text=sotu_text) |> 
  as_tibble() 
sotu = unnest_tokens(sotu, word, text)
sotu |> 
  group_by(word) |> 
  summarize(n=n()) |> 
  arrange(-n) |> 
  head()
```

## Stop word removal

As you might have guessed, none of these words are very informative of
the various President’s policy choices. Of course, if you are interested
in communication style or inclusiveness, the difference between ‘I’ and
‘we’ or the use of modal verbs such as ‘should’ or ‘will’ can actually
be quite interesting. However, for most cases we want to remove such
‘stop words’.

This can be done by `anti_join`ing the tokens with a data frame of stop
words, such as the one from the tidytext package:

``` r
data(stop_words)
sotu |> pull(word) |> head() 
sotu_clean = sotu |> anti_join(stop_words)
sotu_clean |> pull(word) |> head()
```

You can also easily use other stop word lists, such as the ones from the
[stopwords]() package.

``` r
library(stopwords)
mystopwords = stopwords(language = 'en', source = 'snowball')
sotu_clean2 = sotu |> filter(!word %in% mystopwords)
sotu_clean2 |> pull(word) |> head()
```

As you can see, the first example removed `great` (which is on the
‘onix’ stop word list), while the second example did not. In fact, there
are many different stop word lists, and `stop_words` actually contains
three different lists. See the documentation for `?stop_words` and
`?stopwords` for more details.

## Trimming overly (in)frequent words

A second useful step can be to trim (or prune) the most infrequent
words. These words are often a relatively large part of the total
vocabulary, but play only a very minor role in most analyses.

For example, the code below groups by word, and then keeps only words
that are used at least 100 times:

``` r
sotu |> pull(word) |> unique() |> length()
sotu_clean3 = sotu_clean |>
  group_by(word) |>
  filter(n() >= 100)
sotu_clean3 |> pull(word) |> unique() |> length()
```

As you can see, although the total number of rows (‘word tokens’, in
jargon) as only decreased slightly, but the number of unique words
(‘word types’) has decreased dramatically. Since in many analyses such
as topic modeling or supervised machine learning performance is (partly)
determined by the number of different words, this can greatly speed up
those analyses and reduce memory usage.  
In fact, I would never run something like a topic model without trimming
a corpus like this.

The threshold used in this example (100) is probably a bit high, but you
can normally safely assume that words that don’t occur in at least 10
documents (or maybe 0.1%-1% of documents) are probably not very
importrant for such quantitative analyses.

# Analyzing and visualizing texts

In case you started here, let’s (re-)activate the packages and construct
the state of the unions data frame:

``` r
library(tidyverse)
library(tidytext)
library(sotu)
data(stop_words)
sotu = add_column(sotu_meta, text=sotu_text) |> 
  as_tibble() |>
  rename(doc_id=X)
```

After importing, tokenizing, and cleaning, it’s time to do some actual
analysis. Of course, there are many different options for this,
including dictionary-based anlayses and supervised and unsupervised
machine learning, for which we have made separate tutorials.

For now, let’s consider simple frequency based analyses: word clouds and
corpus comparisons

## Word frequencies and word clouds

Since the token list is a regular data frame, we can simply `group_by`
word and `summarize` to get frequency information:

``` r
frequencies = sotu |> 
  unnest_tokens(word, text) |>
  group_by(word) |>
  summarize(termfreq=n(), 
            docfreq=length(unique(doc_id)),
            relfreq=docfreq/nrow(sotu)) |>
  anti_join(stop_words) |>
  arrange(-docfreq) 
frequencies
```

Now, we can make a wordcloud using `ggplot` with the
`geom_text_wordcloud` geom from the `ggwordcloud` package. This geom is
very similar to the regular `geom_text` geom, but it moves around words
to avoid overlap.

``` r
library(ggwordcloud)
frequencies |> 
  slice_max(termfreq, n=200) |>
  ggplot() + 
  geom_text_wordcloud(aes(label=word, size=termfreq, color=relfreq))
```

## Corpus comparison

Finally, let’s compare word use of two presidents, for example Obama and
Trump. First, we can compute the frequency of each word for each
president:

``` r
table(sotu$president)
comparison = sotu |> 
  filter(president %in% c("Donald Trump", "Barack Obama")) |>
  mutate(president=str_remove_all(president, ".* ")) |>
  unnest_tokens(word, text) |>
  group_by(president, word) |>
  summarize(n=n()) |>
  pivot_wider(names_from=president, values_from=n, values_fill=0) |>
  arrange(-Trump)
head(comparison)
```

Now, we can compare the relative frequencies: is Obama more likely to
use this word than Trump?

``` r
comparison = comparison |> 
  mutate(Obama_prop=(Obama+1)/sum(Obama),
         Trump_prop=(Trump+1)/sum(Trump),
         diff=Trump_prop / Obama_prop,
         total=Obama+Trump,
         logdiff=log(diff)) 
comparison |> arrange(-diff) |> head()
```

So, Trump’s speeches is much more likely to contain the word applause,
and in contrast to Obama, Trump used the words ISIS and beautiful a
number of times.

(Note that we ‘smoothed’ the frequencies by adding one to each
frequency, preventing division by zero and allowing some form of
comparison when the other did not use a word at all.)

We can also plot this, taking a selection of words and using the
difference as the horizontal axis:

``` r
bind_rows(slice_max(comparison, diff, n=50),
          slice_max(comparison, -diff, n=50),
          slice_max(comparison, total, n=50)) |>
  ggplot() + 
  geom_text_wordcloud(aes(label=word, x=logdiff, size=total, color=diff)) +
  scale_color_gradient2(low="blue", high="red", mid="purple", midpoint = 1)+
  scale_size_continuous(range = c(2,10)) +
  theme_void()
```

# Where next?

To learn more about text processing in R, see also our other tutorials:

- [Topic modeling with
  Tidytext](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/tidytext-topicmodel.md)
- [Dictionary analysis with
  Tidytext](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/tidytext-dictionary.md)
- [Lingusitic preprocessing with Spacy(r) and
  UDPipe](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/r_text_nlp.md)
