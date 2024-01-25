# -*- coding: utf-8 -*-
"""
Created on Mon Dec 11 17:53:20 2023

@author: Gustav
"""
import matplotlib.pyplot as plt

import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression
from brokenaxes import brokenaxes
import seaborn as sns
import matplotlib.pyplot as plt
from scipy.stats import gaussian_kde

plt.rcParams.update({'font.size': 8.5})  # You can adjust the size as needed

# Define the "rocket" color palette from Seaborn
palette = sns.color_palette("rocket", 5)



df1 = pd.read_csv( r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\results_N_CBS_50.csv")
line1_y_values = df1.iloc[0:12,12]*100

df1 = pd.read_csv( r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\results_N_CBS_100.csv")
line2_y_values = df1.iloc[0:12,12]*100

df1 = pd.read_csv( r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\results_N_CBS_250.csv")
line3_y_values = df1.iloc[0:12,12]*100

df1 = pd.read_csv( r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\results_N_CBS_500.csv")
line4_y_values = df1.iloc[0:12,12]*100

df1 = pd.read_csv( r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\results_N_CBS_1400.csv")
line5_y_values = df1.iloc[0:12,12]*100

# Create a figure and an axes
fig, ax = plt.subplots()

# Setting up the X-axis from 0 to 20 in steps of 2
x_values = list(np.arange(0, 21, 2))

# Append 50 and 100 to the x_values list
x_values.extend([50])


# Define a color palette
colors = ['deepskyblue', 'limegreen', 'fuchsia', 'gold', 'darkorange']

# Adding lines to the plot with semi-transparency using the color palette
# The color order is matched to the line order
ax.plot(x_values, line1_y_values, label='50', color=palette[4], alpha=0.3)
ax.plot(x_values, line2_y_values, label='100', color=palette[3], alpha=0.3)
ax.plot(x_values, line3_y_values, label='250', color=palette[2], alpha=0.3)
ax.plot(x_values, line4_y_values, label='500', color=palette[1], alpha=0.3)
ax.plot(x_values, line5_y_values, label='1400', color=palette[0], alpha=0.3)

# Calculate the mean line
mean_y_values = np.mean([line1_y_values, line2_y_values, line3_y_values, line4_y_values, line5_y_values], axis=0)

# Add the mean line as a dotted line
ax.plot(x_values, mean_y_values, label='Mean', color='black', linestyle='dotted')

# Finding the minimum and maximum y-values at each x-value
min_y_values = np.minimum.reduce([line1_y_values, line2_y_values, line3_y_values, line4_y_values, line5_y_values])
max_y_values = np.maximum.reduce([line1_y_values, line2_y_values, line3_y_values, line4_y_values, line5_y_values])

# Shading the area between the minimum and maximum lines with semi-transparency
ax.fill_between(x_values, min_y_values, max_y_values, color='grey', alpha=0.3)

# Adding labels and title
ax.set_xlabel('Frequency of Overbids Allowed (%)')
ax.set_ylabel('% of total flexibility bid')
ax.legend()

# Show the plot
plt.show()

