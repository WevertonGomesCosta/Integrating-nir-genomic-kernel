# Integrating Near-Infrared Reflectance Spectroscopy and Genomic Data Using Kernel Methods

This repository contains the analytical pipeline used to compare genomic, phenomic, environmental, and weather-derived information through kernel methods for prediction of grain yield and 500-kernel weight (KW) in multi-environment maize trials.

## Official workflow

The pipeline follows this sequence:

1. `climate_data`
2. `matrizes`
3. `variance_components`
4. `analysis_prediction`
5. `analysis_prediction_run_outputs`
6. `visualization`

## Bilingual organization

The repository follows a fixed bilingual rule:

- **EN** = main mechanical version
- **PT** = functional version dependent on EN

In practice, the English files define the main execution logic. The Portuguese files preserve the same didactic structure in translated form and reuse artifacts already produced by the English workflow whenever necessary. This keeps the tutorial readable in both languages while avoiding unnecessary reprocessing of heavy steps.

## Prediction stage

The prediction stage is divided into two modules:

- **Part I — `analysis_prediction`**: inputs, MCMC settings, the 18-model catalog, Eta specification, and evaluation design (CV1, CV0, CV00, plus the CV2 training-set recovery diagnostic)
- **Part II — `analysis_prediction_run_outputs`**: prediction execution, output inventory, and metadata generated from the prediction stage

### Current execution standard

The current project standard is:

- **18 prediction models**
- **5,000 MCMC iterations**
- **10 repetitions**

These defaults should be kept consistent across the prediction modules and the downstream documentation unless a future methodological revision explicitly changes them.

## Output conventions

The main prediction outputs are stored in:

- **Final prediction CSV files**: `output/results/`
- **Persistent BGLR fitting files for convergence diagnostics**: `output/results/bglr_runs/`
- **Processed summary tables**: `output/tables/`
- **Figures**: `output/figures/`

The prediction files use the current naming convention based on `Eta1`–`Eta18`. Scenario, trait, repetition, and fold are represented in the hierarchical output paths and file names, with fold metadata also retained in the result tables where applicable.

## Repository architecture

The official structural and operational architecture of the pipeline is documented in [`ARQUITETURA_OPERACIONAL_PIPELINE.md`](ARQUITETURA_OPERACIONAL_PIPELINE.md).

That document summarizes:

- the logical order of the pipeline steps;
- the role of the EN and PT modules;
- the current split of `analysis_prediction` into two parts;
- the main outputs of each stage;
- the current rules for bilingual maintenance;
- the operational defaults used in the prediction workflow.
