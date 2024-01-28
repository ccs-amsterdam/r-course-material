Running Large Language Models via the Huggingface API, and learning a
bit about APIs on the way
================
Kasper Welbers, Philipp Masuer & Wouter van Atteveldt
2024-01

- [Introduction](#introduction)
  - [Setting up a hugging face
    account](#setting-up-a-hugging-face-account)
- [Using the Hugging Face Inference
  API](#using-the-hugging-face-inference-api)
  - [What can we do with the Hugging Face
    API](#what-can-we-do-with-the-hugging-face-api)
  - [How can we use this API from within
    R](#how-can-we-use-this-api-from-within-r)
  - [Creating a beautiful function](#creating-a-beautiful-function)
  - [Wrap-up](#wrap-up)
- [Creating a more general function](#creating-a-more-general-function)
  - [Using our cool new function to run all sorts of
    models](#using-our-cool-new-function-to-run-all-sorts-of-models)
    - [Summarization](#summarization)
    - [Named Entity Recognition](#named-entity-recognition)
    - [Emotion classification](#emotion-classification)
  - [Wrap-up](#wrap-up-1)

# Introduction

[Hugging Face](https://huggingface.co/) is a popular platform and
community for open-source sharing of Large Language Models and datasets.
In addition to letting you search and download all sorts of models to
use them on your own computer, Hugging Face provides an API for running
models on their servers. This API also includes a free-tier, which we’ll
use in this tutorial to play around with LLMs.

If you are not yet familiar with how APIs work, don’t worry! We’ll make
this tutorial a quick introduction to using API’s as well.

## Setting up a hugging face account

Although we can assess the Hugging Face API anonymously, it is better to
register and use the API via your own account, as this will increase the
rate limit for API prompts. Registering is free and easy:

1.  Go to <https://www.huggingface.co>

2.  Click on “Sign Up” in the upper right corner and follow the steps.

3.  Once you have an account, click on your account picture in the upper
    right corner and click on settings:

4.  Click on “Access Tokens” on the left and create a new one.

5.  Copy the Access Token (the long string of random characters). This
    is kind of like your password for connecting to the API. To use it,
    we’ll now directly enter it in R. Note, however, that these keys are
    sensitive information (especially if you have a paid account), so
    normally you would want to avoid storing them visibly in your code.

``` r
token = "PASTE YOUR ACCESS TOKEN HERE"
```

# Using the Hugging Face Inference API

Now we’re going to set up a small routine for talking to the Hugging
Face API. There is probably some R package out there that can do this
for you, but it’s really not that difficult, and we want to show you how
to do this yourself. We’ll first walk throug the steps, and then wrap
them up in our own custom function!

We’ll be using the httr2 library, which provides a powerfull framework
for making HTTP requests. In simple terms, it allows us to talk to the
Hugging Face API.

``` r
library(httr2)
```

## What can we do with the Hugging Face API

The way Hugging Face works is that any user can upload models. For
example, Moritz Laurer has created and uploaded a cool zero-shot model:
<https://huggingface.co/MoritzLaurer/deberta-v3-large-zeroshot-v1.1-all-33>

If you go to that model page, you can see some details about the model.
You can also see a section labeled the **Inference API**. In this case,
the Inference API allows you to quickly test what the model does. But
it’s this exact Inference API that we will in a minute also talk with
from within R!

At the top of the Inference API section you see that the task this model
performs is [Zero-Shot
Classification](https://huggingface.co/tasks/zero-shot-classification),
and if you click this link it brings you to the Hugging Face page
describing what this task does.

At the [Zero-Shot
Classification](https://huggingface.co/tasks/zero-shot-classification)
page you see a nice visualization of how you can use this model. As
input you need to provide a **Text input** and **Candidate Labels**.
Here you basically say: For this input text, tell me which of these
candidate labels best describes the text. The output of the model tells
you this by assigning a score to each label.

## How can we use this API from within R

So now that we know what model we want to use
(MoritzLaurer/deberta-v3-large-zeroshot-v1.1-all-33) and what this model
can do, we can set up our code for using the Hugging Face Inference API
to use the model from within R. For this we just need to know three
things:

- How to tell Hugging Face API what model we want to use
- How to provide the input values
- How to authenticate ourselves with our shiny new **token**

This information can be found in the
[documentation](https://huggingface.co/docs/api-inference/detailed_parameters),
but we’ll spoil the answers because we’re cool like that:

- We specify the model in the **endpoint**. An API endpoint is basically
  just a URL that indicates what resource on a server you want to
  interact with. To use the Inference API for a specific model, the
  endpoint is:
  `https://api-inference.huggingface.co/models/[author]/[modelname]`.
- The [documentation for zero-shot classification
  tasks](https://huggingface.co/docs/api-inference/detailed_parameters#zero-shot-classification-task)
  shows us that we need to make a **POST request** to the API endpoint
  in which we include the input text and candidate labels in a specific
  JSON format (which we show below).
- In the same documentation we see that to authenticate, we need to
  include an Authorization header, and provide the value “Bearer \[our
  shiny token\]”. This is a commonly used standard, that is readily
  supported by httr2.

Without further ado, let us show you the R code, and then we’ll go
through it step-by-step.

``` r
library(tidyverse)
library(httr2)

endpoint = "https://api-inference.huggingface.co/models/MoritzLaurer/deberta-v3-large-zeroshot-v1.1-all-33"
inputs = c("Hi, I recently bought a device from your company but it is not working as advertised and I would like to get",
           "I am so going to sue you for selling me this crap!!")
parameters = list(candidate_labels = c("refund", "legal", "faq"))

# Perform the request. Note that that sometimes you might get an "HTTP 503 Service Unavailable" error. 
# This simply means Hugging Face is too busy for us freewheelers. If so, just try again a few times. 
resp = request(endpoint) |>
  req_headers(Authorization = paste("Bearer", token)) |>
  req_body_json(list(inputs = inputs, parameters = parameters)) |>
  req_perform()

resp |> resp_body_json(simplifyVector = T) 
```

Tada!! Hugging Face now responded with the labels per input text
(sequence), sorted by which label has the best fit. According to the
model, the first text best matches the “refund” label, and the second
text the “legal” label, which seems appropriate.

Let’s summarize what you did;

- You specified your input text and the candidate labels. Note that we
  specified multiple input texts, because that’s allowed.
- You made a request to the API endpoint for the specific model you
  wanted to use
- You added an Authentication header (req_headers) to show Hugging Face
  your token to let Hugging Face to know it’s you
- You provided a JSON request body (req_body_json) with your input
  values. (by providing a body, httr2 automatically makes this a POST
  request)
- The previous steps created the request. With req_perform, you send
  your request to Hugging Face.
- You now performed the request and received a response (resp). In the
  response, Hugging Face returns you the output in a JSON format. Our
  last step is to parse this response (resp_body_json)

## Creating a beautiful function

So now we know how to talk with Hugging Face. But it’s not very
convenient to always have to perform all this code for every single
request. So this a great use case for creating our own function.

Now, we first need to decide the scope of our function. On the one hand,
we could make a very general function, that allows us to use any model
on Hugging Face with any kind of parameters. On the other hand, we could
make a more specialized function that just let’s us use Moritz’s model
for this one particular task.

Let’s first create the more specialized function, because this is a bit
easier. In our specialized function, we’ll always use the same model, so
the only input we need from the user is (1) their token, (2) what the
input text is, and (3) what the candidate labels are.

As output, let’s say that we don’t care about the specific label scores.
We just want the highest scoring label.

``` r
ask_moritz <- function(token, texts, candidate_labels) {
  # indicate that this function needs the following packages
  require(tidyverse) 
  require(httr2) 
  
  # ask Hugging Face 
  output = request("https://api-inference.huggingface.co/models/MoritzLaurer/deberta-v3-large-zeroshot-v1.1-all-33") |>
    req_headers("Authorization" = paste("Bearer", token)) |>
    req_body_json(list(inputs = texts, parameters = list(candidate_labels = candidate_labels))) |>
    req_perform() |>
    resp_body_json(simplifyVector = T)

  # return only the top label. The output looks differently depending on the number of inputs,
  # so we need two approaches
  if (length(texts) == 1) {
    return(tibble(input = output$sequence, label=first(output$labels)))
  } else {
    output$label = sapply(output$labels, first)
    return(select(output, input = sequence, label))
  }
}
```

So now we can just call this function to label some texts.

``` r
texts = c('this is a test', 
          'this is an example')

ask_moritz(token, texts, candidate_labels=c('test', 'example'))
```

Now off course, there are some limitations here. First of all, Hugging
Face throws around the “HTTP 503 Service Unavailable” error quite a lot.
Simply put, if you want to use this on any serious scale, you’ll need to
pay them. Secondly, there are limits to how many texts we can provide,
and how long these texts can be. If we need to classify many texts,
we’ll need to send them to Hugging Face in batches. I don’t actually
know how many texts we can send per request, or how long these texts can
be (the documentation is a bit hazy), but generally speaking, assume
it’s limited when using a free account.

## Wrap-up

In short, the current function we created is not ready for using it in
practice to perform content analysis. For that, you’ll need to spend
some money, and deal with some practical issues. But it does hopefully
show you the potential of using API’s run your LLMs on servers. In many
practical use cases, paying a company like Hugging Face or OpenAi to use
their API can be cheaper and easier than purchasing, installing and
maintaining the equipment you’d need to run these models on your own
device.

# Creating a more general function

Now, as a small bonus, let’s get back to our dilemma of how general our
function should be. We initially made simple function for just using
Moritz’s model, but we can also make a more general function that let’s
us select the model, and let’s us provide the input parameters for
different types of models (not just the zero-shot classifier).

We’ll also implement a better way of dealing with that annoying 503
(service unavailable) error. When Hugging Face throws this error, it
actually also tells us how long it expects to be unavailable. So now
when we get a 503 we automatically retry after this estimated time.

``` r
ask_huggingface <- function(token, model, texts, ...) {
  # indicate that this function needs the following packages
  require(tidyverse) 
  require(httr2) 
  
  endpoint = paste0("https://api-inference.huggingface.co/models/", model)
  body = list(inputs = texts)
  if (length(list(...)) > 0) body$parameters = list(...) 
  
  retry_after <- function(resp) {
    message('Hugging Face is busy, and asks us to wait...')
    resp_body_json(resp)$estimated_time
  }

  request(endpoint) |>
    req_headers("Authorization" = paste("Bearer", token)) |>
    req_body_json(body) |>
    req_retry(max_seconds=120, after = retry_after) |>
    req_perform() |>
    resp_body_json(simplifyVector = T)
}
```

Most stuff here is the same as last time. One thing that’s changed is
that the user now needs to specify the model. This just needs to be the
last part of the url: \[author\]/\[modelname\].

A bit more complicated is how to pass the parameters. Before the model
was specifically a zero-shot classifier, so we knew that we just had the
“inputs” and “candidate_labels” input values. Since we’re focusing on
text models, we can assume we’ll always need texts, but the other
parameters depend on the type of model. The trick we used here is the
weird parameters **…**. This captures all other names arguments passed
into the function. By saying `parameters = list(...)` we then create a
list containing these named arguments. Perhaps an example makes this
more obvious.

``` r
arguments_to_list <- function(...) {
  list(...)
}
arguments_to_list(candidate_labels = c('yes','no'), more_arguments = 42)
```

So what this means for our function, is that any parameters the Hugging
Face model needs, we can just pass as parameters to our function. Long
story short, if we want to use this generalized function to run the same
zero-shot classifier as above, it would look like this.

``` r
ask_huggingface(token, 
      model = "MoritzLaurer/deberta-v3-large-zeroshot-v1.1-all-33", 
      texts = c('a test', 'an example'), 
      candidate_labels=c('test','example'),
      simplify_output=T)
```

It works! Do note that there are currently two downsides of making our
function more general:

- Users need to know themselves what type of model they’re using, and
  what parameters the Hugging Face API expects them to provide.
- We can no longer make a nicer output, because we don’t know what type
  of output the model will give us. Currently we just return a list
  based on the JSON output that Hugging Face gives us. We’ve added a
  simplify_output argument, which can help a bit in some cases, but
  that’s it.

If our goal would be to really develop a nice package for working with
the Hugging Face APi, we would ideally do a bit more work. We could then
make special functions for every type of model, with documentation for
what parameters to use, and always returning the output in a nice
tibble. Luckily that’s not our goal, because it sounds like a lot of
tedious work.

## Using our cool new function to run all sorts of models

If you go to the [Hugging Face Model
page](https://huggingface.co/models) you’ll find tons of models that you
might now use with our function. Off course, not all models will work.
Firstly, our function is only aimed at text/NLP. Secondly, not every
model might be available via the API (if you view the model, you should
see whether it has the Inference API section)

### Summarization

using the
[facebook/bart-large-cnn](https://huggingface.co/facebook/bart-large-cnn)
model

``` r
text = "The tower is 324 metres (1,063 ft) tall, about the same height as an 81-storey building, and the tallest structure in Paris. Its base is square, measuring 125 metres (410 ft) on each side. During its construction, the Eiffel Tower surpassed the Washington Monument to become the tallest man-made structure in the world, a title it held for 41 years until the Chrysler Building in New York City was finished in 1930. It was the first structure to reach a height of 300 metres. Due to the addition of a broadcasting aerial at the top of the tower in 1957, it is now taller than the Chrysler Building by 5.2 metres (17 ft). Excluding transmitters, the Eiffel Tower is the second tallest free-standing structure in France after the Millau Viaduct."

ask_huggingface(token, model = "facebook/bart-large-cnn", texts=text)
```

### Named Entity Recognition

using the
[dslim/bert-base-NER](https://huggingface.co/dslim/bert-base-NER) model

``` r
text = "My name is Sarah and I live in London"
ask_huggingface(token, model = "dslim/bert-base-NER", texts=texts)
```

### Emotion classification

using the
[SamLowe/roberta-base-go_emotions](https://huggingface.co/SamLowe/roberta-base-go_emotions)
model

``` r
texts = c("I am not having a great day",
          "I am having a great day!")
ask_huggingface(token, model = "SamLowe/roberta-base-go_emotions", texts=texts)
```

## Wrap-up

Ok, that’s about enough for now. Go ahead and have some fun with this.
Try some different models.
