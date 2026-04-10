install.packages("readxl")
install.packages("dplyr")
library(readxl)
library(dplyr)
microbiome.data <- read_excel("Microbiome_MNP_Exposure.xlsx")
microbiome.data

meta.info <- c("SampleID","Dose","Cage","Timepoint")

meta.data <- microbiome.data %>% select(all_of(meta.info))
abundance.mat <- microbiome.data %>% select(-all_of(meta.info))

print(meta.data)
print(abundance.mat)

write.csv(meta.data, "metadata.csv", row.names = FALSE)
write.csv(abundance.mat, "abundance.csv", row.names = FALSE)

# missing value: for the pseudocount, first I want to find the lowest non-zero value in the abundace matrix and divide it by 5.

min.value <- min(abundance.mat[abundance.mat > 0], na.rm = TRUE)
print(min.value)

pseudocount <- min.value/5
print(pseudocount)

abundance.mat[is.na(abundance.mat)] <- 0
abundance.mat <- abundance.mat %>%
  mutate(across(where(is.numeric), ~ ifelse(. == 0, pseudocount, .)))
summary(as.vector(as.matrix(abundance.mat)))
sum(abundance.mat == pseudocount)
summary(meta.data)

#normalization

row_totals <- rowSums(abundance.mat, na.rm = TRUE)
print(row_totals)

norm_abundane.mat <- abundance.mat / row_totals

write.csv(norm_abundane.mat, "normabundance.csv", row.names = FALSE)
print(norm_abundane.mat)

cat("\nRow sums after normalization (min/max): ",
    min(rowSums(norm_abundane.mat)), "/",
    max(rowSums(norm_abundane.mat)), "\n", sep = "")

cat("Missing values in normalized matrix: ", sum(is.na(norm_abundane.mat)), "\n", sep = "")

#summary
group_cols <- intersect(names(meta.data), c("Dose","Cage","Timepoint"))
grouping_summary <- meta.data %>%
  group_by(across(all_of(meta.info))) %>%
  summarise(n_samples = n(), .groups = "drop") %>%
  arrange(desc(n_samples))
print(grouping_summary)

# Alpha and beta diversity 

install.packages("vegan")
library(vegan)
#first, i add sample ID to the normalized abundance data, it helps me to track my samples
norm_abundane.mat <- bind_cols(SampleID = meta.data$SampleID, norm_abundane.mat)
print(norm_abundane.mat)

# I want to remove sampleID for diversity analysis
norm_abundance <- norm_abundane.mat %>%
  select(-SampleID) %>%
  mutate(across(everything(), as.numeric))

shannon.index <- diversity(norm_abundance, index = "shannon")
simpson.index <- diversity(norm_abundance, index = "simpson")

Alpha.diversity <- tibble(
  SampleID = norm_abundane.mat$SampleID,
  Shannon = shannon.index,
  Simpson = simpson.index
)

print(Alpha.diversity)


meta.alpha <- Alpha.diversity %>%
  left_join(meta.data, by = "SampleID")


write.csv(Alpha.diversity, "alphadiversity.csv")
write.csv(meta.alpha, "metaalpha.csv")

library(ggplot2)
table(meta.alpha$Dose)

#boxplot diversity
ggplot(meta.alpha, aes(x = Dose, y = Shannon, fill = Dose)) +
  geom_boxplot(outlier.shape = 16, outlier.alpha = 0.5) +
  geom_jitter(width = 0.2, alpha = 0.7) +
  labs(title = "Shannon Diversity by MNP Dose Group",
       x = "MNP Dose",
       y = "Shannon Diversity Index") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

ggplot(meta.alpha, aes(x = Dose, y = Simpson, fill = Dose)) +
  geom_boxplot(outlier.shape = 16, outlier.alpha = 0.5) +
  geom_jitter(width = 0.2, alpha = 0.7) +
  labs(title = "Simpson Diversity by MNP Dose Group",
       x = "MNP Dose",
       y = "Simspson Diversity Index") +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

#statistic tests
install.packages("rstatix")
library(rstatix)

kw_shannon <- kruskal.test(Shannon ~ Dose, data = meta.alpha)
kw_shannon

# For Simpson
kw_simpson <- kruskal.test(Simpson ~ Dose, data = meta.alpha)
kw_simpson

wlcoxon_simpson <- pairwise_wilcox_test(meta.alpha, Simpson ~ Dose, p.adjust.method = "BH")
wlcoxon_simpson
write.csv(wlcoxon_simpson,"Wilcoxon_Simpson.csv", row.names = FALSE)



rownames(norm_abundance) <- meta.data$SampleID
bray_curtistest <- vegdist(norm_abundance, method = "bray")

print(bray_curtistest)

bray.mat <- as.matrix(bray_curtistest)
write.csv(bray.mat, "BrayCurtis_Dissimilarity.csv")

bray <- as.dist(bray.mat)

PCOAtest <- cmdscale(bray, k=2, eig = TRUE, add = TRUE)
print(PCOAtest)

pcoaresult <- as.data.frame(PCOAtest$points)
colnames(pcoaresult) <- c("PCoA1","PCoA2")
pcoaresult$SampleID <- rownames(PCOAtest$points)

PCOA.plot <- pcoaresult %>%
  left_join(meta.data %>% select(SampleID, Dose, Cage, Timepoint), by = "SampleID")

eig <- PCOAtest$eig
PCoA1_percent <- round(100 * eig[1] / sum(eig[eig > 0]), 1)
PCoA2_percent <- round(100 * eig[2] / sum(eig[eig > 0]), 1)
PCoA1_percent
PCoA2_percent

dose_cols <- c("Control"="#6BAED6","LowDose"="#74C476","HighDose"="#FD8D3C")
plot.one <- ggplot(PCOA.plot, aes(PCoA1, PCoA2, color = Dose, shape = factor(Cage))) +
  geom_point(size = 3, alpha = 0.9) +
  scale_color_manual(values = dose_cols) +
  theme_minimal(base_size = 13) +
  labs(
    title = "PCoA (Bray–Curtis): Colored by Dose, Shaped by Cage",
    x = paste0("PCoA1 (", PCoA1_percent, "%)"),
    y = paste0("PCoA2 (", PCoA2_percent, "%)")
  ) +
  theme(legend.position = "right", panel.grid.minor = element_blank())
plot.one
install.packages("stringr")
library(stringr)
ggplot(PCOA.plot, aes( PCoA1, PCoA2, color= Dose, shape = Timepoint)) +
  geom_point(size = 3, alpha = 0.9) +
  scale_color_manual(values = dose_cols) +
  theme_minimal(base_size = 13) +
  labs(
    title = "PCoA (Bray–Curtis): Colored by Dose, Shaped by timeponit",
    x = paste0("PCoA1 (", PCoA1_percent, "%)"),
    y = paste0("PCoA2 (", PCoA2_percent, "%)")
  ) + facet_wrap(~ Cage) + 
  theme(legend.position = "right", panel.grid.minor = element_blank())




per_dose <- adonis2(bray ~ Dose, data = meta.data, permutations = 999)
print(per_dose)
write.csv(per_dose, "perdose.csv")


per_double <- adonis2(bray ~ Dose + Cage, data = meta.data, permutations = 999)
print(per_double)

# Check if Cage itself is significant
per_cage <- adonis2(bray ~ Cage, data = meta.data, permutations = 999)
print(per_cage)
write.csv(per_cage, "percage.csv")



ggplot(PCOA.plot, aes(PCoA1, PCoA2, color = Dose, shape = Cage)) +
  geom_point(size = 3, alpha = 0.9) +
  stat_ellipse(aes(group = Cage, color = Cage), linetype = 2) +
  scale_color_manual(values = c("Control"="#6BAED6","LowDose"="#74C476","HighDose"="#FD8D3C")) +
  theme_minimal(base_size = 13) +
  labs(
    title = "PCoA (Bray–Curtis): Cages outlined by 68% ellipses",
    x = paste0("PCoA1 (", round(PCoA1_percent,1), "%)"),
    y = paste0("PCoA2 (", round(PCoA2_percent,1), "%)")
  )


ggplot(PCOA.plot, aes(PCoA1, PCoA2, color = Dose, shape = factor(Cage))) +
  geom_point(size = 3, alpha = 0.9) +
  stat_ellipse(aes(group = Dose, color = Dose), linewidth = 0.8, level = 0.68) +
  scale_color_manual(values = c("Control"="#6BAED6", "LowDose"="#74C476", "HighDose"="#FD8D3C")) +
  theme_minimal(base_size = 13) +
  labs(
    title = "PCoA (Bray–Curtis): Dose-colored points and ellipses",
    x = paste0("PCoA1 (", round(PCoA1_percent, 1), "%)"),
    y = paste0("PCoA2 (", round(PCoA2_percent, 1), "%)")
  ) +
  theme(legend.position = "right")




ggplot(PCOA.plot, aes(PCoA1, PCoA2, color = Dose, shape = factor(Cage))) +
  geom_point(size = 3, alpha = 0.9) +
  stat_ellipse(aes(group = Dose, color = Dose), linewidth = 0.8, level = 0.68) +
  scale_color_manual(values = c("Control"="#6BAED6", "LowDose"="#74C476", "HighDose"="#FD8D3C")) +
  facet_wrap(~ Timepoint)
  theme_minimal(base_size = 13) +
  labs(
    title = "PCoA (Bray–Curtis): Dose-colored points and ellipses",
    x = paste0("PCoA1 (", round(PCoA1_percent, 1), "%)"),
    y = paste0("PCoA2 (", round(PCoA2_percent, 1), "%)")
  ) +
  theme(legend.position = "right")


