
library(tidyverse)
library(here)

# Raw election data

d = read_csv(here("data-scripts/tmp/elections_raw.csv")) |>
  pivot_longer(-contest_name:-total_counted, names_to="party", values_to="votes") |>
  filter(!str_starts(party, "uncounted_|rejected_"), !is.na(votes))

# Meta data on zip codes and municipalities

postcodes = read_csv2(here("data-scripts/tmp/pc6hnr20220801_gwb.csv")) |>
  inner_join(read_csv2(here("data-scripts/tmp/brt2022.csv")) |>
                         select(Buurt2022=buurtcode2022, buurt="buurtnaam2022", gm=GM_2022, gemeente=GM_NAAM, wk=WK_2022, wijk="WK_NAAM")) |>
  select(-Buurt2022, -Wijk2022, -Gemeente2022)

pc_gemeente = postcodes |> select(PC6, gm, gemeente) |> unique()


# Link results on zip code
# Note: A small number (42) of zip codes are in multiple municipalities - we discard these
pc_gemeente_u = pc_gemeente |> group_by(PC6) |> filter(n() ==  1) |> ungroup()
results_zip = d |> select(election_id, station_id, PC6=postcode, party, votes) |>
  mutate(PC6=str_replace(PC6, " ", "")) |>
  left_join(pc_gemeente_u) |>
  filter(!is.na(gm))

# Link on authority name, which seems to be the gemeente
authority_link = pc_gemeente |> select(gm, gemeente) |> unique()
results_name = d |> select(election_id, station_id, gemeente=managing_authority, PC6=postcode, party, votes) |>
    # Change 'Bergen (NH)' into 'Bergen (NH.)'
    mutate(gemeente=str_replace_all(gemeente, "\\)", ".)")) |>
    anti_join(results_zip, by="station_id") |>
    left_join(authority_link)

results = bind_rows(results_zip, results_name)

results_gm = results |>
  group_by(gm, gemeente, party) |>
  summarize(votes=sum(votes))

write_csv(results_gm, here("data/dutch_elections_2023ps.csv"))

# CBS data per gemeente

library(cbsodataR)
kern_cbs_2023 = cbs_get_data("70072ned", RegioS=has_substring("GM"), Perioden="2023JJ00")
kern_cbs_2022 = cbs_get_data("70072ned", RegioS=has_substring("GM"), Perioden="2022JJ00")
kern_cbs_2021 = cbs_get_data("70072ned", RegioS=has_substring("GM"), Perioden="2021JJ00")
demographics = kern_cbs_2021 |>
  select(gm=RegioS,
         v01_pop="TotaleBevolking_1",
         v57_density="Bevolkingsdichtheid_57",
         v20_65plus="k_65Tot80Jaar_20",
         v21_80plus="k_80JaarOfOuder_21",
         v43_nl="NederlandseAchtergrond_43",
         v122_disposable="ParticuliereHuishoudensExclStudenten_122",
         v132_income="ParticuliereHuishoudensExclStudenten_132",
         v142_wealth="ParticuliereHuishoudensExclStudenten_142",
         v153_uitkering="TotDeAOWLeeftijd_153"
         ) |>
  semi_join(results_gm)

write_csv(demographics, here("data/dutch_demographics.csv"))
