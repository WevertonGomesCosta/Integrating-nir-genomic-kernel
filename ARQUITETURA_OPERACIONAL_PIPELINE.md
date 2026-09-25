# Arquitetura Operacional do Pipeline

## Finalidade

Este documento descreve a arquitetura ativa do projeto **Integrating Near-Infrared Reflectance Spectroscopy and Genomic Data Using Kernel Methods**. Ele serve como mapa do fluxo analítico, das dependências EN/PT e dos principais artefatos produzidos pelo pipeline.

## Regra EN/PT

O projeto mantém pares de módulos em inglês e português:

- **EN**: referência principal da lógica analítica e da execução;
- **PT**: versão didática equivalente, evitando reprocessamento pesado quando a etapa correspondente está desativada com `eval=FALSE`.

Mudanças analíticas devem ser implementadas primeiro no EN e depois refletidas no PT.

## Fluxo oficial

A ordem lógica do pipeline é:

1. `climate_data`
2. `matrizes`
3. `variance_components`
4. `analysis_prediction`
5. `analysis_prediction_run_outputs`
6. `visualization`

```text
climate_data
   ↓
matrizes
   ↓
variance_components
   ↓
analysis_prediction
   ↓
analysis_prediction_run_outputs
   ↓
visualization
```

Não há etapa auxiliar de revisão no pipeline oficial.

## 1. Dados climáticos

Arquivos:

- `analysis/climate_data.Rmd`
- `analysis/climate_data_pt.Rmd`

Funções principais:

- consultar e organizar os dados meteorológicos da NASA POWER;
- calcular covariáveis derivadas do clima;
- calcular fotoperíodo e PTR usando as coordenadas da estação experimental;
- produzir as bases climáticas consumidas pela etapa de matrizes.

Coordenadas usadas pelo workflow:

- 30.55133° N;
- 96.43342° W.

Saídas versionadas:

- `output/climate_results/texas_climate_data_raw.csv`
- `output/climate_results/environmental_covariates.csv`
- `output/climate_results/environmental_covariates_expanded.csv`

## 2. Matrizes e kernels

Arquivos:

- `analysis/matrizes.Rmd`
- `analysis/matrizes_pt.Rmd`

Funções principais:

- harmonizar observações fenotípicas, genômicas e fenômicas;
- construir o efeito categórico de ambiente;
- construir o kernel climático;
- construir kernels lineares, Gaussianos e Arccosine;
- construir as interações usadas pelos modelos.

Principais artefatos em `output/Matrizes/`:

- `Pheno.rds`
- `ZG.rds`, `ZP.rds`, `ZE.rds`, `ZW.rds`
- `ZGZE.rds`, `ZPZE.rds`, `ZGZW.rds`, `ZPZW.rds`
- `GGK.rds`, `PGK.rds`, `GAK.rds`, `PAK.rds`
- kernels de interação correspondentes.

## 3. Componentes de variância

Arquivos:

- `analysis/variance_components.Rmd`
- `analysis/variance_components_pt.Rmd`

Funções principais:

- ajustar o conjunto reduzido de 18 modelos;
- consolidar os componentes de variância;
- produzir resumos percentuais usados na interpretação dos modelos.

Saídas versionadas em `output/variance_components/`:

- `model_catalog.csv`
- `variance_components_raw.csv`
- `variance_components_processed.csv`
- `variance_components_table_percent.csv`

Os arquivos BGLR intermediários `.dat` não são versionados.

## 4. Predição — Parte I

Arquivos:

- `analysis/analysis_prediction.Rmd`
- `analysis/analysis_prediction_pt.Rmd`

Responsabilidades:

- carregar os kernels e o fenótipo;
- definir os parâmetros MCMC;
- definir o catálogo dos 18 modelos;
- construir `Eta_list`;
- documentar CV1, CV2, CV0 e CV00;
- documentar o contrato de nomes e pastas.

Padrão atual:

- 18 modelos;
- 5.000 iterações MCMC;
- burn-in de 1.000;
- thin de 10;
- 10 repetições;
- 5 folds de genótipos por repetição.

## 5. Predição — Parte II

Arquivos:

- `analysis/analysis_prediction_run_outputs.Rmd`
- `analysis/analysis_prediction_run_outputs_pt.Rmd`

Responsabilidades:

- documentar a execução dos ajustes;
- gerar os resultados em nível de fold;
- inventariar os resultados disponíveis;
- resumir as contagens por cenário e trait.

Estrutura de execução:

- CV1 e CV2 compartilham o mesmo ajuste em cada fold;
- CV0 e CV00 compartilham o mesmo ajuste em cada combinação ambiente × fold;
- CV1/CV2 usam cinco ajustes por repetição;
- CV0/CV00 usam os mesmos cinco folds em quatro ambientes deixados de fora, totalizando 20 ajustes ambiente × fold por repetição.

Saídas locais/regeneráveis:

- `output/results/CV1/`
- `output/results/CV2/`
- `output/results/CV0/`
- `output/results/CV00/`
- `output/results/bglr_runs/CV1/`
- `output/results/bglr_runs/CV0/`
- `output/tables/analysis_prediction/`

Essas saídas de execução e inventário não são mantidas como artefatos permanentes de controle de versão; podem ser regeneradas a partir do workflow.

## 6. Visualização e tabelas finais

Arquivos:

- `analysis/visualization.Rmd`
- `analysis/visualization_pt.Rmd`

Responsabilidades:

- carregar os resumos finais de predição;
- associar os resultados ao catálogo de modelos;
- produzir tabelas de apresentação;
- resumir os efeitos de inclusão de `W`;
- comparar famílias de kernels;
- produzir as figuras finais.

Tabelas principais em `output/tables/`:

- `prediction_cv1_cv2_summary.csv`
- `prediction_cv0_cv00_summary.csv`
- `prediction_cv1_cv2_display_table.csv`
- `prediction_cv0_cv00_display_table.csv`
- `prediction_cv1_cv2_top3.csv`
- `prediction_cv0_cv00_top3.csv`
- `prediction_cv1_cv2_w_effect_pairs.csv`
- `prediction_cv0_cv00_w_effect_pairs.csv`
- `prediction_cv1_cv2_kernel_family_compare.csv`
- `prediction_cv0_cv00_kernel_family_compare.csv`

Figuras geradas:

- `output/figures/`

## Estrutura ativa

```text
analysis/
├── climate_data.Rmd
├── climate_data_pt.Rmd
├── matrizes.Rmd
├── matrizes_pt.Rmd
├── variance_components.Rmd
├── variance_components_pt.Rmd
├── analysis_prediction.Rmd
├── analysis_prediction_pt.Rmd
├── analysis_prediction_run_outputs.Rmd
├── analysis_prediction_run_outputs_pt.Rmd
├── visualization.Rmd
├── visualization_pt.Rmd
├── index.Rmd
├── about.Rmd
├── license.Rmd
└── _site.yml

output/
├── climate_results/
├── Matrizes/
├── variance_components/
├── results/                  # gerado localmente; resultados em nível de fold
├── tables/                   # resumos e tabelas finais
└── figures/                  # figuras geradas
```

## Arquivos versionados versus regeneráveis

Devem permanecer versionados:

- os `.Rmd` do pipeline;
- os objetos de matriz/kernel necessários às etapas posteriores;
- os dados climáticos processados usados pelo pipeline;
- as tabelas finais necessárias para reproduzir o site e os resultados apresentados.

Devem permanecer fora do controle de versão:

- arquivos BGLR `.dat`;
- resultados de predição em nível de fold em `output/results/`;
- inventários operacionais de `output/tables/analysis_prediction/`;
- tabelas intermediárias `*_raw.csv`, `*_by_rep.csv` e `*_by_rep_fold_env.csv`;
- arquivos locais do R/RStudio e dados externos pesados.

## Navegação do site

A navegação principal é definida em `analysis/_site.yml` e contém:

- Home
- Climate data
- Matrices
- Variance components
- Prediction — Part I
- Prediction — Part II
- Visualization
- About
- License

As versões PT permanecem acessíveis pelos links internos das páginas correspondentes.

## Princípios de manutenção

1. A lógica analítica é alterada primeiro no EN e sincronizada no PT.
2. Blocos computacionalmente pesados permanecem explicitamente identificados.
3. Artefatos regeneráveis não devem ser tratados como resultados finais versionados.
4. O código deve permanecer explícito e legível, evitando abstrações desnecessárias.
5. A documentação deve descrever apenas o pipeline ativo, sem etapas temporárias ou auxiliares já encerradas.
6. Os HTMLs em `docs/` são produtos de renderização e devem ser regenerados a partir dos `.Rmd`, não editados manualmente.
