# CCS.Amsterdam R Tutorials

This repository contains tutorials used for teaching R. For each tutorial, both an interactive and static 'handout' version is available.

Available tutorials:

| Name  | Description | Main packages / functions | Tutorial | Handout | 
|-|-|-|-|-|
| tidy-1-select  | Intro to TidyVerse | select, filter, mutate |  [link](https://vanatteveldt.shinyapps.io/tidy-1-select/) | [link](handouts/tidy-1-select.md) |

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
