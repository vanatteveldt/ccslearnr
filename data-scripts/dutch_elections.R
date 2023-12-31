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

results <- bind_rows(results_zip, results_name)

results_gm <- results |>
  group_by(gm, gemeente, party) |>
  summarize(votes=sum(votes)) |>
  mutate(votes = votes/sum(votes) * 100) |>
  mutate(party = case_when(
    party == "Belang van Nederland (BVNL)" ~ "BVNL",
    party == "Partij van de Arbeid (P.v.d.A.)" ~ "PvdA",
    party == "PVV (Partij voor de Vrijheid) " ~ "PVV",
    party == "SP (Socialistische Partij)" ~ "SP",
    party == "Staatkundig Gereformeerde Partij (SGP)" ~ "SGP",
    party == "Partij van de Arbeid (P.v.d.A.) / GROENLINKS" ~ "PvdA / GROENLINKS",
    T ~ party
  ))

results_gm |> group_by(party) |> summarize(votes=sum(votes) / 345) |> arrange(-votes) |> print(n=100)

write_csv(results_gm, here("data/dutch_elections_2023ps.csv"))

# CBS data per gemeente

gm <- read_csv(here("data/dutch_elections_2023ps.csv")) |>select(gm, gemeente) |> unique()
# gm = results_gm |> select(gm, gemeente) |> unique()

library(cbsodataR)
#kern_cbs_2023 = cbs_get_data("70072ned", RegioS=has_substring("GM"), Perioden="2023JJ00")
#kern_cbs_2022 = cbs_get_data("70072ned", RegioS=has_substring("GM"), Perioden="2022JJ00")
kern_cbs_2021 = cbs_get_data("70072ned", RegioS=has_substring("GM"), Perioden="2021JJ00")
demographics =
  kern_cbs_2021 |>
  select(gm=RegioS,
         v01_pop="TotaleBevolking_1",
         v57_density="Bevolkingsdichtheid_57",
         v20_65_80="k_65Tot80Jaar_20",
         v21_80plus="k_80JaarOfOuder_21",
         v43_nl="NederlandseAchtergrond_43",
         v122_disposable="ParticuliereHuishoudensExclStudenten_122",
         v132_income="ParticuliereHuishoudensExclStudenten_132",
         v142_wealth="ParticuliereHuishoudensExclStudenten_142",
         v153_uitkering="TotDeAOWLeeftijd_153",
         v212_afstand_ziekenhuis="AfstandTotZiekenhuis_212",
         v216_afstand_basisschool="AfstandTotSchoolBasisonderwijs_216",
         v225_dichtheid_restaurants="AantalRestaurantsBinnen3Km_225"
         ) |>
  mutate(c_65plus=v20_65_80 + v21_80plus, v20_65_80=NULL, v21_80plus=NULL,
         v153_uitkering=v153_uitkering/v01_pop*100,
         gm = case_when(
           gm == "GM0370" ~ "GM0439",
           gm %in% c("GM0756", "GM1684", "GM0786", "GM0815", "GM1702") ~ "GM1982",
           gm %in% c("GM0398", "GM0416") ~ "GM1980",
           gm %in% c("GM1685", "GM0856") ~ "GM1991",

           T ~ gm
         ))  |>
  inner_join(gm) |>
    group_by(gm, gemeente) |>
    filter(!is.na(v01_pop)) |>
    summarize(
      v57_density = mean(v57_density),
      across(v43_nl:c_65plus, ~sum(.*v01_pop)/sum(v01_pop)),
      v01_pop=sum(v01_pop)) |>
  select(gm, gemeente, v01_pop,  everything())



write_csv(demographics, here("data/dutch_demographics.csv"))


veiligheid_raw = cbs_get_data("85146NED", RegioS=has_substring("GM"), Perioden="2021JJ00")

veiligheid <- veiligheid_raw |>
  select(gm=RegioS,
         voorzieningen_fysiek = FysiekeVoorzieningenSchaalscore_6,
         sociale_cohesie = SocialeCohesieSchaalscore_15,
         cijfer_leefbaarheid = RapportcijferLeefbaarheidWoonbuurt_18,
         overlast_sociaal = EenOfMeerVormenVanSocialeOverlast_34,
         cijfer_veiligheid = RapportcijferVeiligheidInBuurt_60,
        voelt_discriminatie = GediscrimineerdGevoeld_66,
        slachtoffers_criminaliteit = Slachtoffers_68,
        slachtoffers_geweld = Slachtoffers_72,
    ) |>
  mutate(gm=trimws(gm)) |>
  inner_join(gm) |>
  select(gm, gemeente, everything())

write_csv(veiligheid, here("data/dutch_demographics_veiligheid.csv"))

## GIS data per gemeente

library(sf)
download.file("https://geodata.ucdavis.edu/gadm/gadm4.1/gpkg/gadm41_NLD.gpkg",
              destfile=here("data-scripts/tmp/gadm41_NLD.gpkg"))

gemeentes <- st_read(
  dsn = here("data-scripts/tmp/gadm41_NLD.gpkg"),
  layer = "ADM_ADM_2")

gemeentes = gemeentes |>
  mutate(gemeente=case_when(
    GID_2 == "NLD.7.5_1" ~ "Bergen (L.)",
    GID_2 == "NLD.9.9_1" ~ "Bergen (NH.)",
    GID_2 == "NLD.3.5_1" ~ "Dantumadiel",
    GID_2 == "NLD.8.43_1" ~ "Nuenen, Gerwen en Nederwetten",
    GID_2 == "NLD.10.19_1" ~ "Rijssen-Holten",
    GID_2 == "NLD.4.34_1" ~ "Neder-Betuwe",
    GID_2 == "NLD.9.7_1" ~ "Purmerend",
    GID_2 %in% c("NLD.9.27_1", "NLD.9.33_1") ~ "Dijk en Waard",
    GID_2 %in% c("NLD.8.36_1", "NLD.8.59_1") ~ "Maashorst",
    GID_2 %in% c("NLD.8.54_1", "NLD.8.12_1", "NLD.8.16_1", "NLD.8.28_1", "NLD.8.41_1") ~ "Land van Cuijk",
    T ~ NAME_2)) |>
  select(GID_2, provincie=NAME_1, gemeente, geom)

write_rds(gemeentes, here("data/sf_nl.rds"))

