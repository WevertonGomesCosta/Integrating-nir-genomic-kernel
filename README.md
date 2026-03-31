# Integrating Near-Infrared Reflectance Spectroscopy and Genomic Data Using Kernel Methods

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
![R](https://img.shields.io/badge/Made%20with-R-blue.svg)
![GitHub repo size](https://img.shields.io/github/repo-size/wevertongomescosta/Integrating-nir-genomic-kernel)
![GitHub last commit](https://img.shields.io/github/last-commit/wevertongomescosta/Integrating-nir-genomic-kernel)
[![Website](https://img.shields.io/badge/Project%20Site-online-brightgreen)](https://wevertongomescosta.github.io/Integrating-nir-genomic-kernel/)

## Project scope

This repository contains the analytical pipeline, tutorial scripts, and project website for evaluating whether genomic, phenomic, and weather-derived information improve prediction for maize grain yield and 500-kernel weight (KW) in multi-environment field trials.

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

### 6. Final manuscript-oriented summaries
Collects the main numerical outputs generated across the pipeline and produces manuscript-oriented summary outputs for downstream interpretation, revision, and reviewer responses.

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
7. final manuscript-oriented summaries

## Important operational note

Before rerunning the prediction pipeline, remove old files from `output/results/`. The visualization script expects the current filename pattern generated by the updated prediction workflow, where prediction files are saved **by repetition** and the fold information is stored in the internal `.id` column of each CSV. This applies to `CV1`, `CV2`, `CV0`, and `CV00`.

## Data and DOI note

The datasets used in this repository are not original to this tutorial pipeline. Reuse conditions for external data sources may depend on the original source terms. A project-specific DOI should only be added once it is formally assigned.

## License

This project is licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

---

# Versão em português

## Escopo do projeto

Este repositório contém o pipeline analítico, os scripts tutorializados e o site do projeto para avaliar se informações genômicas, fenômicas e derivadas do clima melhoram a predição de produtividade de grãos e peso de grãos de milho em ensaios multiambientes.

O projeto integra três fontes principais de informação:

- **Marcadores genômicos** como preditores baseados em SNPs
- **Espectros NIR** como preditores fenômicos de alta dimensionalidade
- **Covariáveis derivadas do clima**, usadas para construir o kernel climático (`W`)

Neste repositório, o termo **weather** é usado quando a referência é especificamente às covariáveis meteorológicas e ao kernel derivado delas. O termo **environment** é reservado para o efeito categórico de macroambiente (`E`) e para as condições de campo nas quais os híbridos foram avaliados.

## Mensagem analítica atual

O fluxo de trabalho foi organizado para apoiar a revisão do manuscrito e a documentação reprodutível dos resultados. O objetivo **não** é assumir que a integração de dados melhora automaticamente a predição. Em vez disso, o pipeline atual avalia:

- a contribuição relativa das informações genômicas (`G`), fenômicas (`P`) e climáticas (`W`)
- o papel de termos de interação como `G × E`, `P × E`, `G × W` e `P × W`
- o comportamento de kernels lineares, Gaussianos e arc-cosine
- o desempenho dos modelos em múltiplos cenários de validação

Um ponto interpretativo central na versão atual do projeto é que:

- `W` deve ser interpretado como um **complemento derivado do clima** a `E`, e não como substituto do efeito categórico de ambiente
- `P` deve ser interpretado com cautela, porque a similaridade baseada em NIR pode capturar forte resposta fisiológica ao ambiente além de uma possível estrutura preditiva útil

## Visão geral do pipeline

O pipeline é organizado como uma sequência de arquivos R Markdown em formato tutorial.

### 1. `climate_data.Rmd`
Baixa dados meteorológicos diários da NASA POWER, constrói covariáveis climáticas anuais e diárias e exporta os arquivos usados posteriormente para construir o kernel climático.

Principais saídas:
- resumos climáticos anuais
- tabela diária expandida
- figuras que descrevem o perfil climático sazonal

### 2. `matrizes.Rmd`
Harmoniza dados fenotípicos, genômicos, fenômicos e climáticos e constrói as matrizes e kernels alinhados em nível de observação usados pelos modelos posteriores.

Principais saídas:
- kernel genômico (`ZG`)
- kernel fenômico (`ZP`)
- matriz categórica de ambiente (`ZE`)
- kernel climático (`ZW`)
- kernels de interação como `ZGZE`, `ZPZE`, `ZGZW`, `ZPZW`
- kernels não lineares e suas interações (`GGK`, `PGK`, `GAK`, `PAK`, `GGKE`, `PGKE`, `GAKE`, `PAKE`, `GGKW`, `PGKW`, `GAKW`, `PAKW`)

### 3. `variance_components.Rmd`
Consolida os resultados de componentes de variância para o conjunto reduzido de **18 modelos Bayesianos multi-kernel**. No fluxo atual, este script é usado principalmente para organizar, resumir e visualizar resultados posteriores já estimados, embora ainda preserve a estrutura necessária para rerodar a etapa de estimação quando necessário.

### 4. `analysis_prediction.Rmd`
Executa as análises preditivas para o mesmo conjunto reduzido de 18 modelos. A versão atual usa:

- `CV1`: genótipos não observados
- `CV2`: desempenho no conjunto de treinamento, seguindo o script de referência
- `CV0`: leave-one-environment-out dentro da estrutura de folds
- `CV00`: genótipos não observados em um cenário leave-one-environment-out, também dentro da estrutura de folds

A etapa computacionalmente mais cara de ajuste dos modelos é paralelizada com `foreach`.

### 5. `visualization.Rmd`
Consolida as saídas brutas de predição e produz as tabelas-resumo e figuras finais do manuscrito.

O fluxo atual de visualização foi desenhado para apoiar comparações diretas entre:
- kernels lineares, Gaussianos e arc-cosine
- modelos sem `W` e com `W`
- vias de fonte única versus vias combinadas `G + P`

### 6. Resumos finais orientados ao manuscrito
Reúne as principais saídas numéricas geradas ao longo do pipeline e produz saídas-resumo orientadas ao manuscrito para interpretação, revisão e respostas a pareceristas.

## Conjunto reduzido de modelos

O fluxo atual usa um conjunto reduzido de **18 modelos**. Esses modelos cobrem:

- vias de fonte única com `E`
- vias combinadas genômicas + fenômicas com `E`
- vias enriquecidas com clima usando `W`

O kernel climático é usado principalmente nos **modelos M10-M18**.

## Estrutura do repositório

- `analysis/`: principais fluxos em R Markdown e arquivos-fonte do site
- `code/`: scripts auxiliares
- `data/`: conjuntos de dados de entrada usados pelo pipeline
- `output/`: kernels gerados, artefatos intermediários, resumos e figuras
- `docs/`: site renderizado para GitHub Pages

## Configuração de reprodutibilidade

### Ambiente em R

Se o projeto usar `renv`, restaure o ambiente local com:

```r
install.packages("renv")
renv::restore()
```

### Principais pacotes usados no pipeline

O pipeline atual depende principalmente de:

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

## Notas sobre terminologia

Para manter manuscrito, site e código consistentes:

- use **weather kernel (`W`)** para covariáveis meteorológicas derivadas da NASA POWER
- use **environment effect (`E`)** para o termo categórico de macroambiente
- use **categorical environment matrix (`ZE`)** para a matriz associada à estrutura ambiental
- evite chamar `W` de **environmental kernel** quando ele na verdade representa informação derivada do clima
- mantenha **environment** para condições de ensaio, macroambientes e efeitos do tipo `G × E` ou `P × E`

## Ordem recomendada de execução

Uma execução limpa do fluxo atual deve seguir esta ordem:

1. `climate_data.Rmd`
2. `matrizes.Rmd`
3. `variance_components.Rmd`
4. limpar `output/results/` se existirem arquivos antigos de predição
5. `analysis_prediction.Rmd`
6. `visualization.Rmd`
7. resumos finais orientados ao manuscrito

## Nota operacional importante

Antes de rerodar o pipeline de predição, remova arquivos antigos de `output/results/`. O script de visualização espera o padrão atual de nomes de arquivos gerado pelo fluxo de predição atualizado, no qual os arquivos de predição são salvos **por repetição** e a informação de fold é armazenada na coluna interna `.id` de cada CSV. Isso se aplica a `CV1`, `CV2`, `CV0` e `CV00`.

## Nota sobre dados e DOI

Os conjuntos de dados usados neste repositório não são originais deste pipeline tutorializado. As condições de reutilização de fontes de dados externas podem depender dos termos definidos na fonte original. Um DOI específico do projeto só deve ser adicionado quando for formalmente atribuído.

## Licença

Este projeto está licenciado sob [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
