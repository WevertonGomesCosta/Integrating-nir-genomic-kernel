# Tutorial helper functions for the NIR + genomic kernel workflow

load_core_data <- function(
  nir_path = "data/NIR.csv",
  geno_path = "data/GAPIT.Genotype.Numerical.txt"
) {
  nir <- data.table::fread(nir_path) |> as.data.frame()
  geno <- data.table::fread(geno_path) |> as.data.frame()
  pheno <- nir[, c("Pedigree", "Env", "GY", "KW")] |>
    dplyr::arrange(Env, Pedigree)

  list(NIR = nir, Geno = geno, Pheno = pheno)
}

filter_shared_genotypes <- function(nir, geno, pheno) {
  pedigree <- intersect(geno$taxa, nir$Pedigree)

  nir_filtered <- nir[nir$Pedigree %in% pedigree, ]
  geno_filtered <- geno[geno$taxa %in% pedigree, ]
  pheno_filtered <- pheno[pheno$Pedigree %in% pedigree, ]

  list(
    NIR = nir_filtered,
    Geno = geno_filtered,
    Pheno = pheno_filtered,
    Pedigree = pedigree
  )
}

split_nir_by_environment <- function(nir) {
  env_labels <- c("CS11_WS", "CS11_WW", "CS12_WS", "CS12_WW")
  env_list <- lapply(env_labels, function(env) {
    df <- nir[nir$Env == env, ]
    rownames(df) <- df$Pedigree
    df[order(rownames(df)), ]
  })

  names(env_list) <- c("a", "b", "c", "d")
  env_list
}

prepare_geno_matrix <- function(geno) {
  geno <- geno[order(geno$taxa), ]
  rownames(geno) <- geno$taxa
  geno[, -1]
}

build_linear_kernel <- function(x) {
  tcrossprod(as.matrix(x)) / ncol(x)
}

build_genomic_kernel <- function(geno_matrix, env_split) {
  geno_a <- scale(subset(geno_matrix, rownames(geno_matrix) %in% env_split$a$Pedigree), center = TRUE, scale = TRUE)
  geno_b <- scale(subset(geno_matrix, rownames(geno_matrix) %in% env_split$b$Pedigree), center = TRUE, scale = TRUE)
  geno_c <- scale(subset(geno_matrix, rownames(geno_matrix) %in% env_split$c$Pedigree), center = TRUE, scale = TRUE)
  geno_d <- scale(subset(geno_matrix, rownames(geno_matrix) %in% env_split$d$Pedigree), center = TRUE, scale = TRUE)

  geno_all <- rbind(geno_a, geno_b, geno_c, geno_d)
  list(Geno.all = geno_all, ZG = build_linear_kernel(geno_all))
}

build_phenomic_kernel <- function(env_split, first_predictor_col = 6L) {
  nir_a <- scale(env_split$a[, -(1:(first_predictor_col - 1))], center = TRUE, scale = TRUE)
  nir_b <- scale(env_split$b[, -(1:(first_predictor_col - 1))], center = TRUE, scale = TRUE)
  nir_c <- scale(env_split$c[, -(1:(first_predictor_col - 1))], center = TRUE, scale = TRUE)
  nir_d <- scale(env_split$d[, -(1:(first_predictor_col - 1))], center = TRUE, scale = TRUE)

  nir_all <- rbind(nir_a, nir_b, nir_c, nir_d)
  list(NIR.all = nir_all, ZP = build_linear_kernel(nir_all))
}

run_data_sanity_checks <- function(nir, geno, pheno) {
  required_nir <- c("Pedigree", "Env", "KW", "GY")
  required_geno <- c("taxa")
  required_pheno <- c("Pedigree", "Env", "GY", "KW")

  checks <- list(
    nir_required_columns = all(required_nir %in% colnames(nir)),
    geno_required_columns = all(required_geno %in% colnames(geno)),
    pheno_required_columns = all(required_pheno %in% colnames(pheno)),
    nir_missing_ids = sum(is.na(nir$Pedigree)) == 0,
    geno_missing_ids = sum(is.na(geno$taxa)) == 0,
    no_duplicate_nir_ids = sum(duplicated(nir[, c("Pedigree", "Env")])) == 0,
    no_duplicate_geno_ids = sum(duplicated(geno$taxa)) == 0,
    shared_ids_gt_zero = length(intersect(unique(nir$Pedigree), unique(geno$taxa))) > 0
  )

  data.frame(check = names(checks), passed = unlist(checks), row.names = NULL)
}
