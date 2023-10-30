Scraping data with RVest
================

- [Introduction: Scraping](#introduction-scraping)
  - [What is web scraping and why learn
    it?](#what-is-web-scraping-and-why-learn-it)
  - [Web scraping in a nutshell](#web-scraping-in-a-nutshell)
  - [How to read this tutorial](#how-to-read-this-tutorial)
- [Web scraping HTML pages in three
  steps](#web-scraping-html-pages-in-three-steps)
  - [A short intro to HTML](#a-short-intro-to-html)
  - [Opening the hood](#opening-the-hood)
  - [HTML Elements](#html-elements)
  - [Inspecting elements](#inspecting-elements)
  - [Finding the right element](#finding-the-right-element)
- [Selecting HTML elements](#selecting-html-elements)
  - [Selecting descendants (children, children’s children,
    etc.)](#selecting-descendants-children-childrens-children-etc)
  - [Selecting elements within an
    element](#selecting-elements-within-an-element)
- [Extracting data from elements](#extracting-data-from-elements)
  - [Selecting attributes](#selecting-attributes)

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

## Introduction: Scraping

Note that this tutorial also has a video version, so if that’s your cup
of tea, check it out
[here](https://www.youtube.com/watch?v=9GR26Y4z_v4). It might be
slightly different in places, but the important parts are still the
same.

### What is web scraping and why learn it?

The internet is a veritable data gold mine, and being able to mine this
data is a valuable skill set. In this tutorial we will be looking at a
technique called **web scraping**, which can greatly expand your horizon
in terms of what data you will be able to collect.

To put this into perspective, let’s distinguish three general ways to
gather online data. In the most straightforward situation, you can just
**download** some data, for instance as a CSV or JSON file. This is
great if it’s possible, but alas, there often is no download button.
Another convenient situation is that some platforms have an **API**. For
example, Twitter has an API where one can collect tweets for a given
search term or user. But what if you encounter data that can’t be
downloaded, and for which no API is available? In this case, you might
still be able to collect it using **web scraping**.

A simple example is a table on a website. This table might practically
be a data.frame, with nice rows and columns, but it can be hassle to
copy this data. A more elaborate example could be that you want to
gather all user posts on a web forum, or all press releases from the
website of a certain organization. You could technically click your way
through the website and copy/paste each item manually, but you (or the
people you hire) will die a little inside. Whenever you encounter such a
tedious, repetitive data collection task, chances are good you can
automate it with a web scraper!

In addition to being a very useful technique, I would furthermore
emphasize that web scraping is an excellent way to learn about R and
programming. When students ask how to approach become better in R (or
Python, or whatever), our first recommendation is to simply to spend
time with it on fun and/or rewarding tasks that intrinsically motivate
you. Web scraping is rather ideal in this regard. It touches upon
various useful programming skills, has an engaging puzzle-like element
in trying to conquer websites, and collecting your own novel data set
that you could use is pretty awesome. I mean, It’s literally building a
robot to do work for you! How cool is that?

### Web scraping in a nutshell

In this tutorial we will be using the `rvest` package (to **ha-rvest**
data). This is a neat little package developed by the venerable Hadley
Wickham (aka the mastermind behind the `tidyverse`). And in true
tidyverse fashion it makes web scraping really intuitive. Check out this
small piece of code that scrapes the world happiness report from
Wikipedia and shows the relationship between wealth and life expectancy.

**Note**: *This code is a bit different from the YouTube video, because
the World Happiness Report tables of recent years are empty (for some
reason)*

``` r
library(rvest)
library(tidyverse)

## import table from the Wikipedia url
happy_tables <- read_html("https://en.wikipedia.org/wiki/World_Happiness_Report") |>
  html_elements(".wikitable") |> 
  html_table()

## The third table (at the time of writing) is 2020, the newer ones are empty :(
happy_table_2020 <- happy_tables[[3]]
head(happy_table_2020)

## Plot relationship wealth and life expectancy
ggplot(happy_table_2020, aes(x=`GDP per capita`, y=`Healthy life expectancy`)) + 
  geom_point() + geom_smooth(method = 'lm')
```

**Exercise:** What happens when you change `[[3]]` into `[[4]]` in the
code above? Can you create a plot of hapiness score (y) against freedom
to make life choices (x)?

If you have a look at the code above, the scraping part is actually just
the short pipe at the top of the code! With `read_html(url)`, we visit
the Wikipedia page. Then `html_elements(".wikitable")` searches this
website to find all elements called ‘wikitable’, and `html_table()`
imports this these tables as data frames.

If you happen to know a bit about HTML, you might realize that
`html_elements(".wikitable")` just uses CSS to select the (first)
element with the `.wikitable` class. If so, congratulations, you now
basically know web scraping! If not, don’t worry! You really only need
to know very little about HTML to use web scraping. We’ll cover this in
the next section.

Off course, this is just a simple example. If you need to scrape all
press releases from a website, you will need more steps and some
additional functions from the `rvest` package. But take a minute to
think how this does cover the key logic. If we would want to scrape all
press releases from a website, our first step would be to find an
archive on the website that contains links to the press releases. We
would read this archive with `read_html()`, and then use
`html_elements()` to look for all HTML elements that contain the links.
Then for each link, we can again use `read_html()` to read the data, and
look for all HTML elements of the press release that we want to collect
(e.g., title, date, body).

### How to read this tutorial

Of course, it makes most sense to just read this thing from start to
finish. However, we’ll go through quite a lot of details before we get
to the actual scraping. If you’re the type of person that rather sees
something in action first, or want to see what scraping can do before
you decide to learn the details, you can also skip straight to the demo
cases section.

## Web scraping HTML pages in three steps

In this tutorial we focus on web scraping of HTML pages, which covers
the vast majority of websites. The general workflow then covers three
steps:

- **Reading HTML pages into R**. This step is by far the easiest. With
  `rvest` we simply use the `read_html()` function for a given URL. As
  such, you now already learned this step (one down, two to go!).
- **Selecting HTML elements from these pages**. This step is the most
  involved, because you need to know a bit about HTML. But even if this
  is completely new to you, you’ll be able to learn the most important
  steps within a good hour or so.
- **Extracting data from these elements**. This step is again quite
  easy. `rvest` has some nice, intuitive functions for extracting data
  from selected HTML elements.

In this section we’ll start with a **short introduction to HTML**, using
an example web page that we made for this tutorial. Then we’ll cover
**selecting HTML elements** and \*\*extracting data from HTML
elements\*.

### A short intro to HTML

The vast majority of the internet users **HTML** to make nice looking
web pages. Simply put, HTML is a markup language that tells a browser
what things are shown where. For example, it could say that halfway on
the page there is a table, and then tell what data there is in the rows
and columns.

In other words, HTML is the language that web developers use to display
**data** as a **web page** that’s nice for human interpretation. With
web scraping, we’re basically translating the **web page** back into
**data**. You really don’t need a deep understanding of HTML to do this,
but it’s convenient to understand the main ideas.

To get a feel for HTML code, open [this link
here](https://bit.ly/3lz6ZRe) in your web browser. Use Chrome or Firefox
if you have it (not all browsers let you *inspect elements* as we’ll do
below). You should see a nicely formatted document. Sure, it’s not very
pretty, but it does have a big bold title, and two ok-ish looking
tables.

### Opening the hood

The purpose of this page is to show an easy example of what the HTML
code looks like. If you right-click on the page, you should see an
option like *view page source*. If you select it you’ll see the entire
HTML source code. This can seem a bit overwhelming, but don’t worry, you
will never actually be reading the entire thing. We only need to look
for the elements that we’re interested in, and there are some nice
tricks for this. For now, let’s say that we’re interested in the table
on the left of the page. Somewhere in the middle of the code you’ll find
the code for this table.

    <table class="someTable" id="exampleTable">           <!-- table                -->
        <tr class="headerRow">                            <!--    table row         -->
            <th>First column</th>                         <!--       table header   -->
            <th>Second column</th>                        <!--       table header   -->
            <th>Third column</th>                         <!--       table header   -->
        </tr>
        <tr>                                              <!--    table row         -->
            <td>1</td>                                    <!--       table data     -->
            <td>2</td>                                    <!--       table data     -->
            <td>3</td>                                    <!--       table data     -->
        </tr>
        <tr>                                              <!--    table row         -->
            <td>4</td>                                    <!--       table dat      -->
            <td>5</td>                                    <!--       table dat      -->
            <td>6</td>                                    <!--       table data     -->
        </tr>
    </table>

This is the HTML representation of the table, and it’s a good showcase
of what HTML is about. The parts after the `<!--` are not part of the
HTML code, but comments to help you see the structure. First of all,
notice that the table has this *family tree* like shape. At the highest
level we have the `<table>`. This table has three **table rows**
(`<tr>`), which we can think of as it’s **children**. Each of these rows
in turn also has three **children** that contain the data in these rows.

### HTML Elements

Let’s see how we can tell where the table starts and ends. The **table**
starts at the opening tag `<table>`, and ends at the closing tag
`</table>` (the `/` always indicates a closing tag). This means that
everything in between of these tags is part of the table. Likewise, we
see that each **table row** opens with `<tr>`, and closes with `</tr>`,
and everything between these tags is part of the row. In the first row,
these are 3 *table headers* `<th>`, which contain the column names. The
second and third row each have 3 *table data* `<td>`, that contain the
data points.

Each of these components can be thought of as an **element** (more
strictly a **node**, but the distinction can be ignored for now). And
each of these elements can be selected with the `html_element` function.
Note that our table is `<table class="someTable" id="exampleTable">`. We
can now use the id to select this table (we’ll cover how this works in
the next section)

``` r
library(rvest)
## first, read the HTML code for our example HTML page
html <- read_html('https://bit.ly/3lz6ZRe')

## select the element where id="exampleTable"
html |> html_element('#exampleTable') 
```

The output looks a bit messy, but what it tells us is that we have
selected the `<table>` html element/node. It also shows that this
element has the three table rows (tr) as children, and shows the values
within these rows.

**Note**: \*that since this is a table element, you could also use
`html_table` like we did above to extract the data.\*\*

### Inspecting elements

HTML always has this tree structure. In this case we saw that the table
has rows, and these rows have values. But if we view the example page we
also see that our page has columns, and these columns have text. Let’s
now select the column on the right, and then extract this text.

To select this column, we first need to know a bit about it. This time,
instead of looking it up in the raw code, we’ll use the **inspect
element** feature of your browser. Note that not all browsers might have
this feature (or it might be disabled). If you can’t find it, it can be
worthwhile to install Google Chrome, because you’ll really like this
feature!! With it, you can right click on any part of a webpage, and
then select **inspect** to inspect the element!

<center>

<img
src="https://github.com/vanatteveldt/ccslearnr/blob/master/data/inspect_element.png?raw=true"
style="width:50.0%" />

</center>

This will open a sidebar in which you see the HTML code, but focused on
that element.

<center>

<img
src="https://github.com/vanatteveldt/ccslearnr/blob/master/data/inspect_element_right_column.png?raw=true"
style="width:50.0%" />

</center>

When you hover your mouse over the elements they light up on the page,
so you can directly see the correspondence between the code and the
page. The tree structure is also made more obvious by allowing you to
fold and unfold elements by clicking on the triangles on the left. This
is a great tool for web scraping, because it allows you to quickly
identify the HTML elements that you want to select.

### Finding the right element

In our case, we now see that the right column is specified as a `div`
with `class="rightColumn"`. We can now select this column by selecting
the div element with this class (more on this in the next section).

``` r
html |> html_element('div.rightColumn') 
```

We can extract the text with the `html_text2` function (more on this
below).

``` r
text <- html |> 
  html_element('div.rightColumn') |>
  html_text2()

cat(text)  ## (cat just prints the text more nicely)
```

**Exercise:** Can you change the code above so it only extracts the text
of the table in the right hand side column? (that is, it should output
the numbers and letters, but not the paragraph above it) Hint: you can
use the **id** of an element, see the example above where the element
with `id=exampleTable` was selected.

(note that there are many ways to do make this selection in HTML, so
don’t worry if you get the right result but R thinks it’s wrong!)

## Selecting HTML elements

The `rvest` package supports two ways for selecting HTML elements. The
first and default approach is to use **CSS selectors**. CSS is mostly
used by web developers to *style* web pages[^1], but it works just as
well for scraping. The second approach is to use **xpath**. This is a
bit more flexible, but it’s also harder to read and write. For sake of
simplicity we’ll only cover CSS selectors, which is often all you need.

There are quite a lot of [CSS
selectors](https://www.w3schools.com/cssref/css_selectors.asp) and we
won’t cover all of them. Here are the most common ones you’ll need for
web scraping. You can always look up the other ones, but these are good
to know by heart.

| selector       | example           | Selects                                                |
|----------------|-------------------|--------------------------------------------------------|
| element/tag    | `table`           | **all** `<table>` elements                             |
| class          | `.someTable`      | **all** elements with `class="someTable"`              |
| id             | `#steve`          | **unique** element with `id="steve"`                   |
| element.class  | `tr.headerRow`    | **all** `<tr>` elements with the `someTable` class     |
| .class1.class2 | `.someTable.blue` | **all** elements with the `someTable` AND `blue` class |

We can use these `CSS selectors` in `rvest` with the `html_element` and
`html_elements` functions. Both work the same way, but `html_element`
only returns **the first** element that meets the criteria, whereas
`html_elements` returns a set with all elements. This is important, but
might be a bit confusing. So let’s just walk through each CSS selector
for both functions to see what it does.

``` r
html = read_html('https://bit.ly/3lz6ZRe')

## find any <table> element
html |> html_element('table')            ## left table 
html |> html_elements('table')           ## set of both tables

## find any element with class="someTable"
html |> html_element('.someTable')       ## left table
html |> html_elements('.someTable')      ## set of both tables

## find any element with id="steve" 
## (only called it steve to show that id can be anything the developer chooses)
html |> html_element('#steve')           ## right table 
html |> html_elements('#steve')          ## set with only the right table 

## find any <tr> element with class="headerRow"
html |> html_element('tr.headerRow')     ## left table first row
html |> html_elements('tr.headerRow')    ## first rows of both tables

## find any element with class="sometable blue"
html |> html_element('.someTable.blue')  ## right table    
html |> html_elements('.someTable.blue') ## set with only the right table    
```

Note that the output of `html_element` is always a `html_node`, and the
output of `html_elements` is always an `xml_nodeset`. This can be a bit
confusing given that we looked for HTML elements, and it’s perfectly
fine for now to just think of an `html_node` as a single element (like a
single table), and of an `xml_nodeset` as just a list of multiple
elements.

Important to remember:

- `html_element` always returns a single element. If there are multiple
  elements that meet the condition, it will return the first element.
- `html_elements` always returns a list of elements. If there is only
  one element that meets the condition, you’ll just get a list with that
  one element.

Luckily, `rvest` is quite flexible in how it handles single elements and
lists of elements. The functions to extract data from single elements
also work on lists, and then just return a list of data. For example,
this is what happens if we use the `html_table()` function on a list of
tables.

``` r
tables = html |> html_elements('table')
html_table(tables)
```

This also works with the other functions for extracting data that we
discuss below.

### Selecting descendants (children, children’s children, etc.)

Sometimes it’s necessary to select elements via their parent. For
example, imagine you have a website with news articles, and you want to
extract all URLs mentioned in the news article. You can’t just extract
all URLs from the web page, because there are probably many outside of
the article as well. Instead, what you’d do is select the article
element first, and then within that article element you’d look for all
URLs.

Here’s how you’d do it. Let’s take the [Wikipedia page for Extinction
Rebellion](https://en.wikipedia.org/wiki/Extinction_Rebellion). And
let’s say we want to get only links from the main text of the article
(so NOT the ones in the left column, the list of languages, the info box
on the right, etc). At the time of writing (2023), the first link was to
the UK, the second was a link explaining environmental movements.

The code below just gets all the links. Links are typically in `<a>`
tags, so we’ll get all of them, and then use the `length()` function to
see how many we got.

``` r
library(rvest)
read_html('https://en.wikipedia.org/wiki/Extinction_Rebellion') |>
  html_elements('a') |>
  length()
```

If you run the code above directly, you will see it results in 540
links, starting mostly with boilerplate links to the various wikipedia
sections.

**Exercise**: Can you change the code so it only finds the links in the
**main text** of the article?

Do achieve this, first inspect the HTML. You will find that the body is
contained in an element with the
attributes`<div id="mw-content-text" ...>`.

Try changing the selection above into `#mw-content-text a`. If all is
well, this should limit the number of hyperlinks, but it does not start
with the link to the UK, but rather with the organization logo and a
list of founders from the infobox.

To get only the links within the article body, you can limit results to
hyperlinks within paragraphs. Paragraphs are `p` tags, so you can use
`#mw-content-text a` (or even just `p a` as there are no paragraphs
outside the main text). Does that work?

The code above allows you to select descendants of elements. The nice
thing about this is that it works for any combination of CSS selectors.
This was a combination of `id` (#content) and `element` (a), but it
could also have been `class element`, `class class` etc. Also, you can
actually string as many together as you like! So if you have an `<a>` in
a `<span>` in a `<div>`, you could look for `div span a`.

### Selecting elements within an element

The example above showed how you can search for elements contained in
other elements.

Sometimes, it can also be useful to first select one element (e.g. the
infobox), and then select further elements within it.

This is quite easy with `rvest`: You assign the first element (the
infobox) to an object. Then, you can run `html_element` on that object
rather than on the whole document.

For example, the code below saves the infobox element, and then lists
all hyperlinks within that element:

``` r
library(rvest)
html <- read_html('https://en.wikipedia.org/wiki/Extinction_Rebellion') 
infobox <- html |> html_element('.infobox')
infobox |> html_elements('a')
```

**Exercise:** Can you alter the code above to select all images from the
infobox?

If this is your first run in with CSS and HTML, this might al seem a bit
overwhelming. The good part though: this should cover most of what you
need! With just these CSS selectors, and the option to look for elements
within elements, you now have a super flexible tool for parsing HTML
content. But if you want to learn more about CSS selectors, you could
look through [this
list](https://www.w3schools.com/cssref/css_selectors.asp), or play [this
game](https://flukeout.github.io/#)

## Extracting data from elements

Once you have selected elements, you still need to extract data from
them. `rvest` offers several nice functions to do this. We’ve already
used the `html_table` and `html_text2` functions, but let’s shed a
little more light on them.

The `html_table` function doesn’t really need much more explanation
(right?). Given a table element, it can produce a data frame in R.

The `html_text` and `html_text2` functions both serve to extract text
from an element. They don’t just get the text directly from the element,
but also the text from all its descendants (children, grandchildren,
etc.). The difference between the two is subtle. `html_text` is faster,
but gives you the text as it appears in the html code. For example, look
at this text from the left column of our toy example:

``` r
library(rvest)
html <- read_html('https://bit.ly/3lz6ZRe')
html |> html_element('.leftColumn') |> html_text() |> cat()
```

That’s pretty ugly. See all those ‘\n’ and empty spaces? That’s because
in the HTML source code the developer added some line breaks and empty
space to make it look better in the code. But in the browser these extra
breaks and spaces are ignored. `html_text2` let’s you get the text as
seen in the browser.

**Exercise:** Can you change `html_text()` into `html_text2()` in the
code above? How does it change the output?

In general, you should just use html_text2(), but note that for huge
amounts of data html_text() might be faster.

### Selecting attributes

Another nice function is `html_attr` or `html_attrs`, for getting
attributes of elements. With `html_attrs` we get all attributes. For
example, we can get the attributes of the `#exampleTable`.

``` r
html |> html_elements('#exampleTable') |> html_attrs()
```

Being able to access attributes is especially useful for scraping links.
Links are typically represented by `<a>` tags, in which the link is
stored as the `href` attribute.

``` r
html |> html_elements('a') |> html_attr('href')
```

**Exercise:** The code below selects all images (`img` tags) in the XR
article. Can you fill in the blank to get the source location (`src`) of
these images?

``` r
library(rvest)
html <- read_html('https://en.wikipedia.org/wiki/Extinction_Rebellion') 
html |> html_elements('img') |> ____
```

[^1]: If you look at the HTML code of our [example
    page](view-source:https://bit.ly/31keW5P), you see that there is
    this `<style>...</style>` section, and in this section we also use
    CSS selectors to select elements. For example, the `.someTable`
    class is selected to style this table like an APA table, and the
    `.blue` class defines that any element with this class (in our case
    the second table) is colored blue.
