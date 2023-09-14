library(tidyverse)

demo = read_csv("https://raw.githubusercontent.com/MEDSL/2018-elections-unoffical/master/election-context-2018.csv")
results = read_csv("https://raw.githubusercontent.com/vanatteveldt/ccslearnr/master/data/countypres_2000-2020.csv")

demo
demo |> select(fips, state, county, total_population, nonwhite_pct, female_pct,  age29andunder_pct, age65andolder_pct, median_hh_inc, clf_unemploy_pct, lesscollege_pct) |>
  write_csv("data/US_Demographics.csv")

results |> filter(year == 2020, office == "US PRESIDENT", mode == "TOTAL") |>
  select(fips=county_fips, state, county=county_name, party, candidatevotes) |>
  mutate(fips = as.numeric(fips), state=str_to_title(state), county=str_to_title(county), party=str_to_title(party)) |>
  write_csv("data/US_Elections_2020.csv")


