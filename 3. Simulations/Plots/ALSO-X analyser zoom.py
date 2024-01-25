# -*- coding: utf-8 -*-
"""
Created on Tue Dec 19 17:30:44 2023

@author: Gustav
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# Replace this with your actual file reading code
flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\ALSO_analyzer.csv")

# Extracting rows as arrays
y1 = flex.iloc[0,:].to_numpy()  # Extracts the first row
y2 = flex.iloc[1,:].to_numpy()  # Extracts the second row
y3 = flex.iloc[2,:].to_numpy()  # Extracts the third row
y4 = flex.iloc[3,:].to_numpy()  # Extracts the fourth row

# Sample data for x-axis
x = np.linspace(1, 31, 31)

fig, ax1 = plt.subplots(figsize=(10, 6))  # You can adjust the size (width, height) as needed

# Create a figure and a set of subplots for the zoomed-in plot
fig, ax1 = plt.subplots()

# First y-axis (ax1)
ax1.plot(x, y2, 'olivedrab', label='q')
ax1.plot(x, y3, 'gold', label='q̲')
ax1.plot(x, y4, 'firebrick', label='q̅')
ax1.set_xlabel('Iteration')
ax1.set_ylabel('Overbid allowance')
ax1.tick_params('y')

# Second y-axis (ax2)
ax2 = ax1.twinx()
ax2.plot(x, y1*100, color="darkmagenta", label='Overbid')
ax2.set_ylabel('Frequency of overbid (%)', color='darkmagenta')
ax2.tick_params('y', colors='darkmagenta')

# Adding a horizontal line at y=10 on the second y-axis
ax2.axhline(y=10, color='plum', linestyle='--')

# Adding vertical grid lines with transparency
ax1.grid(which='major', axis='x', linestyle='-', color='grey', alpha=0.5)

# Setting the x-axis limits for zoom (x=10 to x=30)
ax1.set_xlim(9.5, 20)
ax2.set_xlim(9.5, 20)
ax1.set_ylim(0, 5)
ax2.set_ylim(0, 20)
# Adding a title
plt.suptitle("ALSO-X operation for 500 CB portfolio with 202 Samples")
# Legend
ax1.legend(loc='upper center')
ax2.legend(loc='upper right')

# Show the plot
plt.show()
