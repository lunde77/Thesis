# -*- coding: utf-8 -*-
"""
Created on Tue Dec 19 10:06:27 2023

@author: Gustav
"""
import matplotlib.pyplot as plt
import numpy as np


import pandas as pd
import matplotlib.pyplot as plt

# Replace this with your actual file reading code
flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\ALSO_analyzer.csv")

y1 = flex.iloc[0,:]  # Extracts the second ro
y1 = y1.to_numpy()

y2 = flex.iloc[1,:]  # Extracts the second ro
y2 = y2.to_numpy()

y3 = flex.iloc[2,:]  # Extracts the second ro
y3 = y3.to_numpy()

y4 = flex.iloc[3,:]  # Extracts the second ro
y4 = y4.to_numpy()

# Sample data
x = np.linspace(1, 31, 31)

fig, ax1 = plt.subplots(figsize=(10, 6))  # You can adjust the size (width, height) as needed

# Create a figure and a set of subplots
fig, ax1 = plt.subplots()

# First y-axis (ax1)
ax1.plot(x, y2, 'olivedrab', label='q')
ax1.plot(x, y3, 'gold', label='q̲ ')
ax1.plot(x, y4, 'firebrick', label='q̅')
ax1.set_xlabel('Intteration')
ax1.set_ylabel('Overbid allowance')
ax1.tick_params('y')

# Second y-axis (ax2)
ax2 = ax1.twinx()
ax2.plot(x, y1*100, 'm-', label='Overbid', color= "darkmagenta")
ax2.set_ylabel('Frequency of overbid (%)', color='darkmagenta')
ax2.tick_params('y', colors='darkmagenta')

# Adding a horizontal line at y=10 on the second y-axis
ax2.axhline(y=10, color='plum', linestyle='--')

# Adding vertical grid lines with transparency
ax1.grid(which='major', axis='x', linestyle='-', color='grey', alpha=0.5)

plt.suptitle("ALSO-X operation for 500 CB portfolio with 202 Samples")
# Legend
ax1.legend(loc='upper center')
ax2.legend(loc='upper right')
ax1.set_xlim(0, 20)
ax2.set_xlim(0, 20)

# Show the plot
plt.show()
