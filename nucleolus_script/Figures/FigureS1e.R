library(ggplot2)

# Read data
data <- read.table("shMETTL3-shGTP_polysome/monosome_data.txt", header = TRUE)

# Apply log2 transformation to data
data <- log2(data)

# Prepare data for plotting
library(reshape2)
melted_data <- melt(data)

# Perform Kolmogorov-Smirnov test for significance
ks_test <- ks.test(data$shGFP, data$shMETTL3)
print(ks_test)

# Create cumulative distribution plot
p <- ggplot(melted_data, aes(x = value, color = variable)) +
  stat_ecdf(geom = "step",size = 1) +
  scale_color_manual(values = c("black", "red")) +
  labs(
    x = "Log2(polysome/monosome)",
    y = "Percentage",
    color = "Condition"
  ) +
  theme_minimal(base_size = 14)+
  theme(''
        legend.position = "top",
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.title.x = element_text(hjust = 0.5),
        axis.title.y = element_text(hjust = 0.5)
  )#+
#annotate("text", x = -2, y = 0.9, label = "K-S test\np-value < 2.2e-16", color = "black", size = 5)


# Print the plot
print(p)

# Save the plot as a PDF
pdf("cumulative_distribution_plot.pdf", width = 5, height = 5)
print(p)
dev.off()
