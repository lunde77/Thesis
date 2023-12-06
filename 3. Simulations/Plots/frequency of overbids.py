# -*- coding: utf-8 -*-
"""
Created on Fri Nov  3 09:19:40 2023

@author: Gustav
"""

import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression

import seaborn as sns
import matplotlib.pyplot as plt


# Load the first CSV file
df1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\tester_2.overbids.csv")
data = df1.iloc[:, 0]
non_zero_elements = data[data != 0]


# Add 17 zero values
zero_values = pd.Series([0] * (-len(non_zero_elements)+203 ) )

# Concatenate the zero values to non_zero_elements
combined_data = pd.concat([non_zero_elements, zero_values])

# Calculate the mean
mean_value = combined_data.mean()

# Create a distribution plot with a KDE using histplot
sns.set_style("whitegrid")  # Set the style of the plot
histplot = sns.histplot(combined_data, color="blue", bins=50, kde=True)

# Customize the KDE line width
histplot.get_lines()[0].set_linewidth(2)

# Add a vertical line at x = 0.1
plt.axvline(x=0.1, color="red", linestyle="--", label="p90 Threadshold")


# Add a vertical line at the mean with a green shading
plt.axvline(x=mean_value, color="green", linestyle="--", label=f"Mean = {mean_value:.3f}")

# Set labels and a title
plt.xlabel("Freqeuncy of overbid % ")
plt.ylabel("Density")
plt.title("Daily Overbids Distribution with KDE")

# Show the plot
plt.legend()  # Add a legend for the vertical line
plt.show()

