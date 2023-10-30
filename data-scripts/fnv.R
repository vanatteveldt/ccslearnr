library(rvest)
library(tidyverse)

scrape_fnv_page <- function(page) {
  url = str_c("https://www.fnv.nl/over-de-fnv/wie-we-zijn/perskamer/persberichten?page=", page)
  doc <- read_html(url)
  urls <-  doc |> html_elements(".nieuwsoverzicht__item") |> html_attr("href")
  titles <- doc |> html_elements(".nieuwsoverzicht__item-title") |> html_text2()
  dates <- doc |> html_elements(".nieuwsoverzicht__item-date") |> html_text()
  result =  tibble(title=titles, date=dates, url=urls) |> mutate(date = parse_date(date, "%d-%m-%Y"))
  return(result)
}


pr <- map(1:44, scrape_fnv_page, .progress=TRUE) |> list_rbind()
scrape_pr_text <- function(url) {
  full_url <- str_c("https://www.fnv.nl", url)
  text <- read_html(full_url) |>
    html_element(".content__without-title-image") |>
    html_text2()
  tibble(url=url, text=text) |>
    mutate(text = str_replace_all(text, "\\s*\n\\s*\\n\\s*", "\n\n"),
           text = trimws(text))
}
texts <- map(result$url, scrape_pr_text, .progress=TRUE) |> list_rbind()
inner_join(pr, texts) |> write_csv(here::here("data/fnv.csv"))

read_csv("~/Dropbox/onderwijs/soc/fnv.csv") |> write_csv(here::here("data/fnv.csv"))



w0 = read_csv("https://raw.githubusercontent.com/vupolcom/VU-Election-Study/main/data/intermediate/wave0.csv")
w0 |> select(gender, age, education,)


d_raw <- read_csv("https://raw.githubusercontent.com/vupolcom/VU-Election-Study/main/data/intermediate/wave0.csv")
source("https://raw.githubusercontent.com/vupolcom/VU-Election-Study/main/src/lib/data.R")
library(here)
long = extract_long(d_raw)
