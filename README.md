# Murine Polystyrene Nanoplastic Microbiome Analysis

This private repository is organized into two top-level analysis areas:

- `R Analysis/`
- `QIIME2 Analysis/`

The repository is meant to hold the source analysis workflows for the thesis project in a cleaner structure than the original working directory.

## Repository Structure

### `R Analysis/`

This directory contains all tracked R Markdown analysis scripts for the project.

- `Combined_Supplementary_Figures.Rmd`
  Generates combined supplementary figure panels across retained groups.

- `Group_1_Analysis.Rmd`
  Main downstream R workflow for Group 1, including diversity analysis, ordination and genus-level outputs.

- `Group_2_Analysis.Rmd`
  Main downstream R workflow for Group 2, including pooled cross-study analysis and batch-aware components.

- `Group_3_Analysis.Rmd`
  Main downstream R workflow for Group 3, including diversity analysis, ordination and genus-level outputs.

- `Group_4_Analysis.Rmd`
  Main downstream R workflow for Group 4, including diversity analysis, ordination and genus-level outputs.

- `Group_2_Exploratory_By_Project.Rmd`
  Exploratory Group 2 analysis separated by BioProject to examine project-level heterogeneity.

- `Top30_Sensitivity_Analysis.Rmd`
  Sensitivity analysis based on top-30 genus filtering across Groups 1-4.

- `Group_1_LEfSe_LDA1.Rmd`
  Exploratory LEfSe workflow for Group 1 using an LDA threshold of 1.

- `Group_2_LEfSe_LDA1.Rmd`
  Exploratory LEfSe workflow for Group 2 using an LDA threshold of 1.

- `Group_3_LEfSe_LDA1.Rmd`
  Exploratory LEfSe workflow for Group 3 using an LDA threshold of 1.

- `Group_4_LEfSe_LDA1.Rmd`
  Exploratory LEfSe workflow for Group 4 using an LDA threshold of 1.

### `QIIME2 Analysis/`

This directory is reserved for QIIME2-side workflow materials for the same project. It is included now so the repository clearly separates R-based downstream analysis from QIIME2 processing materials.

## How To Use The Repository

1. Start in `R Analysis/` with the relevant main group-level file.
2. Use `Group_2_Exploratory_By_Project.Rmd` only when you want the project-separated Group 2 exploratory view.
3. Use `Top30_Sensitivity_Analysis.Rmd` and the `Group_*_LEfSe_LDA1.Rmd` files for sensitivity and exploratory analyses rather than the core thesis workflow.
4. Use `Combined_Supplementary_Figures.Rmd` after the group-level outputs needed for supplementary panels have already been generated locally.

## Important Notes

- The tracked scripts still reflect the original local analysis environment and may contain absolute file paths that need to be edited before rerunning elsewhere.
- Generated outputs, temporary files and machine-specific clutter are intentionally excluded from version control.
- This repository is intended to preserve and organize source analysis scripts, not every derived output file from the original working directory.
