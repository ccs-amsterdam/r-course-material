Supervised Text Classification
================
Wouter van Atteveldt & Kasper Welbers
2022-01

- [Getting training data](#getting-training-data)
- [Supervised machine learning with
  tidymodels](#supervised-machine-learning-with-tidymodels)
  - [Using `textrecipes` to turn text into
    features](#using-textrecipes-to-turn-text-into-features)
  - [Fitting and testing a model](#fitting-and-testing-a-model)
  - [Using embeddings as features](#using-embeddings-as-features)

This handout contains a brief introduction to using supervised machine
learning for text classification in R. In particular, we will show how
[tidymodels](machine_learning.md) can be used to train and fit
supervised text classification models.

In this tutorial, we use the following packages: (note that there is no
need to install packages again if you previously installed them)

To install the various packages (of course, you can skip this step for
packages already installed on your machine):

``` r
install.packages("tidyverse")
install.packages("tidymodels")
install.packages("textrecipes")
```

## Getting training data

For machine learning, we need annotated training data. Fortunately,
there are many review data files available for free. For this exercise,
we will use a set of Amazon movie reviews cached as CSV on our github
site. See <http://deepyeti.ucsd.edu/jianmo/amazon/index.html> for other
(and more up-to-date) Amazon product reviews.

``` r
library(tidyverse)
reviews = read_csv("https://raw.githubusercontent.com/ccs-amsterdam/r-course-material/master/data/reviews2.csv")
head(reviews)
table(reviews$overall)
```

As you can see, there’s the star rating (dichotomised to positive and
negative), a summary text, the full review text, and the ID of the
reviewer and the product (ASIN).

Before getting started, let’s define a two-class rating from the numeric
overall rating:

``` r
reviews = mutate(reviews, rating=as.factor(ifelse(overall==5, "good", "bad")))
```

The goal for this tutorial is supervised sentiment analysis, i.e. to
predict the star rating given the review text.

# Supervised machine learning with tidymodels

Using the preprocessing steps from
[textrecipes](https://textrecipes.tidymodels.org), we can also use
tidymodels to test our data.

Although this involves a bit more steps if you are already using
quanteda, using tidymodels allows more flexibility in selecting and
tuning the best models.

The example below will quickly show how to train and test a model using
these recipes. See the [machine learning with
Tidymodels](machine_learning.md) handout and/or the [tidyverse
documentation](https://tidyverse.org) for more information.

## Using `textrecipes` to turn text into features

``` r
library(tidymodels)
library(textrecipes)
rec = recipe(rating ~ summary + reviewText, data=reviews) |>
  step_tokenize(all_predictors())  |>
  step_tokenfilter(all_predictors(), min_times = 3) |>
  step_tf(all_predictors())
```

We can inspect the results of the preprocessing by `prepping` the recipe
and baking the training data:

``` r
rec |> 
  prep(reviews) |>
  bake(new_data=NULL) |> 
  select(1:10)
```

## Fitting and testing a model

First, we create a *worflow* from the recipe and model specification.
Let’s start with a naive bayes model:

``` r
library(discrim)
lr_workflow = workflow() |>
  add_recipe(rec) |>
  add_model(logistic_reg(mixture = 0, penalty = 0.1))
```

Now, we can split our data, fit the model on the train data, and
validate it on the test data:

``` r
split = initial_split(reviews)
m <- fit(lr_workflow, data = training(split))
predict(m, new_data=testing(split)) |>
  bind_cols(select(testing(split), rating)) |>
  rename(predicted=.pred_class, actual=rating) |>
  metrics(truth = actual, estimate = predicted)
```

To see which words are the most important predictors, we can use the
`vip` package to extract the predictors, and then use regular
tidyverse/ggplot functions to visualize it:

``` r
m |> extract_fit_parsnip() |>
  vip::vi() |> 
  group_by(Sign) |>
  top_n(20, wt = abs(Importance)) %>%
  ungroup() |>
  mutate(
    Importance = abs(Importance),
    Variable = str_remove(Variable, "tf_"),
    Variable = fct_reorder(Variable, Importance)
  ) |>
  ggplot(aes(x = Importance, y = Variable, fill = Sign)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~Sign, scales = "free_y") +
  labs(y = NULL)
```

The positive predictors make perfect sense: *great*, *best*,
*excellent*, etc. So, interestingly *not*, *but*, and *ok* are the best
negative predictors, and *good* in the summary is also not a good sign.
This makes it interesting to see if using ngrams will help performance,
as it is quite possible that it is *not good*, rather than good. Have a
look at the [textrecipes
documentation](https://textrecipes.tidymodels.org/reference/) to see the
possibilities for text preprocessing.

Also, we just tried out a regularization penalty of 0.1, and it is quite
possible that this is not the best choice possible. Thus, it is a good
idea to now do some hyperparameter tuning for the regularization penalty
and other parameters. Take a look at the [machine learning
handout](machine_learning.md) and/or the [tune
documentation](https://tune.tidymodels.org/) to see how to do parameter
tuning.

Of course, you can also try one of the other classification models in
[parsnip](https://parsnip.tidymodels.org/), and/or try a regression
model instead to predict the actual star value.

## Using embeddings as features

Rather than using word frequencies (i.e. DTM columns) as features, we
can also use word embedding dimensions. First, let’s download these
embeddings using the textdata package:

``` r
library(textdata)
# Note, if you get a timeout you might want to manually download http://nlp.stanford.edu/data/glove.6B.zip,
# and copy it to ~/.cache/textdata/glove6b. See ?embedding_glove for more info
embeddings = textdata::embedding_glove6b()
```

Now, you can manually join these embeddings with the tokens, and use
these columns as numerical predictors.

To make this a bit easier, `textrecipes` contains a step to do this.
Note that this recipe seems to assume that there is a single column
labeled `text`, so we merge the summary and reviewText columns:

``` r
library(textrecipes)
reviews_text <- reviews |>
  mutate(text = str_c(summary, reviewText))
embedding_recipe = recipe(rating ~ text, data=reviews_text) |>
  step_tokenize(all_predictors())  |>
  step_word_embeddings(text, embeddings = embeddings, aggregation='mean', keep_original_cols=FALSE) 
```

Let’s see how that preps the data:

``` r
embedding_recipe |> prep() |> bake(new_data = NULL) |> select(1:10)
```

So you can see, for every document it computed the mean dimension
loading

We can now use that as before, e.g.:

``` r
library(discrim)
library(tidymodels)

embedding_workflow = workflow() |>
  add_recipe(embedding_recipe) |>
  add_model(logistic_reg(mixture = 0, penalty = 0.1))

split = initial_split(reviews_text)

m <- fit(embedding_workflow, data = training(split))
predict(m, new_data=testing(split)) |>
  bind_cols(select(testing(split), rating)) |>
  rename(predicted=.pred_class, actual=rating) |>
  metrics(truth = actual, estimate = predicted)
```

Did it acutally perform better in this case? Why would that be the case?
Can you think of ways to improve this?
