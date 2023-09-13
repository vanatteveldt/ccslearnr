R Tidyverse: Data Summarization with group_by, summarize, and mutate
================

- [Introduction: Grouping and
  Summarizing](#introduction-grouping-and-summarizing)
  - [The role of grouping](#the-role-of-grouping)
- [Summarizing data in R](#summarizing-data-in-r)
  - [Data](#data)
  - [Grouping rows](#grouping-rows)
  - [Summarization functions](#summarization-functions)
  - [Summarizing data](#summarizing-data)
- [Using mutate on grouped data](#using-mutate-on-grouped-data)
- [Computing multiple summary
  values](#computing-multiple-summary-values)
  - [Exercise: Z-scores](#exercise-z-scores)
- [Grouping by multiple columns](#grouping-by-multiple-columns)
  - [Exercise: deviations from group
    means](#exercise-deviations-from-group-means)

<style>
.Info {
    background-color: rgb(204, 229, 255);
    border: 1px solid rgb(184, 218, 255);
    color: rgb(0, 64, 133);
    padding: 1em;
    margin: 1em;
}
.Info::before {
  font-weight: bold;
  content: "🛈 Information";
}
&#10;</style>

## Introduction: Grouping and Summarizing

The functions used in the earlier tutorial on data preparation worked on
individual rows. In many cases, you need to compute properties of groups
of rows (cases).

For example, you might want to know the average age per group of
respondents, or the total number of votes for a party based on data per
region.

This is called aggregation (or summarization) and in tidyverse uses the
`group_by` function followed by either `summarize` or `mutate`.

This tutorial will explain how these functions work and how they can be
used for data summarization.

### The role of grouping

When we summarize data, we generally want to summarize some value per
group of rows. For this reason, the process in R consists of two steps.

For this example, assume we have individual-level survey data with
gender and age per respondent:

<figure>
<img
src="https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/summarize1.png"
alt="Data to summarize" />
<figcaption aria-hidden="true">Data to summarize</figcaption>
</figure>

First, you define the groups by which you want to summarize. In this
case, we want two groups (for male and female), but of course in other
cases there can be many more groups. The result of *grouping* is a very
similar data frame, but in this case the groups are explicitly marked:

<figure>
<img
src="https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/summarize2.png"
alt="Grouped data" />
<figcaption aria-hidden="true">Grouped data</figcaption>
</figure>

Now, the second step is to compute the summary statistics per group. For
example, we could compute the average age for each group:

<figure>
<img
src="https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/summarize3.png"
alt="Summarized data" />
<figcaption aria-hidden="true">Summarized data</figcaption>
</figure>

In R, summarization also follows the same steps, with `group_by` used
for creating the groups (without changing the data), and `summarize`
used for computing the summary statistics and creating the resulting
frame containing the summarized data.

In the next section, we will look at these commands in detail.

## Summarizing data in R

Let’s look at how we can we summarize data in R:

### Data

First, let’s fire up tidyverse and load the gun polls data used in the
earlier example:

``` r
library(tidyverse)
url <- "https://raw.githubusercontent.com/fivethirtyeight/data/master/poll-quiz-guns/guns-polls.csv"
polls <- read_csv(url) |>
  select(Question, Population, Pollster, Support)
polls
```

    # A tibble: 57 × 5
       Question     Pollster           Support   Rep   Dem
       <chr>        <chr>                <dbl> <dbl> <dbl>
     1 age-21       CNN/SSRS                72    61    86
     2 age-21       NPR/Ipsos               82    72    92
     3 age-21       Rasmussen               67    59    76

### Grouping rows

Now, we can use the group_by function to group by, for example,
Question:

``` r
polls |> group_by(Question)
```

    # A tibble: 57 × 5
    # Groups:   Question [8]
       Question     Pollster           Support   Rep   Dem
       <chr>        <chr>                <dbl> <dbl> <dbl>
     1 age-21       CNN/SSRS                72    61    86
     2 age-21       NPR/Ipsos               82    72    92
     3 age-21       Rasmussen               67    59    76
     4 age-21       Harris Interactive      84    77    92
     5 age-21       Quinnipiac              78    63    93
     [...]

As you can see, the data itself didn’t actually change yet, it merely
recorded (at the top) that we are now grouping by Question, and that
there are 8 groups (different questions) in total.

<div class="Info">

The grouping information created by `group_by` is recorded on the data
frame, and will stay intact until you `group_by` on a different
variable. You can also remove grouping information using the `ungroup()`
function.

</div>

### Summarization functions

An important consideration here is that the function used should be a
*summarization function*, that is, a function that summarizes a group of
values to a single value. An example summarization function is `mean`,
which computes the mean (average) of a group of values:

``` r
values = c(1,2,3)
mean(values)
```

Other useful functions are for example `sum`, `max` and `min`.

Can you change the code above to compute the `sum` rather than the mean
of values?

### Summarizing data

Now, we are ready to use `summarize` to create the summarized data
frame.

This function is similar to `mutate` in the sense that we specify how to
compute the new columns using `name=function(column)` arguments.

``` r
polls |> group_by(Question) |> summarize(Support=mean(Support))
```

**Exercise**: Alter the code above to compute the highest level of
support (i.e. max support) per pollster

## Using mutate on grouped data

The previous section used `group_by(col1) |> summarize(name=fn(col2))`.
As you could see, this creates a new and often much smaller ‘summarized’
data frame, with one row per unique group and only keeps the grouping
column(s) and the calculated column(s).

Instead of `summarize`, you can also run `mutate` with summarization
functions on grouped data. In that case, the summary is computer per
group, but instead of replacing the data frame with only the summarized
data, the new column is added to the existing data frame, with the
values repeated within a group:

``` r
polls |> group_by(Question) |> mutate(Mean_Support=mean(Support))
```

This can be very useful to compute the relation between single values
and e.g. the group averages.

**Exercise:** Can you create a new column `difference`, that shows to
what extend an individual poll is higher or lower than the group
average? E.g. for the first row, the result would be (approximately)
`72 - 75.9 = -3.9`.

``` r
polls |> group_by(Question) |> mutate(Mean_Support=mean(Support), difference=____)
```

<div class="Info">

In `mutate`, if you compute two variables, you can already use the first
value in the second computation: R will do the computations one by one.

</div>

## Computing multiple summary values

The previous examples all grouped by a single variable and then computed
a single summary value. It is also possible to compute multiple values
in a single call.

The snippet below shows how you can compute the mean and standard
deviation (`sd`) of the Support per question. It also uses the function
`n()` (without argument) to compute the number of cases per question.

``` r
polls |> 
  group_by(Question) |> 
  summarize(mean=mean(Support), sd=sd(Support), n=n())
```

### Exercise: Z-scores

In statistics, the z-score or normalized value of a variable is it’s
number of standard deviations from the mean. For example, In the poll
from CNN support from age-21 was 72%. As you can see above, the mean
support for that question was about 76%, and the standard deviation was
about 6 percentage points. So, the CNN polls was about 0.67 standard
deviations lower than the average: it’s z-score is -0.67.

Can you compute the z-score for all polls? To do this, you can start
from the code above but use mutate rather than summarize to compute the
mean and standard deviation per question. Then, you compute the new
column by comparing the Support for that question to the computed mean.

``` r
polls |>
  group_by(Question) |>
  mutate(mean=mean(Support),  sd=sd(Support))
```

You can first just run the snippet above to see how the data looks.
Then, add a second `mutate` command to compute a new column called
`zscore`.

(Note that you can also include the new computation in the first mutate
call if desired, but it is a bit more readable to create a new mutate to
differentiate the group level and individual level computations.)\`  

## Grouping by multiple columns

In the `group_by` function, you can also specify multiple columns. For
example, the code below computes the average by question and by
populuation category.

``` r
polls |> group_by(Question, Population) |> summarize(Support=mean(Support))
```

    `summarise()` has grouped output by 'Question'. You can override using the `.groups` argument.
    # A tibble: 15 × 3
    # Groups:   Question [8]
       Question                    Population        Support
       <chr>                       <chr>               <dbl>
     1 age-21                      Adults               74.5
     2 age-21                      Registered Voters    76.4
     3 arm-teachers                Adults               42.7
     4 arm-teachers                Registered Voters    41.3
     [...]

As you can see, the result is a data set with one row per unique group,
that is, ther question - population combination. In the message above
the output, and in the output itself, you can also see that the result
it itself grouped by Question. When summarizing data with multiple
grouping value, R by default removes the last grouping column, so
instead of Question and Population it’s now just grouped by Question.

This behaviour can be quite useful if you want to compute new statistics
for the remaining groups. Note that you can remove this grouping either
by either adding `.groups=drop', or by calling the function`\|\>
ungroup()\` on the result.

### Exercise: deviations from group means

Starting from the code above, and taking into account that after the
summarize function the data is grouped by question, can you calculate
the deviation from the average support per population within each
question? So, the adults are `-0.95` point away from the average support
for age-21: the average support for age-21 is `75.4`, and
`74.5 - 75.4 = -0.95`.

``` r
polls |> 
  group_by(Question, Population) |> 
  summarize(Support=mean(Support)) |> 
  mutate(mean_support=____, deviation=____)
```
