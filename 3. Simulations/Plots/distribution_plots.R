# Install and load the required packages

library(ggridges)
library(ggplot2)
library(viridis)
library(tidyr)

# Load your data
# Replace 'your_data.csv' with the actual file path to your CSV data
data <- read.csv("C:\\Users\\Gustav\\Documents\\Kandidat\\tester.csv")

names(data) <- c(1:24)
# Reshape the data from wide to long format
data_long <- gather(data, Hour, Flexibility, 1:24)

# Reorder the levels of the "Hour" factor
data_long$Hour <- factor(data_long$Hour, levels = as.character(1:24))

x_axis_range <- c(0, 1000)
plot <- ggplot(data_long, aes(x = Flexibility, y = Hour, fill = stat(x))) +
  geom_density_ridges_gradient(scale = 3, size = 0.3, rel_min_height = 0.01) +
  scale_fill_viridis_c(name = "KW" ,option = "C") +
  labs(title = 'Energy flexiblity distribution for individual hours (50 CBs)') +
  xlim(x_axis_range)

ggsave("C:\\Users\\Gustav\\Documents\\Thesis\\Git\\3. Simulations\\Plots\\To overleaf\\50_E.png", plot, width = 8, height = 6, units = "in")
