# -*- coding: utf-8 -*-
"""
Created on Thu Nov 30 16:29:25 2023

@author: Gustav
"""

# Example usage
file_path = r"C:\Users\Gustav\Documents\Thesis\data\Price\FCR_prices.xlsx"  # replace with your file path

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Generate a date range for the time series
date_range = pd.date_range(start='2022-03-23', end='2023-03-23', freq='H')

# Load your data from Excel files
# Assuming each file contains one vector of 8760 data points
file_path = r"C:\Users\Gustav\Documents\Thesis\data\Price\FCR_prices.xlsx"  # replace with your file path

data1 = pd.read_excel(file_path, header=None, squeeze=True)

data2 = data1.iloc[1::,3]*7.46

data1 = data1.iloc[1::,1]*7.46

# Assign the date range to your data
data1.index = date_range[0:8760]
data2.index = date_range[0:8760]

# Plot the time series
plt.figure(figsize=(12, 5))
plt.plot(data1.index, data1, label='Upwards', color='goldenrod')
plt.plot(data2.index, data2, label='Downwards', color='steelblue')
plt.xlabel('Date')
plt.ylabel('DKK/MW')
plt.title('Regulation prices over scope period')
plt.legend()
plt.show()

# Plot histograms with KDE for each series
plt.figure(figsize=(5.7, 4))
sns.histplot(data1, kde=False, bins=30, color='goldenrod')
plt.title('Upwards regulation price distribution')
plt.xlabel('DKK/MW')
plt.ylabel('Occurrences')
plt.xlim([0, 1350])  # Set x-axis limits for Series 1 histogram
plt.ylim([0, 2000])  # Set y-axis limits for Series 1 histogram
plt.show()

plt.figure(figsize=(5.7, 4))
sns.histplot(data2, kde=False, bins=30, color='steelblue')
plt.title('Downwards regulation price distribution')
plt.xlabel('DKK/MW')
plt.ylabel('Occurrences')
plt.xlim([0, 1350])  # Set x-axis limits for Series 1 histogram
plt.ylim([0, 2000])  # Set y-axis limits for Series 1 histogram
plt.show()
