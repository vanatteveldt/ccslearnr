StringR: Working with Textual Data in R
================

- [Introduction](#introduction)
- [String basics](#string-basics)
  - [Using string functions](#using-string-functions)
  - [Combining Strings](#combining-strings)
  - [Subsetting Strings](#subsetting-strings)
  - [Exercise: subsetting](#exercise-subsetting)
- [Regular expressions](#regular-expressions)
  - [Regular expression syntax](#regular-expression-syntax)
  - [Patterns for words, whitepace, or specific
    characters](#patterns-for-words-whitepace-or-specific-characters)
  - [Backslashes and escaping](#backslashes-and-escaping)
  - [Finding more than one character](#finding-more-than-one-character)
  - [Creating patterns](#creating-patterns)
- [Finding and filtering on
  patterns](#finding-and-filtering-on-patterns)
- [Mutate: Replacing, removing, and extracting
  patterns](#mutate-replacing-removing-and-extracting-patterns)
  - [Extracting patterns](#extracting-patterns)
- [Unnest: Extracting multiple
  values](#unnest-extracting-multiple-values)
  - [List columns](#list-columns)
  - [Splitting text](#splitting-text)
  - [Using str_split](#using-str_split)
  - [Special case: `separate` for a known amount of
    columns](#special-case-separate-for-a-known-amount-of-columns)
- [A note on Unicode, UTF-8 and
  Encoding](#a-note-on-unicode-utf-8-and-encoding)
  - [Background](#background)
  - [Text encoding in R](#text-encoding-in-r)
  - [Dealing with encodings](#dealing-with-encodings)

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

The goal of this tutorial is to get you acquainted with basic string
handling in R. A large part of this uses the `stringr` included in the
[Tidyverse](https://www.tidyverse.org/). See also chapter 14 of [R for
Data Science](http://r4ds.had.co.nz/) and the [stringr cheat
sheet](https://raw.githubusercontent.com/rstudio/cheatsheets/main/strings.pdf)

Note that ‘string’ is not an official word in R (which uses `character`
to denote textual data), but since it’s the word used in most
documentations I will also use `strings` to refer to objects containing
textual data. (the name originates from seeing a text as a `string` or
sequence of characters). In any case, the words `text`, `string`, and
`character data` can be seen as synonyms for this tutorial.

## String basics

The package `stringr` has a number of functions for dealing with
strings. Conveniently, almost all start with `str_`, so in RStudio you
can type `str_` and then press tab to get a list of available functions.

### Using string functions

For example, `str_length` gives the length of the string, `str_to_upper`
converts a string to upper case, and `str_detect` tells you whether a
string contains a substring (in this case, `johnny` contains `nn`):

``` r
library(tidyverse)
str_length("johnny")
str_to_upper("johnny")
str_detect("johnny", "nn")
```

As usual, these functions can be applied to a column of strings using
`mutate` or `filter`:

``` r
library(tidyverse)
df = tibble(name=c("johnathan", "mary"))
mutate(df, len=str_length(name))
filter(df, str_detect(name, "y"))
```

Other useful functions are `str_to_lower`, `str_to_upper` (which mostly
mimic built-in `tolower` and `toupper`), and `str_to_title`.

### Combining Strings

To combine two strings, you can use `str_c` (which is equivalent to
built-in `paste0`):

``` r
library(tidyverse)
str_c("john", "mary")
str_c("john", "mary", sep = " & ")
```

It can also work of longer vectors, where shorter vectors are repeated
as needed:

``` r
library(tidyverse)
names = c("john", "mary")
str_c("Hello, ", names)
```

Finally, you can also ask it to *collapse* longer vectors after the
initial pasting:

``` r
library(tidyverse)
names = c("john", "mary")
str_c(names, collapse=" & ")
str_c("Hello, ", names, collapse=" and ")
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

## Regular expressions

The example above showed how to extract or replace a fixed part of a
string. In many cases, however, we want to find, replace, or extract
certain patterns in a string (for example, dates, email addresses, or
html tags), similar to how word or other text editors allow you to
search and replace specific patterns.

For this purpose, R (like most other languages) use *regular
expressions*, a very powerful way to write text patterns. Although a
full overview of regular expressions is beyond the scope of this handout
(there’s full books written on the subject!), below are some examples of
what you can do.

### Regular expression syntax

To find a regular expression in a text, we use the `str_view` command,
which is quite useful for designing/debugging expressions. At its
simplest, literal text such as `Bob` will simply match that word in the
text.

``` r
# if needed: install.packages("htmlwidgets")
txt = c("Hi, I'm Bob", "my email address  is  Bob@example.com", "A #hashtag for the #millenials")
str_view(txt, "Bob") # literal text just matches that text - Bob matches Bob
```

(Note: You might have to install the htmlwidgets package for this to
work)

### Patterns for words, whitepace, or specific characters

Regular expressions can specify what to match in a number of ways. The
examples below all match (a sequence of) individual characters, such as
word characters (`\\w`), digits (`\\d`), or whitespace (`\\s`):

``` r
str_view(txt, "m.") # . matches any character 
str_view(txt, "\\.") # \\. matches an actual period (.)  
str_view(txt, "\\w") # \w matches any 'word' character, meaning letters, numbers, and underscores
str_view(txt, "\\W") # \W matches anything except word characters
str_view(txt, "[a-z]") # [..] are character ranges, in this case, all lower caps letters 
str_view(txt, "[^abc]") # [^..] is a negated character range, in this case, all except the letters a, b, and c 
str_view(txt, "\\ba") # \b matches word boundaries,this matches an a at the beginning of a word
```

See e.g. [this
table](https://cssbook.net/content/chapter09.html#tbl-regex) for a more
complete overview.

### Backslashes and escaping

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

### Finding more than one character

You can also specify multiples of a character:

``` r
str_view(txt, "ad*")   # * means an a followed by zero or more (d's, in this case)
                       # and as many as possible (greedy)
str_view(txt, "ad*?")  # *? means zero or more (d's, in this case), but as few as needed (non-greedy)
str_view(txt, "ad+")   # + means one or more d's
str_view(txt, "ad+?")  # + means one or more d's, but as few as needed
str_view(txt, "ad?")   # ? means zero or one, i.e. an 'optional' match
str_view(txt, "add?")  # a single d, optionally followed by another d
str_view(txt, "B.*m")  # a B, followed by zero or more of any character 
                       # (and as many as possible), followed by an m
str_view(txt, "B.*?m") # a B, followed by zero or more of any character 
                       # (but as few as needed), followed by an m
```

Again, see e.g. [this
table](https://cssbook.net/content/chapter09.html#tbl-regex) for a more
complete overview.

### Creating patterns

These elements can be combined to make fairly powerful patterns, such as
for emails or introductions:

``` r
str_view(txt, "\\w+@\\w+\\.\\w+")  # matches (some) email addresses
str_view(txt, "I'm \\w+\\b")       # matches "I'm XXX" phrases
str_view(txt,  "#\\w+")            # matches #hashtags
```

Note, the email address pattern is far from complete, and will match
addresses with subdomains, numbers, and many other possibilities. It
turns out emails are surprisingly complex to match - but the pattern
below should do pretty well for all but the most arcane addresses:

``` r
regex_email = regex("[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+")
str_view(txt, regex_email)
```

For more information, see the [section on regular expressions in
Computational Analysis of
Commmunication](https://cssbook.net/content/chapter09.html#sec-regular)
and/or the [relevant section of
R4DS](https://r4ds.had.co.nz/strings.html#matching-patterns-with-regular-expressions),
or one of the many available resources on regular expressions.

## Finding and filtering on patterns

Regular expressions can be used e.g. to find rows containing a specific
pattern. For example, if we had a data frame containing the earlier
texts, we can filter for rows containing an email address:

``` r
t = tibble(id=1:3, text=txt)
t
t |> filter(str_detect(text, regex_email))
```

You can also `str_count` to count how many matches of a pattern are
found in each text:

``` r
t |> mutate(n = str_count(text, "#\\w+"))
```

**Exercise**: Can you `filter` the data frame `t` to keep only rows that
contain the word Bob?

``` r
t <- filter(t, ____)
t
```

## Mutate: Replacing, removing, and extracting patterns

You can also use regular expressions to do find-an-replace with
`str_replace_all`. For example, you can remove all punctionation,
normalize whitespace, or redact email addresses:

``` r
t |> mutate(
  nopunct = str_replace_all(text, "[^\\w ]", ""),
  normalized = str_replace_all(text, "\\s+", " "),
  redacted = str_replace_all(text, "\\w+@", "****@"),
)
```

To remove text, you can also use `str_remove_all`. So, you could replace
the `str_replace_all(text, "[^\\w ]", "")` in the example above with
`str_remove_all(text, "[^\\w ]")`. Note that `str_replace_all` replaces
all occurences of a pattern, while `str_replace` would only replace the
first, and similarly for `str_remove_all` and `str_remove`.

**Exercise**: Can you remove every word that starts with an ‘a’ or ‘A’
in the text column from the example data frame `t`? (so it should remove
the words ‘address’ and ‘A’, but nothing else)

``` r
t <- mutate(t, text=____)
t
```

*Hint*: This exercise is more challenging than it might appear. To make
the pattern to remove, think about what “a word starting with a specific
letter” means, and look at the examples above (or this table) for word
boundaries, word characters, and character classes.

Note that there are many other ways to solve this challenge, so if your
code produces the right outcome but doesn’t match the ‘official’
solution, that’s totally fine as well.

### Extracting patterns

Besides replacing patterns, it can also be useful to extract elements
from a string, for example the email or hashtag:

``` r
regex_email = regex("[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+")
t |> mutate(email = str_extract(text, regex_email),
             hashtag = str_extract(text, "#\\w+"))
```

Note that this only extracts the first occurrence of each pattern. You
can also use `str_extract_all` to extract all patterns, but since
multiple values don’t really fit into a single destination column, this
is a bit more complicated. The next section of this tutorial will show
how you can use `unnest_longer` to solve this issue.

**Exercise: extracting zip codes**

As an exercise, can you extract Dutch zip (postal) codes from the data
frame below? Modify the example code (which extracts the first number)
to match only zip codes.

Note: A Dutch zip code is four digits, followed by an optional space,
followed by two letters. So, “1234 AB” or “6543zz” would be valid zip
codes.

Hint: You can use `\\b` before and after the pattern to ensure that it
needs to be a separate word.

``` r
library(tidyverse)
t <- tibble(text=c("On Singel 445 my zip code was 1012 AB", "9876aa is also a zip code", "There are 9999 air balloons"))
t <- mutate(t, zip=str_extract(text, "\\d+"))
t
```

Again, this exercise is more challenging than it appears. To create the
pattern, just start from the left, and convert each element (“four
numbers”, “an optional space”, etc) into the corresponding regular
expression syntax.

Also note that there are many solutions that are all equally good. For
example, `\\d{4}` matches four digits, but so does `[0-9]{4}` or
`\\d\\d\\d\\d` – all of them are perfectly fine. So, if your code works
but doesn’t match the ‘official’ solution, don’t worry about it and be
proud of yourself!

## Unnest: Extracting multiple values

So far, all examples in this tutorial produced single values from each
string, e.g. containing whether it found a pattern, the result of a
replacement, or a single extracted value. This made it relatively easy
to work with using our known tidyverse functions such as `filter` and
`mutate` (if anything that uses regular expressions can be called easy…)

### List columns

However, in some cases you want to extract multiple values from a
string, or split a string into multiple values. Since this places
multiple values in a single column, R creates a *list column* for the
result. For example, let’s use `str_extract_all` to extract all the hash
tags from the earlier example:

``` r
txt = c("Hi, I'm Bob", "my email address  is  Bob@example.com", "A #hashtag for the #millenials")
t = tibble(id=1:3, text=txt)
mutate(t, tags=str_extract_all(text, "#\\w+"))
```

As you can see the resulting column (tags) has a `<list>` type, with the
first two rows having zero entries, and the third having two entries.

Now, if we want to continue working with these tags we need to first
turn them into a regular column. The best way to deal with this in the
context of a data frame is to use `unnest_longer` to turn the list into
a long format.

As you can see below, `unnest_longer` duplicates the rows with multiple
values, similar to how an inner join copies values if either data frame
has more rows per case.

``` r
library(tidyverse)
txt = c("Hi, I'm Bob", "my email address  is  Bob@example.com", "A #hashtag for the #millenials")
t = tibble(id=1:3, text=txt)
mutate(t, tags=str_extract_all(text, "#\\w+")) |>
  unnest_longer(tags, keep_empty = TRUE)
```

What happens if you remove the `keep_empty` option?

### Splitting text

Besides extracting multipe values, it can be very useful to split a text
column into multiple values. For example, a column could contains
multiple data points separated with a comma. Suppose we have this data:

``` r
d = tibble(person=c("Liam Jones", "Olivia Smith"), books=c("The great Gatsby, To kill a Mockingbird", "Pride and Prejudice, 1984, Moby Dick"))
d
```

If we want to split a column, in this case books, there are two good
options: `str_split` and `separate`.

### Using str_split

First, if there is variable number of data points such as the list of
books in the data set above, you can use str_split, which takes a
regular expression argument to split the column:

``` r
mutate(d, books = str_split(books, pattern=","))
```

Just like above, this produces a column of type ‘list’ which contains
multiple values per row.

**Exercise**: Can you normalize the output using `unnest_longer`? As an
added challenge, add a `mutate` call to call the `trimws` function on
the resulting column. This function **strip**s the **w**hite **s**pace
from a text.

``` r
mutate(d, books = str_split(books, pattern=",")) |>
  unnest_longer(____) |>
  mutate(___)
```

### Special case: `separate` for a known amount of columns

As a special case, the `separate` command can be used to split a column
into multiple columns, especially when it always contains the same
amount of values.

For example, the code below uses `separate` to separate the person
column into seperate columns for first and last name:

``` r
d |> separate(person, into=c("firstname", "lastname"), sep=" ")
```

As said, this is mostly useful if a column always contains a fixed
number of data points that each have a distinct meaning, e.g. first and
last name or city and state.

## A note on Unicode, UTF-8 and Encoding

<div class="Info">

This section is only needed if you are encountering encoding issues,
especially when dealing with non-Western text.

You can safely skip this section, and come back to it if you’re having
issues with non-latin characters or diacritics.

</div>

Finally, a short note about unicode and character encodings. As with
regular expressions, a full explanation of this topic is (well) beyond
the scope of this tutorial. See this [guide on unicode in
R](https://kevinushey.github.io/blog/2018/02/21/string-encoding-and-r/)
and the classic [What Every Programmer .. Needs To Know About Encodings
..](http://kunststube.net/encoding/) for some very useful information if
you need to know more.

### Background

A fairly short version of the story is as follows: when computers were
mostly dealing with English text, life was easy, as there are not a lot
of different letters and they could easily assign each letter and some
punctuation marks to a number below 128, so it could be stored as 7
bits. For example, A is number 65. This encoding was called ‘ASCII’.

It turned out, however, that many people needed more than 26 letters,
for example to write accented letters. For this reason, the 7 bits were
expanded to 8, and many accented latin letters were added. This
representation is called latin-1, also known as ISO-8859-1.

Of course, many languages don’t use the latin script, so other 8-bit
encodings were invented to deal with Cyrillic, Arabic, and other
scripts. Most of these are based on ASCII, meaning that 65 still refers
to ‘A’ in e.g. the Hebrew encoding. However, character 228 could refer
to greek δ, cyrillic ф, or hebrew ה. Things get even more complex if you
consider Chinese, where you can’t fit all characters in 256 numbers, so
several larger (multi-byte) encodings were used.

This can cause a lot of confusion if you read a text that was encoding
in e.g. greek as if it were encoded in Hebrew. A famous example of this
confusion is that Microsoft Exchange used the WingDings font and
encoding for rendering symbols in emails, amongst others using character
74 as a smiley. For non-exchange users (who didn’t have that font),
however, it renders as the ASCII character nr 74: “J”. So, if you see an
email from a microsoft user with a J where you expected a smiley, now
you know `:)`.

To end this confusion, *unicode* was invented, which assigns a unique
number (called a code point) to each letter. A is still 65 (or “1” in
hexadecimal R notataion), but δ is now uniquely “3B4”, and ф is uniquely
“444”. There are over 1M possible unicode characters, of which about 100
thousand have been currently assigned. This gives enough room for
Chinese, old Nordic runes, and even Klingon to be encoded.

You can directly use these in an R string:

``` r
"Some Unicode letters: \u41 \u03B4 \u0444"
```

Now, to be able to write all 1M characters to string, one would need
almost 24 bits per character, tripling the storage and memory needed to
handle most text. So, more efficient encodings were invented that would
normally take only 8 or 16 bits per character, but can take more bits if
needed. So, while the problem of defining characters is solved,
unfortunately you still need to know the actual encoding of a text.
Fortunately, UTF-8 (which uses 1 byte for latin characters, but more for
non-western text) is emerging as a de facto standard for most texts.
This is a compromise which is most efficient for latin alphabeters, but
is still able to unambiguously express all languages.

It is still quite common, however, to encounter text in other encodings,
so it can be good to understand what problems you can face and how to
deal with them

### Text encoding in R

To show how this works in R, we can use the charToRaw function to see
how a character is encoded in R:

``` r
charToRaw('A')
```

    ## [1] 41

Note that the output of this function depends on your regional settings
(called ‘locale’). On most computers, this should produce 41 however, as
most encodings are based on ASCII.

For other alphabets it can be more tricky. The Chinese character “蘭”
(unicode “62d”) on my computer is expressed in UTF-8, where it takes 3
bytes:

### Dealing with encodings

To convert between encodings, you can use the iconv function. For
example, to express the Chinese character above in GB2312 (Chinese
national standard) encoding:

``` r
charToRaw(iconv('蘭', to='GB2312'))
```

The most common way of dealing with encodings is to ignore the problem
and hope it goes away. However, outside the English world this is often
not an option. Also, due to general unicode ignorance many people will
use the wrong encoding, and you will even see things like
double-utf8-encoded text.

The *sane* way to deal with encodings is to make sure that all text
stored inside your program is encoded in a standard encoding, presumably
UTF-8. This means that whenever you read text from an external source,
you need to convert it to UTF-8 if it isn’t already in that form.

This means that when you use `read_csv` (on text data) or `readtext`,
you should ideally *always* specify which encoding the text is encoded
in:

``` r
readtext::readtext("file.txt", encoding = "utf-8")
read_csv("file.csv", locale=locale(encoding='utf-8'))
```

If you don’t know what encoding a text is in, you can try utf-8 and the
most common local encodings (e.g. latin-1 in many western countries),
you can inspect the raw bytes, or you can use the guessEncoding function
from readr:

``` r
guess_encoding("file.txt")
```
