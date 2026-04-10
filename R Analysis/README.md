# R Analysis

This folder contains the main downstream R Markdown workflows used for the murine polystyrene nanoplastic microbiome thesis project. These files take the processed QIIME2 outputs and carry them through diversity analysis, ordination, genus-level summaries, sensitivity checks and combined figure building.

## Files In This Folder

- `Group_1_Analysis.Rmd`
  Main downstream workflow for Group 1. This file covers alpha diversity, beta diversity, ordination, relative abundance summaries and genus-level comparisons for the retained Group 1 dataset.

- `Group_2_Analysis.Rmd`
  Main downstream workflow for Group 2. This file handles the pooled cross-study analysis, including the batch-aware steps used to account for BioProject-level heterogeneity.

- `Group_2_Exploratory_By_Project.Rmd`
  Exploratory Group 2 workflow run by BioProject rather than as one pooled comparison. This was used to look more closely at study-level differences inside Group 2.

- `Group_3_Analysis.Rmd`
  Main downstream workflow for Group 3. This file covers diversity analysis, ordination, relative abundance summaries and genus-level outputs for the retained Group 3 dataset.

- `Group_4_Analysis.Rmd`
  Main downstream workflow for Group 4. This file covers diversity analysis, ordination, relative abundance summaries and genus-level outputs for the retained Group 4 dataset.

- `Combined_Supplementary_Figures.Rmd`
  Builds the combined supplementary figure panels using outputs from the retained group-level workflows.

- `Top30_Sensitivity_Analysis.Rmd`
  Runs the top-30 sensitivity analysis across Groups 1 to 4.

- `LEfSe LDA1 Analysis/`
  Contains the exploratory LEfSe scripts run with an LDA threshold of 1:
  `Group_1_LEfSe_LDA1.Rmd`, `Group_2_LEfSe_LDA1.Rmd`, `Group_3_LEfSe_LDA1.Rmd` and `Group_4_LEfSe_LDA1.Rmd`.

## How To Use This Folder

1. Start with the main group-level file you need: `Group_1_Analysis.Rmd`, `Group_2_Analysis.Rmd`, `Group_3_Analysis.Rmd` or `Group_4_Analysis.Rmd`.
2. Use `Group_2_Exploratory_By_Project.Rmd` if you want the separated project-level view for Group 2.
3. Use `Top30_Sensitivity_Analysis.Rmd` and the `LEfSe LDA1 Analysis/` folder for supporting and exploratory checks rather than the main thesis workflow.
4. Use `Combined_Supplementary_Figures.Rmd` after the group-level outputs it depends on have already been generated locally.

## Notes

- These files reflect the original local analysis environment, so some absolute file paths may need to be edited before rerunning them somewhere else.
- The scripts are meant to preserve the full source analysis workflow, not every generated output file.
- Temporary files and machine-specific clutter are intentionally left out of version control.
