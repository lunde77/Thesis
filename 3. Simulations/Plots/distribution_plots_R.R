# Install and load the required packages

library(ggridges)
library(ggplot2)
library(viridis)
library(tidyr)

res <- 60 

# Load your data
# Replace 'your_data.csv' with the actual file path to your CSV data
data <- read.csv("C:\\Users\\Gustav\\Documents\\Kandidat\\sampling.csv")
data <- data[421:480]

names(data) <- c(1:res)
# Reshape the data from wide to long format
data_long <- gather(data, Minute, Flexibility, 1:res)

# Reorder the levels of the "Hour" factor
data_long$Minute <- factor(data_long$Minute, levels = as.character(1:res))

x_axis_range <- c(0, 1800)
plot <- ggplot(data_long, aes(x = Flexibility, y = Minute, fill = stat(x))) +
  geom_density_ridges_gradient(scale = 3, size = 0.3, rel_min_height = 0.01) +
  scale_fill_viridis_c(name = "KW" ,option = "C") +
  labs(title = 'Downwards flexiblity distribution for individual minutes between 7 and 8 AM (500 CBs)') +
  xlim(x_axis_range)

ggsave("C:\\Users\\Gustav\\Documents\\Thesis\\Git\\3. Simulations\\Plots\\To overleaf\\500_down_2.png", plot, width = 8, height = 6, units = "in")
