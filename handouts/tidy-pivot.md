Pivot data from long to wide and back
================

- [Introduction](#introduction)
  - [Long and Wide data](#long-and-wide-data)
- [Columns to rows: pivot_longer](#columns-to-rows-pivot_longer)
  - [Data](#data)
  - [`Pivot_longer`: from columns to
    rows](#pivot_longer-from-columns-to-rows)
  - [Exercise: plotting the data](#exercise-plotting-the-data)
- [Rows to columns: pivot_wider](#rows-to-columns-pivot_wider)
  - [From rows to columns](#from-rows-to-columns)
- [A more complicated case: wealth
  inequality](#a-more-complicated-case-wealth-inequality)
  - [The plan](#the-plan)
  - [Step 1. Pivot longer (wide to
    long)](#step-1-pivot-longer-wide-to-long)
  - [Step 2. Separating columns (splitting one column into
    two)](#step-2-separating-columns-splitting-one-column-into-two)
  - [Step 3. Pivot wider (long to
    wide)](#step-3-pivot-wider-long-to-wide)
  - [Conclusion](#conclusion)

<style>
.match {color: red}
li pre {border: 0px; padding: 0; margin:0}
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
.compacttable table {width:0%}
</style>

## Introduction

This tutorial discusses how to *reshape* data, particularly from long to
wide format and vice versa.

You can check out [Section 6.5 of Computational Analysis of
Communication](https://cssbook.net/content/chapter06.html#sec-pivot)
and/or [Chapter 12 of the R4DS
book](http://r4ds.had.co.nz/tidy-data.html) for mote information

### Long and Wide data

In a data matrix, normally the rows consist of observations (cases,
respondents) and the columns of variables containing information about
these cases. However, sometimes the columns really represent multiple
observations, e.g. different years of data on the same country or
different waves from the same respondents. Inversely, sometimes a single
observation is spread over multiple rows, with e.g. the number of lower
and higher education citizens treated as different rows.

In general, data is said to be in `long` format if there are many rows
and few columns, for example with student–grade data like below, where
there is a row for each student-course combination:

<div class="compacttable">

| Student | Course | Grade |
|:--------|:-------|:------|
| Nana    | BDCT   | 8.5   |
| Nana    | ISOC   | 7.0   |
| Joan    | BDCT   | 7.5   |
| Joan    | ISOC   | 6.0   |

The same data could be represented by creating a column for each course,
which would turn it into a `wide` table with one row per student:

| Student | BDCT | ISOC |
|:--------|:-----|:-----|
| Nana    | 8.5  | 7.0  |
| Joan    | 7.5  | 6.0  |

</div>

Which of these data is more useful depends on the task at hand. For many
tidyverse functions, such as creating a graph with a color per course,
or computing any form of average grade per course, long format is
generally the best option. In fact, the Tidyverse book refers to long
data as *tidy* data.

However, if we want to specifically compare different grades for a
student, or use the courses as separate variables in a statistical
model, it can be easier to have them in wide format.

Fortunately, as we will see in the code below, R makes it quite easy to
**pivot** between these format: `pivot_wider` makes long data wider, and
`pivot_longer` does the reverse.

## Columns to rows: pivot_longer

In this section, you will learn how to pivot wide data into longer data.

### Data

For this tutorial we will use the data from Piketty’s Capital in the
21st Century. In particular, we will work with the data on income
inquality, with the goal of making a graph showing the evolution of
income inequality in different countries.

For this, we load the income inequality data set and remove missing
values.

``` r
library(tidyverse)
url <- "https://raw.githubusercontent.com/ccs-amsterdam/r-course-material/master/data/income_topdecile.csv"
income_raw <- read_csv(url) |> na.omit()
income_raw
```

As you can see, the data stores the share of income going to the top
decile of earners per decade per country. This data is ‘wide’, in the
sense that the columns contain multiple observations, while it is
normally better (or tidier) to have the observations in different rows.
As we will see, that will make it easier to combine, adjust, or
visualize the data.

### `Pivot_longer`: from columns to rows

In tidyverse, the function used for transforming data from columns
(wide) to rows (long) is `pivot_longer`: the idea is that you stack the
information from multiple columns into a single, longer column.

The syntax for calling `pivot_longer` is as follows:
`pivot_longer(data, columns, names_to="key_column", values_to="value_column")`.
The first argument is the data (unless you use pipe notation, as shown
below). The second argument, columns, is a list of columns which need to
be gathered in a single column. You can list the columns one by one, or
specify them as a sequence `first:last`. The `names_to=` argument
specifies the name of a new column that will hold the names of the
observations, i.e. the old column names. In our case, that would be
`country` since the columns refer to countries. The `values_to=`
argument specifies the name of the new column that will hold the values,
in our case the top-decile of incomes. Note that you can omit both the
`names_to` and `values_to` argument, in which case the columns will get
the default names `name` and `value`.

Note that (similar to mutate and other tidyverse functions), the column
names don’t need to be quoted as long as they don’t contain spaces or
other characters that are invalid in R names.

``` r
# using pipe (%>%) notation
income <- income_raw |> pivot_longer(U.S.:Europe, names_to = 'country', values_to = 'income_topdecile')

# without using pipe notation
income <- pivot_longer(income_raw, U.S.:Europe, names_to = 'country', values_to = 'income_topdecile')

income
```

As you can see, every row now specifies the income inequality in a
single country in a single year (or actually, decade).

Note that in tidyverse style, you can also use negative select to
indicate which column NOT to pivot to longer. In that case, you would
use `-Year` instead of `U.S.:Europe`

### Exercise: plotting the data

As an exercise, can you pivot the data while:

- using the `-Year` notation
- calling the values column simply ‘topdecile’
- and plot it with a line graph, showing the `income_topdecile` on the
  y-axis, the year on the x-axis, and making a color per country?

``` r
income_raw |> 
  pivot_longer(____) |> 
  ggplot(____)
```

## Rows to columns: pivot_wider

Perhaps unsurprisingly, you can use `pivot_wider` to turn long data into
wide data. Let’s start from the wide-format country data created above:

``` r
income
```

### From rows to columns

Now, suppose we would like to compute the correlation between income
inequality in France and the U.S. For this, R expects these two values
to be in separate columns. The syntax of `pivot_wider` is
`pivot_wider(data, names_from=names_column, values_from=values_column)`.
Can you pivot the income data to wide format so the correlation
calculation below works?

``` r
income_wide <- pivot_wider(___)
cor.test(income_wide$U.S., income_wide$France)
```

## A more complicated case: wealth inequality

Let’s now look at the wealth inequality data from Piketty. Of course,
there is nothing inherently more complex about wealth inequality than
income inequality (from the data side, at least), but in this particular
case the columns contain the country as well as the measurement level
(top-decile, percentile, or promille):

``` r
wealth_raw <- read_csv("https://raw.githubusercontent.com/ccs-amsterdam/r-course-material/master/data/wealth_inequality.csv")
wealth_raw
```

As you can see, this dat is quite ‘messy’: Not only are the countries
contained in the columns, but the measurement level is as well. To make
sense of this data, we want to create a data frame with each row being
one year and country, and having columns for the various measured
quantities:

<div class="compacttable">

| Year | Country | top_decile | top_percentile | top_promille |
|:-----|:--------|:-----------|:---------------|:-------------|
| 1810 | France  | 0.799      | 0.456          | 0.171        |
| 1820 | France  | 0.818      | 0.467          | 0.190        |

</div>

### The plan

So, how do we get from columns containing both country anbd measurement
level, to rows for the countries and columns for the measurement level?

One way do do this would be the following:

1.  First, use `pivot_longer` so all the measurements are in a single
    column.
2.  Second, use `separate` to split `France: top decile` into `France`
    and `top decile`.
3.  Finally, use `pivot_wider` to pivot the measurement levels back to
    columns.

Don’t worry if this solution did not seem immediately obvious to you:
converting ‘data challenges’ into workflows like this is probably the
hardest part of data-driven research, and it will get more logical with
more practice.

### Step 1. Pivot longer (wide to long)

The first step is the same as above: gather all columns except for the
year column into a single column. You can keep the default names for the
columns (as we will be changing them later anyway)

``` r
wealth <- pivot_longer(____)
wealth
```

### Step 2. Separating columns (splitting one column into two)

The next step is to split the ‘key’ column into two columns, for country
and for measurement. As explained in the [working with
strings](https://github.com/vanatteveldt/ccslearnr/blob/master/handouts/tidy-stringr.md)
tutorial, this can be done using the `separate` command, for which you
specify the column to split, the new column names, and what `sep`arator
to split on:

``` r
separate(wealth, name, into = c("country","measurement"), sep=":")
```

As you can see, the `measurement` starts with a space, which is
annoying. Moreover, it contains a space in the middle, which will be
problematic if we turn it into a column later.

**Exercise**: Can you change the separator to get rid of the leading
space, and use `str_replace_all` to turn the remaining space into an
underscore?

``` r
wealth2 <- wealth |> 
  separate(____) |>
  mutate(____)
wealth2
```

### Step 3. Pivot wider (long to wide)

The wealth data above is now ‘too long’ to be tidy: the measurement for
each country is spread over multiple rows, listing the three different
measurement levels (decile, percentile, promille).

**Exercise**: Can you pivot the measurements back to columns and plot
the result as a line graph, showing top_percentile per year for each
country?

(Note that we first call na.omit to omit any completely empty rows in
the end result. )

``` r
wealth2 <- wealth |> 
  separate(name, into = c("country","measurement"), sep=": ") |>
  mutate(measurement=str_replace_all(measurement, " ", "_"))
```

``` r
pivot_wider(wealth2, ____) |>
  ggplot(____) + geom_line()
```

### Conclusion

Congrats! Coming up with such complicated data cleaning workflows is
quite challenging, but you now have all the tools needed for even the
most complex data cleaning and data wrangling operations.
