# -*- coding: utf-8 -*-
"""
Created on Tue Dec 19 09:00:37 2023

@author: Gustav
"""

import pandas as pd
import matplotlib.pyplot as plt

# Replace this with your actual file reading code
flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\data\EV\20_minute data\ssall.csv")



# Extracting groups
group3 = flex['x1'][0:1260]
group2 = flex['x2'][0:1260]
group1 = flex['x3'][0:1260]

group3 = group3*1000/(60*8760)
group2 = group2*1000/(60*8760)
group1 = group1*1000/(60*8760)

# Show the plot
plt.show()
# Calculating medians
median1 = group1.median()
median2 = group2.median()
median3 = group3.median()

# Colors for the median lines
colors = ['blue', 'green', 'red']

# Creating the boxplot
plt.figure(figsize=(10, 6))
bplot = plt.boxplot([group1, group2, group3], labels=['Upwards', 'Downwards', 'Energy'], meanline=True)

# Changing the color of the median lines and matching the label text
for median_line, color in zip(bplot['medians'], colors):
    median_line.set_color(color)

# Creating the label box
label_text = (f"Median:\n"
              f"Upwards: {median1:.1f} kW\n"
              f"Downwards: {median2:.1f} kW\n"
              f"Energy: {median3:.1f} kW")

plt.text(0.05, 0.95, label_text, transform=plt.gca().transAxes, fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle="round,pad=0.5", facecolor='white', edgecolor='black'))

# Adding title and labels
plt.xlabel('Flexibilitiy dimension')
plt.ylabel('Average flexbility of CB (kW)')
plt.grid(color='gray', linestyle='--', linewidth=0.5, alpha=0.3, axis='y')

# Show the plot
plt.show()


Mean1 = group1.mean()
Mean2 = group2.mean()
Mean3 = group3.mean()

Q1_group1, Q3_group1 = group1.quantile(0.25), group1.quantile(0.75)
Q1_group2, Q3_group2 = group2.quantile(0.25), group2.quantile(0.75)
Q1_group3, Q3_group3 = group3.quantile(0.25), group3.quantile(0.75)

# Print the results
print(f"Group 1: Q1 = {Q1_group1}, Q3 = {Q3_group1}")
print(f"Group 2: Q1 = {Q1_group2}, Q3 = {Q3_group2}")
print(f"Group 3: Q1 = {Q1_group3}, Q3 = {Q3_group3}")