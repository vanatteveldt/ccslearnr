# This file actually needs to be in the VU-election-study folder, just copied it here as a log

library(here)
library(tidyverse)

source(here("src/lib/data.R"))
data = list(w0 = read_csv(here("data/intermediate/wave0.csv")),
            w1 = read_csv(here("data/intermediate/wave1.csv")),
            w2 = read_csv(here("data/intermediate/wave2.csv")),
            w3 = read_csv(here("data/intermediate/wave3.csv")),
            w4 = read_csv(here("data/intermediate/wave4.csv"))
)

w = extract_waves(data)

k17 = resp %>% select(iisID, name=vote_2017) %>% add_column(wave="k17")
votes = w %>% filter(variable=="A2") %>% select(iisID, wave, name) %>% bind_rows(k17) %>%
  mutate(name=recode(name, "GroenLinks"="GL", "Undecided"="?"))

v <- votes |> filter(wave == "k17" | wave == "w4") |> pivot_wider(names_from="wave", values_from="name") |> 
  select(iisID, tk2017=k17, tk2021=w4)


v <- extract_wide(data$w0) |> select(iisID, age, education, job, gender, region, ethnicity) |> 
  inner_join(v) |>
  write_csv("~/ccslearnr/data/vu_election_2021.csv")
