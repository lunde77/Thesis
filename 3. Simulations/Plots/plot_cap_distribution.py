# -*- coding: utf-8 -*-
"""
Created on Wed Sep 20 09:15:48 2023

@author: Gustav
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

h = 3 # hours to plot

# Load your data
data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Up_bids_I.csv", header="infer")

# Convert the data to a NumPy array
data_np = data.to_numpy()

# Get the data for each series using column indices
y_values = [data_np[0:60*h, i] for i in range(data_np.shape[1])]

# Generate x values representing the 1440 data points
x = np.arange(60*h)



# Create a stacked bar plot
bottom = np.zeros(60*h)
for i, y in enumerate(y_values):
    print(f"Shape of y_values[{i}]: {y.shape}, Shape of bottom: {bottom.shape}")  # Add this to debug
    if sum(y) >= 0.1:
        plt.bar(x, y, bottom=bottom, label=f'CB {i+1}')
        bottom += y
    
    
total = np.sum(data_np, axis=1)
plt.plot(x, total[0:60*h], color='black', label='Total')

# Add vertical dashed lines and shaded region
x1, x2, x3, x4 = 0, 60, 120, 180  # Specify the x positions of the lines
plt.axvline(x=x1, color='gray', linestyle='--', label='New Hour')
plt.axvline(x=x2, color='gray', linestyle='--')
plt.axvline(x=x3, color='gray', linestyle='--')
plt.axvline(x=x4, color='gray', linestyle='--')
# Customize the plot
plt.xlabel('Time (minutes)')
plt.ylabel('Capacity bid from each CB')
plt.title('Distribution of upwards bid')
plt.ylim((0,35))
plt.legend(loc='upper center', bbox_to_anchor=(0.5, -0.15), ncol=4)

plt.savefig(r"C:\Users\Gustav\Documents\Thesis\Git\4. Tests\Plots\Deterministic d1\Upwards_Bid_Distribution.png", bbox_inches='tight')



# Display the plot
plt.show()
