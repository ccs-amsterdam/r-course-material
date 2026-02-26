Dealing with images in R
================

# Downloading and handling images

As a first step to image analysis, you need to acquire the source
material. For now, let’s assume we have a data frame with image URLs and
other relevant information, for example politicians and gender:

``` r
library(tidyverse)

images <- tribble(
  ~name, ~gender, ~url,
    "merkel", "female", "https://upload.wikimedia.org/wikipedia/commons/d/d7/Angela_Merkel_11.jpg",
    "obama", "male", "https://upload.wikimedia.org/wikipedia/commons/d/d1/Barack_Obama_Fold.jpg",
    "rutte", "male", "https://upload.wikimedia.org/wikipedia/commons/c/cd/Mark_Rutte.jpg",  
    "meloni", "female", "https://upload.wikimedia.org/wikipedia/commons/7/78/Giorgia_meloni.jpg"
  )
```

To store the images locally, we can use the `download.file` function. To
make it easy to run this for each politician, let’s define a helper
function to download the images as needed:

``` r
download_image <- function(name, url, ...) {
  destfile = paste0("tutorial_images/", name, ".jpg")
  if (!file.exists(destfile)) 
    download.file(url, destfile, mode = "wb", headers=c("User-Agent" = "RTutorial/1.0"))
} 
```

Now, we can use the `pwalk` function to call this function for each row
of our data frame. Note that this is why I included the ellipsis (`...`)
in the function arguments: R will call it with each column from the data
frame, and without the ellipsis it would throw an error about the
unexpected ‘gender’ argument.

``` r
dir.create("tutorial_images", showWarnings = F)
pwalk(images, download_image, .progress = TRUE)
```

Note that `pwalk` and `pmap` are both ways to call a function on each
row of a tibble. In this case, we use `pwalk` because we are performing
an **action** where we care about the ‘side effect’, like downloading a
file or printing a plot. `pwalk` returns the *input data*, which makes
it perfect for the middle of a pipe since we can just continue with the
original data.

In most cases, we want to use a function to **transform data** rather
than execute an action. For this we can use `pmap` (or `map` on single
columns/vectors rather than whole data frames). This returns the output
of each function call, which is ideal to continue processing the data.

## Preprocessing images with Magick

Imagemagick is a powerful tool to deal with images which can be accessed
with the R `magick` library.

For example, we can use `image_read` and `image_info` to see basic
information of our images

``` r
library(magick)
paste0("tutorial_images/", images$name, ".jpg") |>
  image_read() |>
  image_info() |> 
  add_column(name=images$name)
```

    # A tibble: 4 × 8
      format width height colorspace matte filesize density name  
      <chr>  <int>  <int> <chr>      <lgl>    <int> <chr>   <chr> 
    1 JPEG    3000   3000 sRGB       FALSE  1851560 72x72   merkel
    2 JPEG     677   1012 sRGB       FALSE   588809 100x100 obama 
    3 JPEG    2922   2238 sRGB       FALSE  1139764 240x240 rutte 
    4 JPEG    1070   2224 sRGB       FALSE  1561131 216x216 meloni

As you can see, the image sizes vary from \~1 to \~10 megapixels and
from portrait to square and even landscape images. Let’s resize all
images to be a square 300x300:

``` r
preprocess_image <- function(name, ...) {
  img <- paste0("tutorial_images/", name, ".jpg") |>
    image_read() |>
    image_resize("300x300^") |>
    image_extent("300x300", gravity = "Center", color = "white")
  tibble(name=name, img=list(img))
}
processed_images <- pmap(images, preprocess_image) |> list_rbind() 
images <- left_join(images, processed_images)
images
```

    # A tibble: 4 × 4
      name   gender url                                                   img       
      <chr>  <chr>  <chr>                                                 <list>    
    1 merkel female https://upload.wikimedia.org/wikipedia/commons/d/d7/… <magck-mg>
    2 obama  male   https://upload.wikimedia.org/wikipedia/commons/d/d1/… <magck-mg>
    3 rutte  male   https://upload.wikimedia.org/wikipedia/commons/c/cd/… <magck-mg>
    4 meloni female https://upload.wikimedia.org/wikipedia/commons/7/78/… <magck-mg>

Note the use of `pmap` as before, but now we return a tibble with the
name as a column, and the image, wrapped in a list, as a second column.
This allows us the join the processed images with the metadata so we now
have all information in one place

Also note this results in **cropped** images because the `^` in
`300x300^` instructs Magick to resize the image based on the smallest
dimension, ensuring the entire 300x300 area is filled even if the other
dimension overflows. The `image_extent` makes the actual change to the
canvas.

To see the result, we can simply select a single image:

``` r
images |> filter(name == "obama") |> pull(img)
```

    [[1]]
    # A tibble: 1 × 7
      format width height colorspace matte filesize density
      <chr>  <int>  <int> <chr>      <lgl>    <int> <chr>  
    1 JPEG     300    300 sRGB       FALSE        0 100x100

What happens if you remove the `^` instead?

## Displaying images with ggplot

We can also incorporate them into ggplot with `image_ggplot`, but this
expects only a single image. So, let’s again make a function to plot one
image with the name as title:

``` r
ggplot_politician <- function(name, img, ...) {
  image_ggplot(img)  + 
    labs(title=name |> str_to_title()) + 
    theme(plot.title = element_text(hjust = 0.5))
}
```

Now, we can use `pmap` as before and combine the four plots in a
`wrap_plots` call:

``` r
library(patchwork)
pmap(images, ggplot_politician) |>
  wrap_plots()
```

![](img/images-patchwork-1.png)

# Help me, Chat! Analyzing images with tidyllm

The easiest and perhaps currently most powerful way to do image analysis
is with LLMs such as OpenAI’s chatGPT or a local (vision-capable) model
which you can run through ollama. In both cases, you can use the tidyllm
package to do the actual analysis.

The example below uses `moondream`, which is a very small vision-capable
LLM which you can install through ollama. To run this example, go to
<https://ollama.com/download> to download ollama, and then use
`ollama pull moondream` to load this model.

This example uses the same `function - pmap - list_rbind()` pattern used
before, which calls the function for each image and returns the result
as a data frame that can be joined back on the `name` column in needed.

Note that unfortunately tidyllm cannot use the image directly from our
data frame, so we write it to a temporary file which we then delete. We
could of course also write all the preprocessed images to disk rather
than keep them in memory.

``` r
library(tidyllm)

describe_politician <- function(name, img, ...) {
  tmp <- tempfile(fileext = ".png")
  image_write(img, path = tmp, format = "png")
  description <- llm_message(
      "Describe the person in this image",
      .imagefile = tmp
    ) |>
      chat(ollama(.model = "moondream")) |>
      get_reply() 
  unlink(tmp)
  tibble(name=name, description=description)
}

pmap(images, describe_politician) |> list_rbind()
```

    # A tibble: 4 × 2
      name   description                                                            
      <chr>  <chr>                                                                  
    1 merkel "\nThe image features a woman with blonde hair, wearing a red jacket. …
    2 obama  "\nThe image features a man dressed in a white shirt and red tie, stan…
    3 rutte  "\nThe image features a group of people standing together, with one ma…
    4 meloni "\nThe image features a woman standing at a podium, giving a speech. S…

We can also run this example on a remote LLM like OpenAI’s chatGPT. For
this, you would need to get an API key from OpenAI and paste it in the
line below:

``` r
Sys.setenv(OPENAI_API_KEY="sk-proj-...")
```

After this, we simply replace the `ollama(..)` function with an
`openai(..)` function and keep the rest the same. Interestingly, I did
have to change the prompt to avoid triggering a guard rail preventing
the AI from commenting on the politician in the picture:

``` r
describe_politician_chat <- function(name, img, ...) {
  tmp <- tempfile(fileext = ".png")
  image_write(img, path = tmp, format = "png")
  description <- llm_message(
      "Describe the main person's clothing, facial expression, and posture in detail. Do not mention their name",
      .imagefile = tmp
    ) |>
      chat(openai(.model = "gpt-4o-mini")) |>
      get_reply() 
  unlink(tmp)
  tibble(name=name, description=description)
}

pmap(images, describe_politician_chat) |> list_rbind()
```

    # A tibble: 4 × 2
      name   description                                                            
      <chr>  <chr>                                                                  
    1 merkel "The person is wearing a bright red blazer that stands out noticeably,…
    2 obama  "The person is wearing a light-colored dress shirt with the sleeves ro…
    3 rutte  "The main person is dressed in a white jacket with a high collar, sugg…
    4 meloni "The main person is wearing a bright teal blazer over a white top, cre…

## Using structured output

The function above returned the output of the LLM as a simple text
description. Often, however, we want specific structured information
such as the gender, emotion, or setting of a picture.

For this, it is generally best to use **structured outputs**, where we
first define the expected output and then tell the AI to provide the
requested format.

First, we define a `schema`, for example with a short description and
then the gender, emotion, and apparent age of the person

``` r
face_schema <- tidyllm_schema(
  name = "Face schema",
  description = field_chr(.description = "Short description (1–2 sentences) of the main person shown in the picture"),
  gender = field_fct(.description = "What is the apparent gender of the main person (M for male, F for female)", .levels = c("F", "M")),
  emotion = field_chr(.description = "Single word for the main emotion shown by the person, e.g. happy, sad or angry")
)
```

Now, we can rewrite the function above to include the `.json_schema`
(and include the desired output in the prompt). We also replace
`get_reply` by `get_reply_data`, which returns a named list that we can
easily turn into a tibble to return:

``` r
analyse_picture <- function(name, img, ...) {
  tmp <- tempfile(fileext = ".png")
  image_write(img, path = tmp, format = "png")
  llm_message(
      "Describe the main person's apparent gender and main emotion as shown in the picture. First give a small description of the overall face, and then list the gender (as F or M) and main emotion",
      .imagefile = tmp
    ) |>
      chat(ollama(.model = "moondream"), .json_schema = face_schema) |>
      get_reply_data() |>
    as_tibble() |>
    add_column(name=name)
}

pmap(images, analyse_picture) |> list_rbind()
```

    # A tibble: 4 × 4
      description                                         gender emotion   name  
      <chr>                                               <chr>  <chr>     <chr> 
    1 A blonde woman with short hair wearing a red jacket F      sad       merkel
    2 a man with black hair                               F      happy     obama 
    3 male                                                M      happy     rutte 
    4 female                                              F      surprised meloni

If you play around with this you will find out that moondream often
makes seemingly stupid mistakes. You might get better results with a
more powerful model (such as `llava`, `qwen3-vl:8b` or
`llama3.2-vision:11b`) but note that it depends on your computer whether
you will be able to run them: the bigger models require a lot of GPU
memory, which not all computers will support. See
https://ollama.com/library for an overview of existing models.

You can also use proprietary models such as `chatgpt` as used above, but
these might hit the brake more often where it comes to talking about
existing persons, so you might have to massage the prompt to ensure the
AI of your good intentions as a researcher…
