# article_results_for_manuscript_updated.R
# ------------------------------------------------------------
# Purpose:
# Collect the main numerical results that will be discussed in the manuscript.
# The script creates a plain-text report and a set of CSV tables that can be
# copied and shared for manuscript revision.
#
# Recommended order before running this script:
# 1) climate_data
# 2) matrizes
# 3) variance_components
# 4) analysis_prediction
# 5) visualization
#
# You can run this script from the project root or from the analysis/ folder.
# ------------------------------------------------------------

rm(list = ls())
options(scipen = 999)

packages_needed <- c("dplyr", "tidyr", "readr", "stringr", "tibble")
packages_missing <- packages_needed[!(packages_needed %in% installed.packages()[, "Package"])]

if (length(packages_missing) > 0) {
  install.packages(packages_missing)
}

library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(tibble)

# ------------------------------------------------------------
# 1. Locate the project root
# ------------------------------------------------------------

project_root <- getwd()

if (!dir.exists(file.path(project_root, "output")) &&
    dir.exists(file.path(project_root, "..", "output"))) {
  project_root <- normalizePath(file.path(project_root, ".."))
}

if (!dir.exists(file.path(project_root, "output"))) {
  stop("Could not find the folder 'output/'. Run this script from the project root or from analysis/.")
}

data_dir <- file.path(project_root, "data")
output_dir <- file.path(project_root, "output")
matrices_dir <- file.path(output_dir, "Matrizes")
climate_dir <- file.path(output_dir, "climate_results")
results_dir <- file.path(output_dir, "results")
tables_dir <- file.path(output_dir, "tables")
variance_dir <- file.path(output_dir, "variance_components")
article_dir <- file.path(output_dir, "article_results")

dir.create(article_dir, recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------
# 2. Start the text report
# ------------------------------------------------------------

report_lines <- c(
  "ARTICLE RESULTS REPORT",
  paste("Date:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "",
  "This report was generated to support the revision of the manuscript.
# The script assumes the new standardized prediction filenames based only on CV, trait, model, repetition, and fold.",
  "It summarizes the main numerical results that are usually needed in Results, Discussion, figure captions, and responses to reviewer comments.",
  ""
)

# ------------------------------------------------------------
# 3. Model catalog used in the reduced pipeline
# ------------------------------------------------------------

model_catalog <- tibble(
  ModelNumber = 1:18,
  Model = sprintf("M%02d", 1:18),
    Group = c(
    "Genomic baseline",
    "Weather single-source",
    "Genomic baseline",
    "Weather single-source",
    "Genomic baseline",
    "Weather single-source",
    "Phenomic baseline",
    "Weather single-source",
    "Phenomic baseline",
    "Weather single-source",
    "Phenomic baseline",
    "Weather single-source",
    "Combined baseline",
    "Weather combined",
    "Combined baseline",
    "Weather combined",
    "Combined baseline",
    "Weather combined"
  )[c(1,10,2,11,3,12,4,13,5,14,6,15,7,16,8,17,9,18)],
  Pathway = c(
    rep("Genomic pathway", 6),
    rep("Phenomic pathway", 6),
    rep("Combined G + P pathway", 6)
  ),
  KernelFamily = c(
    "Linear", "Linear",
    "Gaussian", "Gaussian",
    "Arc-cosine", "Arc-cosine",
    "Linear", "Linear",
    "Gaussian", "Gaussian",
    "Arc-cosine", "Arc-cosine",
    "Linear", "Linear",
    "Gaussian", "Gaussian",
    "Arc-cosine", "Arc-cosine"
  ),
  WeatherStatus = c(
    "Without W", "With W",
    "Without W", "With W",
    "Without W", "With W",
    "Without W", "With W",
    "Without W", "With W",
    "Without W", "With W",
    "Without W", "With W",
    "Without W", "With W",
    "Without W", "With W"
  ),
  Description = c(
    "G + E",
    "G + W",
    "GGK + E",
    "GGK + W",
    "GAK + E",
    "GAK + W",
    "P + E",
    "P + W",
    "PGK + E",
    "PGK + W",
    "PAK + E",
    "PAK + W",
    "G+P + E",
    "G+P + W",
    "GGK+PGK + E",
    "GGK+PGK + W",
    "GAK+PAK + E",
    "GAK+PAK + W"
  )
)

write_csv(model_catalog, file.path(article_dir, "model_catalog_18_models.csv"))

report_lines <- c(
  report_lines,
  "MODEL CATALOG",
  "The reduced pipeline works with 18 models (M01-M18).",
  "A CSV file with model descriptions was saved as: output/article_results/model_catalog_18_models.csv",
  ""
)

# ------------------------------------------------------------
# 4. Load phenotype data and summarize the experimental design
# ------------------------------------------------------------

Pheno <- NULL

if (file.exists(file.path(matrices_dir, "Pheno.rds"))) {
  Pheno <- readRDS(file.path(matrices_dir, "Pheno.rds"))
}

if (is.null(Pheno) && file.exists(file.path(data_dir, "NIR.csv"))) {
  NIR_raw <- read.csv(file.path(data_dir, "NIR.csv"), stringsAsFactors = FALSE)
  if (all(c("Pedigree", "Env", "GY", "KW") %in% colnames(NIR_raw))) {
    Pheno <- NIR_raw[, c("Pedigree", "Env", "GY", "KW")]
  }
}

if (!is.null(Pheno)) {
  if (!("ObsID" %in% colnames(Pheno)) && all(c("Pedigree", "Env") %in% colnames(Pheno))) {
    Pheno$ObsID <- paste(Pheno$Pedigree, Pheno$Env, sep = "_")
  }

  phenotype_overall <- tibble(
    Trait = c("GY", "KW"),
    Mean = c(mean(Pheno$GY, na.rm = TRUE), mean(Pheno$KW, na.rm = TRUE)),
    SD = c(sd(Pheno$GY, na.rm = TRUE), sd(Pheno$KW, na.rm = TRUE)),
    Min = c(min(Pheno$GY, na.rm = TRUE), min(Pheno$KW, na.rm = TRUE)),
    Max = c(max(Pheno$GY, na.rm = TRUE), max(Pheno$KW, na.rm = TRUE))
  )

  phenotype_by_env <- Pheno %>%
    group_by(Env) %>%
    summarise(
      n_obs = n(),
      n_hybrids = n_distinct(Pedigree),
      GY_mean = mean(GY, na.rm = TRUE),
      GY_sd = sd(GY, na.rm = TRUE),
      KW_mean = mean(KW, na.rm = TRUE),
      KW_sd = sd(KW, na.rm = TRUE),
      .groups = "drop"
    )

  write_csv(phenotype_overall, file.path(article_dir, "phenotype_overall_summary.csv"))
  write_csv(phenotype_by_env, file.path(article_dir, "phenotype_by_environment_summary.csv"))

  report_lines <- c(
    report_lines,
    "EXPERIMENTAL DESIGN SUMMARY",
    paste("Number of observations:", nrow(Pheno)),
    paste("Number of unique hybrids:", dplyr::n_distinct(Pheno$Pedigree)),
    paste("Number of environments:", dplyr::n_distinct(Pheno$Env)),
    paste("Environment labels:", paste(sort(unique(Pheno$Env)), collapse = ", ")),
    "",
    "Overall trait summary:",
    paste("GY  - mean =", round(phenotype_overall$Mean[phenotype_overall$Trait == "GY"], 3),
          "; sd =", round(phenotype_overall$SD[phenotype_overall$Trait == "GY"], 3),
          "; min =", round(phenotype_overall$Min[phenotype_overall$Trait == "GY"], 3),
          "; max =", round(phenotype_overall$Max[phenotype_overall$Trait == "GY"], 3)),
    paste("KW  - mean =", round(phenotype_overall$Mean[phenotype_overall$Trait == "KW"], 3),
          "; sd =", round(phenotype_overall$SD[phenotype_overall$Trait == "KW"], 3),
          "; min =", round(phenotype_overall$Min[phenotype_overall$Trait == "KW"], 3),
          "; max =", round(phenotype_overall$Max[phenotype_overall$Trait == "KW"], 3)),
    "",
    "Environment-level summary saved as:",
    "output/article_results/phenotype_by_environment_summary.csv",
    ""
  )
} else {
  report_lines <- c(
    report_lines,
    "EXPERIMENTAL DESIGN SUMMARY",
    "Phenotype file not found. Expected one of these files:",
    "- output/Matrizes/Pheno.rds",
    "- data/NIR.csv",
    ""
  )
}

# ------------------------------------------------------------
# 5. Climate covariates summary and units
# ------------------------------------------------------------

climate_units <- tibble(
  Variable = c(
    "TMAX_AVG", "TMIN_AVG", "GDD_CUM", "HEAT_STRESS_DAYS", "PRECTOT",
    "DRY_DAYS", "RH_AVG", "WS2M_AVG", "RAD_CUM", "T_AVG", "DTR_AVG",
    "COLD_STRESS_DAYS", "RAINY_DAYS", "PREC_INTENSITY", "LOW_RH_DAYS",
    "VPD_AVG", "VPD_STRESS_DAYS"
  ),
  Unit = c(
    "deg C", "deg C", "deg C day", "days", "mm",
    "days", "%", "m s-1", "MJ m-2", "deg C", "deg C",
    "days", "days", "mm day-1", "days",
    "kPa", "days"
  ),
  Interpretation = c(
    "Average maximum temperature during the season",
    "Average minimum temperature during the season",
    "Accumulated growing degree days",
    "Number of heat stress days",
    "Total precipitation during the season",
    "Number of dry days",
    "Average relative humidity",
    "Average wind speed at 2 m",
    "Accumulated shortwave radiation",
    "Average mean temperature",
    "Average daily temperature range",
    "Number of cold stress days",
    "Number of rainy days",
    "Average precipitation intensity on rainy days",
    "Number of low relative humidity days",
    "Average vapor pressure deficit",
    "Number of vapor pressure deficit stress days"
  )
)

write_csv(climate_units, file.path(article_dir, "climate_covariates_units.csv"))

if (file.exists(file.path(climate_dir, "environmental_covariates.csv"))) {
  climate_annual <- read_csv(file.path(climate_dir, "environmental_covariates.csv"), show_col_types = FALSE)

  if ("year" %in% colnames(climate_annual)) {
    climate_long <- climate_annual %>%
      pivot_longer(
        cols = -year,
        names_to = "Variable",
        values_to = "Value"
      ) %>%
      left_join(climate_units, by = "Variable") %>%
      arrange(Variable, year)

    write_csv(climate_long, file.path(article_dir, "climate_annual_long_table.csv"))

    if (length(unique(climate_annual$year)) >= 2) {
      climate_wide <- climate_long %>%
        select(year, Variable, Value) %>%
        pivot_wider(names_from = year, values_from = Value)

      if (all(c("2011", "2012") %in% colnames(climate_wide))) {
        climate_wide <- climate_wide %>%
          mutate(Difference_2012_minus_2011 = `2012` - `2011`)
      }

      climate_wide <- climate_wide %>%
        left_join(climate_units, by = "Variable")

      write_csv(climate_wide, file.path(article_dir, "climate_annual_comparison_table.csv"))
    }

    report_lines <- c(
      report_lines,
      "CLIMATE COVARIATES SUMMARY",
      "The annual weather covariates were found and summarized.",
      "Saved files:",
      "- output/article_results/climate_covariates_units.csv",
      "- output/article_results/climate_annual_long_table.csv",
      "- output/article_results/climate_annual_comparison_table.csv",
      "",
      "This section is useful for Results and for reviewer comments asking for measurement units.",
      ""
    )
  }
} else {
  report_lines <- c(
    report_lines,
    "CLIMATE COVARIATES SUMMARY",
    "The file output/climate_results/environmental_covariates.csv was not found.",
    "The table with climate variable units was still created and saved as:",
    "output/article_results/climate_covariates_units.csv",
    ""
  )
}

# ------------------------------------------------------------
# 6. Kernel dimensions and quantile information used in Gaussian kernels
# ------------------------------------------------------------

kernel_summary <- tibble(
  Object = character(),
  nrow = numeric(),
  ncol = numeric()
)

kernel_files_to_check <- c(
  "ZG", "ZP", "ZE", "ZW",
  "ZGZE", "ZPZE", "ZGZW", "ZPZW",
  "GGK", "PGK", "GAK", "PAK",
  "GGKE", "PGKE", "GAKE", "PAKE",
  "GGKW", "PGKW", "GAKW", "PAKW"
)

for (obj_name in kernel_files_to_check) {
  obj_file <- file.path(matrices_dir, paste0(obj_name, ".rds"))
  if (file.exists(obj_file)) {
    current_object <- readRDS(obj_file)
    if (is.matrix(current_object) || is.data.frame(current_object)) {
      kernel_summary <- bind_rows(
        kernel_summary,
        tibble(Object = obj_name, nrow = nrow(current_object), ncol = ncol(current_object))
      )
    }
  }
}

if (nrow(kernel_summary) > 0) {
  write_csv(kernel_summary, file.path(article_dir, "kernel_dimension_summary.csv"))
}

q05_summary <- tibble(
  Quantity = character(),
  Value = numeric(),
  Source = character()
)

if (file.exists(file.path(matrices_dir, "q05G.rds"))) {
  q05G <- readRDS(file.path(matrices_dir, "q05G.rds"))
  q05_summary <- bind_rows(q05_summary, tibble(Quantity = "q05G", Value = as.numeric(q05G), Source = "output/Matrizes/q05G.rds"))
} else if (file.exists(file.path(matrices_dir, "DG_proj.rds"))) {
  DG_proj <- readRDS(file.path(matrices_dir, "DG_proj.rds"))
  q05_summary <- bind_rows(q05_summary, tibble(Quantity = "q05G", Value = as.numeric(stats::quantile(DG_proj, probs = 0.05, na.rm = TRUE)), Source = "computed from output/Matrizes/DG_proj.rds"))
}

if (file.exists(file.path(matrices_dir, "q05P.rds"))) {
  q05P <- readRDS(file.path(matrices_dir, "q05P.rds"))
  q05_summary <- bind_rows(q05_summary, tibble(Quantity = "q05P", Value = as.numeric(q05P), Source = "output/Matrizes/q05P.rds"))
} else if (file.exists(file.path(matrices_dir, "DP_proj.rds"))) {
  DP_proj <- readRDS(file.path(matrices_dir, "DP_proj.rds"))
  q05_summary <- bind_rows(q05_summary, tibble(Quantity = "q05P", Value = as.numeric(stats::quantile(DP_proj, probs = 0.05, na.rm = TRUE)), Source = "computed from output/Matrizes/DP_proj.rds"))
}

if (nrow(q05_summary) > 0) {
  write_csv(q05_summary, file.path(article_dir, "gaussian_kernel_quantiles_q05.csv"))
}

if (nrow(kernel_summary) > 0 || nrow(q05_summary) > 0) {
  report_lines <- c(
    report_lines,
    "KERNEL SUMMARY",
    "Kernel dimension table saved as: output/article_results/kernel_dimension_summary.csv"
  )

  if (nrow(q05_summary) > 0) {
    for (i in 1:nrow(q05_summary)) {
      report_lines <- c(
        report_lines,
        paste(q05_summary$Quantity[i], "=", round(q05_summary$Value[i], 6), "(", q05_summary$Source[i], ")")
      )
    }
    report_lines <- c(
      report_lines,
      "These values are useful when explaining the 5% quantile used to scale Gaussian kernels."
    )
  }

  report_lines <- c(report_lines, "")
}

# ------------------------------------------------------------
# 7. Read prediction results
# Prefer final tables created by visualization.Rmd.
# If they do not exist, compute summaries from raw files.
# ------------------------------------------------------------

cv12_summary <- NULL
cvloo_summary <- NULL
cv12_top3 <- NULL
cvloo_top3 <- NULL
cv12_w_effect <- NULL
cvloo_w_effect <- NULL
cv12_kernel_family_compare <- NULL
cvloo_kernel_family_compare <- NULL

if (file.exists(file.path(tables_dir, "prediction_cv1_cv2_summary.csv"))) {
  cv12_summary <- read_csv(file.path(tables_dir, "prediction_cv1_cv2_summary.csv"), show_col_types = FALSE)
}
if (file.exists(file.path(tables_dir, "prediction_cv0_cv00_summary.csv"))) {
  cvloo_summary <- read_csv(file.path(tables_dir, "prediction_cv0_cv00_summary.csv"), show_col_types = FALSE)
}
if (file.exists(file.path(tables_dir, "prediction_cv1_cv2_top3.csv"))) {
  cv12_top3 <- read_csv(file.path(tables_dir, "prediction_cv1_cv2_top3.csv"), show_col_types = FALSE)
}
if (file.exists(file.path(tables_dir, "prediction_cv0_cv00_top3.csv"))) {
  cvloo_top3 <- read_csv(file.path(tables_dir, "prediction_cv0_cv00_top3.csv"), show_col_types = FALSE)
}
if (file.exists(file.path(tables_dir, "prediction_cv1_cv2_w_effect_pairs.csv"))) {
  cv12_w_effect <- read_csv(file.path(tables_dir, "prediction_cv1_cv2_w_effect_pairs.csv"), show_col_types = FALSE)
}
if (file.exists(file.path(tables_dir, "prediction_cv0_cv00_w_effect_pairs.csv"))) {
  cvloo_w_effect <- read_csv(file.path(tables_dir, "prediction_cv0_cv00_w_effect_pairs.csv"), show_col_types = FALSE)
}
if (file.exists(file.path(tables_dir, "prediction_cv1_cv2_kernel_family_compare.csv"))) {
  cv12_kernel_family_compare <- read_csv(file.path(tables_dir, "prediction_cv1_cv2_kernel_family_compare.csv"), show_col_types = FALSE)
}
if (file.exists(file.path(tables_dir, "prediction_cv0_cv00_kernel_family_compare.csv"))) {
  cvloo_kernel_family_compare <- read_csv(file.path(tables_dir, "prediction_cv0_cv00_kernel_family_compare.csv"), show_col_types = FALSE)
}

# Fallback: compute summaries from raw CSV results if final tables are not available
all_result_files <- character(0)

if (dir.exists(results_dir)) {
  all_result_files <- list.files(results_dir, pattern = "\\.csv$", full.names = TRUE)
}

all_result_names <- basename(all_result_files)
cv12_files <- all_result_files[grepl("^CV1_|^CV2_", all_result_names)]
cvloo_files <- all_result_files[grepl("^CV0_|^CV00_", all_result_names)]

if (is.null(cv12_summary) && length(cv12_files) > 0) {
  cv12_list <- vector("list", length(cv12_files))

  for (i in seq_along(cv12_files)) {
    current_file <- cv12_files[i]
    file_name <- basename(current_file)
    file_name <- sub("\\.csv$", "", file_name)
    parts <- strsplit(file_name, "_")[[1]]

    current_data <- read_csv(current_file, show_col_types = FALSE)
    current_data$CV <- parts[1]
    current_data$Trait <- parts[2]
    current_data$Model <- parts[3]
    current_data$ModelNumber <- as.numeric(gsub("M", "", current_data$Model[1]))
    current_data$Rep <- as.numeric(gsub("rep", "", parts[4]))
    if (length(parts) >= 5) {
      current_data$Fold <- as.numeric(gsub("fold", "", parts[5]))
    } else {
      current_data$Fold <- 1
    }

    cv12_list[[i]] <- current_data
  }

  cv12_raw <- bind_rows(cv12_list) %>%
    left_join(model_catalog, by = c("ModelNumber", "Model"))

  write_csv(cv12_raw, file.path(article_dir, "prediction_cv1_cv2_raw.csv"))

  cv12_env_fold <- cv12_raw %>%
    group_by(ModelNumber, Model, Trait, CV, Rep, Fold, Env) %>%
    summarise(
      EnvCorrelation = mean(unique(cor[!is.na(cor)]), na.rm = TRUE),
      ValidationCount = sum(!is.na(cor)),
      .groups = "drop"
    ) %>%
    mutate(
      EnvCorrelation = ifelse(is.nan(EnvCorrelation), NA_real_, EnvCorrelation)
    ) %>%
    filter(!is.na(EnvCorrelation), ValidationCount > 0)

  cv12_env_rep <- cv12_env_fold %>%
    group_by(ModelNumber, Model, Trait, CV, Rep, Env) %>%
    summarise(
      EnvCorrelation = weighted.mean(EnvCorrelation, w = ValidationCount, na.rm = TRUE),
      ValidationCount = sum(ValidationCount, na.rm = TRUE),
      .groups = "drop"
    )

  cv12_rep_summary <- cv12_env_rep %>%
    group_by(ModelNumber, Model, Trait, CV, Rep) %>%
    summarise(
      WeightedCorrelation = weighted.mean(EnvCorrelation, w = ValidationCount, na.rm = TRUE),
      .groups = "drop"
    )

  cv12_summary <- cv12_rep_summary %>%
    group_by(ModelNumber, Model, Trait, CV) %>%
    summarise(
      MeanCorrelation = mean(WeightedCorrelation, na.rm = TRUE),
      SDCorrelation = sd(WeightedCorrelation, na.rm = TRUE),
      NumberOfRepetitions = n(),
      .groups = "drop"
    ) %>%
    left_join(model_catalog, by = c("ModelNumber", "Model")) %>%
    arrange(Trait, CV, desc(MeanCorrelation))

  write_csv(cv12_summary, file.path(article_dir, "prediction_cv1_cv2_summary.csv"))

  cv12_top3 <- cv12_summary %>%
    group_by(Trait, CV) %>%
    slice_max(order_by = MeanCorrelation, n = 3, with_ties = FALSE) %>%
    ungroup()

  write_csv(cv12_top3, file.path(article_dir, "prediction_cv1_cv2_top3.csv"))
}

if (is.null(cvloo_summary) && length(cvloo_files) > 0) {
  cvloo_list <- vector("list", length(cvloo_files))

  for (i in seq_along(cvloo_files)) {
    current_file <- cvloo_files[i]
    file_name <- basename(current_file)
    file_name <- sub("\\.csv$", "", file_name)
    parts <- strsplit(file_name, "_")[[1]]

    current_data <- read_csv(current_file, show_col_types = FALSE)

    current_data$CV <- parts[1]
    current_data$Trait <- parts[2]
    current_data$Env_leave <- paste(parts[3], parts[4], sep = "_")
    current_data$Model <- parts[5]
    current_data$ModelNumber <- as.numeric(gsub("M", "", current_data$Model[1]))
    current_data$Rep <- as.numeric(gsub("rep", "", parts[6]))

    cvloo_list[[i]] <- current_data
  }

  cvloo_raw <- bind_rows(cvloo_list) %>%
    left_join(model_catalog, by = c("ModelNumber", "Model"))

  write_csv(cvloo_raw, file.path(article_dir, "prediction_cv0_cv00_raw.csv"))

  cvloo_env_filtered <- cvloo_raw %>%
    mutate(Env = as.character(Env), Env_leave = as.character(Env_leave)) %>%
    filter(Env == Env_leave)

  cvloo_file_summary <- cvloo_env_filtered %>%
    group_by(ModelNumber, Model, Trait, CV, Env_leave, Rep) %>%
    summarise(
      LOEOCorrelation = mean(unique(cor[!is.na(cor)]), na.rm = TRUE),
      ValidationCount = sum(!is.na(cor)),
      .groups = "drop"
    ) %>%
    mutate(
      LOEOCorrelation = ifelse(is.nan(LOEOCorrelation), NA_real_, LOEOCorrelation)
    ) %>%
    filter(!is.na(LOEOCorrelation), ValidationCount > 0)

  cvloo_summary <- cvloo_file_summary %>%
    group_by(ModelNumber, Model, Trait, CV, Env_leave) %>%
    summarise(
      MeanCorrelation = mean(LOEOCorrelation, na.rm = TRUE),
      SDCorrelation = sd(LOEOCorrelation, na.rm = TRUE),
      NumberOfRuns = n(),
      .groups = "drop"
    ) %>%
    left_join(model_catalog, by = c("ModelNumber", "Model")) %>%
    arrange(Trait, CV, Env_leave, desc(MeanCorrelation))

  write_csv(cvloo_summary, file.path(article_dir, "prediction_cv0_cv00_summary.csv"))

  cvloo_top3 <- cvloo_summary %>%
    group_by(Trait, CV, Env_leave) %>%
    slice_max(order_by = MeanCorrelation, n = 3, with_ties = FALSE) %>%
    ungroup()

  write_csv(cvloo_top3, file.path(article_dir, "prediction_cv0_cv00_top3.csv"))
}

if (!is.null(cv12_summary)) {
  write_csv(cv12_summary, file.path(article_dir, "prediction_cv1_cv2_summary.csv"))

  cv12_best <- cv12_summary %>%
    group_by(Trait, CV) %>%
    slice_max(order_by = MeanCorrelation, n = 1, with_ties = FALSE) %>%
    ungroup()

  cv12_baseline <- cv12_summary %>%
    filter(Model == "M01") %>%
    select(Trait, CV, BaselineCorrelation = MeanCorrelation)

  cv12_best_vs_baseline <- cv12_best %>%
    left_join(cv12_baseline, by = c("Trait", "CV")) %>%
    mutate(DeltaVsM01 = MeanCorrelation - BaselineCorrelation)

  write_csv(cv12_best_vs_baseline, file.path(article_dir, "prediction_cv1_cv2_best_vs_M01.csv"))

  report_lines <- c(
    report_lines,
    "PREDICTIVE ABILITY: CV1 AND CV2",
    ifelse(file.exists(file.path(tables_dir, "prediction_cv1_cv2_summary.csv")),
           "Summary source: output/tables/prediction_cv1_cv2_summary.csv",
           paste("Number of CV1/CV2 files processed:", length(cv12_files))),
    "Summary table: output/article_results/prediction_cv1_cv2_summary.csv",
    "Top 3 table: output/article_results/prediction_cv1_cv2_top3.csv",
    "Best model vs M01 table: output/article_results/prediction_cv1_cv2_best_vs_M01.csv",
    ""
  )

  for (i in 1:nrow(cv12_best_vs_baseline)) {
    report_lines <- c(
      report_lines,
      paste0(
        cv12_best_vs_baseline$Trait[i], " - ", cv12_best_vs_baseline$CV[i],
        ": best model = ", cv12_best_vs_baseline$Model[i],
        " (", cv12_best_vs_baseline$Description[i], ")",
        "; mean correlation = ", round(cv12_best_vs_baseline$MeanCorrelation[i], 4),
        "; sd = ", round(cv12_best_vs_baseline$SDCorrelation[i], 4),
        "; delta vs M01 = ", round(cv12_best_vs_baseline$DeltaVsM01[i], 4)
      )
    )
  }

  if (!is.null(cv12_w_effect)) {
    write_csv(cv12_w_effect, file.path(article_dir, "prediction_cv1_cv2_weather_delta_pairs.csv"))

    mean_weather_delta_cv12 <- cv12_w_effect %>%
      group_by(Trait, CV) %>%
      summarise(
        MeanDeltaWithW = mean(DeltaWithW, na.rm = TRUE),
        .groups = "drop"
      )

    write_csv(mean_weather_delta_cv12, file.path(article_dir, "prediction_cv1_cv2_mean_weather_delta.csv"))

    report_lines <- c(
      report_lines,
      "",
      "Average effect of adding W to matched model pairs (CV1/CV2):"
    )

    for (i in 1:nrow(mean_weather_delta_cv12)) {
      report_lines <- c(
        report_lines,
        paste0(
          mean_weather_delta_cv12$Trait[i], " - ", mean_weather_delta_cv12$CV[i],
          ": mean delta (with W - without W) = ",
          round(mean_weather_delta_cv12$MeanDeltaWithW[i], 4)
        )
      )
    }
  }

  if (!is.null(cv12_kernel_family_compare)) {
    write_csv(cv12_kernel_family_compare, file.path(article_dir, "prediction_cv1_cv2_kernel_family_compare.csv"))

    report_lines <- c(
      report_lines,
      "",
      "Kernel-family comparison table saved as:",
      "output/article_results/prediction_cv1_cv2_kernel_family_compare.csv"
    )
  }

  report_lines <- c(report_lines, "")
} else {
  report_lines <- c(
    report_lines,
    "PREDICTIVE ABILITY: CV1 AND CV2",
    "No CV1/CV2 results were found.",
    ""
  )
}

if (!is.null(cvloo_summary)) {
  write_csv(cvloo_summary, file.path(article_dir, "prediction_cv0_cv00_summary.csv"))

  cvloo_best <- cvloo_summary %>%
    group_by(Trait, CV, Env_leave) %>%
    slice_max(order_by = MeanCorrelation, n = 1, with_ties = FALSE) %>%
    ungroup()

  write_csv(cvloo_best, file.path(article_dir, "prediction_cv0_cv00_best_models.csv"))

  report_lines <- c(
    report_lines,
    "PREDICTIVE ABILITY: CV0 AND CV00",
    ifelse(file.exists(file.path(tables_dir, "prediction_cv0_cv00_summary.csv")),
           "Summary source: output/tables/prediction_cv0_cv00_summary.csv",
           paste("Number of CV0/CV00 files processed:", length(cvloo_files))),
    "Summary table: output/article_results/prediction_cv0_cv00_summary.csv",
    "Top 3 table: output/article_results/prediction_cv0_cv00_top3.csv",
    "Best model table: output/article_results/prediction_cv0_cv00_best_models.csv",
    ""
  )

  for (i in 1:nrow(cvloo_best)) {
    report_lines <- c(
      report_lines,
      paste0(
        cvloo_best$Trait[i], " - ", cvloo_best$CV[i], " - ", cvloo_best$Env_leave[i],
        ": best model = ", cvloo_best$Model[i],
        " (", cvloo_best$Description[i], ")",
        "; mean correlation = ", round(cvloo_best$MeanCorrelation[i], 4),
        "; sd = ", round(cvloo_best$SDCorrelation[i], 4)
      )
    )
  }

  if (!is.null(cvloo_w_effect)) {
    write_csv(cvloo_w_effect, file.path(article_dir, "prediction_cv0_cv00_weather_delta_pairs.csv"))
  }

  if (!is.null(cvloo_kernel_family_compare)) {
    write_csv(cvloo_kernel_family_compare, file.path(article_dir, "prediction_cv0_cv00_kernel_family_compare.csv"))
  }

  report_lines <- c(report_lines, "")
} else {
  report_lines <- c(
    report_lines,
    "PREDICTIVE ABILITY: CV0 AND CV00",
    "No CV0/CV00 results were found.",
    ""
  )
}

# ------------------------------------------------------------
# 8. Read variance component results
# ------------------------------------------------------------

variance_data <- NULL

if (file.exists(file.path(variance_dir, "variance_components_processed.csv"))) {
  variance_data <- read_csv(file.path(variance_dir, "variance_components_processed.csv"), show_col_types = FALSE)
}

if (is.null(variance_data) && file.exists(file.path(variance_dir, "variance_components_all.rds"))) {
  variance_data <- readRDS(file.path(variance_dir, "variance_components_all.rds"))
}

if (!is.null(variance_data)) {
  if (!("ComponentLabel" %in% colnames(variance_data)) && "Component" %in% colnames(variance_data)) {
    variance_data$ComponentLabel <- variance_data$Component
  }

  if (!("Percentage" %in% colnames(variance_data)) && "VariancePercent" %in% colnames(variance_data)) {
    variance_data$Percentage <- variance_data$VariancePercent
  }

  if (!("Model" %in% colnames(variance_data)) && "ModelID" %in% colnames(variance_data)) {
    variance_data$Model <- sprintf("M%02d", variance_data$ModelID)
  }

  if ("Model" %in% colnames(variance_data)) {
    variance_data$Model <- as.character(variance_data$Model)
    variance_data$Model <- ifelse(grepl("^Eta", variance_data$Model),
                                  sprintf("M%02d", as.numeric(gsub("Eta", "", variance_data$Model))),
                                  variance_data$Model)
  }

  if ("Trait" %in% colnames(variance_data)) {
    variance_data$Trait <- as.character(variance_data$Trait)
  }

  variance_data <- variance_data %>%
    left_join(model_catalog %>% select(Model, Description), by = "Model")

  write_csv(variance_data, file.path(article_dir, "variance_components_raw_or_processed_loaded.csv"))

  variance_family_summary <- variance_data %>%
    mutate(
      Family = case_when(
        ComponentLabel %in% c("E") ~ "Environment main effect",
        ComponentLabel %in% c("W") ~ "Weather main effect",
        ComponentLabel %in% c("G", "GGK", "GAK") ~ "Genomic kernels",
        ComponentLabel %in% c("P", "PGK", "PAK") ~ "Phenomic kernels",
        ComponentLabel %in% c("GE", "GGKE", "GAKE") ~ "Genomic x environment",
        ComponentLabel %in% c("PE", "PGKE", "PAKE") ~ "Phenomic x environment",
        ComponentLabel %in% c("GW", "GGKW", "GAKW") ~ "Genomic x weather",
        ComponentLabel %in% c("PW", "PGKW", "PAKW") ~ "Phenomic x weather",
        ComponentLabel %in% c("Residual", "Residuals", "Error", "e") ~ "Residual",
        TRUE ~ "Other"
      )
    ) %>%
    group_by(Trait, Model, Family) %>%
    summarise(Percentage = sum(Percentage, na.rm = TRUE), .groups = "drop")

  write_csv(variance_family_summary, file.path(article_dir, "variance_components_family_summary.csv"))

  variance_family_average <- variance_family_summary %>%
    group_by(Trait, Family) %>%
    summarise(
      MeanPercentage = mean(Percentage, na.rm = TRUE),
      SDPercentage = sd(Percentage, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(Trait, desc(MeanPercentage))

  write_csv(variance_family_average, file.path(article_dir, "variance_components_family_average.csv"))

  dominant_component <- variance_data %>%
    group_by(Trait, Model) %>%
    slice_max(order_by = Percentage, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    select(Trait, Model, Description, ComponentLabel, Percentage)

  write_csv(dominant_component, file.path(article_dir, "variance_components_dominant_component_by_model.csv"))

  report_lines <- c(
    report_lines,
    "VARIANCE COMPONENTS",
    "Loaded variance component results successfully.",
    "Saved files:",
    "- output/article_results/variance_components_raw_or_processed_loaded.csv",
    "- output/article_results/variance_components_family_summary.csv",
    "- output/article_results/variance_components_family_average.csv",
    "- output/article_results/variance_components_dominant_component_by_model.csv",
    "",
    "Average variance share by family across models:"
  )

  for (i in 1:nrow(variance_family_average)) {
    report_lines <- c(
      report_lines,
      paste0(
        variance_family_average$Trait[i], " - ", variance_family_average$Family[i],
        ": mean = ", round(variance_family_average$MeanPercentage[i], 2),
        "% ; sd = ", round(variance_family_average$SDPercentage[i], 2), "%"
      )
    )
  }

  report_lines <- c(report_lines, "", "Dominant component for each model and trait saved in:")
  report_lines <- c(report_lines, "output/article_results/variance_components_dominant_component_by_model.csv", "")
} else {
  report_lines <- c(
    report_lines,
    "VARIANCE COMPONENTS",
    "No variance component file was found.",
    "Expected one of these files:",
    "- output/variance_components/variance_components_processed.csv",
    "- output/variance_components/variance_components_all.rds",
    ""
  )
}

# ------------------------------------------------------------
# 9. Reviewer-oriented notes
# ------------------------------------------------------------

reviewer_notes <- tibble(
  Topic = c(
    "Terminology",
    "Missing references",
    "Units of measurement",
    "Gaussian kernel scaling",
    "MCMC settings and convergence",
    "Graph interpretation"
  ),
  What_the_script_provides = c(
    "No numerical output needed. Prefer 'weather' for W when referring only to meteorological variables.",
    "No numerical output. Add references manually during manuscript revision.",
    "The script exports a climate covariate table with variable names and units.",
    "The script exports q05G and q05P when available.",
    "This script does not compute convergence by itself unless full BGLR chains were saved. If chains were not saved, rerun selected models keeping full fit objects for trace plots and effective sample size.",
    "The script exports concise prediction, weather-effect, kernel-family, and variance tables that can be used to revise figures and captions."
  )
)

write_csv(reviewer_notes, file.path(article_dir, "reviewer_comment_support_table.csv"))

report_lines <- c(
  report_lines,
  "REVIEWER-ORIENTED NOTES",
  "A support table linking reviewer topics to numerical outputs was saved as:",
  "output/article_results/reviewer_comment_support_table.csv",
  "",
  "Important note on convergence:",
  "If the reviewers require formal convergence diagnostics for sigma2e or other posterior quantities, keep full BGLR fit objects for selected models and generate trace plots and effective sample size summaries.",
  ""
)

# ------------------------------------------------------------
# 10. Final write-out
# ------------------------------------------------------------

write_lines(report_lines, file.path(article_dir, "article_results_report.txt"))

cat(paste(report_lines, collapse = "\n"))
cat("\n\n")
cat("Main report saved in: output/article_results/article_results_report.txt\n")
cat("All supporting tables were saved in: output/article_results/\n")
