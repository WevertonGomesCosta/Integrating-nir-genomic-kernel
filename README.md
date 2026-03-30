# Integrating Near-Infrared Reflectance Spectroscopy and Genomic Data Using Kernel Methods

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
![R](https://img.shields.io/badge/Made%20with-R-blue.svg)
![GitHub repo size](https://img.shields.io/github/repo-size/wevertongomescosta/Integrating-nir-genomic-kernel)
![GitHub last commit](https://img.shields.io/github/last-commit/wevertongomescosta/Integrating-nir-genomic-kernel)
[![Website](https://img.shields.io/badge/Project%20Site-online-brightgreen)](https://wevertongomescosta.github.io/Integrating-nir-genomic-kernel/)

## Project scope

This repository contains the analytical pipeline, tutorial scripts, and project website for evaluating whether genomic, phenomic, and weather-derived information improve prediction for maize grain yield and kernel weight in multi-environment field trials.

The project integrates three main information sources:

- **Genomic markers** as SNP-based predictors
- **NIR spectra** as high-dimensional phenomic predictors
- **Weather-derived covariates** used to build the weather kernel (`W`)

In this repository, the term **weather** is used when referring specifically to meteorological covariates and the kernel derived from them. The term **environment** is reserved for the categorical macro-environment effect (`E`) and for the field-trial conditions in which the hybrids were evaluated.

## Current analytical message

The workflow is organized to support manuscript revision and reproducible reporting. The goal is **not** to assume that data integration automatically improves prediction. Instead, the current pipeline evaluates:

- the relative contribution of genomic (`G`), phenomic (`P`), and weather (`W`) information
- the role of interaction terms such as `G × E`, `P × E`, `G × W`, and `P × W`
- the behavior of linear, Gaussian, and arc-cosine kernels
- model performance across multiple prediction scenarios

A key interpretive point in the current version of the project is that:

- `W` should be interpreted as a **weather-derived complement** to `E`, not as a replacement for the categorical environment effect
- `P` should be interpreted with caution, because NIR-based similarity may capture strong physiological response to the environment in addition to potentially useful predictive structure

## Pipeline overview

The pipeline is organized as a sequence of tutorial-style R Markdown files.

### 1. `climate_data.Rmd`
Downloads daily weather data from NASA POWER, builds annual and daily weather-derived covariates, and exports the files used later to build the weather kernel.

Main outputs:
- annual weather summaries
- expanded daily weather table
- figures describing the seasonal weather profile

### 2. `matrizes.Rmd`
Harmonizes phenotypic, genomic, phenomic, and weather data and builds the aligned observation-level matrices and kernels used by the downstream models.

Main outputs:
- genomic kernel (`ZG`)
- phenomic kernel (`ZP`)
- categorical environment matrix (`ZE`)
- weather kernel (`ZW`)
- interaction kernels such as `ZGZE`, `ZPZE`, `ZGZW`, `ZPZW`
- nonlinear kernels and their interactions (`GGK`, `PGK`, `GAK`, `PAK`, `GGKE`, `PGKE`, `GAKE`, `PAKE`, `GGKW`, `PGKW`, `GAKW`, `PAKW`)

### 3. `variance_components.Rmd`
Consolidates variance-component results for the reduced set of **18 Bayesian multi-kernel models**. In the current workflow, this script is used mainly to organize, summarize, and visualize previously estimated posterior results, although it still preserves the structure needed to rerun the estimation stage when necessary.

### 4. `analysis_prediction.Rmd`
Runs the predictive analyses for the same reduced set of 18 models. The current version uses:

- `CV1`: untested genotypes
- `CV2`: training-set performance following the reference script
- `CV0`: leave-one-environment-out inside the fold structure
- `CV00`: untested genotypes in a leave-one-environment-out setting, also inside the fold structure

The computationally expensive model-fitting step is parallelized with `foreach`.

### 5. `visualization.Rmd`
Consolidates the raw prediction outputs and produces final summary tables and figures for the manuscript.

The current visualization workflow was designed to support direct comparison of:
- linear vs Gaussian vs arc-cosine kernels
- models without `W` vs models with `W`
- single-source vs combined `G + P` pathways

### 6. `article_results_for_manuscript_final.R`
Collects the main numerical outputs generated across the pipeline and writes manuscript-oriented summary tables and a compact report for downstream interpretation, revision, and reviewer responses.

## Reduced model set

The current workflow uses a reduced set of **18 models**. These models cover:

- single-source pathways with `E`
- combined genomic + phenomic pathways with `E`
- weather-augmented pathways with `W`

The weather kernel is used mainly in **models M10-M18**.

## Repository layout

- `analysis/`: main R Markdown workflows and website source files
- `code/`: auxiliary scripts
- `data/`: input datasets used by the pipeline
- `output/`: generated kernels, intermediate artifacts, summaries, and figures
- `docs/`: rendered project site for GitHub Pages

## Reproducibility setup

### R environment

If the project uses `renv`, restore the local environment with:

```r
install.packages("renv")
renv::restore()
```

### Main packages used in the pipeline

The current pipeline relies mainly on:

- `BGLR`
- `tidyverse`
- `ggplot2`
- `ggthemes`
- `patchwork`
- `workflowr`
- `nasapower`
- `foreach`
- `doParallel`
- `kableExtra`

## Notes on terminology

To keep the manuscript, website, and code consistent:

- use **weather kernel (`W`)** for meteorological covariates derived from NASA POWER
- use **environment effect (`E`)** for the categorical macro-environment term
- use **categorical environment matrix (`ZE`)** for the matrix associated with the environment structure
- avoid calling `W` an **environmental kernel** when it actually represents weather-derived information
- keep **environment** for trial conditions, macro-environments, and `G × E` or `P × E` style effects

## Recommended execution order

A clean run of the current workflow should follow this order:

1. `climate_data.Rmd`
2. `matrizes.Rmd`
3. `variance_components.Rmd`
4. clean `output/results/` if old prediction files exist
5. `analysis_prediction.Rmd`
6. `visualization.Rmd`
7. `article_results_for_manuscript_final.R`

## Important operational note

Before rerunning the prediction pipeline, remove old files from `output/results/`. The visualization script expects the current filename pattern generated by the updated prediction workflow, where prediction files are saved **by repetition** and the fold information is stored in the internal `.id` column of each CSV. This applies to `CV1`, `CV2`, `CV0`, and `CV00`.

## Data and DOI note

The datasets used in this repository are not original to this tutorial pipeline. Reuse conditions for external data sources may depend on the original source terms. A project-specific DOI should only be added once it is formally assigned.

## License

This project is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
