# -*- coding: utf-8 -*-
"""
Created on Tue Nov 14 11:23:55 2023

@author: Gustav
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Assuming df1 is your DataFrame
df1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\test 1 (sampling og metode)\CVaR VS ALSO-X VS sampling generel results.csv")

Overibid = df1.iloc[:, 5] * 100
Do_flexibility = df1.iloc[:, 12] * 100

overbid_m = np.zeros(6)
Do_flexibility_m = np.zeros(6)

for j in range(6):
    overbid_m[j] = np.mean(Overibid[j * 3:(j + 1) * 3])
    Do_flexibility_m[j] = np.mean(Do_flexibility[j * 3:(j + 1) * 3])

x_sampling = ["Random hourly", "Random minute", "Correlated minute", "Random hourly", "Random minute", "Correlated minute"]
x_method = ["CVaR", "CVaR", "CVaR", "ALSO-X", "ALSO-X", "ALSO-X"]

# Create a DataFrame for plotting
plot_data = pd.DataFrame({
    'x_sampling': x_sampling,
    'x_method': x_method,
    'OB': overbid_m
})

# Set up the color map for different methods
colors = {'CVaR': 'blue', 'ALSO-X': 'orange'}
plot_data['color'] = plot_data['x_method'].map(colors)

# Create a scatter plot
scatter = plt.scatter(plot_data['x_sampling'], plot_data['OB'], c=plot_data['color'], s=100, alpha=0.7)

# Customize the plot
plt.xlabel('Sampling method')
plt.ylabel("Frequency of overbid %")

# Add legend manually
legend_labels = ['CVaR', 'ALSO-X']
legend_handles = [plt.Line2D([0], [0], marker='o', color='w', markerfacecolor=colors[method], markersize=10) for method in legend_labels]
plt.legend(legend_handles, legend_labels, loc='center')

# Show the plot
plt.show()
