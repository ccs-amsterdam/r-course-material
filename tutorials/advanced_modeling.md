Advanced Statistical Modeling in R
================
Kasper Welbers & Wouter van Atteveldt
November 2018

-   [Advanced Modeling](#advanced-modeling)
-   [Generalized linear models](#generalized-linear-models)
    -   [Logistic regression](#logistic-regression)

Advanced Modeling
=================

In this tutorial we show how to perform several advanced statistical models in R. For the sake of parsimony, we will not discuss each model in detail, but only point out the main usage and provide a general example.

``` r
library(tidyverse)
library(stats)
library(texreg)
```

Generalized linear models
=========================

> In statistics, the generalized linear model (GLM) is a flexible generalization of ordinary linear regression that allows for response variables that have error distribution models other than a normal distribution. The GLM generalizes linear regression by allowing the linear model to be related to the response variable via a link function and by allowing the magnitude of the variance of each measurement to be a function of its predicted value. [Wikipedia](https://en.wikipedia.org/wiki/Generalized_linear_model)

Probably the most common use of generalized linear models is the logistic regression, or binary regression, that allows for a dichotomous response variable. Another common use is the Poisson regression, which allows for a response variable with a Poisson distribution.

Generalized linear models can be performed with the regular stats package, in a way that is very similar to the regular linear models. Where regular linear models have the `lm` function, generalized linear models have the `glm` function. Other than this, the main difference is that the family function, or link function, of the glm needs to be given.

Logistic regression
-------------------

First, we create a copy of the iris data, but with a dichotomous variable for whether a case (row) is of the species "versicolor".

``` r
d = mutate(iris, versicolor = as.numeric(Species == 'versicolor'))
head(d)
```

|  Sepal.Length|  Sepal.Width|  Petal.Length|  Petal.Width| Species |  versicolor|
|-------------:|------------:|-------------:|------------:|:--------|-----------:|
|           5.1|          3.5|           1.4|          0.2| setosa  |           0|
|           4.9|          3.0|           1.4|          0.2| setosa  |           0|
|           4.7|          3.2|           1.3|          0.2| setosa  |           0|
|           4.6|          3.1|           1.5|          0.2| setosa  |           0|
|           5.0|          3.6|           1.4|          0.2| setosa  |           0|
|           5.4|          3.9|           1.7|          0.4| setosa  |           0|

The `glm` function uses the same type of formula as the `lm` function: `dependent ~ independent1 + independent2 + ...`. Here we try to predict whether the species is `versicolor` based on the Sepal size (length and width). We specify that we use the `binomial` family, for modeling a binomial dependent variable. To view the model we again use the texreg package (but summary(m) would also work).

``` r
m = glm(versicolor ~ Sepal.Length + Sepal.Width, family = binomial, data = d)
screenreg(m)
```

    ## 
    ## ==========================
    ##                 Model 1   
    ## --------------------------
    ## (Intercept)       8.09 ***
    ##                  (2.39)   
    ## Sepal.Length      0.13    
    ##                  (0.25)   
    ## Sepal.Width      -3.21 ***
    ##                  (0.64)   
    ## --------------------------
    ## AIC             157.65    
    ## BIC             166.68    
    ## Log Likelihood  -75.83    
    ## Deviance        151.65    
    ## Num. obs.       150       
    ## ==========================
    ## *** p < 0.001, ** p < 0.01, * p < 0.05

Here we see that only Sepal.Width has a significant effect. The smaller the Sepal.Width, the more likely that the species is Versicolor.

Note that there is no R2 value, because the glm model is fit with a maximum likelihood estimator instead of the least squares approach used in regular lm. To evaluate model fit, you can compare models using the anova function. For example, we can make a second model with the Petal information included, and check whether the new model is an improvement.

``` r
m1 = glm(versicolor ~ Sepal.Length + Sepal.Width, family = binomial, data = d)
m2 = glm(versicolor ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width, family = binomial, data = d)
anova(m1,m2, test="Chisq")
```

|  Resid. Df|  Resid. Dev|   Df|  Deviance|  Pr(&gt;Chi)|
|----------:|-----------:|----:|---------:|------------:|
|        147|    151.6504|   NA|        NA|           NA|
|        145|    145.0697|    2|  6.580749|    0.0372399|

Here we see that adding these variables does (somewhat) improve the model fit. If we look at the model, we also see that Petal.Width is a significant predictor.

``` r
screenreg(list(m1,m2))
```

    ## 
    ## ======================================
    ##                 Model 1     Model 2   
    ## --------------------------------------
    ## (Intercept)       8.09 ***    7.38 ** 
    ##                  (2.39)      (2.50)   
    ## Sepal.Length      0.13       -0.25    
    ##                  (0.25)      (0.65)   
    ## Sepal.Width      -3.21 ***   -2.80 ***
    ##                  (0.64)      (0.78)   
    ## Petal.Length                  1.31    
    ##                              (0.68)   
    ## Petal.Width                  -2.78 *  
    ##                              (1.17)   
    ## --------------------------------------
    ## AIC             157.65      155.07    
    ## BIC             166.68      170.12    
    ## Log Likelihood  -75.83      -72.53    
    ## Deviance        151.65      145.07    
    ## Num. obs.       150         150       
    ## ======================================
    ## *** p < 0.001, ** p < 0.01, * p < 0.05

Finally, to illustrate how fitting a `glm` is different from using a regular `lm`, we can plot the regression line for the Sepal.Width. To keep it simple, we'll fit a model with only the Sepal.Width as predictor.

``` r
## create model
m = glm(versicolor ~ Sepal.Width, family = binomial, data = d)

## create a sequence of values within the observed boundaries of Sepal.Width
x = seq(min(d$Sepal.Width), max(d$Sepal.Width), 0.01)     

## predict response (probability of species being 'versicolor') for the values in x
y = predict(m, list(Sepal.Width = x), type = 'response')  

## plot the actual values for versicolor
plot(d$Sepal.Width, d$versicolor)

## add the predicted values
lines(x,y, col='blue')
```

![](img/fitting_glm-1.png)

here we see that the versicolor cases (the dots at the top and bottom) are mostly on the left side (small Sepal Width). The curved prediction line shows that the probability approaches (but never exceeds) 1 the smaller the Sepal.Width gets, and approaches 0 the larger the Sepal.Width gets. In a regular `lm`, this line would be straight, which is less suited for fitting the probability, and would arbitrarily have values higher than 1 and lower than 0.
