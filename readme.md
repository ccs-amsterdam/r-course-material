R course material
============

This page contains a collection of R tutorials, developed at the Vrije Universiteit Amsterdam for Communication Science courses that use R. 

The goal is to organize relevant material into modular components, for more efficient design and maintenance of material, that can be used across courses, and that are accessible to students during and after their studies.

Below we list the relevant handouts/tutorials. Each links to the md file, see the Rmd file with the same name for the source code of the tutorials. 

# R Basics

* [Getting started](tutorials/R_basics_1_getting_started.md) ([shorter version](tutorials/R_basics_1_getting_started_short.md))
* [Data and functions](tutorials/R_basics_2_data_and_functions.md) ([practise template](practise/R_basics_2_data_and_functions_practise.Rmd))

# Data mangling in the tidyverse

This is a set of tutorials designed to teach using the tidyverse functions for data cleaning, reshaping, visualizing etc.
The chapter numbers are relevant chapters from the excellent (and freely available) book ["R for Data Scientists" (R4DS)](http://r4ds.had.co.nz/)

| Handout | Tutorial | R4DS ch. | Core packages / functions |
|----|---|---|
| [R Basics](tutorials/R-tidy-4-basics.md) | [Intro to R](https://www.youtube.com/watch?v=PVhZD5MINYM&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=1) | 4 | (base R functions) |
| Fun with R | [Fun with R](https://www.youtube.com/watch?v=eYCV8kIsgGs&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=2) | 3 | tidyverse,ggplot2,igraph |
| [Transforming Data](tutorials/R-tidy-5-transformation.md) | 5 | dplyr: filter, select, arrange, mutate | 
| [Summarizing Data](tutorials/R-tidy-5b-groupby.md) | 5 | dplyr: group_by, summarize |
| [Visualizing Data](tutorials/r-tidy-3_7-visualization.md) | 7 | ggplot2  |
| [Reshaping data](tutorials/r-tidy-12-reshaping.md) | 12 | tidyr: spread, gather |
| [Combining (merging) Data](tutorials/R-tidy-13a-joining.md) | 13 | dplyr: inner_join, left_join, etc. | 
| [Basic string (text) handling](tutorials/R-tidy-14-strings.md) | 14 | readr: str_detect, str_extract etc., iconv |

# Statistical Analysis
| Tutorial | Core packages / functions |
|----|---|
| [Basic statistics](tutorials/simple_modeling.md) | stats: lm, aov, t.test |
| [Advanced statistics overview](tutorials/advanced_modeling.md) | stats: glm, lme4: lmer, glmer |
| [Generalized linear models](https://htmlpreview.github.io/?https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/generalized_linear_models.html) | stats: glm, family, sjPlot: tab_model, plot_model |
| [Multilevel Models](https://htmlpreview.github.io/?https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/multilevel_models.html) | lme4: lmer, glmer, sjPlot: tab_model, plot_model |


# Text analysis 

| Tutorial | Core packages / functions |
|----|---|
| [Text analysis](tutorials/R_text_3_quanteda.md) | [quanteda](https://quanteda.io/) |
| [Lexical sentiment analysis](tutorials/sentiment_analysis.md) | [quanteda](https://quanteda.io/), [corpustools](https://github.com/kasperwelbers/corpustools) |
| [LDA Topic Modeling](tutorials/r_text_lda.md) | [topicmodels](https://www.rdocumentation.org/packages/topicmodels/versions/0.2-8),[quanteda](https://quanteda.io/)   |
| [Structural Topic Modeling](tutorials/r_text_stm.md) | [stm](https://www.structuraltopicmodel.com/), [quanteda](https://quanteda.io/)  |
| [NLP Preprocessing with Spacy(r)](tutorials/r_text_nlp.md) | [spacyr](https://www.rdocumentation.org/packages/spacyr/versions/0.9.91), [quanteda](https://quanteda.io/) (see also [spacy](https://spacy.io/) itself) |
| [Supervised machine learning for text classification](tutorials/r_text_ml.md) | caret |
| [Creating a topic browser with LDA](tutorials/R_text_topicbrowser.md) | [corpustools](https://cran.r-project.org/web/packages/corpustools/vignettes/corpustools.html) |



# Miscellaneous

* [R Markdown codeblock parameters](miscellaneous/RMarkdown_parameters.Rmd)
* [Gathering Data](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/Gathering_data.md)
* [Scraping the Guardian](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/guardian.md)
