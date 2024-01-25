# -*- coding: utf-8 -*-
"""
Created on Thu Jan  4 12:04:44 2024

@author: Gustav
"""

import pandas as pd
import matplotlib.pyplot as plt

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from scipy.stats import norm


flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\data\EV\Flexibility\Upwards_flexibilities.csv")
flex = flex.iloc[::1440, :]
# Define parameters for the dummy data
num_points = 365  # number of y-values for each x
num_x_values = 140  # adjusted number of x-values
x_values = np.arange(10, 1410, 10)  # x-values from 10 to 1400 in steps of 10

# Generate dummy data for y-values
np.random.seed(0)  # for reproducibility
data = flex.iloc[:, :]

# Compute the cumulative distribution function for each x-value
sorted_data = np.sort(data.iloc[:,:], axis=0)
cdf_values = np.cumsum(sorted_data, axis=0) / sorted_data.sum(axis=0)


# Plotting
plt.figure(figsize=(12, 8))

# Create the color gradient for the plot
colors = plt.cm.viridis(np.linspace(0, 1, num_x_values))

# For each x-value, plot a vertical line where the color intensity represents the CDF value
for i, x in enumerate(x_values):
    y = sorted_data[:, i]
    cdf = cdf_values[:, i]
    color = colors[i % num_x_values]
    print(len([x]*num_points))
    print(len(y))
    print(len(cdf))
    plt.scatter([x]*num_points, y, c=cdf, cmap='viridis', vmin=0, vmax=1)

# Add the mean line
mean_values = flex.mean(axis=0)
plt.plot(x_values, mean_values[0:140], color='red', label='Mean')

# Customizing the plot
plt.title('Data Plot with Cumulative Distribution Function Mapped to Y Axis')
plt.xlabel('X Value (10 to 1400 in steps of 10)')
plt.ylabel('Y Value')
plt.xticks(np.arange(10, 1410, 10))  # Set x-axis ticks in steps of 10
plt.grid(True)
plt.colorbar(label='CDF Value')
plt.legend()

# Show the plot
plt.show()