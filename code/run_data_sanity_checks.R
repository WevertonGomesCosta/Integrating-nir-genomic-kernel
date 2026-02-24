#!/usr/bin/env Rscript

# Automated data sanity checks for tutorial datasets (R-only workflow)

source("code/tutorial_functions.R")

core_data <- load_core_data(
  nir_path = "data/NIR.csv",
  geno_path = "data/GAPIT.Genotype.Numerical.txt"
)

NIR <- core_data$NIR
Geno <- core_data$Geno
Pheno <- core_data$Pheno

sanity_table <- run_data_sanity_checks(NIR, Geno, Pheno)

summary_table <- data.frame(
  metric = c(
    "nir_rows", "geno_rows", "nir_columns", "geno_columns",
    "nir_unique_pedigree", "geno_unique_taxa", "shared_ids"
  ),
  value = c(
    nrow(NIR), nrow(Geno), ncol(NIR), ncol(Geno),
    length(unique(NIR$Pedigree)), length(unique(Geno$taxa)),
    length(intersect(unique(NIR$Pedigree), unique(Geno$taxa)))
  )
)

known_env <- c("CS11_WS", "CS11_WW", "CS12_WS", "CS12_WW")
extra_checks <- data.frame(
  check = c("nir_has_known_environments"),
  passed = c(all(known_env %in% unique(NIR$Env)))
)

final_checks <- rbind(sanity_table, extra_checks)

if (!dir.exists("output")) dir.create("output", recursive = TRUE)

write.csv(final_checks, "output/data_sanity_report.csv", row.names = FALSE)
write.csv(summary_table, "output/data_sanity_summary.csv", row.names = FALSE)

print(final_checks)
print(summary_table)

if (!all(final_checks$passed)) {
  stop("Data sanity checks failed. Inspect output/data_sanity_report.csv")
}
