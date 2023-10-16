# CCS.Amsterdam R Tutorials

This repository contains tutorials used for teaching R. For each tutorial, both an interactive and static 'handout' version is available.

Available tutorials:

<!-- Tutorial table -->


| Name  | Tutorial | Handout |
|-|-|
tidy-join | [link](https://vanatteveldt.shinyapps.io/tidy-join) | [link](handouts/tidy-join.md)
fun-with-cbs_for_Rockstars | [link](https://vanatteveldt.shinyapps.io/fun-with-cbs_for_Rockstars) | [link](handouts/fun-with-cbs_for_Rockstars.md)
fun-with-cbs | [link](https://vanatteveldt.shinyapps.io/fun-with-cbs) | [link](handouts/fun-with-cbs.md)
svd | [link](https://vanatteveldt.shinyapps.io/svd) | [link](handouts/svd.md)
tidy-stringr | [link](https://vanatteveldt.shinyapps.io/tidy-stringr) | [link](handouts/tidy-stringr.md)
rvest | [link](https://vanatteveldt.shinyapps.io/rvest) | [link](handouts/rvest.md)
tidy-summarize | [link](https://vanatteveldt.shinyapps.io/tidy-summarize) | [link](handouts/tidy-summarize.md)
tidy-pivot | [link](https://vanatteveldt.shinyapps.io/tidy-pivot) | [link](handouts/tidy-pivot.md)
ggplot | [link](https://vanatteveldt.shinyapps.io/ggplot) | [link](handouts/ggplot.md)
fun-with-cbs_for_young_audience | [link](https://vanatteveldt.shinyapps.io/fun-with-cbs_for_young_audience) | [link](handouts/fun-with-cbs_for_young_audience.md)
fun-with-cbs_engaging_language | [link](https://vanatteveldt.shinyapps.io/fun-with-cbs_engaging_language) | [link](handouts/fun-with-cbs_engaging_language.md)
svd-recommender | [link](https://vanatteveldt.shinyapps.io/svd-recommender) | [link](handouts/svd-recommender.md)
fun-with-cbs_for_artlovers | [link](https://vanatteveldt.shinyapps.io/fun-with-cbs_for_artlovers) | [link](handouts/fun-with-cbs_for_artlovers.md)
fun-with-cbs_ai_helper | [link](https://vanatteveldt.shinyapps.io/fun-with-cbs_ai_helper) | [link](handouts/fun-with-cbs_ai_helper.md)
tidy-1-select | [link](https://vanatteveldt.shinyapps.io/tidy-1-select) | [link](handouts/tidy-1-select.md)
functions | [link](https://vanatteveldt.shinyapps.io/functions) | [link](handouts/functions.md)
fun-with-cbs_for_gourmets | [link](https://vanatteveldt.shinyapps.io/fun-with-cbs_for_gourmets) | [link](handouts/fun-with-cbs_for_gourmets.md)
recoding | [link](https://vanatteveldt.shinyapps.io/recoding) | [link](handouts/recoding.md)


<!-- /Tutorial table -->


## Running tutorials locally

The interactive versions listed above are hosted on the free tier of [shinyapps.io](https://shinyapps.io), and might be unavailable if too many people have used them this month.

To run the tutorials locally, you should first install the `ccslearnr` package from GitHub:

```{r}
remotes::install_github("vanatteveldt/ccslearnr")
```

Now, you can run any of the tutorials as follows: 
(changing `tidy-1-select` to the name of the tutorial you want to run)

```{r}
learnr::run_tutorial("tidy-1-select", package = "ccslearnr")
```

Note that if you have trouble installing or running the packages, you can install the needed dependencies with the code below:

```{r}
install.packages("remotes")
install.packages("learnr")
remotes::install_github("rstudio/gradethis")
```
