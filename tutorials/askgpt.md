Using AskGPT
================
Wouter van Atteveldt
September 2024

- [Calling GPT from R](#calling-gpt-from-r)
  - [Installing and setting up
    AskGPT](#installing-and-setting-up-askgpt)
  - [Asking for help for specific packages or
    functions](#asking-for-help-for-specific-packages-or-functions)
- [R and RStudio integration](#r-and-rstudio-integration)
  - [Help!](#help)
  - [Improving and explaining code](#improving-and-explaining-code)

# Calling GPT from R

Like many companies, OpenAI (maker of ChatGPT) has an API that makes it
easy to call it from R or other languages. In this tutorial, you will
learn how to use the `askGPT` package (created by my colleague Johannes
Gruber) to send questions to GPT automatically.

For this, you will need an **API key**. The instructor might make one
available for your, otherwise you can [make one at
openai.com](https://platform.openai.com/signup). There are some costs
involved, but it’s [pretty cheap](https://openai.com/api/pricing/) – you
can make hundreds of calls for a single euro.

Check out his [blog
post](https://www.johannesbgruber.eu/post/2023-04-02-introducing-askgpt-a-chat-interface-that-helps-you-to-learn-r/)
for more information!

## Installing and setting up AskGPT

As usual, you can install askgpt in the packages pane or by calling
`install.packages("askgpt")`. After that, you provide your API key using
the login() function. The first time, this will ask you to provide the
key and provide some information on how to make one. After doing this,
it will cache (remember) this key so the next time you call it nothing
needs to be done.

``` r
library(askgpt)
login()
```

After logging in, you can use the `askgpt` function to ask a question to
askgpt:

``` r
askgpt("How do I plot a line graph in R using ggplot?")
```

GPT remembers the conversation, so you can e.g. ask for extra
information. For example, when I make this tutorial, GPT gave me a
number of options for line plots. Number 5 included a call to `labs` to
set the axis labels and titles. Let’s ask for some more information on
that one:

``` r
askgpt("Can you explain to me in a bit more detail how option 5 works?")
```

(Note that you might need to adapt the follow up question based on GPT’s
answer to the question above, as GPT is not deterministic and is also
improved over time)

## Asking for help for specific packages or functions

Let’s look at the simple plot code introduced in the ggplot handout:

``` r
demographics <- read_csv("https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/dutch_demographics.csv")
ggplot(demographics, x = v57_density, y = c_65plus, color = v132_income) + geom_point()
```

Can you ask GPT how to change the color scale to go from white to dark
green? Does the answer help?

Tip: it helps to be as specific as possible, especially naming the
function (ggplot) or package that you want help on.

# R and RStudio integration

There are some R (and RStudio) specific features in the package:

## Help!

One specific use case is asking for help on an error message. To use
this, first run `log_init()` to give askGPT access to the error log.
Then, if you get an error, you can use the special prompt
`askgpt("help!")` to get information on the last error:

For example, suppose we are tring to filter our dataframe to only
include Almere:

``` r
# don't forget to call log_init()
log_init()
filter(demographics, gemeente="Almere")
```

This gives an error message, with actually a fairly good explanation.
However, in case we still don’t understand what’s wrong, we can ask gpt
for `help!`

``` r
askgpt("help!")
```

## Improving and explaining code

The help command in the last case works because there was an error
message that GPT could understand and explain. Sometimes, however, the
error message does not provide enough information or maybe there isn’t
even an error message.

For example, consider this code:

``` r
ggplot(demographics) + geom_point(x = v57_density, y = c_65plus)
askgpt("help!")
```

The ggplot call will give an error message (do you understand why?).
Does the information from `help!` actually help?

The problem is that gpt won’t understand the context of the error, so it
will only know that the name `v57_density` does not exist as an object.
The underlying problem, that it should have been wrapped in an `aes()`
call to make it clear that the name refers to a column in the
`demographics` data frame, is not clear without looking at the source
code, which `help!` does not have access to.

To ask GPT to improve the code, you can select the code and ask for GPT
to improve it using the “Improve code” addin (Using the *Addins* button
in the top toolbar in RStudio). Does that help?

Finally, you can also ask GPT to explain specific code by selecting the
code and choosing “Explain code” in the same addin menu.

Have fun! :)
