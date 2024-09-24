StringR: Working with Textual Data in R
================

- [Introduction](#introduction)
- [String basics](#string-basics)
  - [Stringr functions](#stringr-functions)
  - [Combining Strings](#combining-strings)
  - [Subsetting Strings](#subsetting-strings)
  - [Exercise: subsetting](#exercise-subsetting)
- [Using string functions within data
  frames](#using-string-functions-within-data-frames)
  - [Changing texts with mutate and
    stringr](#changing-texts-with-mutate-and-stringr)
  - [Filtering texts](#filtering-texts)
  - [NAs and empty texts](#nas-and-empty-texts)
- [Searching for patterns: Regular
  expressions](#searching-for-patterns-regular-expressions)
  - [Searching for a specific text](#searching-for-a-specific-text)
  - [Case insensitive matching](#case-insensitive-matching)
  - [Matching whole words](#matching-whole-words)
  - [Finding numbers](#finding-numbers)
  - [Quantifiers: Finding multiples](#quantifiers-finding-multiples)
  - [Looking for letters](#looking-for-letters)
  - [Looking for symbols](#looking-for-symbols)
  - [A note on Backslashes and
    escaping](#a-note-on-backslashes-and-escaping)
- [Extracting patterns](#extracting-patterns)
  - [Using str_extract](#using-str_extract)
  - [Exercise: Extracting zip codes](#exercise-extracting-zip-codes)
- [Overview of regular expression
  syntax](#overview-of-regular-expression-syntax)

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
</style>

## Introduction

The goal of this tutorial is to get you acquainted with basic text
handling in R. A large part of this uses the `stringr` included in the
[Tidyverse](https://www.tidyverse.org/). For a more exhaustive
discussion of regular expressions and the stringr package, see chapter 9
of [Computational Analysis of
Communication](https://cssbook.net/content/chapter09.html), chapter 14
of [R for Data Science](http://r4ds.had.co.nz/), and the [stringr cheat
sheet](https://raw.githubusercontent.com/rstudio/cheatsheets/main/strings.pdf)

Note that in computer jargon, the word ‘string’ is often used to refer
to text or textual data. This name originates from seeing a text as a
‘string’ (sequence) of characters. Interestingly, even though R uses the
term `character` for textual values, the tidyverse package for handling
these values is called `stringr`. In any case, the words `text`,
`string`, and `character data` can be seen as synonyms for this
tutorial.

## String basics

The package `stringr` has a number of functions for dealing with
strings. Conveniently, almost all start with `str_`, so in RStudio you
can type `str_` and then press tab to get a list of available functions.

### Stringr functions

For all `str_` functions the first argument is the text we are working
with, that is, the within which we want to search, replace, or extract
something from. For example, `str_length` gives the length of the
string, `str_to_upper` converts a string to upper case, and `str_detect`
tells you whether a string contains a substring (in this case, `johnny`
contains `nn`):

``` r
library(tidyverse)
text = "String is just a fancy name for text"
str_length(text)
str_to_upper(text)
str_detect(text, "fancy")
```

### Combining Strings

To combine two strings, you can use `str_c` (which is equivalent to
built-in `paste0`):

``` r
library(tidyverse)
str_c("john", "mary")
str_c("john", "mary", sep = " & ")
```

It can also work of longer vectors, for example to put a prefix in front
of all words in a vector (or column) of texts:

``` r
library(tidyverse)
names = c("john", "mary")
str_c("Hello, ", names)
```

### Subsetting Strings

To take a fixed subset of a string, you can use str_sub. This can be
useful, for example, to strip the time part off dates:

``` r
library(tidyverse)
dates <- c("2019-04-01 12:00", "2012-07-29 01:12")
str_sub(dates, start = 1, end = 10)
```

### Exercise: subsetting

Below you have a tibble (data frame) with a date variable. Can you
create a new column ‘year’ that contains only the year part?

``` r
library(tidyverse)
d <- tibble(id=1:2, date=c("2019-04-01 12:00", "2012-07-29 01:12"))
d <- ____
head(d)
```

## Using string functions within data frames

The `stringr` functions discussed above directly work on textual
**values** rather than data frames (or tibbles). Normally, these values
would be contained within columns in our data frame.

For example, we could have a data frame of survey respondents, where we
asked people about their favourite animal:

``` r
library(tidyverse)
responses <- tibble(resp_id=c(1:5), name=c("Harry", "Shrek", "Homer", "Winnie", "Lurch"), 
                    answer=c("Owls, of course", "DONKEYS", NA, "owl", ""))
```

``` r
responses
```

### Changing texts with mutate and stringr

Suppose we would want to select only respondents who have an owl as a
favourite animal.

Since respondents are very careless with using capital letters, it makes
sense to first convert all responses to lower case. Since `str_to_lower`
works directly on the textual values, we can use it within a `mutate`
call to change a text within a column:

``` r
mutate(responses, answer=str_to_lower(answer))
```

Similarly, you can use `str_remove_all` to remove words from a text. For
example, we can remove the “, of course” part in the first answer:

``` r
mutate(responses, answer=str_remove_all(answer, ", of course"))
```

### Filtering texts

Now, we can use `str_detect` within a `filter` function to select only
rows containing a specific word.

**Exercise**: Can you complete the code below to convert the responses
to lower case, and then select only the respondents that love owls?

``` r
responses <- mutate(responses, answer=___)
owl_lovers <- filter(responses, ___)
owl_lovers
```

### NAs and empty texts

As you can see, two respondents didn’t really give an answer. Homer
skipped the question, leading to a missing value (NA). Lurch, however,
entered an empty (zero-length) answer, which is different from a missing
value. One way to deal with this is to use `str_length` within filter to
keep only answers with a minimal length, which can also be useful to
remove other answers that are too short (or too long) to be used:

``` r
filter(responses, str_length(answer) > 1)
```

Note: that automatically also removes the missing values, as
`str_length(NA)` results in a missing value, which causes the row to be
removed by the `filter` function.

## Searching for patterns: Regular expressions

The examples above showed how to find a specific word within a string.
In many cases, however, we want to find, replace, or extract certain
patterns in a string (for example, zip codes, dates, email addresses, or
html tags).

For this purpose, R (like most other languages) use *regular
expressions*, a very powerful way to define patterns for searching in
text. Although a full overview of regular expressions is beyond the
scope of this handout (there’s full books written on the subject!), this
tutorial will show you a number of useful patterns.

These patterns can be used in many other languages such as Python, but
also in word or excel within the search and replace function! So,
learning regular expressions will be quite useful even if you end up
using a different tool than R.

### Searching for a specific text

To showcase patterns, we will use the `str_view` command. This commands
highlights the found text within a longer text, which is very useful for
writing (and debugging!) patterns

As we saw above, we can easily search for a specific word in a text by
just searching for that word, for example the word ‘owl’:

``` r
txt = c("Owls, of course")
str_view(txt, "Owl") 
```

(Note: If you run this on your own computer, you might have to install
the htmlwidgets package for this to work)

### Case insensitive matching

Sometimes, it can be useful to match a word regardless of whether it is
lower or upper case. This can be achieved by defining the pattern more
explicitly using the `regex` function, which allows you to specify
options including `ignore_case`:

``` r
txt = c("Owls, of course", "I have an owl")
str_view(txt, regex("owl", ignore_case = TRUE)) 
```

### Matching whole words

As you can see in the example above, the pattern ‘owl’ did not really
match a word, but also the start of the word ‘owls’. In fact, all
patterns match one or more characters, in this case the letters o-w-l,
without regard for word boundaries. So, it would also match a text like
“Guinea fowl” – a beautiful bird, but not an owl!

To find words, we have to specify a **word boundary** at the start (and
maybe the end) of our pattern. A word boundary is indicated by the
special symbol `\\b`, so two backslashes followed by a b. So, to match
only the word ‘owl’, the patter would be `\\bowl\\b` (so, a `\\b`
followed by the word to find, followed by another `\\b`):

``` r
txt = c("Owls, of course", "I have an owl", "Guinea fowl are beautiful birds")
str_view(txt, regex("\\bowl\\b", ignore_case = TRUE)) 
```

**Exercise:** Can you change the code above to match any word starting
with owl? (so it should match ‘owl’ and ‘owls’, but not ‘fowl’)

### Finding numbers

Another common use case is to look for numbers within a text. For
example, respondents might give their age or mention a frequency in an
open text. It can also be useful to search for e.g. years or phone
numbers.

There’s a special symbol `\\d` that matches a number (a **d**igit). So,
suppose we have list of song titles:

``` r
songs = tribble(~author, ~title,
                "Nena", "99 Luftballons",
                "Billy Eilish", "Birds of a feather",
                "Pretenders", "2000 miles",
                "Pink Floyd", "Summer of '69")
```

``` r
songs
```

| author       | title              |
|:-------------|:-------------------|
| Nena         | 99 Luftballons     |
| Billy Eilish | Birds of a feather |
| Pretenders   | 2000 miles         |
| Pink Floyd   | Summer of ’69      |

**Exercise**: Can you filter this data set so you keep only the songs
that contain a number?

``` r
numbered_songs = filter(songs, ___)
numbered_songs
```

### Quantifiers: Finding multiples

The example above contained a pattern looking for a single digit.
Sometimes, however, we want to match multiple digits. For example, 4
consecutive digits could specify a year, and 5 digits could be an
(American) zip code, like the famous 90210 for Beverly hills.

At its simplest, like ‘aa’ would match two a’s, the pattern ‘\d\d’
matches two digits. We could combine this with a word boundary (`\\b`)
as discussed above to only match exactly two digits:

``` r
filter(songs, str_detect(title, '\\b\\d\\d\\b'))
```

Apart from repeating the `\\d` (or any other character or pattern), you
can also add a **quantifier**. A quantifier specifies how often the
thing before it should be repeated. You specify this with curly braces
and a number, for example `\\d{4}` matches four digits. You can also
specify a range, so `\\d{2,4}` matches 2 to four digits, and `\\d{4,}`
matches 4 digits or more.

Because it is so common to look for one or more of something
(i.e. `\\d{1,}`), this can be abbreviated to a simple `\\d+` You can
also make something optional, that is: match zero or one of them, by
using a question mark as an abbreviation for `{0,1}`.

``` r
films = c("12 years a slave", "2001: A space oddisey", "Se7en", "1492: Conquest of Paradise", "10000 Years later")
str_view(films, '\\d\\d')
str_view(films, '\\d{4}')
str_view(films, '\\d+')
```

(Note that the first pattern `\\d\\d` highlights four numbers in
e.g. 2001, but these are really two separate matches: it first matches
`20`, and then also matches `01`.

You can also make something optional, that is: match zero or one of
them, by using a question mark as an abbreviation for `{0,1}`. So,
`\\d+:` matches one or more digits followed by a colon, while `\\d+:?`
matches one or more digits, optionally followed by a colon:

``` r
films = c("12 years a slave", "2001: A space oddisey", "Se7en", "1492: Conquest of Paradise", "10000 Years later")
str_view(films, '\\d+:')
str_view(films, '\\d+:?')
```

### Looking for letters

Besides looking for numbers, sometimes we want to look for letters as
part of a pattern. For example, we could look for hashtags as a
hash-character followed by one or more letters.

We can use the special symbol `\\w` to find so called ‘**w**ord
characters’. Interestingly, this includes numbers and the underscore
sign (`_`) as well as letters:

If we are only looking for letters, we can use `\\p{L}` – where a bit
confusingly the curly braces are used to select a set of characters (in
this case, **L**etters) rather than to indidate the quantity. So, to
find exactly two letters, we could use `\\p{L}{2}`.

As an examples, we can use the pattern `#\\w+` to find hashtags: a hash
sign followed by one or more word characters.

``` r
tweets = tibble(tweet=c("I love #hashtags #rad", "@vanatteveldt is inactive", "Don't mail me at noreply@example.com #wontwork"))
filter(tweets, str_detect(tweet, '#\\w+'))
```

**Exercise**: Can you change to pattern above to match (simple) email
addresses, defined here as one or more letters, followed by an at-sign
(@), followed by more letters, a period, and more letters?

Note that there are many ways to solve this, so don’t worry if your
solution works but it’s not the one R was looking for.

### Looking for symbols

As you have seen, some symbols have a special meaning within regular
expressions (patterns): For example, `+` does not look for a literal
plus symbol in the text, rather it means that the preceding character
may be repeated. Similarly, we’ve seen that `{}` has a special meaning
as a quantifier. In fact, many non-alphanumeric characters have a
special meaning, including periods (`.`), dollar signs (`$`), question
marks (`?`), and parentheses (`(` and `)`). Note that you don’t need to
learn all of these now, but if you want there is an overview of symbols
at the end of this tutorial if you’re curious.

Of course, we sometimes need to look for actual parentheses or question
marks. This can be achieved by *escaping* the symbol with a double
backslash. So, while `.` has a special meaning (spoiler: it matches
everything), `\\.` matches only actual periods, and the same for `\\$`,
`\\?` and so on.

### A note on Backslashes and escaping

A small note on the use of backslashes `\`: these are said to *escape*
the next character, which means that they lose their special meaning.
So, `.` has a special meaning (any character), but `\\.` is “escaped”
and returns to just meaning a literal period.

If you ‘escape’ a regular character such as ‘w’, the reverse happens:
`w` has its literal meaning, but `\\w` has a special meaning (in this
case: **w**ord characters).

In regular expressions, **all** regular alphanumeric characters (a, b,
c) are literal matches, and some can be made special by escaping them
(such as `\\w` and `\\s`). Similarly, **some** non-alphanumeric
characters (such as `.` or `[`) have a special meaning, and **all**
non-alphanumeric characters can be escaped to represent its literal
match, so `\\.` matches a period, and `\\[` matches an opening square
bracket.

Finally, you **need to use double backslashes** every time because
otherwise R first processes the text, and also uses backslashes to
escape. So, `\\w` is processed to read `\w`, which is then used in the
regular expression. This also means that, to match a literal backslash,
you’d have to use `\\\\`, which is escaped by R to `\\`, which is the
regular expression for a literal backslash.

## Extracting patterns

Besides searching for (or filtering on) patterns, we often want to clean
up text in various ways. Suppose we have a data set with open survey
responses where we asked people for their email address:

``` r
addresses <- tribble(~id, ~text,
             1, "My address is wouter@example.com",
             2, "I don't want to give my address",
             3, "Don't mail me, just DM at @vanatteveldt",
             4, "dontreply@vu.nl")
```

``` r
addresses
```

|  id | text                                    |
|----:|:----------------------------------------|
|   1 | My address is <wouter@example.com>      |
|   2 | I don’t want to give my address         |
|   3 | Don’t mail me, just DM at @vanatteveldt |
|   4 | <dontreply@vu.nl>                       |

### Using str_extract

Besides replacing patterns, it can also be useful to extract elements
from a string, for example we can extract all hashtags or emails using
the (oversimplified) patterns we used earlier

``` r
addresses |> mutate(email = str_extract(text, "\\w+@\\w+\\.\\w+"))
```

(Note that this only extracts the first occurrence of each pattern.
Extracting multiple occurrences is more complicated as the results
wouldn’t really fit in a data frame. For this, see the ‘advanced usage’
section below)

### Exercise: Extracting zip codes

As an exercise, can you extract Dutch zip (postal) codes from the data
frame below? Modify the example code (which extracts the first number)
to match only zip codes.

Note: A Dutch zip code is four digits, followed by an optional space,
followed by two letters. So, “1234 AB” or “6543zz” would be valid zip
codes.

``` r
library(tidyverse)
t <- tibble(text=c("On Singel 445 my zip code was 1012 AB", "9876aa is also a zip code", "There are 9999 air balloons"))
t <- mutate(t, zip=str_extract(text, "\\d+"))
t
```

This exercise is more challenging than it appears. To create the
pattern, just start from the left, and convert each element (“four
numbers”, “an optional space”, etc) into the corresponding regular
expression syntax.

In the interactive version, you can use the ‘hint’ button to get hints.

Also note that there are many solutions that are all equally good. For
example, `\\d{4}` matches four digits, but so does `[0-9]{4}` or
`\\d\\d\\d\\d` – all of them are perfectly fine. So, if your code works
but doesn’t match the ‘official’ solution, don’t worry about it and be
proud of yourself!

## Overview of regular expression syntax

For reference, here is an overview of the various ways in which we used
regular expressions (patterns) in this tutorial

| Pattern                   | Explanation                                                  |
|---------------------------|--------------------------------------------------------------|
| owl                       | Matches the literal text ‘owl’                               |
| regex(owl, ignore_case=T) | Matches case-insensitively, e.g. ‘owl’, ‘Owl’, or even ‘OWL’ |
| \b                        | Word boundary, i.e. start or end of word                     |
| \bcat\b                   | The word ‘cat’, i.e. not ‘cats’ or ‘locate’                  |
| \bdog                     | A word starting with dog, i.e. ‘dog’, ‘dogs’, or ‘doggerel’  |
| \d                        | Any digit, i.e. 1 or 7                                       |
| \d\d                      | Two digits, i.e. 42                                          |
| \d{4}                     | Exactly four digits, i.e. 1984                               |
| \d{2,4}                   | Two to four digits, i.e. 69 or 1969                          |
| \d{4,}                    | At least four digits, i.e. 1984 or 90210                     |
| \d+                       | One or more digits                                           |
| \w                        | A word character (letter, number, or underscore)             |
| \p{L}                     | A letter                                                     |

This is only a (small) part of everything that’s possible with regular
expressions. See e.g. [this
table](https://cssbook.net/content/chapter09.html#tbl-regex) for a more
complete overview.

Note that if you search online for regular expression syntax, they will
usually include only single backslashes (so `\b` instead of `\\b`).
Simply add another backslash if you want to use it in R.
