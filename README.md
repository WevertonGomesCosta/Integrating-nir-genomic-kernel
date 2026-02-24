# Integrating Near-Infrared Reflectance Spectroscopy and Genomic Data for Improved Prediction Using Kernel Methods

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
![R](https://img.shields.io/badge/Made%20with-R-blue.svg)
![GitHub repo size](https://img.shields.io/github/repo-size/wevertongomescosta/Integrating-nir-genomic-kernel)
![GitHub last commit](https://img.shields.io/github/last-commit/wevertongomescosta/Integrating-nir-genomic-kernel)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.xxxxxxx.svg)](https://doi.org/10.5281/zenodo.xxxxxxx)
[![Website](https://img.shields.io/badge/Project%20Site-online-brightgreen)](https://wevertongomescosta.github.io/Integrating-nir-genomic-kernel/)

## Project scope

This tutorial repository contains code, data, and reports for integrating:

- **NIR spectra** (high-dimensional phenomic predictors),
- **Genomic markers** (SNP-based features), and
- **Environmental covariates**

into kernel-based predictive models for quantitative traits in plant breeding.

## Methodological components

- Data loading and harmonization across sources (`NIR`, `Geno`, `Pheno`).
- Genotype alignment and quality checks for consistent sample indexing.
- Kernel construction:
  - Genomic kernel (`ZG`)
  - Phenomic/NIR kernel (`ZP`)
  - Environmental kernels (`ZEZE`, `ZW`)
  - Interaction kernels (e.g., `ZG×E`, `ZP×E`, `ZG×W`, `ZP×W`)
- Predictive modeling with Bayesian regression (`BGLR`) under multiple cross-validation schemes (CV0, CV00, CV1, CV2).
- Consolidation and visualization of predictive ability.

## Repository layout

- `analysis/`: main R Markdown workflows and website source files.
- `code/`: modular R helper functions and automation scripts.
- `data/`: raw tutorial datasets.
- `output/`: generated matrices, intermediate artifacts, and predictive summaries.
- `docs/`: rendered static site (GitHub Pages target).

## Reproducibility setup (R-only)

### R environment (`renv`)

This repository includes a starter `renv.lock` file as a dependency manifest template for tutorial use. To reproduce the R environment locally:

```r
install.packages("renv")
renv::restore()  # or renv::init(); renv::snapshot()
```

### Package manifest (`requirements.txt`)

`requirements.txt` is used here as a plain list of **R packages** used by the analyses and helper scripts.

## Automated data sanity checks (R)

Run the automated data checks script:

```bash
Rscript code/run_data_sanity_checks.R
```

This script validates required columns, sample IDs, duplicates, environment labels, and overlap between NIR and genotype IDs. Reports are saved to:

- `output/data_sanity_report.csv`
- `output/data_sanity_summary.csv`

## Data and DOI note

The datasets in this repository are not original to this tutorial. For this reason, the DOI badge remains unchanged (placeholder format) until a project-specific DOI is formally assigned.

## License

This project is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
