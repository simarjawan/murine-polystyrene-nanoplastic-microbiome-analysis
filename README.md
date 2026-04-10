# Murine Polystyrene Nanoplastic Microbiome Analysis

This private repository holds the main analysis scripts used for the murine polystyrene nanoplastic gut microbiome thesis project. It is organized into two main analysis areas:

- `R Analysis/`
- `QIIME2 Analysis/`

The goal of this repository is to keep the source workflows in one cleaner location without including all of the generated output files from the original working directory.

## Repository Structure

### `R Analysis/`

This folder contains all tracked R Markdown files for the downstream R analyses.

- `Combined_Supplementary_Figures.Rmd`
  This script builds the combined supplementary figure panels across the retained groups.

- `Group_1_Analysis.Rmd`
  This is the main downstream R workflow for Group 1. It includes alpha-diversity, beta-diversity, ordination and genus-level outputs.

- `Group_2_Analysis.Rmd`
  This is the main downstream R workflow for Group 2. It includes the pooled cross-study analysis and the batch-aware steps needed for that group.

- `Group_3_Analysis.Rmd`
  This is the main downstream R workflow for Group 3. It includes alpha-diversity, beta-diversity, ordination and genus-level outputs.

- `Group_4_Analysis.Rmd`
  This is the main downstream R workflow for Group 4. It includes alpha-diversity, beta-diversity, ordination and genus-level outputs.

- `Group_2_Exploratory_By_Project.Rmd`
  This is an exploratory Group 2 script separated by BioProject. It was used to look more closely at project-level heterogeneity within the pooled group.

- `Top30_Sensitivity_Analysis.Rmd`
  This script runs the top-30 sensitivity analysis across Groups 1 to 4.

- `Group_1_LEfSe_LDA1.Rmd`
  This is the exploratory LEfSe workflow for Group 1 using an LDA threshold of 1.

- `Group_2_LEfSe_LDA1.Rmd`
  This is the exploratory LEfSe workflow for Group 2 using an LDA threshold of 1.

- `Group_3_LEfSe_LDA1.Rmd`
  This is the exploratory LEfSe workflow for Group 3 using an LDA threshold of 1.

- `Group_4_LEfSe_LDA1.Rmd`
  This is the exploratory LEfSe workflow for Group 4 using an LDA threshold of 1.

### `QIIME2 Analysis/`

This folder is reserved for the QIIME2 side of the project. It is included so the repository clearly separates the downstream R analysis from the upstream QIIME2 processing workflow.

## How To Use The Repository

1. Start in `R Analysis/` with the main group-level file you need.
2. Use `Group_2_Exploratory_By_Project.Rmd` only if you want the project-separated exploratory view for Group 2.
3. Use `Top30_Sensitivity_Analysis.Rmd` and the `Group_*_LEfSe_LDA1.Rmd` files for supporting sensitivity or exploratory analyses rather than the main thesis workflow.
4. Use `Combined_Supplementary_Figures.Rmd` after the group-level outputs it depends on have already been generated locally.

## Important Notes

- These scripts still reflect the original local analysis environment, so some absolute file paths may need to be edited before rerunning them elsewhere.
- Generated outputs, temporary files and machine-specific clutter are intentionally excluded from version control.
- This repository is meant to preserve and organize the source analysis scripts, not every derived output file from the original working directory.
