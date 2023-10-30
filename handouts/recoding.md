Recoding data in R
================

- [Introduction: Recoding variables](#introduction-recoding-variables)
- [Recoding values](#recoding-values)
  - [Why Recoding?](#why-recoding)
  - [Creating two categories:
    `if_else`](#creating-two-categories-if_else)
  - [Creating multiple categories:
    `case_match`](#creating-multiple-categories-case_match)
  - [Checking recoding results with
    `summarize`](#checking-recoding-results-with-summarize)
  - [Recoding any value: `case_when`](#recoding-any-value-case_when)
- [Dates and date formats](#dates-and-date-formats)
  - [Converting text to dates](#converting-text-to-dates)
  - [Format strings](#format-strings)
  - [Exercise](#exercise)
  - [Weeks, Months, and years](#weeks-months-and-years)

## Introduction: Recoding variables

Quite often, the data you have is not quite the data you’d like to have.
For example, dates might be in the wrong format, variables might be
coded the wrong way, it might contain typos or other mistakes, etc.

In this tutorial, you will learn about a number of common recoding steps
that you can use to solve such issues.

## Recoding values

Often, our data is categorized or coded differently from how we would
like to analyse it. Fixing this is generally called ‘recoding’, and in
this section you will learn three tidyverse functions for achieving
this.

### Why Recoding?

For example, for the 2021 elections we received data from a panel survey
company that looked like this:

``` r
library(tidyverse)
votes = read_csv("https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/vu_election_2021.csv")
head(votes)
```

As you can see, this lists individual respondents with their age,
education, etc, and their voting behaviour in 2017 and 2021. Note that
the 2021 data contains many missing values as not everyone who started
the panel survey finished it.

Suppose we want to make an overview of e.g. TV use by age and education
(like in [our analysis of the first
wave](https://tk2021.vupolcom.nl/reports/wave0/#media-use-by-age-and-education)).
This means we would need to categorize age into age groups, and change
the categorization of the education column.

### Creating two categories: `if_else`

Om the simplest case, you might want to recode into two categories. For
example, is someone older than 65, did someone vote PVV or not, is
someone of Dutch origin or not?

In such cases, `if_else` is the easiest way to recode values. This
function takes 4 arguments: `if_else(condition, true, false, missing)`,
where `missing` is optional. The condition is a comparison similar to
when you use `filter`, e.g. `age >= 65`. For each row, if this condition
is True (i.e. the respondent is indeed older than 65), it will assign
the `true` value, otherwise it will assign the `false` value. If `age`
is missing (NA), it will assign the `missing` value. If you don’t
specify a value for missing cases, they will simply assign `NA`.

``` r
votes |> 
  mutate(is_65plus = if_else(age >= 65, "65+", "Not 65+")) |>
  select(iisID, age, is_65plus)
```

Exercise: In addition to the is_65plus column above, can you create a
column ‘origin’ with two values, ‘Dutch’ and ‘other’?

<div class="Info">

Note that base R also contains a very similar function, `ifelse`
(without the underscore). Although they will do the same in most cases.
we advise using the tidyverse fucntion `if_else` for two reasons. First,
it has explicit support for dealing with missing values, which can often
be quite useful. Second, there are some cases in which `ifelse` gives an
undesired result, especially when dealing with date values.

</div>

### Creating multiple categories: `case_match`

If we want to recode existing values into more than one category, we can
use `case_match(column, recode)`. The recode arguments match values from
the column, and specify which new category to assign. They do this by
(ab)using the **formula** notation that you might know from statistical
models. In case_match, each recode argument looks like
`value(s) ~ category`. If the column matches the value(s) in the
argument, it’s assigned that category. If if matched none of the
arguments, if will be assigned `NA` unless you specify a default value
with `.default=value`.

This sounds very complicated, so let’s look at an example. The following
code recodes the education into three categories:

``` r
votes |> mutate(edu_level=case_match(
  education,
  c("VMBO-T", "VMBO, MBO 1", "Elementary") ~ "Low",
  c("MBO 2-4", "HAVO/VWO") ~ "Middle",
  c("Bachelor", "Master") ~ "High"
)) |> select(iisID, education, edu_level)
```

### Checking recoding results with `summarize`

When recoding, it is often a good idea to check how the old and new
values correspond. We can group by on the old and new value, and use
`summarize` to count how often each case arises. For example, let’s
consider the following

``` r
votes |> mutate(job_category=case_match(
  job,
  c("Full-time employed", "Part-time employed") ~ "Employed",
  .default="Other"
)) |> group_by(job, job_category) |>
  summarize(n=n()) |> 
  arrange(job_category, desc(n))
```

**Exercise**: Can you update the code above to also include
‘enterpreneur’ in the employed category, and to create a category for
unemployed that contains both unemployed conditions?

### Recoding any value: `case_when`

The final function for recoding, `case_when`, is quite similar to the
case_match function you played with earlier. You also specify conditions
and values using the `condition ~ value` format. The big difference is
that where `case_match` used simple values or value lists as conditions,
with `case_when` you specify the condition as a comparison.

Again, let’s look at an example first:

``` r
votes |> mutate(age_category=case_when(
  age <= 30 ~ "Younger than 30",
  age < 65 ~ "Between 31 and 65",
  age >= 65 ~ "65+"
)) |> select(iisID, age, age_category)
```

**Exercise**: Can you split the 31 to 65 category into two categories,
“Between 31 and 45” and “Between 46 and 65”?

An important thing to note in the code above is that you don’t need to
specify e.g. `age > 30 & age < 65` for that category. The reason for
that is that the conditions are evaluated from top to bottom. Thus,
anyone younger than 30 will already be dealt with by the first category,
so the second condition is never checked. As with case_match, you can
set a `.default` value for any case not matched by the conditions,
e.g. because of missing values.

While this last function is a bit more verbose than `case_match`, it is
incredibly useful in two cases. First, like the example above, for
categorizing values into ranges it is better to specify the range with a
comparison than as a list of all ages belonging to the category.
Secondly, you can use aribitrary functions from different columns. For
example, we could use `str_detect(job, 'Unemployed') ~ "unemployed"` to
find all cases that include the word ‘Unemployed’, rather than having to
specify them all. We could also combine values from different columns,
e.g. with something like
`age < 30 & str_detect(job, 'Unemployed') ~ "Unemployed youth"`

The advice is generally to use the simplest function possible. If
`if_else` does the job, it’s the easiest function to use. However,
learning how to use `case_match` and `case_when` gives you acess to two
very flexible recoding functions.

## Dates and date formats

We are often interested in how things change over time, for which we
need to work with date and time data. In this tutorial, we go over three
of the most common use cases: converting text to date, formatting dates
as text, and computing the year, month or week of a date (so we can
group by e.g. year).

These examples all use functions from tidyverse’s `lubridate` package,
which is automatically loaded when you load tidyverse. See also the
[lubridate page](https://lubridate.tidyverse.org/), which also links to
the R4DS chapter and cheat sheet.

### Converting text to dates

Many data sets contain a date or timestamp column, but often these are
not directly recognized as dates. For example, they might be in German
(4.11.2016), American (11/4/2016) or textual foramt (4 November 2016).

The good news is that the `parse_date` (and `parse_date_time`) functions
make this quite easy. The bad news is that you still need to tell the
computer the **format** used: Is `11/4/2016` is a date in April or in
November?

For example, the call below parses that date assuming it’s American
notation:

``` r
library(tidyverse)
date <- parse_date_time("11/4/2016", "dmy")
date
class(date)
```

The code above converts the **text** “11/4/2016” in a Date object which
is represented as “2016-11-04”. It then checks the data type (or
`class`) of the object, which is `POSIXct`, which for R means a date
plus time. Since R now knows that it’s a date value, you can e.g. use +1
to add one day to the value. Try adding or subtracting a large number of
days, and you will see that R understand months, years, and even leap
years.

### Format strings

In the `parse_date_time` function above, a crucial role is played by the
second (`order`) argument. This describes how to read the date. In that
case, we are looking for a month number (`m`), day number (`d`), and a
year number (`y`).

For a full list of possible codes in this argument (like `m`), see the
[parse_date_time
documentation](https://lubridate.tidyverse.org/reference/parse_date_time.html).
The table below lists some of the most frequently used codes:

| Code |
|------|
| y    |
| m    |
| d    |
| H    |
| M    |
| S    |
| \-   |

Can you parse all of the dates below?

``` r
library(tidyverse)
parse_date_time("4.11.2016", ____)
parse_date_time("04-11-16", ____)
parse_date_time("4 November 2016", ____)
parse_date_time("November 4th, 2016", ____)
parse_date_time("04-11-2016 11:23", ____)
```

``` r
library(tidyverse)
parse_date_time("4.11.2016", "dmy")
parse_date_time("04-11-16", "dmy")
parse_date_time("4 November 2016", "dmy")
parse_date_time("November 4th, 2016", "mdy")
parse_date_time("04-11-2016 11:23", "dmy HM")
```

### Exercise

In 2015, the data science blog 538 had an [item about the US satirical
TV show *The Daily
Show*](https://fivethirtyeight.com/features/every-guest-jon-stewart-ever-had-on-the-daily-show/),
for which they kindly made their data available. As this is shared in a
CSV format, R inteprets the `Show` column (which has the date of the
show) as a textual (string) variable. Can you convert it into a Date
column?

``` r
library(tidyverse)
daily = read_csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/daily-show-guests/daily_show_guests.csv")
# daily <- daily |> mutate(date = parse_date_time(Show, ____))
head(daily)
```

``` r
library(tidyverse)
daily = read_csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/daily-show-guests/daily_show_guests.csv")
daily <- daily |> mutate(date = parse_date_time(Show, "mdy"))
head(daily)
```

### Weeks, Months, and years

Suppose we would want to analyse changes in the Daily show (or political
results, or income and poverty ) over time. Often, our date (like above)
is at the daily level, but for a model or graph we generally want to
group it at the monthly or weekly level. To do this, we can use the
`floor_date` function, which rounds a date down to the first day of the
month, week, or quarter it’s in.

The syntax for floor_date is floor_date(date, unit), where unit can be
e.g. “week”, “month”, or “quarter”.

Can you create a plot of the number of guests per category for each
quarter for the daily show?

Tip: If you select part of the code and press Run Code, only the
selected part is execute. This allows you to e.g. first only run the
first step and work on the second step once that works.

``` r
library(tidyverse)
daily = read_csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/daily-show-guests/daily_show_guests.csv")
daily <- daily |> 
  mutate(Date = parse_date_time(Show, "mdy")) |>
  mutate(Quarter = ____)  # Compute the Quarter from the Date value
perquarter <- daily |> group_by(Quarter, Group) |> 
  summarize(n=n()) |>
  mutate(Percentage=____)  # Compute the percentage from the count (hint: and the group total, i.e. the sum(n))
ggplot(perquarter, aes(____)) + # Set the right aesthetics
  geom_line() 
```

As an extra challenge (which is not included in the ‘official answer’
above), can you use the recode functions from the start of the tutorial
to clean up the guest categories, i.e. combine media and Media, and
create categories for all science or politics related guests?
