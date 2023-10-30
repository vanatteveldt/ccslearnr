Tidyverse I: tidy data
================

- [Explain scraping (copy-paste from or link to tutorial
  Kasper)](#explain-scraping-copy-paste-from-or-link-to-tutorial-kasper)
- [1. Let’s scrape FNV](#1-lets-scrape-fnv)
- [2. You can put that in a
  function!](#2-you-can-put-that-in-a-function)
- [3. And you can automate that:](#3-and-you-can-automate-that)
- [4. And you can also get the full text and see how often they mention
  something](#4-and-you-can-also-get-the-full-text-and-see-how-often-they-mention-something)
- [And as a bonus, you can add inflatie data to the
  mix](#and-as-a-bonus-you-can-add-inflatie-data-to-the-mix)

# Explain scraping (copy-paste from or link to tutorial Kasper)

# 1. Let’s scrape FNV

``` r
library(tidyverse)
library(rvest)

url <- str_c("https://www.fnv.nl/over-de-fnv/wie-we-zijn/perskamer/persberichten?page=1")
page <- read_html(url)
item_urls <-  page |> html_elements(".nieuwsoverzicht__item") |> html_attr("href")
dates <- page |> html_elements(".nieuwsoverzicht__item-date") |> html_text()
titles <- page |> html_elements(".nieuwsoverzicht__item-title") |> html_text()
persberichten <- tibble(date=dates, title=titles, url = item_urls)
persberichten
```

# 2. You can put that in a function!

``` r
scrape_fnv <- function(page) {
  url <- str_c("https://www.fnv.nl/over-de-fnv/wie-we-zijn/perskamer/persberichten?page=", page)
  page <- read_html(url)
  item_urls <-  page |> html_elements(".nieuwsoverzicht__item") |> html_attr("href")
  dates <- page |> html_elements(".nieuwsoverzicht__item-date") |> html_text()
  titles <- page |> html_elements(".nieuwsoverzicht__item-title") |> html_text()
  tibble(date=dates, title=titles, url = item_urls)
}

scrape_fnv(1)
scrape_fnv(2)
```

# 3. And you can automate that:

``` r
library(purrr)
pages = 1:10
persberichten = map_df(pages, scrape_fnv)
persberichten
```

# 4. And you can also get the full text and see how often they mention something

``` r
fnv_text <- function(url) {
  full_url <- str_c("https://www.fnv.nl", url)
  text = read_html(full_url) |>
    html_element(".content__without-title-image") |>
    html_text()
  tibble(url=url, text=text)
}

texts <- map_df(persberichten$url, fnv_text)
persberichten <- inner_join(persberichten, texts)

stakingen <- persberichten |>
  mutate(staking = str_count(text, "staking"),
         date = parse_date(date, "%d-%m-%Y"),
         month = floor_date(date, "month")) |>
  group_by(month) |>
  summarize(staking=sum(staking))
ggplot(stakingen, aes(x=month, y=staking)) + geom_line()
```

# And as a bonus, you can add inflatie data to the mix

``` r
library(cbsodataR)
inflatie = cbs_get_data("70936ned", Perioden=has_substring("MM")) |>
  mutate(month=parse_date(Perioden, "%YMM%m")) |>
  select(month, inflatie=JaarmutatieCPI_1)

inner_join(stakingen, inflatie) |>
  ggplot(aes(x=month, y=staking)) + 
  geom_line() +
  geom_line(aes(y=inflatie), color='red')
```
