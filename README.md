# CCS.Amsterdam R Tutorials

This repository contains tutorials used for teaching R. For each tutorial, both an interactive and static 'handout' version is available.

Available tutorials:

<!-- Tutorial table -->


| Name  | Description | Tutorial | Handout |
|-|-|-|
fun-with-cbs | Demo of some fun stuff you can do in R |  [link](https://vanatteveldt.shinyapps.io/fun-with-cbs) | [link](handouts/fun-with-cbs.md)
tidy-1-select | Tidyverse basics | [link](https://vanatteveldt.shinyapps.io/tidy-1-select) | [link](handouts/tidy-1-select.md)
tidy-summarize | Tidyverse: Grouping and summarizing | [link](https://vanatteveldt.shinyapps.io/tidy-summarize) | [link](handouts/tidy-summarize.md)
ggplot | GGPlot Visualizations | [link](https://vanatteveldt.shinyapps.io/ggplot) | [link](handouts/ggplot.md)
tidy-join | Tidyverse: Joinging datasets | [link](https://vanatteveldt.shinyapps.io/tidy-join) | [link](handouts/tidy-join.md)
tidy-pivot | Tidyverse: Reshaping data | [link](https://vanatteveldt.shinyapps.io/tidy-pivot) | [link](handouts/tidy-pivot.md)
recoding | Recoding data | [link](https://vanatteveldt.shinyapps.io/recoding) | [link](handouts/recoding.md)
tidy-stringr | Basic text handling | [link](https://vanatteveldt.shinyapps.io/tidy-stringr) | [link](handouts/tidy-stringr.md)
rvest | Basics of web scraping | [link](https://vanatteveldt.shinyapps.io/rvest) | [link](handouts/rvest.md)
functions | Basics of R functions | [link](https://vanatteveldt.shinyapps.io/functions) | [link](handouts/functions.md)

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
