# Install and load the required packages

library(ggridges)
library(ggplot2)
library(viridis)
library(tidyr)

res <- 8

# Load your data
# Replace 'your_data.csv' with the actual file path to your CSV data
data <- read.csv("C:\\Users\\Gustav\\Documents\\Kandidat\\sampling.csv")
data <- data[421:425]
data2 <- read.csv("C:\\Users\\Gustav\\Documents\\Kandidat\\bundle_energy_up.csv")
data <- data2

names(data) <- c(1:res)
names(data) <- c(20, 50, 100, 140, 200, 350, 700, 1400)
# Reshape the data from wide to long format
data_long <- gather(data, Minute, Flexibility, 1:res)

# Reorder the levels of the "Hour" factor
data_long$Minute <- factor(data_long$Minute, levels = c("20", "50", "100", "140", "200", "350", "700", "1400"))


x_axis_range <- c(0, 0.5)
plot <- ggplot(data_long, aes(x = Flexibility, y = Minute, fill = stat(x))) +
  geom_density_ridges_gradient(scale = 3, size = 0.3, rel_min_height = 0.01) +
  scale_fill_viridis_c(name = "KW", option = "C") +
  #labs(title = 'Downwards flexiblity distribution for individual minutes between 7 and 8 AM (500 CBs)') +
  xlim(x_axis_range) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.background = element_blank(), # Make background transparent
    axis.line = element_line(color = "black"),
    panel.border = element_blank(), # Remove panel border
    strip.background = element_blank() # Remove background from strip labels if present
  ) +
  theme(axis.ticks.y = element_line(color = "black")) # Add ticks for the y-axis


plot <- ggplot(data_long, aes(x = Flexibility, y = Minute, fill = stat(x))) +
  geom_density_ridges_gradient(scale = 3, size = 0.3, rel_min_height = 0.01) +
  scale_fill_viridis_c(name = "kW", option = "C") +
  labs(
    #title = 'Downwards Flexibility Distribution for Individual Minutes',
    #subtitle = 'Between 7 and 8 AM (500 CBs)',
    x = 'Downwards flexibility per CB in portfolio [kW]',
    y = 'Number of CBs in portfolio ',
    fill = 'Gradient Scale'
  ) +
  xlim(x_axis_range) +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "grey", size = 0.2),
    panel.grid.minor.y = element_blank(),
    axis.line = element_line(color = "black"),
    plot.title = element_text(size = 20),
    plot.subtitle = element_text(size = 16),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    axis.line = element_line(color = "black"),
    panel.border = element_blank(), # Remove panel border
  )
  
ggsave("C:\\Users\\Gustav\\Documents\\Thesis\\Git\\3. Simulations\\Plots\\To overleaf\\500_down_2t.png", plot, width = 8, height = 6, units = "in")

