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

| Handout | Video Tutorial | R4DS ch. | Core packages / functions |
|----|---|---| --- |
| Fun with R | [Fun with R](https://www.youtube.com/watch?v=eYCV8kIsgGs&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=2) | 3 | tidyverse,ggplot2,igraph |
| [R Basics](tutorials/R-tidy-4-basics.md) | [Intro to R](https://www.youtube.com/watch?v=PVhZD5MINYM&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=1) | 4 | (base R functions) |
| [Transforming Data](tutorials/R-tidy-5-transformation.md) | [Importing and Cleaning](https://www.youtube.com/watch?v=CATqkFiZljU&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=3) |  5 | dplyr: filter, select, arrange, mutate | 
| [Summarizing Data](tutorials/R-tidy-5b-groupby.md) | [Grouping and Summarizing](https://www.youtube.com/watch?v=lde7wLORQpo&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=4) | 5 | dplyr: group_by, summarize |
| [Visualizing Data](tutorials/r-tidy-3_7-visualization.md) | [ggplot 1](https://www.youtube.com/watch?v=wO5mrVaCB28&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=7) |7 | ggplot2  |
| [Reshaping data](tutorials/r-tidy-12-reshaping.md) | [Reshaping](https://www.youtube.com/watch?v=j4lZWJ3Osr8&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=5) |12 | tidyr: spread, gather |
| [Combining (merging) Data](tutorials/R-tidy-13a-joining.md) | [Joining](https://www.youtube.com/watch?v=gg87Nv98VhQ&list=PLjXODJ_lGN_V2ntvV2CN_GvzZ6Qm5km9L&index=6) |13 | dplyr: inner_join, left_join, etc. | 
| [Basic string (text) handling](tutorials/R-tidy-14-strings.md) |  |14 | readr: str_detect, str_extract etc., iconv |

# Statistical Analysis
| Tutorial | Video tutorial | Core packages / functions |
|----|---|---|
| [Basic statistics](tutorials/simple_modeling.md) | [Basic stats](https://www.youtube.com/watch?v=1K3SKsEj9eI) | stats: lm, aov, t.test |
| [Advanced statistics overview](tutorials/advanced_modeling.md) | see GLM and Multilevel | stats: glm, lme4: lmer, glmer |
| [Generalized linear models](https://htmlpreview.github.io/?https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/generalized_linear_models.html) | [GLM](https://www.youtube.com/watch?v=DDP62EUMRFs&list=PL-i7GM-A1wBarcTV3wN2f-AAuEK3j76M0) (on [family](https://www.youtube.com/watch?v=DDP62EUMRFs&list=PL-i7GM-A1wBarcTV3wN2f-AAuEK3j76M0&index=1) argument) | stats: glm, family, sjPlot: tab_model, plot_model |
| [Multilevel Models](https://htmlpreview.github.io/?https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/multilevel_models.html) | [Multilevel](https://www.youtube.com/watch?v=1Tw1eIfSyEQ&list=PL-i7GM-A1wBarcTV3wN2f-AAuEK3j76M0&index=4) | lme4: lmer, glmer, sjPlot: tab_model, plot_model |


# Text analysis 


For a general introduction to text analysis (in R), see these videos on [preprocessing](https://www.youtube.com/watch?v=O6CGXnxPHok&list=PL-i7GM-A1wBZYRYTpem7hNVHK3hSV_1It&index=1&t=482s) and different [analysis approaches](https://www.youtube.com/watch?v=bHa2CClBYFw&list=PL-i7GM-A1wBZYRYTpem7hNVHK3hSV_1It&index=4)

| Tutorial | Video tutorial |  Core packages / functions |
|----|---|---|
| [Text analysis](tutorials/R_text_3_quanteda.md) | [corpus stats](https://www.youtube.com/watch?v=7z7U7ORFWQM&list=PL-i7GM-A1wBZYRYTpem7hNVHK3hSV_1It&index=3) |  [quanteda](https://quanteda.io/) |
| [Lexical sentiment analysis](tutorials/sentiment_analysis.md) | [dictionaries](https://www.youtube.com/watch?v=U0l5GB0i3uU&list=PL-i7GM-A1wBZYRYTpem7hNVHK3hSV_1It&index=5) | [quanteda](https://quanteda.io/), [corpustools](https://github.com/kasperwelbers/corpustools) |
| [LDA Topic Modeling](tutorials/r_text_lda.md) | [Video series](https://www.youtube.com/playlist?list=PLjXODJ_lGN_WtxhPsQ_t0aHtFAcsIh1-8), [Tutorial demo](https://youtu.be/4YyoMGv1nkc) |  [topicmodels](https://www.rdocumentation.org/packages/topicmodels/versions/0.2-8),[quanteda](https://quanteda.io/)   |
| [Structural Topic Modeling](tutorials/r_text_stm.md) | [Variants of Topic Models](https://www.youtube.com/watch?v=3rqkSqKp85s&list=PLjXODJ_lGN_U02yQyZG5YpBgseVpiS9s2&index=2&t=0s); [Structural Topic Models](https://www.youtube.com/watch?v=37yvQdQw5j8&list=PLjXODJ_lGN_U02yQyZG5YpBgseVpiS9s2&index=2) | [stm](https://www.structuraltopicmodel.com/), [quanteda](https://quanteda.io/)  |
| [NLP Preprocessing with Spacy(r)](tutorials/r_text_nlp.md) | |  [spacyr](https://www.rdocumentation.org/packages/spacyr/versions/0.9.91), [quanteda](https://quanteda.io/) (see also [spacy](https://spacy.io/) itself) |
| [Supervised machine learning for text classification](tutorials/r_text_ml.md) | [Supervised Machine Learning](https://www.youtube.com/playlist?list=PLjXODJ_lGN_XdMBgyscXHXuSB81zUoXCR) |  caret |
| [Creating a topic browser with LDA](tutorials/R_text_topicbrowser.md) | |  [corpustools](https://cran.r-project.org/web/packages/corpustools/vignettes/corpustools.html) |

# Note on installing packages

In general, most R packages can be installed without any issues. However, there are some exceptions that you need to know about. 
For **quanteda** (that we use in the text analysis tutorials), your computer needs certain software that is not always installed, as mentioned on the [quanteda website](https://quanteda.io/).
You can either install this software, but we rather recommend using R version 4.0.0 (or higher) where this is no longer required.
To see your current R version, enter `version` in your R console.
To update, visit the R website ([Windows](https://cran.r-project.org/bin/windows/base/), [Mac](https://cran.r-project.org/bin/macosx/)).

When running `install.packages()` You sometimes get the message that **There is a binary version available but the source version is later** (we're mainly seen this on Mac).
You then get the question whether you want to **install from sources the package which needs compilation (Yes/no)** .
To answer this question, you have to type "yes" or "no" in your R console.
Most often, **you'll want to say no**.
Simply put, R tells you that it has a new version of a package, but if you want to use it your computer will need to build it.
The problem is that this requires some development software that you might not have installed.
If you say no, you'll install an older version that has already been build for you.
In rare cases, installing from source is the only way, in which case you'll have to install the software that R refers to.

# Miscellaneous

* [R Markdown codeblock parameters](miscellaneous/RMarkdown_parameters.Rmd)
* [Gathering Data](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/Gathering_data.md)
* [Scraping the Guardian](https://github.com/ccs-amsterdam/r-course-material/blob/master/tutorials/guardian.md)
