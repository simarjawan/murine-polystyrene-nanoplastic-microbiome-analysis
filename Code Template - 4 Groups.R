# ============================================================
# R TEMPLATE FOR 4 QIIME GROUPS
# ============================================================
# Purpose:
# 1. Run each of your 4 groups separately.
# 2. Account for batch effects in the merged multi-study group.
# 3. Save alpha diversity, beta diversity, PERMANOVA, and plots.
#
# What you need to edit:
# - Only the "USER INPUTS" section below.
#
# Expected input table structure:
# - One row per sample
# - Metadata columns first or mixed in with feature columns
# - One column that uniquely identifies each sample
# - One biological condition column for comparison
# - One accession/study column for the merged 3-study group
# - All remaining feature columns should be abundance columns
# ============================================================


# ============================================================
# PACKAGE SETUP
# ============================================================
required_packages <- c(
  "broom",
  "readxl",
  "dplyr",
  "tidyr",
  "tibble",
  "ggplot2",
  "vegan",
  "rstatix"
)

missing_packages <- required_packages[!required_packages %in% rownames(installed.packages())]
if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

library(readxl)
library(dplyr)
library(tidyr)
library(tibble)
library(ggplot2)
library(vegan)
library(rstatix)
library(broom)


# ============================================================
# USER INPUTS
# ============================================================
# Edit this section carefully before running.
#
# file_path:
#   Path to the file for that group.
#   Use .xlsx, .csv, or .tsv.
#
# sample_id_col:
#   Column with sample IDs.
#
# condition_col:
#   Column with the main biological comparison for that group.
#
# secondary_condition_col:
#   Optional second analysis variable for the same group.
#   Use this for PSNP size where needed.
#
# batch_col:
#   Use the accession number column only for merged multi-study data.
#   For single-paper groups, leave as NA unless there is a real internal batch.
#
# metadata_cols:
#   List every metadata column you want to keep.
#   Feature columns are assumed to be all other columns not listed here.
#
# output_dir:
#   Folder where results for that group will be saved.

group_configs <- list(
  list(
    group_name = "Group_1",
    file_path = "REPLACE_WITH_GROUP_1_FILE.xlsx",
    sample_id_col = "SampleID",
    condition_col = "Condition",
    secondary_condition_col = NA,
    batch_col = NA,
    metadata_cols = c("SampleID", "Condition", "AccessionNumber"),
    output_dir = "Group_1_results"
  ),
  list(
    group_name = "Group_2_Merged_3_Studies",
    file_path = "REPLACE_WITH_GROUP_2_FILE.xlsx",
    sample_id_col = "SampleID",
    condition_col = "Condition",
    secondary_condition_col = "PSNP_Size",
    batch_col = "AccessionNumber",
    metadata_cols = c("SampleID", "Condition", "PSNP_Size", "AccessionNumber"),
    output_dir = "Group_2_results"
  ),
  list(
    group_name = "Group_3",
    file_path = "REPLACE_WITH_GROUP_3_FILE.xlsx",
    sample_id_col = "SampleID",
    condition_col = "Condition",
    secondary_condition_col = "PSNP_Size",
    batch_col = NA,
    metadata_cols = c("SampleID", "Condition", "PSNP_Size", "AccessionNumber"),
    output_dir = "Group_3_results"
  ),
  list(
    group_name = "Group_4",
    file_path = "REPLACE_WITH_GROUP_4_FILE.xlsx",
    sample_id_col = "SampleID",
    condition_col = "Condition",
    secondary_condition_col = NA,
    batch_col = NA,
    metadata_cols = c("SampleID", "Condition", "AccessionNumber"),
    output_dir = "Group_4_results"
  )
)


# ============================================================
# HELPER FUNCTIONS
# ============================================================
read_input_file <- function(file_path) {
  if (!file.exists(file_path)) {
    stop(paste("File not found:", file_path))
  }

  lower_path <- tolower(file_path)

  if (grepl("\\.xlsx$", lower_path)) {
    return(read_excel(file_path))
  }

  if (grepl("\\.csv$", lower_path)) {
    return(read.csv(file_path, check.names = FALSE))
  }

  if (grepl("\\.tsv$", lower_path) || grepl("\\.txt$", lower_path)) {
    return(read.delim(file_path, check.names = FALSE))
  }

  stop("Unsupported file type. Use .xlsx, .csv, .tsv, or .txt")
}

safe_dir_create <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
}

clean_abundance_matrix <- function(abundance_df) {
  abundance_df <- abundance_df %>%
    mutate(across(everything(), as.numeric))

  abundance_df[is.na(abundance_df)] <- 0

  if (!any(abundance_df > 0, na.rm = TRUE)) {
    stop("Abundance matrix has no values greater than zero.")
  }

  min_value <- min(abundance_df[abundance_df > 0], na.rm = TRUE)
  pseudocount <- min_value / 5

  abundance_df <- abundance_df %>%
    mutate(across(everything(), ~ ifelse(. == 0, pseudocount, .)))

  row_totals <- rowSums(abundance_df, na.rm = TRUE)
  if (any(row_totals == 0)) {
    stop("At least one sample has a row total of zero after preprocessing.")
  }

  norm_abundance <- abundance_df / row_totals

  list(
    raw_abundance = abundance_df,
    normalized_abundance = norm_abundance,
    pseudocount = pseudocount
  )
}

save_plot <- function(plot_obj, file_path, width = 8, height = 6) {
  ggsave(filename = file_path, plot = plot_obj, width = width, height = height, dpi = 300)
}

make_top_taxa_barplots <- function(norm_abundance, metadata_df, config, top_n = 15) {
  long_df <- norm_abundance %>%
    mutate(SampleID = metadata_df[[config$sample_id_col]]) %>%
    pivot_longer(
      cols = -SampleID,
      names_to = "Taxon",
      values_to = "RelativeAbundance"
    ) %>%
    left_join(
      metadata_df %>% select(all_of(unique(c(config$sample_id_col, config$condition_col)))),
      by = setNames(config$sample_id_col, "SampleID")
    )

  top_taxa <- long_df %>%
    group_by(Taxon) %>%
    summarise(TotalAbundance = sum(RelativeAbundance, na.rm = TRUE), .groups = "drop") %>%
    arrange(desc(TotalAbundance)) %>%
    slice_head(n = top_n) %>%
    pull(Taxon)

  plot_df <- long_df %>%
    mutate(TaxonPlot = ifelse(Taxon %in% top_taxa, Taxon, "Other")) %>%
    group_by(SampleID, .data[[config$condition_col]], TaxonPlot) %>%
    summarise(RelativeAbundance = sum(RelativeAbundance), .groups = "drop")

  names(plot_df)[names(plot_df) == config$condition_col] <- "ConditionValue"

  sample_order <- metadata_df %>%
    select(all_of(c(config$sample_id_col, config$condition_col))) %>%
    rename(SampleID = all_of(config$sample_id_col), ConditionValue = all_of(config$condition_col)) %>%
    arrange(ConditionValue, SampleID) %>%
    pull(SampleID)

  plot_df$SampleID <- factor(plot_df$SampleID, levels = sample_order)

  sample_plot <- ggplot(plot_df, aes(x = SampleID, y = RelativeAbundance, fill = TaxonPlot)) +
    geom_col(width = 0.95) +
    facet_grid(. ~ ConditionValue, scales = "free_x", space = "free_x") +
    theme_minimal(base_size = 12) +
    labs(
      title = paste("Relative Abundance by Sample -", config$group_name),
      x = "Sample",
      y = "Relative Abundance",
      fill = "Taxon"
    ) +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
      panel.grid.minor = element_blank()
    )

  condition_plot_df <- plot_df %>%
    group_by(ConditionValue, TaxonPlot) %>%
    summarise(RelativeAbundance = mean(RelativeAbundance, na.rm = TRUE), .groups = "drop")

  condition_plot <- ggplot(condition_plot_df, aes(x = ConditionValue, y = RelativeAbundance, fill = TaxonPlot)) +
    geom_col(width = 0.8) +
    theme_minimal(base_size = 12) +
    labs(
      title = paste("Mean Relative Abundance by Condition -", config$group_name),
      x = config$condition_col,
      y = "Mean Relative Abundance",
      fill = "Taxon"
    ) +
    theme(panel.grid.minor = element_blank())

  list(
    sample_plot = sample_plot,
    condition_plot = condition_plot,
    long_table = plot_df,
    condition_table = condition_plot_df
  )
}

run_single_condition_analysis <- function(
  metadata_df,
  norm_abundance,
  sample_id_values,
  sample_id_col,
  condition_col,
  batch_col,
  output_dir,
  analysis_label,
  group_name
) {
  safe_dir_create(output_dir)

  condition_values <- metadata_df[[condition_col]]
  plot_config <- list(
    group_name = paste(group_name, "-", analysis_label),
    sample_id_col = sample_id_col,
    condition_col = condition_col
  )

  summary_df <- metadata_df %>%
    group_by(across(all_of(intersect(c(condition_col, batch_col), names(metadata_df))))) %>%
    summarise(n_samples = dplyr::n(), .groups = "drop")
  write.csv(summary_df, file.path(output_dir, paste0("group_summary_", analysis_label, ".csv")), row.names = FALSE)

  shannon_index <- diversity(norm_abundance, index = "shannon")
  simpson_index <- diversity(norm_abundance, index = "simpson")

  alpha_df <- tibble(
    SampleID = sample_id_values,
    Shannon = shannon_index,
    Simpson = simpson_index
  )

  meta_alpha <- alpha_df %>%
    left_join(metadata_df, by = setNames(sample_id_col, "SampleID"))

  write.csv(alpha_df, file.path(output_dir, paste0("alpha_diversity_", analysis_label, ".csv")), row.names = FALSE)
  write.csv(meta_alpha, file.path(output_dir, paste0("alpha_diversity_with_metadata_", analysis_label, ".csv")), row.names = FALSE)

  alpha_shannon_plot <- ggplot(meta_alpha, aes_string(x = condition_col, y = "Shannon", fill = condition_col)) +
    geom_boxplot(outlier.shape = 16, outlier.alpha = 0.5) +
    geom_jitter(width = 0.2, alpha = 0.7) +
    theme_minimal(base_size = 13) +
    theme(legend.position = "none") +
    labs(
      title = paste("Shannon Diversity -", group_name, "-", analysis_label),
      x = condition_col,
      y = "Shannon Index"
    )

  alpha_simpson_plot <- ggplot(meta_alpha, aes_string(x = condition_col, y = "Simpson", fill = condition_col)) +
    geom_boxplot(outlier.shape = 16, outlier.alpha = 0.5) +
    geom_jitter(width = 0.2, alpha = 0.7) +
    theme_minimal(base_size = 13) +
    theme(legend.position = "none") +
    labs(
      title = paste("Simpson Diversity -", group_name, "-", analysis_label),
      x = condition_col,
      y = "Simpson Index"
    )

  save_plot(alpha_shannon_plot, file.path(output_dir, paste0("alpha_shannon_boxplot_", analysis_label, ".png")))
  save_plot(alpha_simpson_plot, file.path(output_dir, paste0("alpha_simpson_boxplot_", analysis_label, ".png")))

  taxa_barplots <- make_top_taxa_barplots(norm_abundance, metadata_df, plot_config, top_n = 15)
  save_plot(taxa_barplots$sample_plot, file.path(output_dir, paste0("taxa_barplot_by_sample_", analysis_label, ".png")), width = 12, height = 7)
  save_plot(taxa_barplots$condition_plot, file.path(output_dir, paste0("taxa_barplot_by_condition_", analysis_label, ".png")), width = 8, height = 6)
  write.csv(taxa_barplots$long_table, file.path(output_dir, paste0("taxa_relative_abundance_by_sample_", analysis_label, ".csv")), row.names = FALSE)
  write.csv(taxa_barplots$condition_table, file.path(output_dir, paste0("taxa_relative_abundance_by_condition_", analysis_label, ".csv")), row.names = FALSE)

  condition_levels <- unique(na.omit(condition_values))

  if (length(condition_levels) >= 2) {
    kruskal_shannon <- kruskal.test(
      as.formula(paste("Shannon ~", condition_col)),
      data = meta_alpha
    )

    kruskal_simpson <- kruskal.test(
      as.formula(paste("Simpson ~", condition_col)),
      data = meta_alpha
    )

    write.csv(
      broom::tidy(kruskal_shannon),
      file.path(output_dir, paste0("kruskal_shannon_", analysis_label, ".csv")),
      row.names = FALSE
    )

    write.csv(
      broom::tidy(kruskal_simpson),
      file.path(output_dir, paste0("kruskal_simpson_", analysis_label, ".csv")),
      row.names = FALSE
    )

    if (length(condition_levels) > 2) {
      pairwise_shannon <- pairwise_wilcox_test(
        meta_alpha,
        as.formula(paste("Shannon ~", condition_col)),
        p.adjust.method = "BH"
      )

      pairwise_simpson <- pairwise_wilcox_test(
        meta_alpha,
        as.formula(paste("Simpson ~", condition_col)),
        p.adjust.method = "BH"
      )

      write.csv(pairwise_shannon, file.path(output_dir, paste0("pairwise_wilcoxon_shannon_", analysis_label, ".csv")), row.names = FALSE)
      write.csv(pairwise_simpson, file.path(output_dir, paste0("pairwise_wilcoxon_simpson_", analysis_label, ".csv")), row.names = FALSE)
    }
  }

  rownames(norm_abundance) <- sample_id_values
  bray_dist <- vegdist(norm_abundance, method = "bray")
  bray_matrix <- as.matrix(bray_dist)
  write.csv(bray_matrix, file.path(output_dir, paste0("bray_curtis_distance_matrix_", analysis_label, ".csv")))

  pcoa_obj <- cmdscale(bray_dist, k = 2, eig = TRUE, add = TRUE)
  pcoa_points <- as.data.frame(pcoa_obj$points)
  colnames(pcoa_points) <- c("PCoA1", "PCoA2")
  pcoa_points$SampleID <- rownames(pcoa_obj$points)

  pcoa_plot_df <- pcoa_points %>%
    left_join(metadata_df, by = setNames(sample_id_col, "SampleID"))

  eig <- pcoa_obj$eig
  positive_eig <- eig[eig > 0]
  pcoa1_percent <- round(100 * positive_eig[1] / sum(positive_eig), 1)
  pcoa2_percent <- round(100 * positive_eig[2] / sum(positive_eig), 1)

  if (!is.na(batch_col) && batch_col %in% names(pcoa_plot_df)) {
    pcoa_plot <- ggplot(
      pcoa_plot_df,
      aes_string(x = "PCoA1", y = "PCoA2", color = condition_col, shape = batch_col)
    ) +
      geom_point(size = 3, alpha = 0.9)
  } else {
    pcoa_plot <- ggplot(
      pcoa_plot_df,
      aes_string(x = "PCoA1", y = "PCoA2", color = condition_col)
    ) +
      geom_point(size = 3, alpha = 0.9)
  }

  pcoa_plot <- pcoa_plot +
    theme_minimal(base_size = 13) +
    theme(panel.grid.minor = element_blank()) +
    labs(
      title = paste("PCoA Bray-Curtis -", group_name, "-", analysis_label),
      x = paste0("PCoA1 (", pcoa1_percent, "%)"),
      y = paste0("PCoA2 (", pcoa2_percent, "%)"),
      color = condition_col
    )

  save_plot(pcoa_plot, file.path(output_dir, paste0("pcoa_bray_curtis_", analysis_label, ".png")))
  write.csv(pcoa_plot_df, file.path(output_dir, paste0("pcoa_coordinates_", analysis_label, ".csv")), row.names = FALSE)

  condition_formula <- as.formula(paste("bray_dist ~", condition_col))
  permanova_condition_only <- adonis2(condition_formula, data = metadata_df, permutations = 999)
  write.csv(
    as.data.frame(permanova_condition_only),
    file.path(output_dir, paste0("permanova_condition_only_", analysis_label, ".csv"))
  )

  if (!is.na(batch_col) && batch_col %in% names(metadata_df)) {
    batch_formula <- as.formula(paste("bray_dist ~", batch_col))
    combined_formula <- as.formula(paste("bray_dist ~", condition_col, "+", batch_col))

    permanova_batch_only <- adonis2(batch_formula, data = metadata_df, permutations = 999)
    permanova_condition_plus_batch <- adonis2(combined_formula, data = metadata_df, permutations = 999)

    write.csv(
      as.data.frame(permanova_batch_only),
      file.path(output_dir, paste0("permanova_batch_only_", analysis_label, ".csv"))
    )

    write.csv(
      as.data.frame(permanova_condition_plus_batch),
      file.path(output_dir, paste0("permanova_condition_plus_batch_", analysis_label, ".csv"))
    )
  }
}


# ============================================================
# MAIN ANALYSIS FUNCTION
# ============================================================
run_group_analysis <- function(config) {
  cat("\n============================================================\n")
  cat("Running:", config$group_name, "\n")
  cat("============================================================\n")

  data_df <- read_input_file(config$file_path)
  safe_dir_create(config$output_dir)

  required_cols <- unique(c(
    config$sample_id_col,
    config$condition_col,
    config$batch_col,
    config$metadata_cols
  ))
  required_cols <- required_cols[!is.na(required_cols)]

  missing_cols <- setdiff(required_cols, names(data_df))
  if (length(missing_cols) > 0) {
    stop(
      paste(
        "Missing required columns in", config$group_name, ":",
        paste(missing_cols, collapse = ", ")
      )
    )
  }

  metadata_cols_present <- intersect(config$metadata_cols, names(data_df))
  metadata_df <- data_df %>% select(all_of(metadata_cols_present))

  feature_cols <- setdiff(names(data_df), metadata_cols_present)
  if (length(feature_cols) == 0) {
    stop(paste("No abundance columns detected in", config$group_name))
  }

  abundance_df <- data_df %>% select(all_of(feature_cols))

  cleaned <- clean_abundance_matrix(abundance_df)
  abundance_clean <- cleaned$raw_abundance
  norm_abundance <- cleaned$normalized_abundance

  sample_id_values <- metadata_df[[config$sample_id_col]]

  write.csv(metadata_df, file.path(config$output_dir, "metadata_used.csv"), row.names = FALSE)
  write.csv(abundance_clean, file.path(config$output_dir, "abundance_clean.csv"), row.names = FALSE)
  write.csv(norm_abundance, file.path(config$output_dir, "abundance_normalized.csv"), row.names = FALSE)
  run_single_condition_analysis(
    metadata_df = metadata_df,
    norm_abundance = norm_abundance,
    sample_id_values = sample_id_values,
    sample_id_col = config$sample_id_col,
    condition_col = config$condition_col,
    batch_col = config$batch_col,
    output_dir = config$output_dir,
    analysis_label = "main_condition",
    group_name = config$group_name
  )

  if (!is.na(config$secondary_condition_col) && config$secondary_condition_col %in% names(metadata_df)) {
    run_single_condition_analysis(
      metadata_df = metadata_df,
      norm_abundance = norm_abundance,
      sample_id_values = sample_id_values,
      sample_id_col = config$sample_id_col,
      condition_col = config$secondary_condition_col,
      batch_col = config$batch_col,
      output_dir = file.path(config$output_dir, "secondary_size_analysis"),
      analysis_label = "secondary_size",
      group_name = config$group_name
    )
  }

  cat("Finished:", config$group_name, "\n")
}


# ============================================================
# RUN THE ANALYSIS
# ============================================================
# Default behavior:
# - Runs all 4 groups in order.
#
# If you want to run only one group, replace the loop with:
# run_group_analysis(group_configs[[2]])
# for example.

for (cfg in group_configs) {
  run_group_analysis(cfg)
}


# ============================================================
# IMPORTANT NOTES
# ============================================================
# 1. Keep the 4 groups as separate runs.
# 2. Use accession number as the batch variable only where needed.
# 3. For the merged 3-study group, the main PERMANOVA result to report is:
#    permanova_condition_plus_batch.csv
# 4. Groups 2 and 3 can also run a secondary PSNP size analysis if
#    secondary_condition_col is set correctly.
# 5. If a result in the merged group looks important, you can then run
#    each study separately as a follow-up sensitivity check.
# ============================================================
