LLMs part 3: running generative models remotely on (paid) APIs
================
2025-01-27

- [Introduction](#introduction)
- [The tidyllm package](#the-tidyllm-package)
  - [Getting your Google Gemini API
    key](#getting-your-google-gemini-api-key)
  - [Holding a conversation](#holding-a-conversation)
- [Zero-shot classification](#zero-shot-classification)
  - [Using structured output](#using-structured-output)

## Introduction

In the previous tutorial we ran models locally. This has many benefits,
but the obvious limitation is how fast your computer is. For the models
that really put the LARGE in LLM, you’ll need a bigger boat.

In this tutorial we’ll show you how to use the APIs from big players in
this market, like OpenAI and Antrophic. You do have to pay for these
services, but the prices are really quite modest (and certainly much
cheaper than human coders).

## The tidyllm package

Before we showed you how to talk to APIs from R using the httr2 package.
This time we’ll go easy on ourselves by just using a package that
handles this stuff for us. Specifically, we’ll use the tidyllm package,
which has support for several large providers.

``` r
library(tidyllm)
```

To try this out, we’ll use Google Gemini, because they have a [free
tier](https://ai.google.dev/pricing#1_5flash). This only allows you to
do a few requests per minute with limited input and output size and not
the best model, but that’s sufficient for just testing it out. If you
want to scale things up, you just need to put in a few dollars. The
process works basically the same for all of the providers.

### Getting your Google Gemini API key

To get your API key, go to [Google AI
studio](https://aistudio.google.com/app/apikey). Sign-in (which is free,
and you don’t yet have to provide billing information), and go to the
Get API key tab. When you create an API key, you see the ‘Plan’ that
it’s on. If you didn’t set up billing, it should say ‘Free’, and you can
try it out without worries. Copy your API key, and use the following
code to use it in your R session.

``` r
Sys.setenv(GOOGLE_API_KEY = "your API key goes here")
```

### Holding a conversation

And really, that’s about all it takes. Now you can use use the tidyllm
`llm_message` function to create a message, and send it to a chatbot.
Since we’re using Google, we need to use `gemini()`.

``` r
conversation = llm_message("What is the cutest animal?") |>
  chat(gemini())

conversation |> get_reply()
```

    ## [1] "There's no single answer to what the cutest animal is!  Cutest is entirely subjective and depends on individual preferences.  What one person finds adorable, another might find unimpressive.  Different people are drawn to different features like big eyes, fluffy fur, tiny size, or playful behavior.\n"

If you want to continue the conversation, you just add new messages to
the conversation

``` r
conversation = conversation |>
  llm_message("If cuteness was not subjective, what would be the cutest animal?") |>
  chat(gemini())

conversation |> get_reply()
```

    ## [1] "If cuteness were objectively measurable, based on things like features that trigger positive emotional responses in the brain (like large eyes relative to head size, soft fur, rounded shapes, etc.),  there's no single definitive answer.  Different researchers might create different algorithms or weighting systems and come up with different results.  However, animals frequently cited as contenders in *subjective* cuteness contests would likely score high in such an objective system.  Animals like:\n\n* **Bunnies (rabbits):**  Their large eyes, fluffy tails, and generally docile demeanor often trigger positive responses.\n* **Kittens:** Similar to bunnies, their features are very frequently associated with cuteness.\n* **Puppies:**  Again, similar features as kittens and bunnies, plus playful behavior, contribute to a perception of cuteness.\n* **Panda cubs:**  Their clumsy movements and endearing expressions frequently charm people.\n\n\nIt's important to stress that even with an objective measure, the \"cutest\" animal would be a matter of the specific criteria used in the objective system itself.\n"

## Zero-shot classification

We can off course use this for zero shot classification. One way is to
simply start a conversation in which we explain the talk to the chatbot.
Then we can re-use this conversation to perform the annotations.

``` r
annotator = llm_message('You are an expert at manual content analysis. Your task is to classify the sentiment of the following text. You will only respond with the sentiment class, which can be "positive", "negative" or "neutral"') |>
  chat(gemini())

annotator |> llm_message("It was a terribly cold day in Paris") |> chat(gemini())  |> get_reply()
```

    ## [1] "Negative\n"

``` r
annotator |> llm_message("It was a nice, warm day in Paris") |> chat(gemini()) |> get_reply()
```

    ## [1] "Positive\n"

### Using structured output

One of the tricky parts is always to make sure that the model gives you
an answers in the specific format that you need. For instance, if you
ask it to do sentiment analysis, you need to instruct it to really only
return the exact words “positive”, “negative” or “neutral” (or whatever
classes you want).

Just strictly asking for a specific type of output works pretty well,
but is still prone to error. Especially if you’re asking for a more
complicated output. A better way to achieve this is to work with
**structured outputs**. Simply put, this is a formal way of describing
to the model what the output could be. We provide a **schema**, and when
the LLM generates the output tokens, it is restricted to producing
tokens that match the schema.

Note that only some of the providers (currently openai, gemini and
ollama) support **structured output**!

#### Defining a schema

The schemas are often specified in JSON format, but the tidyllm package
also has a nice function to help us build the JSON. You first provide a
name for the schema (here we call it “annotation schema”). Then you just
provide the names of the fields (think ‘variables’) that you want to get
in the answer. Per field you then specify the ‘type’, like
**character**, or **numeric**. You can request for specific classes with
**factor(class1, class2)**. And if you add **\[\]**, like in
**character\[\]**, it means give me a list of values of this type.

Here’s an example of a simple schema where we ask for a topic in
character format, a list of entities in character format, and a
sentiment with specific values “negative”, “positive” or “neutral”.

``` r
json_schema = tidyllm_schema(
  name = "annotation schema",
  topic = "character",
  entities = "character[]",
  sentiment = "factor(negative, positive, neutral)"
)
```

Now we can create an annotator conversation just like above. When we
provide the text, we specify that we want the response to be in the
format of our JSON schema.

``` r
annotator = llm_message('You are an expert at manual content analysis. I will show you a text, and your task is to annotate three components. First, the topic of the text. Second, you need to list all the named entities. Third, you classify the sentiment of the text as either "positive", "negative" or "neutral".') |>
  chat(gemini())

response = annotator |>
  llm_message("Anna and Bob hate skeeing") |>
  chat(gemini(), .json_schema = json_schema)

response |> get_reply()
```

    ## [1] "{\"entities\": [\"Anna\", \"Bob\"], \"sentiment\": \"negative\", \"topic\": \"skiing\"}"

Pretty cool huh!! Since we know that our response is in a valid JSON
format, we can now parse it into R. You could do this yourself, but
tidyllm also has the convenient `get_reply_data` function that does this
for you.

``` r
response |> get_reply_data()
```

    ## $entities
    ## [1] "Anna" "Bob" 
    ## 
    ## $sentiment
    ## [1] "negative"
    ## 
    ## $topic
    ## [1] "skiing"
