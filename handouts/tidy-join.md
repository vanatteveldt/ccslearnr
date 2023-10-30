R Tidyverse: Joining data
================

- [Introduction](#introduction)
  - [Joining data](#joining-data)
  - [This tutorial](#this-tutorial)
- [Data](#data)
  - [Downloading and preparing the
    data](#downloading-and-preparing-the-data)
- [Inner joins](#inner-joins)
  - [Specifying columns](#specifying-columns)
  - [Different column names](#different-column-names)
- [Left and right joins](#left-and-right-joins)
  - [Performing left, right, and full
    joins](#performing-left-right-and-full-joins)
- [Investigating missing data](#investigating-missing-data)
  - [Anti and semi joins](#anti-and-semi-joins)

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
</style>

## Introduction

In many cases, you need to combine data from multiple data sources. For
example, you might need to combine political results per country or
region with demographics of these regions; or combine a text analysis of
various tweets or other texts with metadata about these texts; or
combine academic performance of students with information about their
school or courses.

In such cases, you need to **join** two different data frames, adding
the information about a *specific case or group* from one frame to the
information about the *same group* from the other frame.

### Joining data

To show how this works, let’s assume we are interested in a relation
between student performance and class size, and we have a data set about
individual student performance and a data set with class sizes per
school:

<figure>
<img
src="https://github.com/vanatteveldt/ccslearnr/blob/master/data/join1.png?raw=true"
alt="Figure 1: Data about students and schools" />
<figcaption aria-hidden="true">Figure 1: Data about students and
schools</figcaption>
</figure>

 

If we *join* this data, the information on class sizes is added to the
information per student:

![Figure 2: Joining
data](https://github.com/vanatteveldt/ccslearnr/blob/master/data/join2.png?raw=true)
 

There are three things to notice in this process. First, for joining it
is essential that the same cases or units can be identified in both data
sets. In this case, the `School` column identify which rows in the
schools data correspond to rows in the student data set. We say that we
**join** the data **by school**.

Second, in most cases there are multiple rows in one data set for each
row in the other data set: there are multiple students in the same
school. This results in the school information being copied to each
corresponding student.

Finally, in this case the same units (schools) existed in both data
sets. This is not always the case: maybe we don’t have students in our
sample for some schools, or maybe the class size information is missing
for some schools. In that case, you must choose which of the information
to keep, and which to remove. This is discussed in detail in the last
section of this tutorial.

### This tutorial

This tutorial will teach you the `inner_join` and other `_join` commands
used to combine two data sets on shared columns. See [CAC chapter 6.4:
Mergin Data](https://cssbook.net/content/chapter06.html#sec-join) and
[R4DS Chapter 13: Relational
Data](http://r4ds.had.co.nz/relational-data.html) for more information
and examples.

## Data

For this tutorial, we will look at data describing the US presidential
primaries. These data originate from the [MIT Election
Lab](https://electionlab.mit.edu/data), but to make it easier a lightly
preprocessed version is available from the repository of this tutorial.

There are two relevant files:

- [US_Demographics.csv](https://github.com/vanatteveldt/ccslearnr/blob/master/data/US_Demographics.csv):
  Demographics per county, such as population, income, and percentage of
  the population without a college degree
- [US_Elections_2020.csv](https://github.com/vanatteveldt/ccslearnr/blob/master/data/US_Elections_2020.csv):
  Election results per county per candidate

For many research questions, we need to be able to combine the data from
these files. For example, we might want to know how Trump’s performance
relates to the proportion of unemployed, non-white, or college-educated
people.

### Downloading and preparing the data

Before we start, let’s download the two data files:

``` r
library(tidyverse)
demographics <- read_csv("https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/US_Demographics.csv")
demographics
```

``` r
results <- read_csv("https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/US_Elections_2020.csv")
results
```

## Inner joins

The basic command for joining data in R is the `inner join`. It takes
two data frames and joins it on any variable that occurs in both.

It results in a new data frame with the information in both frames
joined together. For example, the code below joins the demographics and
results data sets

``` r
inner_join(demographics, results)
```

This seems to work very well, but as you can see it now joins on all
shared columns: state, county, and fips. This could be problematic if
there are e.g. spelling variations in the county names.

In fact, take a look at the county with fips 1049 in both demographics
and results data sets. What do you notice? Can you see this county in
the result of the inner join?

``` r
demographics |> filter(fips == 1049)
```

(add lines for the results and joined results above)

### Specifying columns

As we saw above, by default, joining is performed with all shared
columns as joining *keys*. If this is not correct, you can specify the
joining key with the `by=` option. This can be used to restrict joining
only on the column(s) we want, e.g. on the FIPS column:

``` r
inner_join(demographics, results, by = "fips")
```

As you can see, this duplicates the variables for state to state.x and
state.y, and the same for county. If this is not desirable, you can also
remove these columns before joining:

``` r
results |> 
  select(-county, -state) |> 
  inner_join(demographics)
```

### Different column names

Another common use case is if the variable names are not the same. For
example, lets say that in the demographics data it was actually renamed
to `county_fips`. We can then specify
`by=c("left_column"="right_column")` to join on two differently named
columns.

``` r
demographics_renamed <- rename(demographics, county_fips = fips)
inner_join(demographics_renamed, results, by=c("county_fips"="fips"))
```

(Of course, you could also first rename the column in either data.frame
and then join them – which is probably what I would do)

## Left and right joins

The function `inner_join` keeps only rows that occur in both data sets.
Thus, only rows with both an election result and demographics will be
kept with the code used above. In fact, if you look at the results of
the `inner_join` you see that there are about 200 missing data points if
you compare it to the results data – so apparently some results lacked
the corresponding demographics.

In many cases, dropping such cases is desirable since these cases are
probably not useful for analysis. However, in some situations you might
want to keep cases where either data frame does not have any rows.

For this, you can use `left_join`, `right_join`, and `full_join`. Their
use is illustrated in the diagram below:

<figure>
<img src="https://cssbook.net/content/img/ch07_figjoins.png"
alt="Figure 3: Join types" />
<figcaption aria-hidden="true">Figure 3: Join types</figcaption>
</figure>

 

As you can see, inner join keeps only data points that occur in both
data sets (the blue intersection in the middle). Left join, on the other
hand, keeps all cases that occur in the ‘left hand side’ data, i.e. the
first argument of the join. Similarly, right join keeps all cases from
the right. Outer (full) join, finally, keeps all cases.

### Performing left, right, and full joins

To illustrate these join types, lets consider some example data about
candidates:

``` r
age <- tibble(candidate = c("Trump", "Biden", "Hawkins"), 
              age = c(77, 80, 70))
party <- tibble(candidate = c("Trump", "Biden", "Jorgensen"),
                party = c("Republican", "Democrat", "Libertarian"))
age
party
```

As you can see, for Trump and Biden we have both age and party
affiliation. For the (green) candidate Hawkins, however, we are missing
party affiliation data, while for Jorgensen we are missing her age.

``` r
inner_join(age, party)
```

As you can see, the result of `inner_join` keeps only the two candidates
who occur in both data sets.

Change the join type to left, right, and full join, and observe the
difference. Does it make sense? What happens to the columns for which we
don’t have data?

## Investigating missing data

If we observe that an inner join causes data loss, we can investigate
what caused it by doing a full join and checking for a `NA` value in a
column that should not be empty:

``` r
full_join(demographics, results, by="fips") |> filter(is.na(county.x))
```

What can you tell from these results? Now check which rows are missing
from the results data. What do these results mean?

### Anti and semi joins

As a final note, you can use `anti_join(d1, d2)` to select only those
rows in d1 that don’t exist in d2. Similarly, `semi_join(d1, d2)`
selects those rows from d1 that also exist in d2.

Can you use anti_join to answer the same question as above, i.e. which
`results` rows are missing demographics data?

``` r
anti_join(___)
```
