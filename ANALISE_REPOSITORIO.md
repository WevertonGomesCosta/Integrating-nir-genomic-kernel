# Repository Analysis: Integrating-nir-genomic-kernel

## 1. High-level overview
This repository organizes a tutorial-oriented research workflow that integrates **NIR spectroscopy**, **genomic SNP data**, and **environmental information** into **kernel-based prediction models** for plant breeding.

The project follows a reproducible reporting style using `workflowr`, where source analyses in `analysis/` are rendered to a static website in `docs/`.

## 2. Project structure
- `analysis/`: R Markdown reports (`index.Rmd`, `analysis.Rmd`, `climate_data.Rmd`, `variance_components.Rmd`) and site configuration (`_site.yml`).
- `data/`: input datasets (e.g., `NIR.csv`, `GAPIT.Genotype.Numerical.txt`).
- `output/`: intermediate and final artifacts (kernels, predictive ability tables, climate covariates).
- `docs/`: rendered website pages and figures.
- `_workflowr.yml`: reproducibility and workflow configuration.
- `code/`: reusable helper functions and automation scripts.

## 3. Main analytical pipeline
From `analysis/analysis.Rmd`, the core workflow is:
1. Load statistical and computational libraries.
2. Read NIR/phenomic and genomic inputs.
3. Harmonize identifiers and align samples across modalities.
4. Split observations into four target environments (`CS11_WS`, `CS11_WW`, `CS12_WS`, `CS12_WW`).
5. Build kernels:
   - `ZG`: genomic relationship kernel
   - `ZP`: phenomic/NIR relationship kernel
   - `ZEZE` and `ZW`: environmental relationship kernels
6. Derive interaction kernels (`G×E`, `P×E`, `G×W`, `P×W`) and evaluate predictive models.

## 4. Strengths
- Clear scientific narrative throughout the reports.
- Good separation between source analyses, input data, results, and published outputs.
- Strong use of matrix-based kernel methodology for multimodal integration.
- Practical cross-validation design for predictive benchmarking.

## 5. Risks and improvement opportunities
1. **Language and naming consistency**
   - There is mixed Portuguese/English naming in folders and comments.
   - Recommendation: converge to English scientific terminology for tutorial clarity.

2. **Large artifacts tracked in Git**
   - Large text/binary assets can reduce collaboration efficiency.
   - Recommendation: evaluate Git LFS or external storage with scripted download.

3. **Limited modularization in early workflow sections**
   - Important preprocessing logic was initially concentrated in the R Markdown file.
   - Recommendation: keep the tutorial notebook as the main file while delegating reusable logic to `code/`.

4. **Dependency reproducibility**
   - Version pinning was not explicit.
   - Recommendation: maintain `renv.lock` (R) and `requirements.txt` (Python helpers).

5. **Automated data quality checks**
   - Data sanity checks existed as ad hoc notebook steps.
   - Recommendation: keep notebook checks and add script-based automatic checks for CI or local validation.

## 6. Priority roadmap
### Short term
- Keep all public-facing docs in English.
- Maintain tutorial-first readability while using modular helper functions.
- Run automated sanity checks before long cross-validation batches.

### Medium term
- Expand modular helper coverage to additional modeling sections.
- Add lightweight execution entry points for reproducible reruns.
- Define explicit policy for handling large generated artifacts.

### Long term
- Adopt a declarative pipeline framework (e.g., `targets`) for dependency-aware execution.
- Introduce automated validation in CI for data integrity and output schema stability.

## 7. Conclusion
The repository already provides a robust tutorial base for multimodal kernel prediction. The main next step is to combine **scientific clarity** with **engineering reproducibility** through standardized language, modular helper functions, environment pinning, and automated data sanity checks.
