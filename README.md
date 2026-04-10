# R Analysis Repository

This repository contains the R Markdown analysis scripts used for the murine polystyrene nanoplastic (PS-NP) gut microbiome thesis workflow. The files are organized around the four main cross-study analysis groups, followed by exploratory and supplementary analyses.

## Repository Purpose

The main purpose of this repository is to preserve the source analysis files in one private, documented location. The core group-level `.Rmd` files contain the primary downstream R analyses used after QIIME2 processing, including alpha-diversity, beta-diversity, genus-level summaries and statistical testing. Additional `.Rmd` files contain exploratory and sensitivity analyses that supported interpretation and supplementary outputs.

## Repository Structure

- `Group_1_Analysis.Rmd`
  Primary downstream R workflow for Group 1. This script performs the main microbiome analyses for the first retained comparison group, including diversity summaries, ordination-based analyses and genus-level visual/statistical outputs.

- `Group_2_Analysis.Rmd`
  Primary downstream R workflow for Group 2. This is the main two-study pooled analysis and includes batch-aware components needed for cross-study comparison where between-study heterogeneity was a major concern.

- `Group_3_Analysis.Rmd`
  Primary downstream R workflow for Group 3. This script carries out the full downstream microbiome analysis for the third compatible retained group.

- `Group_4_Analysis.Rmd`
  Primary downstream R workflow for Group 4. This script contains the main downstream analysis for the fourth group and corresponds to the group that yielded the clearest genus-level results in the final thesis.

- `Combined_Supplementary_Figures.Rmd`
  Builds combined supplementary figure panels across groups. This script is used to generate multi-panel outputs intended for supplementary reporting rather than one specific retained group alone.

- `Group 2 Exploratory Outputs/Group_2_Exploratory_By_Project.Rmd`
  Exploratory analysis of Group 2 separated by BioProject accession. This script was used to examine project-level structure within the pooled Group 2 dataset and to better understand cross-study heterogeneity.

- `Top30 Sensitivity Outputs/Top30_Sensitivity_Analysis.Rmd`
  Sensitivity analysis based on top-30 genus filtering across Groups 1-4. This script was used to check whether key patterns persisted under a reduced-feature downstream framework.

- `LEfSe LDA 1 Top50/Group_1_LEfSe_LDA1.Rmd`
  Exploratory LEfSe analysis for Group 1 using an LDA threshold of 1 on a top-50 filtered genus table.

- `LEfSe LDA 1 Top50/Group_2_LEfSe_LDA1.Rmd`
  Exploratory LEfSe analysis for Group 2 using an LDA threshold of 1 on a top-50 filtered genus table.

- `LEfSe LDA 1 Top50/Group_3_LEfSe_LDA1.Rmd`
  Exploratory LEfSe analysis for Group 3 using an LDA threshold of 1 on a top-50 filtered genus table.

- `LEfSe LDA 1 Top50/Group_4_LEfSe_LDA1.Rmd`
  Exploratory LEfSe analysis for Group 4 using an LDA threshold of 1 on a top-50 filtered genus table.

- `Code Template.R`
  General R code template used during workflow development.

- `Code Template - 4 Groups.R`
  Multi-group template file used while standardizing the downstream analysis structure across the four retained groups.

- `R workflow.pdf`
  Workflow reference document summarizing the broader R-side analysis pipeline.

## How To Use This Repository

1. Start with the relevant primary group-level analysis file:
   - `Group_1_Analysis.Rmd`
   - `Group_2_Analysis.Rmd`
   - `Group_3_Analysis.Rmd`
   - `Group_4_Analysis.Rmd`

2. Use the exploratory scripts only when needed:
   - `Group_2_Exploratory_By_Project.Rmd` for project-level dissection of the pooled Group 2 analysis
   - `Top30_Sensitivity_Analysis.Rmd` for reduced-feature sensitivity checks
   - `Group_*_LEfSe_LDA1.Rmd` for exploratory LEfSe outputs

3. Use `Combined_Supplementary_Figures.Rmd` when rebuilding supplementary multi-panel figure outputs.

## Important Notes

- Many scripts currently use local absolute file paths. These paths reflect the original analysis environment and may need to be edited before re-running the files on a different machine.
- This repository is intended to store source analysis files and documentation. Large generated outputs, temporary files and machine-specific clutter are intentionally excluded from version control.
- The scripts rely on R packages that are loaded and, in some cases, installed within the `.Rmd` files themselves.

## Suggested Workflow

- Review the relevant `.Rmd` file header and package-loading section.
- Confirm that all file paths point to the correct local input files.
- Run the primary group-level analysis first.
- Run exploratory or sensitivity scripts only after the relevant primary group outputs exist.
- Regenerate supplementary figures last, once the underlying group-level outputs are available.
