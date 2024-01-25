# -*- coding: utf-8 -*-
"""
Created on Thu Jan  4 14:47:22 2024

@author: Gustav
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
plt.rcParams.update({'font.size': 20})  # You can adjust the size as needed


# Assuming 'flex' is a pandas DataFrame loaded from your CSV file
# Replace the following line with your actual file reading code
flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\data\EV\Flexibility\Upwards_flexibilities.csv")
#flex = flex.iloc[1+1440:1440+365, :]


# Define parameters for the dummy data
num_points = 365*1440  # number of y-values for each x
num_x_values = 140  # number of distinct x-values
x_values = np.arange(10, 1410, 10)  # x-values from 10 to 1400 in steps of 10

# Generate dummy data for y-values
np.random.seed(0)  # for reproducibility
data = flex
# Compute the cumulative distribution function for each x-value individually
cdf_values = np.array([np.cumsum(np.sort(flex.iloc[:, i])) / np.sum(np.sort(flex.iloc[:, i])) for i in range(num_x_values)]).T

# Get global max value across all x for plotting
global_max_y = np.max(flex.iloc[:,:].values)

# Create meshgrid for the x and y values for plotting
X, Y = np.meshgrid(x_values, np.linspace(0, global_max_y, num_points))

# Prepare Z values for color mapping, based on individual CDFs per x
Z = np.array([np.interp(np.linspace(0, global_max_y, num_points), np.sort(flex.iloc[:, i]), cdf_values[:, i]) for i in range(num_x_values)]).T

# Plotting
plt.figure(figsize=(16, 8))

# Use pcolormesh to create a continuous color plot, note the change in the Y scaling
color_mapping = plt.cm.inferno_r 
plt.pcolormesh(X, Y, Z, shading='auto', cmap=color_mapping, alpha=0.85)

# Add the mean line for each x-value
mean_values = flex.mean(axis=0)
plt.plot(x_values, mean_values[0:140], color='limegreen', label='Mean', linewidth=4.7)

# Customizing the plot
#plt.title('Data Plot with Cumulative Distribution Function Mapped to Y Axis')
plt.xlabel('Number of CBs in Portfolio')
plt.ylabel('Upwards flexibility [kW]')
plt.xticks(np.arange(0, x_values[-1] + 100, 100))  # Adjust the step as needed
plt.grid(False)
plt.colorbar(plt.cm.ScalarMappable(cmap=color_mapping), label='CDF')
plt.legend()
# Rotate the tick labels to be diagonal
plt.xticks(rotation=20)  # Rotate the labels diagonally


# Show the plot
plt.show()  # Uncomment to display the plot when running the script
