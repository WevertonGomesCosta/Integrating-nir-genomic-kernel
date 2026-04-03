# script_tabelas_resultados_pipeline_v2.R
# -----------------------------------------------------------------------------
# OBJETIVO
# -----------------------------------------------------------------------------
# Este script organiza tabelas-resumo do pipeline para inspeção e interpretação
# posterior dos resultados.
#
# O foco aqui é:
#
# 1) inventariar os arquivos produzidos pelo pipeline;
# 2) resumir as principais saídas climáticas;
# 3) criar um inventário leve dos objetos gerados em output/Matrizes;
# 4) resumir os resultados de variance_components;
# 5) resumir os arquivos brutos de predição;
# 6) organizar as tabelas finais produzidas por visualization.Rmd;
# 7) gerar uma tabela final de checagem do pipeline.
#
# Este script foi escrito em português, com foco em didática, funcionalidade
# e simplicidade.
# -----------------------------------------------------------------------------

rm(list = ls())
options(scipen = 999)

# -----------------------------------------------------------------------------
# 1. Pacotes
# -----------------------------------------------------------------------------
# Nesta seção carregamos apenas os pacotes necessários para leitura de arquivos
# e manipulação simples de tabelas.
# -----------------------------------------------------------------------------

library(readr)
library(dplyr)
library(stringr)

# -----------------------------------------------------------------------------
# 2. Localizar a raiz do projeto e criar pasta de saída
# -----------------------------------------------------------------------------
# O script pode ser executado a partir da raiz do projeto, de code/ ou de
# analysis/. Aqui padronizamos os caminhos e criamos uma pasta própria para as
# tabelas de revisão do pipeline.
# -----------------------------------------------------------------------------

project_root <- getwd()

if (!dir.exists(file.path(project_root, "output")) &&
    dir.exists(file.path(project_root, "..", "output"))) {
  project_root <- normalizePath(file.path(project_root, ".."))
}

if (!dir.exists(file.path(project_root, "output"))) {
  stop("Não foi possível localizar a pasta 'output/'. Execute este script a partir da raiz do projeto, de code/ ou de analysis/.")
}

output_dir <- file.path(project_root, "output")
tables_dir <- file.path(output_dir, "tables")
review_dir <- file.path(tables_dir, "pipeline_review")

dir.create(review_dir, recursive = TRUE, showWarnings = FALSE)

cat("Raiz do projeto:", project_root, "\n")
cat("Pasta de saída das tabelas de revisão:", review_dir, "\n")

# -----------------------------------------------------------------------------
# 3. Inventário geral de arquivos do pipeline
# -----------------------------------------------------------------------------
# Aqui criamos uma tabela com os arquivos encontrados nas principais pastas do
# pipeline. Importante: excluímos a própria pasta pipeline_review para evitar
# que o inventário comece a listar os arquivos de auditoria gerados pelo script.
# -----------------------------------------------------------------------------

inventory <- data.frame()

dirs_to_scan <- c(
  file.path(output_dir, "climate_results"),
  file.path(output_dir, "Matrizes"),
  file.path(output_dir, "variance_components"),
  file.path(output_dir, "results"),
  file.path(output_dir, "tables"),
  file.path(output_dir, "figures")
)

for (current_dir in dirs_to_scan) {
  if (dir.exists(current_dir)) {
    current_files <- list.files(current_dir, recursive = TRUE, full.names = TRUE)

    if (length(current_files) > 0) {
      current_files_norm <- normalizePath(current_files, winslash = "/", mustWork = FALSE)
      review_dir_norm <- normalizePath(review_dir, winslash = "/", mustWork = FALSE)

      current_files_norm <- current_files_norm[!startsWith(current_files_norm, review_dir_norm)]

      if (length(current_files_norm) > 0) {
        current_info <- data.frame(
          folder = basename(current_dir),
          relative_path = gsub(
            paste0("^", normalizePath(project_root, winslash = "/"), "/?"),
            "",
            current_files_norm
          ),
          file_name = basename(current_files_norm),
          extension = tools::file_ext(current_files_norm),
          stringsAsFactors = FALSE
        )

        inventory <- bind_rows(inventory, current_info)
      }
    }
  }
}

if (nrow(inventory) > 0) {
  inventory <- inventory %>%
    arrange(folder, relative_path)

  write_csv(inventory, file.path(review_dir, "01_inventario_geral_arquivos.csv"))
}

# -----------------------------------------------------------------------------
# 4. Resumo dos arquivos climáticos
# -----------------------------------------------------------------------------
# Esta seção resume os arquivos principais produzidos por climate_data.Rmd.
# O objetivo é deixar claro:
# - quais tabelas climáticas existem;
# - quantas linhas e colunas cada uma possui;
# - quais ambientes aparecem em cada tabela.
# -----------------------------------------------------------------------------

climate_file_annual <- file.path(output_dir, "climate_results", "environmental_covariates.csv")
climate_file_daily  <- file.path(output_dir, "climate_results", "environmental_covariates_expanded.csv")

climate_overview <- data.frame()

if (file.exists(climate_file_annual)) {
  climate_annual <- read_csv(climate_file_annual, show_col_types = FALSE)

  climate_overview <- bind_rows(
    climate_overview,
    data.frame(
      file_name = "environmental_covariates.csv",
      rows = nrow(climate_annual),
      cols = ncol(climate_annual),
      stringsAsFactors = FALSE
    )
  )

  annual_columns <- data.frame(
    file_name = "environmental_covariates.csv",
    column_name = names(climate_annual),
    stringsAsFactors = FALSE
  )

  write_csv(annual_columns, file.path(review_dir, "02_climate_colunas_tabela_anual.csv"))

  if ("Env" %in% names(climate_annual)) {
    annual_envs <- climate_annual %>%
      count(Env, name = "n_linhas") %>%
      arrange(Env)

    write_csv(annual_envs, file.path(review_dir, "03_climate_ambientes_tabela_anual.csv"))
  }
}

if (file.exists(climate_file_daily)) {
  climate_daily <- read_csv(climate_file_daily, show_col_types = FALSE)

  climate_overview <- bind_rows(
    climate_overview,
    data.frame(
      file_name = "environmental_covariates_expanded.csv",
      rows = nrow(climate_daily),
      cols = ncol(climate_daily),
      stringsAsFactors = FALSE
    )
  )

  daily_columns <- data.frame(
    file_name = "environmental_covariates_expanded.csv",
    column_name = names(climate_daily),
    stringsAsFactors = FALSE
  )

  write_csv(daily_columns, file.path(review_dir, "04_climate_colunas_tabela_expandida.csv"))

  if ("Env" %in% names(climate_daily)) {
    daily_envs <- climate_daily %>%
      count(Env, name = "n_linhas") %>%
      arrange(Env)

    write_csv(daily_envs, file.path(review_dir, "05_climate_ambientes_tabela_expandida.csv"))
  }
}

if (nrow(climate_overview) > 0) {
  write_csv(climate_overview, file.path(review_dir, "06_climate_resumo_arquivos.csv"))
}

# -----------------------------------------------------------------------------
# 5. Inventário leve dos objetos em output/Matrizes
# -----------------------------------------------------------------------------
# Aqui criamos um inventário mais leve dos .rds produzidos por matrizes.Rmd.
# Para evitar alto consumo de memória, o script:
#
# - sempre registra nome do arquivo e tamanho em disco;
# - tenta ler o objeto apenas quando o arquivo for pequeno;
# - pula a leitura de objetos grandes.
#
# Assim, a etapa continua informativa, mas evita virar uma mini execução pesada
# da etapa de matrizes.
# -----------------------------------------------------------------------------

matrices_dir <- file.path(output_dir, "Matrizes")
matrix_inventory <- data.frame()
max_mb_for_object_preview <- 10

if (dir.exists(matrices_dir)) {
  matrix_files <- list.files(matrices_dir, pattern = "\\.rds$", full.names = TRUE)

  if (length(matrix_files) > 0) {
    for (current_file in matrix_files) {
      current_info <- file.info(current_file)

      current_size_mb <- round(current_info$size / (1024 ^ 2), 4)
      current_class <- NA
      current_nrow <- NA
      current_ncol <- NA
      current_length <- NA
      current_preview_mode <- "nao_lido_objeto_grande"

      if (!is.na(current_size_mb) && current_size_mb <= max_mb_for_object_preview) {
        current_object <- tryCatch(readRDS(current_file), error = function(e) NULL)

        if (!is.null(current_object)) {
          current_class <- paste(class(current_object), collapse = "; ")
          current_length <- length(current_object)
          current_preview_mode <- "lido"

          if (is.matrix(current_object) || is.data.frame(current_object)) {
            current_nrow <- nrow(current_object)
            current_ncol <- ncol(current_object)
          }
        } else {
          current_preview_mode <- "erro_na_leitura"
        }
      }

      matrix_inventory <- bind_rows(
        matrix_inventory,
        data.frame(
          file_name = basename(current_file),
          object_name = sub("\\.rds$", "", basename(current_file)),
          size_mb = current_size_mb,
          class = current_class,
          nrow = current_nrow,
          ncol = current_ncol,
          length = current_length,
          preview_mode = current_preview_mode,
          stringsAsFactors = FALSE
        )
      )
    }
  }
}

if (nrow(matrix_inventory) > 0) {
  matrix_inventory <- matrix_inventory %>%
    arrange(file_name)

  write_csv(matrix_inventory, file.path(review_dir, "07_matrizes_inventario_objetos.csv"))
}

# -----------------------------------------------------------------------------
# 6. Resumo dos resultados de variance_components
# -----------------------------------------------------------------------------
# Esta seção organiza as principais saídas produzidas em output/variance_components.
# O objetivo é deixar prontas tabelas fáceis de revisar antes da descrição dos
# resultados.
# -----------------------------------------------------------------------------

variance_dir <- file.path(output_dir, "variance_components")

variance_file_catalog   <- file.path(variance_dir, "model_catalog.csv")
variance_file_raw       <- file.path(variance_dir, "variance_components_raw.csv")
variance_file_processed <- file.path(variance_dir, "variance_components_processed.csv")
variance_file_table     <- file.path(variance_dir, "variance_components_table_percent.csv")

variance_check <- data.frame(
  file_name = c(
    "model_catalog.csv",
    "variance_components_raw.csv",
    "variance_components_processed.csv",
    "variance_components_table_percent.csv"
  ),
  exists = c(
    file.exists(variance_file_catalog),
    file.exists(variance_file_raw),
    file.exists(variance_file_processed),
    file.exists(variance_file_table)
  ),
  stringsAsFactors = FALSE
)

write_csv(variance_check, file.path(review_dir, "08_variance_components_check.csv"))

if (file.exists(variance_file_catalog)) {
  variance_catalog <- read_csv(variance_file_catalog, show_col_types = FALSE)
  write_csv(variance_catalog, file.path(review_dir, "09_variance_model_catalog.csv"))
}

if (file.exists(variance_file_raw)) {
  variance_raw <- read_csv(variance_file_raw, show_col_types = FALSE)

  variance_raw_review <- variance_raw %>%
    arrange(Trait, Model, Rep, Component)

  write_csv(variance_raw_review, file.path(review_dir, "10_variance_components_raw_review.csv"))
}

if (file.exists(variance_file_processed)) {
  variance_processed <- read_csv(variance_file_processed, show_col_types = FALSE)

  variance_processed_review <- variance_processed %>%
    mutate(
      AvgVar = round(AvgVar, 6),
      MeanDIC = round(MeanDIC, 3),
      MeanRuntimeSec = round(MeanRuntimeSec, 2),
      Percentage = round(100 * Percentage, 2)
    ) %>%
    rename(PercentagePercent = Percentage) %>%
    arrange(Trait, Model, ComponentLabel)

  write_csv(variance_processed_review, file.path(review_dir, "11_variance_components_processed_review.csv"))

  variance_component_summary <- variance_processed %>%
    group_by(Trait, ComponentLabel) %>%
    summarise(
      MediaPercentual = round(mean(100 * Percentage, na.rm = TRUE), 2),
      MinPercentual = round(min(100 * Percentage, na.rm = TRUE), 2),
      MaxPercentual = round(max(100 * Percentage, na.rm = TRUE), 2),
      .groups = "drop"
    ) %>%
    arrange(Trait, desc(MediaPercentual))

  write_csv(variance_component_summary, file.path(review_dir, "12_variance_components_summary_by_trait.csv"))
}

if (file.exists(variance_file_table)) {
  variance_table <- read_csv(variance_file_table, show_col_types = FALSE)
  write_csv(variance_table, file.path(review_dir, "13_variance_components_table_percent_review.csv"))
}

# -----------------------------------------------------------------------------
# 7. Inventário dos arquivos brutos de predição
# -----------------------------------------------------------------------------
# Nesta seção organizamos os arquivos presentes em output/results/. A ideia é
# resumir rapidamente:
# - esquema de validação (CV1, CV2, CV0, CV00);
# - trait;
# - modelo;
# - repetição;
# - fold;
# - ambiente deixado de fora quando aplicável.
# -----------------------------------------------------------------------------

results_dir <- file.path(output_dir, "results")
prediction_inventory <- data.frame()

if (dir.exists(results_dir)) {
  prediction_files <- list.files(results_dir, pattern = "\\.csv$", full.names = TRUE)

  if (length(prediction_files) > 0) {
    for (current_file in prediction_files) {
      current_name <- basename(current_file)
      current_name_no_ext <- sub("\\.csv$", "", current_name)
      current_parts <- strsplit(current_name_no_ext, "_")[[1]]

      current_cv <- NA_character_
      current_trait <- NA_character_
      current_model <- NA_character_
      current_rep <- NA_character_
      current_fold <- NA_character_
      current_env_leave <- NA_character_

      if (length(current_parts) >= 5 && current_parts[1] %in% c("CV1", "CV2")) {
        current_cv <- current_parts[1]
        current_trait <- current_parts[2]
        current_model <- current_parts[length(current_parts) - 2]
        current_rep <- current_parts[length(current_parts) - 1]
        current_fold <- current_parts[length(current_parts)]
      }

      if (length(current_parts) >= 6 && current_parts[1] %in% c("CV0", "CV00")) {
        current_cv <- current_parts[1]
        current_trait <- current_parts[2]
        current_model <- current_parts[length(current_parts) - 2]
        current_rep <- current_parts[length(current_parts) - 1]
        current_fold <- current_parts[length(current_parts)]

        env_index_start <- 3
        env_index_end <- length(current_parts) - 3

        if (env_index_end >= env_index_start) {
          current_env_leave <- paste(current_parts[env_index_start:env_index_end], collapse = "_")
        }
      }

      prediction_inventory <- bind_rows(
        prediction_inventory,
        data.frame(
          file_name = current_name,
          CV = current_cv,
          Trait = current_trait,
          Env = current_env_leave,
          Env_leave = current_env_leave,
          Model = current_model,
          Rep = current_rep,
          Fold = current_fold,
          stringsAsFactors = FALSE
        )
      )
    }
  }
}

if (nrow(prediction_inventory) > 0) {
  prediction_inventory <- prediction_inventory %>%
    arrange(CV, Trait, Env_leave, Model, Rep, Fold)

  write_csv(prediction_inventory, file.path(review_dir, "14_predicao_inventario_arquivos.csv"))

  prediction_count_by_cv <- prediction_inventory %>%
    count(CV, name = "n_arquivos") %>%
    arrange(CV)

  write_csv(prediction_count_by_cv, file.path(review_dir, "15_predicao_contagem_por_cv.csv"))

  prediction_count_by_trait <- prediction_inventory %>%
    count(CV, Trait, name = "n_arquivos") %>%
    arrange(CV, Trait)

  write_csv(prediction_count_by_trait, file.path(review_dir, "16_predicao_contagem_por_cv_trait.csv"))
}

# -----------------------------------------------------------------------------
# 8. Tabelas finais produzidas por visualization.Rmd
# -----------------------------------------------------------------------------
# Aqui organizamos as principais tabelas finais que serão mais úteis para a
# descrição dos resultados do pipeline:
#
# - resumo de CV1/CV2;
# - resumo de CV0/CV00;
# - top 3 modelos;
# - comparações com e sem W;
# - comparação entre famílias de kernel.
# -----------------------------------------------------------------------------

file_cv12_summary <- file.path(tables_dir, "prediction_cv1_cv2_summary.csv")
file_cvloo_summary <- file.path(tables_dir, "prediction_cv0_cv00_summary.csv")
file_cv12_top3 <- file.path(tables_dir, "prediction_cv1_cv2_top3.csv")
file_cvloo_top3 <- file.path(tables_dir, "prediction_cv0_cv00_top3.csv")
file_cv12_w <- file.path(tables_dir, "prediction_cv1_cv2_w_effect_pairs.csv")
file_cvloo_w <- file.path(tables_dir, "prediction_cv0_cv00_w_effect_pairs.csv")
file_cv12_kernel <- file.path(tables_dir, "prediction_cv1_cv2_kernel_family_compare.csv")
file_cvloo_kernel <- file.path(tables_dir, "prediction_cv0_cv00_kernel_family_compare.csv")
file_model_catalog <- file.path(tables_dir, "prediction_model_catalog.csv")

if (file.exists(file_model_catalog)) {
  model_catalog <- read_csv(file_model_catalog, show_col_types = FALSE)
  write_csv(model_catalog, file.path(review_dir, "17_model_catalogo_predicao.csv"))
}

if (file.exists(file_cv12_summary)) {
  cv12_summary <- read_csv(file_cv12_summary, show_col_types = FALSE)

  cv12_summary_review <- cv12_summary %>%
    mutate(
      MeanCorrelation = round(MeanCorrelation, 4),
      SDCorrelation = round(SDCorrelation, 4),
      MeanRuntimeSec = round(MeanRuntimeSec, 2)
    ) %>%
    arrange(Trait, CV, ModelNumber)

  write_csv(cv12_summary_review, file.path(review_dir, "18_predicao_resumo_cv1_cv2.csv"))
}

if (file.exists(file_cvloo_summary)) {
  cvloo_summary <- read_csv(file_cvloo_summary, show_col_types = FALSE)

  cvloo_summary_review <- cvloo_summary %>%
    mutate(
      MeanCorrelation = round(MeanCorrelation, 4),
      SDCorrelation = round(SDCorrelation, 4),
      MeanRuntimeSec = round(MeanRuntimeSec, 2)
    ) %>%
    arrange(Trait, CV, Env_leave, ModelNumber)

  write_csv(cvloo_summary_review, file.path(review_dir, "19_predicao_resumo_cv0_cv00.csv"))
}

if (file.exists(file_cv12_top3)) {
  cv12_top3 <- read_csv(file_cv12_top3, show_col_types = FALSE)

  cv12_top3_review <- cv12_top3 %>%
    arrange(Trait, CV, desc(MeanCorrelation))

  write_csv(cv12_top3_review, file.path(review_dir, "20_predicao_top3_cv1_cv2.csv"))
}

if (file.exists(file_cvloo_top3)) {
  cvloo_top3 <- read_csv(file_cvloo_top3, show_col_types = FALSE)

  cvloo_top3_review <- cvloo_top3 %>%
    arrange(Trait, CV, Env_leave, desc(MeanCorrelation))

  write_csv(cvloo_top3_review, file.path(review_dir, "21_predicao_top3_cv0_cv00.csv"))
}

if (file.exists(file_cv12_w)) {
  cv12_w <- read_csv(file_cv12_w, show_col_types = FALSE)

  cv12_w_review <- cv12_w %>%
    mutate(
      MeanWithoutW = round(MeanWithoutW, 4),
      MeanWithW = round(MeanWithW, 4),
      DeltaWithW = round(DeltaWithW, 4)
    ) %>%
    arrange(Trait, CV, Comparison)

  write_csv(cv12_w_review, file.path(review_dir, "22_predicao_efeito_w_cv1_cv2.csv"))
}

if (file.exists(file_cvloo_w)) {
  cvloo_w <- read_csv(file_cvloo_w, show_col_types = FALSE)

  cvloo_w_review <- cvloo_w %>%
    mutate(
      MeanWithoutW = round(MeanWithoutW, 4),
      MeanWithW = round(MeanWithW, 4),
      DeltaWithW = round(DeltaWithW, 4)
    ) %>%
    arrange(Trait, CV, Env_leave, Comparison)

  write_csv(cvloo_w_review, file.path(review_dir, "23_predicao_efeito_w_cv0_cv00.csv"))
}

if (file.exists(file_cv12_kernel)) {
  cv12_kernel <- read_csv(file_cv12_kernel, show_col_types = FALSE)
  write_csv(cv12_kernel, file.path(review_dir, "24_predicao_kernel_cv1_cv2.csv"))
}

if (file.exists(file_cvloo_kernel)) {
  cvloo_kernel <- read_csv(file_cvloo_kernel, show_col_types = FALSE)
  write_csv(cvloo_kernel, file.path(review_dir, "25_predicao_kernel_cv0_cv00.csv"))
}

# -----------------------------------------------------------------------------
# 9. Tabela final de checagem do pipeline
# -----------------------------------------------------------------------------
# Esta tabela resume, em uma única visão, se os principais arquivos que serão
# usados na descrição dos resultados já existem ou ainda estão faltando.
# -----------------------------------------------------------------------------

pipeline_check <- data.frame(
  etapa = c(
    "climate_data",
    "climate_data",
    "matrizes",
    "variance_components",
    "variance_components",
    "variance_components",
    "predicao_bruta",
    "visualizacao",
    "visualizacao",
    "visualizacao",
    "visualizacao"
  ),
  arquivo_esperado = c(
    "output/climate_results/environmental_covariates.csv",
    "output/climate_results/environmental_covariates_expanded.csv",
    "output/Matrizes/*.rds",
    "output/variance_components/model_catalog.csv",
    "output/variance_components/variance_components_processed.csv",
    "output/variance_components/variance_components_table_percent.csv",
    "output/results/*.csv",
    "output/tables/prediction_cv1_cv2_summary.csv",
    "output/tables/prediction_cv0_cv00_summary.csv",
    "output/tables/prediction_cv1_cv2_top3.csv",
    "output/tables/prediction_cv0_cv00_top3.csv"
  ),
  existe = c(
    file.exists(climate_file_annual),
    file.exists(climate_file_daily),
    dir.exists(matrices_dir) && length(list.files(matrices_dir, pattern = "\\.rds$")) > 0,
    file.exists(variance_file_catalog),
    file.exists(variance_file_processed),
    file.exists(variance_file_table),
    dir.exists(results_dir) && length(list.files(results_dir, pattern = "\\.csv$")) > 0,
    file.exists(file_cv12_summary),
    file.exists(file_cvloo_summary),
    file.exists(file_cv12_top3),
    file.exists(file_cvloo_top3)
  ),
  stringsAsFactors = FALSE
)

write_csv(pipeline_check, file.path(review_dir, "26_pipeline_check_final.csv"))

# -----------------------------------------------------------------------------
# 10. Mensagem final
# -----------------------------------------------------------------------------
# Ao final, o script informa onde as tabelas foram salvas. Essas tabelas podem
# ser usadas depois para descrevermos os resultados do pipeline de forma mais
# organizada.
# -----------------------------------------------------------------------------

cat("\n")
cat("Tabelas de revisão geradas em:\n")
cat(review_dir, "\n")
cat("\n")
cat("Arquivos principais produzidos por este script:\n")
cat("- 01_inventario_geral_arquivos.csv\n")
cat("- 06_climate_resumo_arquivos.csv\n")
cat("- 07_matrizes_inventario_objetos.csv\n")
cat("- 08_variance_components_check.csv\n")
cat("- 11_variance_components_processed_review.csv\n")
cat("- 12_variance_components_summary_by_trait.csv\n")
cat("- 13_variance_components_table_percent_review.csv\n")
cat("- 14_predicao_inventario_arquivos.csv\n")
cat("- 18_predicao_resumo_cv1_cv2.csv\n")
cat("- 19_predicao_resumo_cv0_cv00.csv\n")
cat("- 20_predicao_top3_cv1_cv2.csv\n")
cat("- 21_predicao_top3_cv0_cv00.csv\n")
cat("- 22_predicao_efeito_w_cv1_cv2.csv\n")
cat("- 23_predicao_efeito_w_cv0_cv00.csv\n")
cat("- 24_predicao_kernel_cv1_cv2.csv\n")
cat("- 25_predicao_kernel_cv0_cv00.csv\n")
cat("- 26_pipeline_check_final.csv\n")
cat("\n")
cat("Revisão concluída.\n")
