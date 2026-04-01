# Arquitetura Operacional do Pipeline

## Finalidade deste documento

Este documento define a arquitetura estrutural e operacional oficial do pipeline do projeto **Integrating Near-Infrared Reflectance Spectroscopy and Genomic Data Using Kernel Methods**.

Ele deve ser mantido na **raiz do repositório** e servir como referência para:

- entendimento do fluxo completo do pipeline;
- manutenção futura dos módulos;
- padronização da lógica bilíngue EN/PT;
- organização da navegação entre etapas;
- apoio a futuras refatorações do repositório.

Este documento **não substitui** o checklist operacional. Ele funciona como **mapa estrutural permanente** do projeto.

---

## Regra estrutural central do projeto

O pipeline segue a seguinte convenção:

- **EN** = versão mecânica principal;
- **PT** = versão funcional dependente do EN.

Na prática, isso significa que:

1. a versão em inglês define a lógica principal de execução;
2. a versão em português espelha a organização didática da versão em inglês;
3. a versão em português evita reexecutar etapas pesadas;
4. a versão em português reutiliza artefatos gerados pela versão em inglês sempre que necessário;
5. os arquivos PT usam:
   - `include=FALSE` para chunks de carga silenciosa;
   - `eval=FALSE` para chunks computacionalmente pesados.

---

## Visão geral do pipeline

A ordem lógica do pipeline é:

1. `climate_data`
2. `matrizes`
3. `variance_components`
4. `analysis_prediction`
5. `analysis_prediction_run_outputs`
6. `visualization`
7. `script_tabelas_resultados_pipeline_v2.R`
8. descrição e interpretação dos resultados

Representação simplificada:

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
   ↓
script_tabelas_resultados_pipeline_v2.R
   ↓
descrição dos resultados
```

---

## Módulos oficiais do pipeline

### 1. Etapa climática

#### EN
- `climate_data_en_chunk_described_final.Rmd`

#### PT
- `climate_data_pt_chunk_described_functional_final.Rmd`

#### Função
- baixar e organizar dados climáticos;
- gerar covariáveis climáticas;
- produzir tabelas e figuras climáticas.

#### Saídas principais
- `output/climate_results/environmental_covariates.csv`
- `output/climate_results/environmental_covariates_expanded.csv`

---

### 2. Etapa de matrizes e kernels

#### EN
- `matrizes_en_chunk_described_final.Rmd`

#### PT
- `matrizes_pt_chunk_described_functional_final.Rmd`

#### Função
- harmonizar dados fenotípicos, genômicos, fenômicos e climáticos;
- construir matrizes e kernels lineares e não lineares.

#### Saídas principais
Pasta:
- `output/Matrizes/`

Objetos principais:
- `Pheno.rds`
- `ZG.rds`
- `ZP.rds`
- `ZE.rds`
- `ZW.rds`
- interações lineares;
- kernels Gaussianos;
- kernels arc-cosine;
- interações derivadas.

---

### 3. Etapa de componentes de variância

#### EN
- `variance_components_en_chunk_described_final.Rmd`

#### PT
- `variance_components_pt_functional_dependent_editorial_cleaned_final_v2.Rmd`

#### Função
- consolidar resultados de componentes de variância;
- organizar tabelas e figuras da etapa;
- preservar a estrutura da modelagem.

#### Saídas principais
Pasta:
- `output/variance_components/`

Arquivos principais:
- `model_catalog.csv`
- `variance_components_raw.csv`
- `variance_components_processed.csv`
- `variance_components_table_percent.csv`

---

### 4. Etapa de predição — Parte 1

#### EN
- `analysis_prediction.Rmd`

#### PT
- `analysis_prediction_pt.Rmd`

#### Função
- apresentar a etapa de predição;
- carregar os insumos;
- definir parâmetros gerais e de MCMC;
- organizar o catálogo dos 18 modelos;
- especificar os modelos;
- explicar os cenários de validação.

#### Estrutura interna
- `setup`
- `load-inputs`
- `mcmc-settings`
- `model-catalog`
- `eta-list-initialize`
- `eta-list-models-1-6`
- `eta-list-models-7-9`
- `eta-list-models-10-12`
- `eta-list-models-13-18`
- `eta-list-check`
- `cv-scenarios-table`
- `cv1-cv2-design`
- `cv0-cv00-design`
- `filename-patterns`

#### Regras PT
- `load-inputs` em `include=FALSE`;
- o restante permanece ativo, pois é leve e didático.

#### Artefatos carregados no PT
De `output/Matrizes/`, pelo menos:
- `Pheno.rds`
- `ZG.rds`
- `ZP.rds`
- `ZE.rds`
- `ZW.rds`
- `ZGZE.rds`
- `ZPZE.rds`
- `ZGZW.rds`
- `ZPZW.rds`
- `GGK.rds`
- `PGK.rds`
- `GAK.rds`
- `PAK.rds`
- `GGKE.rds`
- `PGKE.rds`
- `GAKE.rds`
- `PAKE.rds`
- `GGKW.rds`
- `PGKW.rds`
- `GAKW.rds`
- `PAKW.rds`

---

### 5. Etapa de predição — Parte 2

#### EN
- `analysis_prediction_run_outputs.Rmd`

#### PT
- `analysis_prediction_run_outputs_pt.Rmd`

#### Função
- documentar a execução da predição;
- separar a camada pesada da camada de outputs;
- organizar os metadados das saídas;
- conectar a etapa com `visualization`.

#### Estrutura interna

**Execução**
- `prepare-output-folders`
- `define-run-objects`
- `start-parallel-backend`
- `run-predictions-cv12`
- `run-predictions-cv0-cv00`

**Saídas**
- `prediction-output-inventory`
- `prediction-output-counts`
- `prediction-output-examples`
- `bglr-run-folder-summary`

#### Regras EN
- a execução pesada permanece documentada e normalmente com `eval=FALSE` no tutorial;
- a camada leve de outputs pode permanecer ativa.

#### Regras PT
- a parte pesada permanece com `eval=FALSE`;
- os metadados gerados pelo EN são carregados com `include=FALSE`;
- a parte visível do PT mostra apenas os metadados já produzidos pela versão em inglês.

#### Artefatos gerados pelo EN
Pasta:
- `output/tables/analysis_prediction/`

Arquivos:
- `analysis_prediction_inventory_cv12.csv`
- `analysis_prediction_inventory_cvloo.csv`
- `analysis_prediction_counts_by_cv.csv`
- `analysis_prediction_counts_by_trait.csv`
- `analysis_prediction_output_examples.csv`
- `analysis_prediction_bglr_run_inventory.csv`

#### Chunk oculto do PT
- `load-generated-output-metadata`

---

### 6. Etapa de visualização

#### EN
- `visualization_en_chunk_described_final.Rmd`

#### PT
- `visualization_pt_chunk_described_functional_final.Rmd`

#### Função
- consolidar os resultados brutos da predição;
- produzir tabelas finais;
- produzir figuras finais;
- preparar a base da interpretação dos resultados.

#### Saídas principais
Pasta:
- `output/tables/`

Arquivos principais:
- `prediction_model_catalog.csv`
- `prediction_cv1_cv2_summary.csv`
- `prediction_cv0_cv00_summary.csv`
- `prediction_cv1_cv2_top3.csv`
- `prediction_cv0_cv00_top3.csv`
- `prediction_cv1_cv2_w_effect_pairs.csv`
- `prediction_cv0_cv00_w_effect_pairs.csv`
- `prediction_cv1_cv2_kernel_family_compare.csv`
- `prediction_cv0_cv00_kernel_family_compare.csv`

#### Regras PT
- carrega as tabelas prontas do EN com `include=FALSE`;
- desliga leitura e consolidação pesada com `eval=FALSE`.

---

### 7. Script auxiliar de revisão do pipeline

#### Arquivo
- `script_tabelas_resultados_pipeline_v2.R`

#### Função
- inventariar arquivos do pipeline;
- resumir clima;
- criar inventário leve de `output/Matrizes`;
- resumir `variance_components`;
- resumir predição;
- resumir visualização;
- gerar tabelas de revisão para inspeção dos resultados.

#### Saída
Pasta:
- `output/tables/pipeline_review/`

---

## Estrutura de pastas

```text
analysis/
├── climate_data_en_chunk_described_final.Rmd
├── climate_data_pt_chunk_described_functional_final.Rmd
├── matrizes_en_chunk_described_final.Rmd
├── matrizes_pt_chunk_described_functional_final.Rmd
├── variance_components_en_chunk_described_final.Rmd
├── variance_components_pt_functional_dependent_editorial_cleaned_final_v2.Rmd
├── analysis_prediction.Rmd
├── analysis_prediction_pt.Rmd
├── analysis_prediction_run_outputs.Rmd
├── analysis_prediction_run_outputs_pt.Rmd
├── visualization_en_chunk_described_final.Rmd
├── visualization_pt_chunk_described_functional_final.Rmd
└── _site.yml

output/
├── climate_results/
├── Matrizes/
├── variance_components/
├── results/
├── tables/
│   ├── analysis_prediction/
│   └── pipeline_review/
└── figures/

code/
└── script_tabelas_resultados_pipeline_v2.R
```

---

## Navegação do site

O menu do site deve refletir a divisão da etapa de predição em duas partes.

No submenu `Prediction`, a estrutura recomendada é:

- Part I: setup, models and CV design — English
- Parte I: setup, modelos e desenho de CV — Português
- Part II: run prediction and outputs — English
- Parte II: execução da predição e saídas — Português

### Regras de navegação interna

**Parte 1**
- `analysis_prediction.html` aponta para `analysis_prediction_run_outputs.html`
- `analysis_prediction_pt.html` aponta para `analysis_prediction_run_outputs_pt.html`

**Parte 2**
- `analysis_prediction_run_outputs.html` aponta para `analysis_prediction.html`
- `analysis_prediction_run_outputs_pt.html` aponta para `analysis_prediction_pt.html`

---

## Princípios didáticos do pipeline

Todos os módulos oficiais do pipeline devem seguir estas regras:

### 1. Todo chunk deve ser explicado
Nenhum chunk relevante deve aparecer sem texto introdutório.

### 2. O texto deve explicar o papel do bloco
Cada explicação deve deixar claro:
- o que o chunk faz;
- por que ele existe;
- como ele se conecta com o restante do fluxo.

### 3. O EN deve preservar a mecânica principal
A versão em inglês é a referência do comportamento analítico.

### 4. O PT deve ser funcional sem reprocessamento pesado
A versão em português deve:
- preservar a leitura tutorial;
- evitar duplicação de custo computacional;
- depender dos artefatos já gerados pelo EN.

### 5. Evitar helpers artificiais
O pipeline deve priorizar:
- código explícito;
- leitura direta;
- blocos compreensíveis;
- pouca abstração desnecessária.

---

## Ordem recomendada de execução

A execução principal recomendada é:

1. `climate_data_en_chunk_described_final.Rmd`
2. `matrizes_en_chunk_described_final.Rmd`
3. `variance_components_en_chunk_described_final.Rmd`
4. `analysis_prediction.Rmd`
5. `analysis_prediction_run_outputs.Rmd`
6. `visualization_en_chunk_described_final.Rmd`
7. `script_tabelas_resultados_pipeline_v2.R`

As versões PT entram como:
- documentação funcional;
- renderização didática;
- reaproveitamento dos artefatos gerados pelo EN.

---

## Critérios de manutenção futura

Mudanças futuras no pipeline devem respeitar as seguintes regras:

### Mudanças na lógica analítica
Devem ser feitas primeiro no EN.

### Mudanças no PT
Devem espelhar a lógica do EN e preservar a dependência funcional.

### Mudanças de estrutura
Devem manter:
- didática;
- simplicidade;
- coerência EN/PT;
- separação entre processamento pesado e leitura tutorial.

### Mudanças no site
Devem preservar:
- navegação clara;
- menu enxuto;
- links internos coerentes entre partes de um mesmo módulo.

---

## Status atual da arquitetura

No estado atual, o pipeline está consolidado como:

- modular;
- didático;
- funcional;
- simples;
- com EN/PT espelhados;
- com EN como mecânica principal;
- com PT como camada funcional dependente;
- sem duplicação de processamento pesado.

---

## Uso recomendado deste documento

Este arquivo deve ser consultado quando houver necessidade de:

- entender o fluxo completo do projeto;
- revisar dependências entre módulos;
- padronizar novas refatorações;
- atualizar o site;
- fazer manutenção bilíngue;
- decidir onde uma nova etapa deve entrar no pipeline.

---

## Observação final

Este documento descreve a **arquitetura oficial do pipeline**.
Ele não substitui o checklist operacional, mas serve como mapa estrutural permanente do projeto.

O checklist operacional continua sendo o instrumento adequado para:
- homologação;
- testes locais;
- conferência antes de execução;
- diagnóstico de falhas.
