Basics of data visualization
================
Kasper Welbers, Wouter van Atteveldt & Philipp Masur
2022-06

-   [A Basic ggplot plot](#a-basic-ggplot-plot)
    -   [Important note on ggplot command
        syntax](#important-note-on-ggplot-command-syntax)
    -   [Other aesthetics](#other-aesthetics)
-   [Bar plots](#bar-plots)
    -   [Setting graph options](#setting-graph-options)
    -   [Grouped bar plots](#grouped-bar-plots)
-   [Line plots](#line-plots)
-   [Multiple ‘faceted’ plots](#multiple-faceted-plots)
-   [Themes](#themes)
-   [Plotting maps](#plotting-maps)

This tutorial teaches the basics of data visualization using the
`ggplot2` package (included in `tidyverse`). For more information, see
[R4DS Chapter 3: Da\`ta
Visualization](http://r4ds.had.co.nz/data-visualisation.html) and [R4DS
Chapter 7: Exploratory Data
Analysis](http://r4ds.had.co.nz/exploratory-data-analysis.html).

For *many* cool visualization examples using `gplot2` (with R code
included!) see the [R Graph
Gallery](https://www.r-graph-gallery.com/portfolio/ggplot2-package/).
For inspiration (but unfortunately no R code), there is also a [538 blog
post on data visualization from
2016](https://fivethirtyeight.com/features/the-52-best-and-weirdest-charts-we-made-in-2016/).
Finally, see the article on ‘[the grammar of
graphics](http://vita.had.co.nz/papers/layered-grammar.html)’ published
by Hadley Wickham for more insight into the ideas behind ggplot.

# A Basic ggplot plot

Suppose that we want to see the relation between college education and
household income, both included in the `county facts` subset published
by [Houston Data Visualisation github
page](https://github.com/houstondatavis/data-jam-august-2016). Since
this data set contains a large amount of columns, we keep only a subset
of columns for now:

``` r
library(tidyverse)
url <- "https://raw.githubusercontent.com/houstondatavis/data-jam-august-2016/master/csv/county_facts.csv"
facts <- read_csv(url) 
facts_subset <- facts %>% 
  select(fips, area_name, state_abbreviation, 
         population = Pop_2014_count, 
         pop_change = Pop_change_pct,
         over65 = Age_over_65_pct, 
         female = Sex_female_pct,
         white = Race_white_pct,
         college = Pop_college_grad_pct, 
         income = Income_per_capita)
facts_state <- facts_subset %>% 
  filter(is.na(state_abbreviation) & fips != 0) %>% 
  select(-state_abbreviation)
facts_state
```

Now, let’s make a *scatter plot* with percentage college-educated on the
x-axis and median income on the y-axis. First, we can used the function
`ggplot` to create an empty canvas tied to the dataset `facts_state` and
tell the function which variables to use:

``` r
ggplot(data = facts_state,        # which data set?
       aes(x=college, y=income))  # which variables as aesthetics?
```

Next, we need to tell ggplot what to plot. In this case, we want to
produce a scatterplot. The function `geom_point` adds a layer of
information to the canvas. In the language of ggplot, each layer has a
*geometrical representation*, in this case “points”. In this case, the
“x” and “y” are mapped to the college and income columns.

``` r
ggplot(data = facts_state,
       mapping = aes(x = college, y = income)) + 
  geom_point()   # adding the geometrical representation
```

So called *aesthetic mappings*, which map the visual elements of the
geometry to columns of the data, can also be included as argument in the
`geom`. This can be handy when several `geoms` are plotted and different
aesthetics are used.

``` r
# same plot as above
ggplot(data = facts_state) + 
  geom_point(mapping = aes(x = college, y = income)) 
```

The result is a plot where each point here represents a state, and we
see a clear correlation between education level and income. There is one
clear outlier on the top-right. Can you guess which state that is?

Due to the layer logic of ggplot, we can add more `geoms` to the plot
(e.g., a regression line). Remember that if we provide aesthetics within
the `ggplot`-function, these are passed to all `geoms`.

``` r
# Loess curve
ggplot(data = facts_state, 
       mapping = aes(x = college, y = income)) + 
  geom_point() +
  geom_smooth() 

# Linear regression line
ggplot(data = facts_state, 
       mapping = aes(x = college, y = income)) + 
  geom_point() +
  geom_smooth(method = "lm")
```

## Important note on ggplot command syntax

For the plot to work, R needs to execute the whole ggplot call and all
layers as a single statement. Practically, that means that if you
combine a plot over multiple lines, the plus sign needs to be at the end
of the line, so R knows more is coming. The general syntax is always:

``` r
ggplot(data = <DATA>) + 
  <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))
```

So, the following is good:

``` r
ggplot(data = facts_state) + 
  geom_point(mapping = aes(x = college, y = income))
```

But this is not:

``` r
ggplot(data = facts_state) 
  + geom_point(mapping = aes(x = college, y = income))
```

Also note that the data and mapping arguments are the first arguments
the functions expect, so you can also leave them out:

``` r
ggplot(facts_state) + 
  geom_point(aes(x = college, y = income))
```

## Other aesthetics

To find out which visual elements can be used in a layer, use
e.g. `?geom_point`. According to the help file, we can (among others)
set the colour, alpha (transparency), and size of points. Let’s first
set the size of points to the (log) population of each state, creating a
bubble plot:

``` r
ggplot(data = facts_state) + 
  geom_point(aes(x = college, y = income, size = population))
```

Since it is difficult to see overlapping points, let’s make all points
somewhat transparent. Note: Since we want to set the alpha of all points
to a single value, this is not a mapping (as it is not mapped to a
column from the data frame), but a constant. These are set outside the
mapping argument:

``` r
ggplot(data = facts_state) + 
  geom_point(aes(x = college, y = income, size = population), 
             alpha = .5, 
             colour = "red")
```

Instead of setting colour to a constant value, we can also let it vary
with the data. For example, we can colour the states by percentage of
population that is identified as ‘white’:

``` r
ggplot(data = facts_state) + 
  geom_point(aes(x=college, y=income, size=population, colour=white), 
             alpha=.9)
```

Finally, you can map to a categorical value as well. Let’s categorize
states into whether population is growing (at least 1%) or stable or
declining. We use the `if_else(condition, iftrue, iffalse)` function,
which assigns the `iftrue` value if the condition is true, and `iffalse`
otherwise:

``` r
facts_state <- facts_state %>% 
  mutate(growth = ifelse(pop_change > 1, "Growing", "Stable"))

ggplot(data=facts_state) + 
  geom_point(aes(x = college, y = income, size = population, colour = growth), 
             alpha=.9)
```

As you can see in these examples, ggplot tries to be smart about the
mapping you ask. It automatically sets the x and y ranges to the values
in your data. It mapped the size such that there are small and large
points, but not e.g. a point so large that it would dominate the graph.
For the colour, for interval variables it created a colour scale, while
for a categorical variable it automatically assigned a colour to each
group.

Of course, each of those choices can be customized, and sometimes it
makes a lot of sense to do so. For example, you might wish to use red
for republicans and blue for democrats, if your audience is used to
those colors; or you may wish to use grayscale for an old-fashioned
paper publication. We’ll explore more options in a later tutorial, but
for now let’s be happy that ggplot does a lot of work for us!

# Bar plots

Another frequently used plot is the bar plot. By default, R bar plots
assume that you want to plot a histogram, e.g. the number of occurences
of each group. As a very simple example, the following plots the number
of states that are growing or stable in population:

``` r
ggplot(data = facts_state) + 
  geom_bar(aes(x = growth))
```

For a more interesting plot, let’s plot the votes per Republican
candidate in the New Hampshire primary. First, we need to download the
per-county data, summarize it per state, and filter to only get the NH
results for the Republican party: (see the previous tutorials on [Data
Transformations](R-tidy-5-transformation.md) and [Joining
data](R-tidy-13a-joining.md) for more information if needed)

``` r
url_state <- "https://raw.githubusercontent.com/houstondatavis/data-jam-august-2016/master/csv/primary_results.csv"

results_state <- read_csv(url_state) %>% 
  group_by(state, party, candidate) %>% 
  summarize(votes=sum(votes))

nh_gop <- results_state %>% 
  filter(state == "New Hampshire" & party == "Republican")
nh_gop
```

Now, let’s make a bar plot with votes (y) per candidate (x). We use
`geom_col` here, which means that we provide a `y` aesthetic rather than
having ggplot calculate it from the frequencies. Equivalently, we could
have users `geom_bar(stat="identity")` to create a bar plot with an
‘identity’ statistics.

``` r
ggplot(nh_gop) + 
  geom_col(aes(x=candidate, y=votes))
```

## Setting graph options

Some options, like labels, legends, and the coordinate system are
graph-wide rather than per layer. You add these options to the graph by
adding extra functions to the call. For example, we can use coord_flip()
to swap the x and y axes:

``` r
ggplot(nh_gop) + 
  geom_col(aes(x=candidate, y=votes)) +
  coord_flip()
```

You can also reorder categories with the `fct_reorder` function, for
example to sort by number of votes. Also, let’s add some colour (just
because we can!):

``` r
ggplot(nh_gop) + 
  geom_bar(aes(x=fct_reorder(candidate, votes), y=votes, fill=candidate), 
           stat='identity') + 
  coord_flip()
```

(Note: this works because ggplot assumes all labels are `factor`s, which
have an ordering; you can use other functions from the `forcats` package
(generally starting with `fct_`) to do other things such as reversing
the order, manually specifying the order, etc).

This is getting somewhere, but the y-axis label is not very pretty and
we don’t need guides for the fill mapping. This can be remedied by more
graph-level options. Also, we can use a `theme` to alter the appearance
of the graph, for example using the minimal theme:

``` r
ggplot(nh_gop) + 
  geom_bar(aes(x=reorder(candidate, votes), y=votes, fill=candidate), 
           stat='identity') + 
  coord_flip() + 
  xlab("Candidate") + 
  guides(fill="none") + 
  theme_minimal()
```

## Grouped bar plots

We can also add groups to bar plots. For example, we can set the x
category to state (taking only NH and IA to keep the plot readable), and
then group by candidate:

``` r
gop2 <- results_state %>% 
  filter(party == "Republican" & (state == "New Hampshire" | state == "Iowa")) 
ggplot(gop2) + geom_col(aes(x=state, y=votes, fill=candidate))
```

By default, the groups are stacked. This can be controlled with the
position parameter, which can be `dodge` (for grouped bars) or `fill`
(stacking to 100%): (note that the position is a constant, not an
aesthetic mapping, so it goes outside the `aes` argument)

``` r
ggplot(gop2) + geom_col(aes(x=state, y=votes, fill=candidate), position='dodge')
ggplot(gop2) + geom_col(aes(x=state, y=votes, fill=candidate), position='fill')
```

Of course, you can also make the grouped bars add up to 100% by
computing the proportion manually, which can give you a bit more control
over the process.

Note that the example below pipes the preprocessing output directly into
the `ggplot` command, that is, it doesn’t create a new temporary data
set like `gop2` above. This is entirely a stylistic choice, but can be
useful for operations that are only intended for a single visualization.

``` r
gop2 %>% 
  group_by(state) %>% 
  mutate(vote_prop=votes/sum(votes)) %>%
  ggplot() + 
    geom_col(aes(x=state, y=vote_prop, fill=candidate), position='dodge') + 
    ylab("Votes (%)")
```

Note that where `group_by %>% summarize` replaces the data frame by a
summarization, `group_by %>% mutate` adds a column to the existing data
frame, using the grouped values for e.g. sums. See our tutorial on [Data
Summarization](R-tidy-5b-groupby.md) for more details.

# Line plots

Finally, another frequent graph is the line graph. For example, we can
plot the ascendancy of Donald Trump by looking at his vote share over
time. First, we combine the results per state with the primary schedule:
(see the tutorial on [Joining data](R-tidy-13a-joining.md))

``` r
# dataset 1: dates for each primary
url2 <- "https://raw.githubusercontent.com/houstondatavis/data-jam-august-2016/master/csv/primary_schedule.csv"
schedule  <- read_csv(url2)
schedule <- schedule %>% 
  mutate(date = as.Date(date, format="%m/%d/%y"))
schedule

# dataset 2: vote share for trump for each state
trump = results_state %>% 
  group_by(state, party) %>% 
  mutate(vote_prop=votes/sum(votes)) %>% 
  filter(candidate=="Donald Trump")
trump

# join the two data sets
trump <- left_join(trump, schedule) %>% 
  group_by(date) %>% 
  summarize(vote_prop = mean(vote_prop))
trump
```

Take a minute to inspect the code above, and try to understand what each
line does! The best way to do this is to inspect the output of each
line, and trace back how that output is computed based on the input
data.

``` r
ggplot(trump) + geom_line(aes(x = date, y = vote_prop))
```

We can do the same for multiple candidates as well, for example for the
democratic candidates:

``` r
dems <- results_state %>% 
  filter(party == "Democrat") %>% 
  left_join(schedule)
dems <- dems %>% 
  group_by(date, candidate) %>% 
  summarize(votes = sum(votes)) %>% 
  mutate(vote_prop = votes / sum(votes))
ggplot(dems) + 
  geom_line(aes(x = date, y = vote_prop, colour = candidate))
```

Bonus question: in the code for Trump, the proportion was calculated in
two statements (first per state, then per date), but in this code it is
calculated only per date. How does that matter? Is either calculation
more correct than the other?

# Multiple ‘faceted’ plots

Just to show off some of the possibilities of ggplot, let’s make a plot
of all republican primary outcomes on Super Tuesday (March 1st):

``` r
super <- results_state %>% 
  left_join(schedule) %>% 
  filter(party == "Republican" & date == "2016-03-01") %>% 
  group_by(state) %>% 
  mutate(vote_prop = votes/sum(votes))

ggplot(super) + 
  geom_bar(aes(x = candidate, y = vote_prop), 
           stat = 'identity') + 
  facet_wrap(~state, nrow = 3) + 
  coord_flip()
```

Note <sub>facet_wrap</sub> wraps around a single facet. You can also use
\~facet_grid() to specify separate variables for rows and columns

# Themes

Customization of things like background colour, grid colour etc. is
handled by themes. `ggplot` has two built-in themes: `theme_grey`
(default) and `theme_bw` (for a more minimal theme with white
background). The package ggthemes has some more themes, including an
‘economist’ theme (based on the newspaper). To use a theme, simply add
it to the plot:

``` r
library(ggthemes)
ggplot(trump) + 
  geom_line(aes(x = date, y = vote_prop)) + 
  theme_economist()
```

You can also modify any of the theming elements yourself (check the help
for `theme()` for more information):

``` r
ggplot(trump) + 
  geom_line(aes(x = date, y = vote_prop)) + 
  theme_economist() +
  theme(panel.grid.major.y = element_line(colour="lightblue"))
```

Some links for learning more about themes:

-   <https://ggplot2.tidyverse.org/reference/theme.html>
-   <https://www.datanovia.com/en/blog/ggplot-themes-gallery>
-   <http://rstudio-pubs-static.s3.amazonaws.com/284329_c7e660636fec4a42a09eed968dc47f32.html>

# Plotting maps

Geographic information can be plotted in `ggplot` much like scatter
plots, simply using longitude and lattitude as x and y. Often, we want
to plot data on an actual map of (part of) the world, for example to
plot locations of tweets or colour a map with information per country or
state.

In `ggplot` this is accomplished by plotting the shapes of the
countries. The package includes shape data for the US, the world, and
some countries like France, but unfortunately not EU or Germany. The
maps originate from the `maps` package, so you can check their
documentation to see what countries are included.

``` r
library(ggplot2)
states <- map_data('state')
head(states)
```

This basically tells ggplot what lines to draw to form a state. If a
state is not contiguous it will contain subregions resulting in multiple
polygons.

We can immediately plot this data, using the `geom_polygon` to plot
shapes. We specify x and y as longitude and lattitude, fill by state,
and make the state borders white.

``` r
ggplot(data = states) + 
  geom_polygon(aes(x = long, y = lat, fill = region, group = group), 
               color = "white") + 
  coord_fixed(1.3) + 
  guides(fill="none")  
```

Note: the last line fixes the aspect ratio to 1.3 and prevents a
per-state legend (guide) from being plotted.

This example coloured the states as a non-informative nominal variable.
We can also colour by our own data, for example by percentage white
ethnicity:

``` r
states <- facts_state %>% 
  mutate(region=tolower(area_name)) %>% 
  select(region, white) %>% 
  inner_join(states)

ggplot(data = states) + 
  geom_polygon(aes(x = long, y = lat, fill = white, group = group), color = "white") + 
  coord_fixed(1.3) + theme_void() + 
  ggtitle("Percentage white population per state") 
```
