# QIIME2 Analysis

This folder contains the QIIME2 command-log R Markdown files for the retained thesis analysis groups. These files turn the command history from the Excel workbook into cleaner step-by-step workflow documents.

## Files In This Folder

- `Group_1_QIIME2_Workflow.Rmd`
  Group 1 single-end workflow for `PRJNA1209429-preg`.

- `Group_2_QIIME2_Workflow.Rmd`
  Group 2 pooled workflow for `PRJNA1158308`, `PRJNA1357312` and `PRJNA944557`, including study-level trimming and the grouped final QIIME2 run.

- `Group_3_QIIME2_Workflow.Rmd`
  Group 3 paired-end workflow for `PRJNA831840`.

- `Group_4_FINAL_QIIME2_Workflow.Rmd`
  Group 4 final paired-end workflow for `PRJNA1060792`.

## Notes

- These files are documentation-style `.Rmd` records of the QIIME2 processing workflow. They are meant to show the commands and reasoning clearly.
- The command blocks are set to `eval = FALSE`, so they are not meant to be knitted as-is to rerun the full pipeline automatically.
- Some paths are still absolute paths from the original local analysis environment.
