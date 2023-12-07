# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 14:15:35 2023

@author: Gustav
"""

import matplotlib.pyplot as plt

# Example data
x_values = [1, 2, 4, 7]
y_values_1 = [10, 20, 30, 40]  # Example y-values for the first plot

# Example lists of y-values for the second plot (boxplots)
y_values_2 = [[5, 7, 8], [10, 12, 14], [20, 22, 24], [30, 33, 36]]  # Replace with your actual data

# Convert x_values to strings for labels
x_labels = [str(x) for x in x_values]

# Create two vertically stacked plots with different heights
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True, gridspec_kw={'height_ratios': [3, 1]})

# Plot data on the first subplot using a range of integers for x-values
ax1.plot(range(len(x_values)), y_values_1, marker='o')
ax1.set_ylabel('Y-axis for Plot 1')

# Create boxplots on the second subplot
ax2.boxplot(y_values_2, positions=range(len(x_values)))
ax2.set_ylabel('Y-axis for Plot 2')

# Set y-axis range for the bottom plot
ax2.set_ylim([0, 50])  # Adjust these values as needed

# Add two horizontal lines
ax2.axhline(y=15, color='red', linestyle='--', label='Line at y=15')
ax2.axhline(y=35, color='green', linestyle='-', label='Line at y=35')

# Set the x-axis label only on the bottom subplot
ax2.set_xlabel('Shared X-axis')

# Set the x-axis ticks to be equally spaced and use string labels
ax1.set_xticks(range(len(x_values)))
ax1.set_xticklabels(x_labels)
ax2.set_xticks(range(len(x_values)))
ax2.set_xticklabels(x_labels)

# Add a legend to the second plot in the upper left corner
ax2.legend(loc='upper left')

# Adjust layout
plt.tight_layout()

# Show the plot
plt.show()
