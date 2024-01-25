# -*- coding: utf-8 -*-
"""
Created on Thu Jan  4 14:47:22 2024

@author: Gustav
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.colors import LinearSegmentedColormap
plt.rcParams.update({'font.size': 20})  # You can adjust the size as needed


# Assuming 'flex' is a pandas DataFrame loaded from your CSV file
# Replace the following line with your actual file reading code
flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\data\EV\Flexibility\upwards_flexibilities.csv")
flex = flex.iloc[1+1440:1440+365, :]

# Load and process your line data
line1_y_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\Downwards_bids_N_bundles_4_1.csv")  # Replace with an array of 1440 y-values for line 1
line2_y_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Downwards_bids_N_bundles_LER_1.csv")
line1_y_values = np.mean(line1_y_data, axis=1)
line2_y_values = np.mean(line2_y_data, axis=1)

# Load your KDE data
your_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\data\EV\Flexibility\Downwards_flexibilities.csv")
your_data = your_data.iloc[:, 139]
# Create a list containing 1440 empty lists
data_1400 = [[] for _ in range(1440)]
counter = -1
for j in range(525600):
    counter = counter + 1
    print(counter)
    data_1400[counter].append(your_data[j])
    if counter == 1439:
        counter = -1


# Define parameters for the dummy data
num_points = 365  # number of y-values for each x
num_x_values = 1440  # number of distinct x-values
x_values = np.arange(1, 1441, 1)  # x-values from 10 to 1400 in steps of 10

# Generate dummy data for y-values
np.random.seed(0)  # for reproducibility
data = flex
# Compute the cumulative distribution function for each x-value individually
cdf_values = np.array([np.cumsum(np.sort(data_1400[i])) / np.sum(np.sort(data_1400[i])) for i in range(num_x_values)]).T

# Get global max value across all x for plotting
global_max_y = np.max(data_1400)

# Create meshgrid for the x and y values for plotting
X, Y = np.meshgrid(x_values, np.linspace(0, global_max_y, num_points))

# Prepare Z values for color mapping, based on individual CDFs per x
Z = np.array([np.interp(np.linspace(0, global_max_y, num_points), np.sort(data_1400[i]), cdf_values[:, i]) for i in range(num_x_values)]).T

# Define the colors
start_color = 'white'  # Color at the beginning
inbtween = "red"
mid_color = 'gainsboro'    # Distinct color between 5% and 15%
end_color = 'teal'     # Color at the end

# Create a color list [(position, color), ...]
colors = [(0, start_color), (0.095, 'red'), (0.105, mid_color), (0.6, end_color), (1, 'black')]

# Create the colormap
cmap_name = 'custom_cmap'
custom_cmap = LinearSegmentedColormap.from_list(cmap_name, colors)

# Plotting
plt.figure(figsize=(16, 8))

# Use pcolormesh to create a continuous color plot, note the change in the Y scaling
#color_mapping = plt.cm.custom_cmap  
#plt.pcolormesh(X, Y, Z, shading='auto', cmap=color_mapping, alpha=0.85)

plt.xlim([1,1440])
custom_cmap = LinearSegmentedColormap.from_list('custom_cmap', colors)

# Now use the custom colormap in your plotting function
# Make sure your X, Y, Z data is defined before this
plt.pcolormesh(X, Y, Z, shading='auto', cmap=custom_cmap, alpha=0.85)

# Add the mean line for each x-value
mean_values = flex.mean(axis=0)
plt.plot(x_values, line2_y_values, color="Navy", label='Without LER req.', linewidth=4.7)
plt.plot(x_values, line1_y_values, color="Darkgreen", label='With LER req.', linewidth=4.7)

x_values = np.arange(0, 1440, 1)  # x-values from 10 to 1400 in steps of 10

hours = (x_values / 60).astype(int)  # Convert minutes to hours
minutes = x_values % 60
time_labels = [f"{h:02d}:{m:02d}" for h, m in zip(hours, minutes)]

# Now set the x-ticks and x-tick labels
plt.xticks(ticks=x_values[::180], labels=time_labels[::180])  # Every 12th label for every other hour

x_values = np.append(x_values, 1439)  # Add the last minute of the day
time_labels.append("23:59")   # Add the label for the last minute of the day

# Set the x-ticks and x-tick labels
plt.xticks(ticks=x_values[::180], labels=time_labels[::180])  # Every 180th label for every 3 hours

# Rotate the tick labels to be diagonal
plt.xticks(rotation=25)  # Rotate the labels diagonally

# Customizing the plot
#plt.title('Data Plot with Cumulative Distribution Function Mapped to Y Axis')
plt.xlabel('Minute of day')
plt.ylabel('Downwards flexibility [kW]')
plt.grid(False)
cbar = plt.colorbar(label='CDF')
cbar.set_ticks(np.arange(0, 1.1, 0.1))
plt.legend()

# Show the plot
plt.show()  # Uncomment to display the plot when running the script
