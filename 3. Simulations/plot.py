# -*- coding: utf-8 -*-
"""
Created on Wed Sep 20 09:15:48 2023

@author: Gustav
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Load your data
data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Up_bids_I.csv", header="infer")

# Convert the data to a NumPy array
data_np = data.to_numpy()

# Get the data for each series using column indices
y_values = [data_np[:, i] for i in range(data_np.shape[1])]

# Generate x values representing the 1440 data points
x = np.arange(1440)

# Calculate the total value for each data point
total = np.sum(data_np, axis=1)

# Create a stacked bar plot
bottom = np.zeros(1440)
for i, y in enumerate(y_values):
    print(f"Shape of y_values[{i}]: {y.shape}, Shape of bottom: {bottom.shape}")  # Add this to debug
    plt.bar(x, y, bottom=bottom, label=f'Data {i+1}')
    bottom += y

# Add a black line indicating the total
plt.plot(x, total, color='black', label='Total')

# Customize the plot
plt.xlabel('Time Points (in minutes)')
plt.ylabel('Value')
plt.title('Stacked Bar Plot for 1440 Minutes')
plt.legend(loc='upper left', bbox_to_anchor=(1, 1))

# Display the plot
plt.show()
