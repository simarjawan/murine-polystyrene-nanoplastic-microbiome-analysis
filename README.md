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

- `LEfSe LDA1 Analysis/`
  This folder contains the exploratory LEfSe scripts run with an LDA threshold of 1:
  `Group_1_LEfSe_LDA1.Rmd`, `Group_2_LEfSe_LDA1.Rmd`, `Group_3_LEfSe_LDA1.Rmd` and `Group_4_LEfSe_LDA1.Rmd`.

### `QIIME2 Analysis/`

This folder contains the QIIME2 command-log R Markdown files that document the upstream sequence-processing workflow for each retained analysis group.

- `Group_1_QIIME2_Workflow.Rmd`
  This file documents the single-end QIIME2 workflow used for Group 1, including primer trimming, DADA2 denoising, taxonomy assignment and export steps.

- `Group_2_QIIME2_Workflow.Rmd`
  This file documents the three-study grouped QIIME2 workflow used for Group 2, including study-level trimming, grouped DADA2 processing, metadata merging, final sample filtering and downstream taxonomy/export steps.

- `Group_3_QIIME2_Workflow.Rmd`
  This file documents the final retained QIIME2 workflow used for Group 3. It records the paired-end denoising, metadata conversion, control filtering, taxonomy assignment and export steps. Primer-testing commands were left out because they were not part of the final retained workflow.

- `Group_4_FINAL_QIIME2_Workflow.Rmd`
  This file documents the final paired-end QIIME2 workflow used for Group 4, including primer trimming, denoising, final sample filtering, taxonomy assignment and export steps.

## How To Use The Repository

1. Start in `R Analysis/` with the main group-level file you need.
2. Use `Group_2_Exploratory_By_Project.Rmd` only if you want the project-separated exploratory view for Group 2.
3. Use `Top30_Sensitivity_Analysis.Rmd` and the files in `LEfSe LDA1 Analysis/` for supporting sensitivity or exploratory analyses rather than the main thesis workflow.
4. Use `Combined_Supplementary_Figures.Rmd` after the group-level outputs it depends on have already been generated locally.
5. Use the files in `QIIME2 Analysis/` if you want the step-by-step command workflow that produced the QIIME2 outputs used in the downstream R analyses.

## Important Notes

- These scripts still reflect the original local analysis environment, so some absolute file paths may need to be edited before rerunning them elsewhere.
- Generated outputs, temporary files and machine-specific clutter are intentionally excluded from version control.
- This repository is meant to preserve and organize the source analysis scripts, not every derived output file from the original working directory.
