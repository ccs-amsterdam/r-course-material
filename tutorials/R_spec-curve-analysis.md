Specification Curve Analysis
================
Philipp Masur
2022-10

-   <a href="#introduction" id="toc-introduction">Introduction</a>
-   <a href="#preparation" id="toc-preparation">Preparation</a>
    -   <a href="#packages" id="toc-packages">Packages</a>
    -   <a href="#getting-some-data" id="toc-getting-some-data">Getting some
        data</a>
-   <a href="#specification-curve-analysis"
    id="toc-specification-curve-analysis">Specification Curve Analysis</a>
    -   <a href="#setup-specifications" id="toc-setup-specifications">Setup
        specifications</a>
    -   <a href="#run-specifications" id="toc-run-specifications">Run
        specifications</a>
-   <a href="#summarizing-and-visualizing-results"
    id="toc-summarizing-and-visualizing-results">Summarizing and visualizing
    results</a>
    -   <a href="#summarizing-the-parameter-distribution"
        id="toc-summarizing-the-parameter-distribution">Summarizing the
        parameter distribution</a>
    -   <a href="#visualize-the-specification-curve"
        id="toc-visualize-the-specification-curve">Visualize the “specification
        curve”</a>
    -   <a href="#alternative-visualization"
        id="toc-alternative-visualization">Alternative visualization</a>
-   <a href="#more-advanced-options" id="toc-more-advanced-options">More
    advanced options</a>
    -   <a href="#adding-more-specification-via-subsets"
        id="toc-adding-more-specification-via-subsets">Adding more specification
        via “subsets</a>
    -   <a href="#decompose-the-variance-in-the-specification-curve"
        id="toc-decompose-the-variance-in-the-specification-curve">Decompose the
        variance in the specification curve</a>
-   <a href="#where-to-go-next" id="toc-where-to-go-next">Where to go
    next?</a>
-   <a href="#references" id="toc-references">References</a>

# Introduction

In this tutorial, I am going to introduce the package
[`specr`](https://masurp.github.io/specr/index.html) (Masur & Scharkow,
2020), which provides a comprehensive framework for conducting so-called
specification curve analyses (also known as multiverse analyses).

Whenever researchers are collecting and analyzing data, they are
confronted with many degrees of freedom. They have to take both
conceptual and analytical decisions about e.g., variable selection, data
transformation, subsetting, whether to include control variables, what
modelling strategy to use, what estimators to choose, and so on. In
fact, in many cases, two alternatives are equally defensible or even
arbitrary. Yet, any of these decisions (in combination with all others)
lead to a unique “data set” or specification strategy that could
(potentially) lead to a (albeit often only slightly) different result.
This has been termed the “garden of forking paths” (see Fig. 1; Gelman &
Lokens, 2013).

This is problematic for several reasons. As Simonsohn, Simmons, and
Nelson (2020) put it one of the most prominent articles on specification
curve analyses:

> When reading the results of a study, people want to learn about the
> true relationship being analysed but this requires that the analyses
> reported are representative of the set of valid analyses that could
> have been conducted. This is often not the case. One problem is the
> possibility that the results may hinge on an arbitrary choice by the
> researcher. A probably greater, more pervasive problem is that people
> in general, and researchers in particular, are more likely to report
> evidence consistent with the claims they are trying to make than to
> report evidence that is inconsistent with such claims. The standard
> errors around published effect sizes represent the sampling error
> inherent in a particular analysis, but they do not reflect the error
> caused by the arbitrary and/or motivated selection of specifications.
> (p. 1208)

Specification curve analysis (or multiverse analysis) aims to circumvent
these issues by reporting results for all “reasonable specifications. A
reasonable specification is one that represents a sensible, that is
defensible test of the hypothesis or research question at hand, that is
further statistically valid, and not redundant with other specifications
in the set.

The analysis itself consists of running all models based on the
different specifications and then summarizing and/or visualizing the
results. Typically, a specification curve is plotted that shows the
estimated effect size across all specifications (often sorted by
magnitude), which is further accompanied by a sort of dashboard chart
that indicates how the different conceptial and analytical choices
affected the results.

As such, specification curve analyses are similar to robustness test
(i.e., running alternative models to prove the stability and robustness
of an effect). Yet, the take this approach a step further by running all
possible combinations of analytical and conceptual choices to produce
often a large, but to a certain degree exhaustive number of
specifications.

# Preparation

## Packages

The following tutorial exemplifies how to use the major functions of
this package. Although using `specr` strictly speaking does not require
any other package, we recommend to also load the `tidyverse` as it
provides valuable functions for data wrangling and adapting outputs from
`specr` functions. Furthermore, the tidyverse includes `ggplot2` which
can be used to modify the layout of the plots.

``` r
library(tidyverse)
library(specr)
```

## Getting some data

Specification curve analyses perhaps particular haven gotten attention
by the scientific community after Amy Orben and Andrew Przybylski (2019)
published a study that showed quite vividly that the association between
adolescent well-being and digital technology use heavily depends on the
analytical choices and type of measures researchers use.

In this tutorial, we are conducting a secondary data analysis of one
wave of the [pairfam](https://www.pairfam.de/en/) data set, which
represents a representative survey of young adolescents in Germany. The
data that we are going to use is not the actual data set, but a
synthetic data set whose properties are similar (but not equal) to the
pairfam data set.

The data set allows use - similar to Orben and Przybylski - investigate
the influence of analytical choices on the relationship between media
use and well-being in young adolescents. The synthetic data set is
available on our github resource and can be loaded directly via the link
below.

``` r
d <- read_csv("https://raw.githubusercontent.com/ccs-amsterdam/r-course-material/master/data/pairfam_synth_data.csv")
head(d)
```

|  …1 |        id | age | gender | tv_use | sns_use | internet_use | self_esteem | depression | depression_p1 | depression_p2 | life_satisfaction_r | friend_satisfaction | outlier |
|----:|----------:|----:|:-------|-------:|--------:|-------------:|------------:|-----------:|--------------:|--------------:|--------------------:|--------------------:|:--------|
|   1 | 547532000 |  16 | female |     28 |       3 |           14 |           4 |   3.769231 |      2.928571 |      4.214286 |                   4 |                   2 | all     |
|   2 | 283764000 |  15 | female |     12 |       0 |           15 |           4 |   3.423077 |      2.285714 |      4.214286 |                   2 |                   3 | all     |
|   3 | 376209000 |  15 | female |      2 |       3 |            8 |           1 |   1.000000 |      1.000000 |      1.000000 |                   1 |                   1 | all     |
|   4 | 716289000 |  16 | male   |     28 |       0 |            5 |           4 |   4.461538 |      4.214286 |      4.214286 |                   4 |                   6 | all     |
|   5 | 143070000 |  17 | male   |      9 |       5 |           10 |           1 |   2.384615 |      1.642857 |      2.928571 |                   2 |                   3 | all     |
|   6 | 677015000 |  15 | female |      0 |       4 |           50 |           1 |   1.000000 |      1.000000 |      1.000000 |                   2 |                   1 | all     |

The data set includes the following variables:

-   Information about participants
    -   id
    -   age
    -   gender
-   Media use
    -   tv_use: TV use in hours per week
    -   internet_use: Internet use in hours per week
    -   sns_use: A frequency scale measures SNS use
-   Well-Being
    -   depression
    -   life_satisfaction
    -   self-esteem
-   Control variables
    -   friend_satisfaction

In a first step, we are going to standardize all variables (except those
that we want to use for subgroup analyses: gender, outlier).
Standardization is technically not necessary for conducting a
specification curve analysis, but it often makes sense as the resulting
standardized coefficients (e.g., betas) are then comparable across the
specifications.

``` r
std_vars <- c("age", "tv_use", "internet_use", "sns_use",
              "self_esteem", "depression", "life_satisfaction_r", "friend_satisfaction")
d <- d %>% 
  mutate(across(std_vars, function(x) (x - mean(x, na.rm = T)) / sd(x, T))) 
```

# Specification Curve Analysis

## Setup specifications

The next step involves identifying possible conceputal and analytical
choices. This step involves an in-depth understanding of the research
question and the model(s) that will be specified. In this case, we
assume simply that media use should be positively (or negatively)
correlated with well-being. We can first use the function
`setup_specs()` to check how different analytical decisions create
varying factorial designs.

We simply pass the different measures for (1) `x` and (2) `y` to the
function, add what type of (3) model we want to compute (can be several)
and finally what (4) control variables we would like to add. By default,
`specr` will compute models that have no controls, each control
variable, and all controls.

``` r
setup_specs(x = c("tv_use", "sns_use", "internet_use"),
            y = c("self_esteem", "depression", "life_satisfaction_r"),
            model = "lm",
            controls = c("friend_satisfaction", "age"))
```

| x            | y                   | model | controls                  |
|:-------------|:--------------------|:------|:--------------------------|
| tv_use       | self_esteem         | lm    | friend_satisfaction + age |
| sns_use      | self_esteem         | lm    | friend_satisfaction + age |
| internet_use | self_esteem         | lm    | friend_satisfaction + age |
| tv_use       | depression          | lm    | friend_satisfaction + age |
| sns_use      | depression          | lm    | friend_satisfaction + age |
| internet_use | depression          | lm    | friend_satisfaction + age |
| tv_use       | life_satisfaction_r | lm    | friend_satisfaction + age |
| sns_use      | life_satisfaction_r | lm    | friend_satisfaction + age |
| internet_use | life_satisfaction_r | lm    | friend_satisfaction + age |
| tv_use       | self_esteem         | lm    | friend_satisfaction       |
| sns_use      | self_esteem         | lm    | friend_satisfaction       |
| internet_use | self_esteem         | lm    | friend_satisfaction       |
| tv_use       | depression          | lm    | friend_satisfaction       |
| sns_use      | depression          | lm    | friend_satisfaction       |
| internet_use | depression          | lm    | friend_satisfaction       |
| tv_use       | life_satisfaction_r | lm    | friend_satisfaction       |
| sns_use      | life_satisfaction_r | lm    | friend_satisfaction       |
| internet_use | life_satisfaction_r | lm    | friend_satisfaction       |
| tv_use       | self_esteem         | lm    | age                       |
| sns_use      | self_esteem         | lm    | age                       |
| internet_use | self_esteem         | lm    | age                       |
| tv_use       | depression          | lm    | age                       |
| sns_use      | depression          | lm    | age                       |
| internet_use | depression          | lm    | age                       |
| tv_use       | life_satisfaction_r | lm    | age                       |
| sns_use      | life_satisfaction_r | lm    | age                       |
| internet_use | life_satisfaction_r | lm    | age                       |
| tv_use       | self_esteem         | lm    | no covariates             |
| sns_use      | self_esteem         | lm    | no covariates             |
| internet_use | self_esteem         | lm    | no covariates             |
| tv_use       | depression          | lm    | no covariates             |
| sns_use      | depression          | lm    | no covariates             |
| internet_use | depression          | lm    | no covariates             |
| tv_use       | life_satisfaction_r | lm    | no covariates             |
| sns_use      | life_satisfaction_r | lm    | no covariates             |
| internet_use | life_satisfaction_r | lm    | no covariates             |

We can see that the function simply computes all combinations from our
input. So these few choices already lead to 36 different specifications
(and thus models)!

## Run specifications

The `setup_specs()` function is only a helper to better understand what
we are doing. For the analysis itself, we don’t need it as we can pass
the “choices” directly to the function `run_specs()`, which computes all
models. It is useful to save the resulting data set in a new object.

For the purpose of exemplifying the inclusion of a different model, we
are also going to define a new model function that we can pass to
`run_specs()` as well. As long as the function only takes formula and
data as arguments, we can directly insert them to `run_specs()`. Yet,
often, alternative models require the specification of a family, a
random effect structure, and so on. In this case, we can simply define a
new function that still takes the formula and the data as arguments, but
adds whatever necessary to the function. In this case, we are going to
create general linear model within the Gaussian family and identity as
link function. For more information on how to use specifically defined
functions in `specr` see e.g.,
[this](https://masurp.github.io/specr/articles/measurement_models.html)
and [this](https://masurp.github.io/specr/articles/random_effects.html)
tutorial.

``` r
# specific model fitting function
lm_gauss <- function(formula, data) {
  glm(formula = formula, 
      data = data, 
      family = gaussian(link = "identity"))
}

results <- run_specs(df = d,
                     x = c("tv_use", "sns_use", "internet_use"),
                     y = c("self_esteem", "depression", "life_satisfaction_r"),
                     model = c("lm", "lm_gauss"),
                     controls = c("friend_satisfaction", "age"))
head(results)
```

| x            | y           | model | controls                  |   estimate | std.error |  statistic |   p.value |   conf.low | conf.high |  obs | subsets |
|:-------------|:------------|:------|:--------------------------|-----------:|----------:|-----------:|----------:|-----------:|----------:|-----:|:--------|
| tv_use       | self_esteem | lm    | friend_satisfaction + age | -0.0029213 | 0.0177257 | -0.1648079 | 0.8691062 | -0.0376769 | 0.0318342 | 3033 | all     |
| sns_use      | self_esteem | lm    | friend_satisfaction + age |  0.0609118 | 0.0182960 |  3.3292492 | 0.0008818 |  0.0250373 | 0.0967863 | 2886 | all     |
| internet_use | self_esteem | lm    | friend_satisfaction + age |  0.0792760 | 0.0178721 |  4.4357392 | 0.0000095 |  0.0442333 | 0.1143187 | 3035 | all     |
| tv_use       | depression  | lm    | friend_satisfaction + age | -0.0027580 | 0.0179085 | -0.1540022 | 0.8776189 | -0.0378729 | 0.0323570 | 2857 | all     |
| sns_use      | depression  | lm    | friend_satisfaction + age |  0.0810108 | 0.0184700 |  4.3860746 | 0.0000120 |  0.0447941 | 0.1172275 | 2719 | all     |
| internet_use | depression  | lm    | friend_satisfaction + age |  0.0793375 | 0.0181282 |  4.3764743 | 0.0000125 |  0.0437918 | 0.1148832 | 2854 | all     |

The resulting data set includes columns for all specifications and adds
relevant statistical parameters for the relationship of interest (the
association between x and y). `specr` automatically extracts relevant
parameters depending on the model type, but usually it will include the
estimate (in this case std. regression coefficients), their standard
error, p-value, confidence intervals, and the number of observations use
in the particular specification (can be different if missing values
exists).

As this is a tibble, we can do whatever we want with is. In the
following, we explore some way to work with it.

# Summarizing and visualizing results

Specification curve analyses typically involve summarizing the
distribution of parameters (e.g., reporting the median effect size) and
visualizing the specification curve with a dashboard of the analytical
choices.

## Summarizing the parameter distribution

To summarize the results, we can use the function `summarize_specs()`.
We can further customize the output by defining what choices the results
should be “grouped by” and what statistics should be computed.

``` r
summarise_specs(results)
```

|    median |       mad |        min |       max |       q25 |       q75 |    obs |
|----------:|----------:|-----------:|----------:|----------:|----------:|-------:|
| 0.0645939 | 0.0229626 | -0.0032347 | 0.0821696 | 0.0101831 | 0.0786368 | 2929.5 |

``` r
summarise_specs(results, 
                x,
                stats = lst(median, mean, min, max))
```

| x            |    median |      mean |        min |       max |    obs |
|:-------------|----------:|----------:|-----------:|----------:|-------:|
| internet_use | 0.0783710 | 0.0765918 |  0.0692013 | 0.0801669 | 3036.5 |
| sns_use      | 0.0518338 | 0.0451619 | -0.0009572 | 0.0810108 | 2887.5 |
| tv_use       | 0.0085274 | 0.0268007 | -0.0032347 | 0.0821696 | 3034.5 |

As we can see, the median relationship between media use and well-being
is
![\beta](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%5Cbeta "\beta")
= .06. The largest effect sizes, however, are found for internet use.

## Visualize the “specification curve”

To produce the standard specification curve plot that we often see in
publications, we can simply use the function `plot_specs()`.

``` r
plot_specs(results)
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

Such a plot contains a lot of information and needs to be investigated
carefully. To give one example, we can see that the largest (positive)
effect sizes are found, when the relationship between TV use and life
satisfaction is estimated, when controlling either for no other
variables or age. The difference between the standard linear model and
the gaussian linear model is (as perhaps expected) negligible.

More generally speaking, the resulting plot includes the ranked
specification curve (A) and an overview about how the different
analytical choices affect the estimate of interest (B). Red represents
negative and significant effects (based on the chosen significance
level, by default
![\alpha](https://latex.codecogs.com/png.image?%5Cdpi%7B110%7D&space;%5Cbg_white&space;%5Calpha "\alpha")
=.05). Blue represents positive and significant effects. Grey refers to
non-significant effects.

In some cases, we may want to adapt the visualization to our liking and
change bits and pieces. This can be done by using the functions
`plot_curve()` (upper panel) and `plot_choices()` (lower panel). They
both produce ggplot objects and can thus be further modified using
standard ggplot syntax.

``` r
library(ggthemes)

# Plot specification curve
(a <- plot_curve(results, ci = F, ribbon = T) + 
   geom_point(size = 4))
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

``` r
# Plot dashboard of choices
(b <- plot_choices(results, choices = c("x", "y", "model", "controls")) +
   geom_point(size = 2, shape = 4)) 
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

We can also add a third panel that shows a histrogram detailing the
sample sizes for each specification.

``` r
(c <- plot_samplesizes(results) + ylim(0, 4000))
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

As all three plots are ggplot-objects, we can easily arrange them with
packages such as ´cowplot\`.

``` r
library(cowplot)
plot_grid(a, b, c, ncol = 1,
          align = "v",
          rel_heights = c(1.5, 2, 0.8),
          axis = "rbl")
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

## Alternative visualization

Despite their prominence in the literature, such visualization are not
the only ones that we can use to summarize and plot our results. An
alternative would be a boxplot, which we can produce with the function
`plot_summary()`. We can again customize with standard ggplot syntax.

``` r
plot_summary(results) + 
  geom_point(alpha = .4) + 
  scale_fill_brewer(palette = "Dark2") +
  theme_wsj() +
  labs(x = "Effect size", fill = "")
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->

# More advanced options

## Adding more specification via “subsets

So far, our specification are only based on choosing different measures,
models, and control variables. The real power of `specr`, however, is
only visible if we start to understand the argument “subset” in the
`run_specs()` function. This allows us to pass “grouping variables”.
Specr will then compute all combinations for each of these groups (as
well as across all). This is of course convenient, when we have grouping
variables such as age or gender, but it can also be used for other
things. For example, we can create a second data set, in which outliers
are removed, add it to the original data set (dont forget to produce a
key variable). This way, a multitude of other specifications
representing a plethora of analytical decisions becomes possible.

``` r
# Checking for outliers
d %>%
  ggplot(aes(x = internet_use)) +
  geom_histogram(color = "lightgrey", fill = "steelblue")
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->

``` r
# Removing outliers
d.sub <- d %>%
  filter(internet_use < 5) %>%
  mutate(outlier = "< 5")

# Create new data set
d.new <- rbind(d %>%
               mutate(outlier = "all"), 
               d.sub)
```

``` r
results2 <- run_specs(df = d.new,
                     x = c("tv_use", "sns_use", "internet_use"),
                     y = c("self_esteem", "depression", "life_satisfaction_r", "depression_p1"),
                     model = c("lm", "lm_gauss"),
                     controls = c("friend_satisfaction", "age"),
                     subsets = list(outlier = unique(d$outlier)))

plot_specs(results2)
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

## Decompose the variance in the specification curve

We can also estimate how much variance in the specification curve is
related to which analytical decisions. Therefore, we have to estimate a
basic multilevel model without predictors and the analytical decisions
as random effects (interactions could be included too). We then use the
function `icc_specs()` to calculate a respective table or
`plot_variance()` to visualize the distribution.

``` r
library(lme4)
model <- lmer(estimate ~ 1 + (1|x)  + (1|y) + (1|controls) + (1|model) + (1|x:y), data = results)

# Get intra-class correlation
icc_specs(model) %>%
  mutate_if(is.numeric, round, 2)
```

| grp      | vcov |  icc | percent |
|:---------|-----:|-----:|--------:|
| x:y      |    0 | 0.68 |   68.00 |
| controls |    0 | 0.00 |    0.04 |
| y        |    0 | 0.00 |    0.00 |
| x        |    0 | 0.27 |   27.24 |
| model    |    0 | 0.00 |    0.00 |
| Residual |    0 | 0.05 |    4.72 |

``` r
# Plot decomposition
plot_variance(model)
```

![](R_spec-curve-analysis_files/figure-gfm/unnamed-chunk-16-1.png)<!-- -->

Perhaps even more clearly than in the typical specification plot, we see
here that most variance is explain by different media use measures and
their interaction with well-being.

# Where to go next?

Specification curve analysis is a powerful tool for investigating the
impact of conceptual and analytical choices on the effect size of
interest. If you want to learn more, we strongly suggest to read the
paper by Gelman & Loken (2013), Simonsohn et al (2020), and Steegen et
al. (2016).

We further suggest to have a look at the [website of
`specr`](https://masurp.github.io/specr/index.html), which provides
further tutorials (also for more specific aspects such as latent
variable modelling, or multilevel modelling). On the homepage, you will
also find a list of papers that have used specr and thus represent
interesting applications of specification curve analyses to various
research areas.

# References

-   Gelman, A., and Loken, E. 2013. The Garden of Forking Paths: Why
    Multiple Comparisons Can Be a Problem, Even When There Is No
    “Fishing Expedition” or “p-Hacking” and the Research Hypothesis Was
    Posited Ahead of Time., Thesis, , January 1.
    (<http://www.stat.columbia.edu/~gelman/research/unpublished/p_hacking.pdf>).

-   Masur, Philipp K. & Scharkow, M. (2020). specr: Conducting and
    Visualizing Specification Curve Analyses. Available from
    <https://CRAN.R-project.org/package=specr>.

-   Orben, A., & Przybylski, A. K. (2019). The association between
    adolescent well-being and digital technology use. Nature Human
    Behavior, 3, 173-182. doi: 10.1038/s41562-018-0506-1

-   Simonsohn, U., Simmons, J.P. & Nelson, L.D. (2020). Specification
    curve analysis. Nature Human Behaviour, 4, 1208–1214.
    <https://doi.org/10.1038/s41562-020-0912-z>

-   Steegen, S., Tuerlinckx, F., Gelman, A., & Vanpaemel, W. (2016).
    Increasing Transparency Through a Multiverse Analysis. Perspectives
    on Psychological Science, 11(5), 702-712.
    <https://doi.org/10.1177/1745691616658637>
