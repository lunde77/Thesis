# -*- coding: utf-8 -*-
"""
Created on Wed Jan 17 16:43:05 2024

@author: Gustav
"""

import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np



# Replace this with your actual file reading code
flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_70.csv")
flex_2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_2_70.csv")
flex_3 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_3_70.csv")
# Remove rows with any NaN values
df_cleaned = flex.dropna()
df_cleaned = df_cleaned.apply(pd.to_numeric, errors='coerce')

flex_2 = flex_2.dropna(0)
flex_2 = flex_2.apply(pd.to_numeric, errors='coerce')
flex_3 = flex_3.dropna(0)
flex_3 = flex_3.apply(pd.to_numeric, errors='coerce')

# Optionally, you can then fill NaNs with zero or handle them as you see fit
df_cleaned = df_cleaned.fillna(0)


sum_column = df_cleaned.iloc[:, 35:70].sum(axis=1)
sum_column_2 = df_cleaned.iloc[:, 1:27].sum(axis=1)

# Filtering rows where the sum is above 0
filtered_df_1 = df_cleaned[sum_column > 0]

filtered_df_2 = df_cleaned[sum_column_2 > 0]

sums_70 = np.zeros(8760)
counter = 0
for j in range(8760):
    if df_cleaned.iloc[j, :].sum() <= 0:
        sums_70[j] = 0 +flex_2.iloc[j, :].sum() +flex_3.iloc[j, :].sum()
    elif counter < len(filtered_df_1) and counter < len(filtered_df_2):
        sums_70[j] = filtered_df_1.iloc[counter, :].sum() + filtered_df_2.iloc[counter, :].sum()+flex_2.iloc[j, :].sum() +flex_3.iloc[j, :].sum()
        counter += 1
    elif counter < len(filtered_df_1):
        sums_70[j] = filtered_df_1.iloc[counter, :].sum()+flex_2.iloc[j, :].sum() +flex_3.iloc[j, :].sum()
        counter += 1
    
a28_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_28.csv")
a14_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_14.csv")
a10_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_10.csv")
a7_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_7.csv")
a4_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_4.csv")
a2_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_2.csv")
a1_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_1.csv")

# Convert all columns to numeric, coercing errors to NaN, then fill NaNs with zero
a28_flex = a28_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a14_flex = a14_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a10_flex = a10_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a7_flex = a7_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a4_flex = a4_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a2_flex = a2_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a1_flex = a1_flex.apply(pd.to_numeric, errors='coerce').fillna(0)


sums_28 = np.zeros(8760)
sums_14 = np.zeros(8760)
sums_10 = np.zeros(8760)
sums_7 = np.zeros(8760)
sums_4 = np.zeros(8760)
sums_2 = np.zeros(8760)
sums_1 = np.zeros(8760)

for j in range(8760):
    sums_28[j] = a28_flex.iloc[j, :].sum()
    sums_14[j] = a14_flex.iloc[j, :].sum()
    sums_10[j]  = a10_flex.iloc[j, :].sum()
    sums_7[j] = a7_flex.iloc[j, :].sum()
    sums_4[j] = a4_flex.iloc[j, :].sum()
    sums_2[j]  = a2_flex.iloc[j, :].sum()
    sums_1[j] = a1_flex.iloc[j, :].sum()
    
      
      
a70_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\CVaRHourly_revenue_N_bundles_70.csv")  
a28_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\CVaRHourly_revenue_N_bundles_28.csv")
a14_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\CVaRHourly_revenue_N_bundles_14.csv")
a10_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\CVaRHourly_revenue_N_bundles_10.csv")
a7_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\CVaRHourly_revenue_N_bundles_7.csv")
a4_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\CVaRHourly_revenue_N_bundles_4.csv")
a2_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\CVaRHourly_revenue_N_bundles_2.csv")
a1_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\CVaRHourly_revenue_N_bundles_1.csv")

# Convert all columns to numeric, coercing errors to NaN, then fill NaNs with zero
a70_flex = a70_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a28_flex = a28_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a14_flex = a14_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a10_flex = a10_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a7_flex = a7_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a4_flex = a4_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a2_flex = a2_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a1_flex = a1_flex.apply(pd.to_numeric, errors='coerce').fillna(0)

sums_70_CVa = np.zeros(8760)
sums_28_CVa = np.zeros(8760)
sums_14_CVa = np.zeros(8760)
sums_10_CVa = np.zeros(8760)
sums_7_CVa = np.zeros(8760)
sums_4_CVa = np.zeros(8760)
sums_2_CVa = np.zeros(8760)
sums_1_CVa = np.zeros(8760)

for j in range(8760):
    sums_70_CVa[j] = a70_flex.iloc[j, :].sum()
    sums_28_CVa[j] = a28_flex.iloc[j, :].sum()
    sums_14_CVa[j] = a14_flex.iloc[j, :].sum()
    sums_10_CVa[j]  = a10_flex.iloc[j, :].sum()
    sums_7_CVa[j] = a7_flex.iloc[j, :].sum()
    sums_4_CVa[j] = a4_flex.iloc[j, :].sum()
    sums_2_CVa[j]  = a2_flex.iloc[j, :].sum()
    sums_1_CVa[j] = a1_flex.iloc[j, :].sum()
#####



# Adjust font size
plt.rcParams.update({'font.size': 20.5})

# Generate dummy data
np.random.seed(0)  # For reproducible results
x_values = np.array([1, 2, 4, 7, 10, 14, 28, 70])  # Different bundle sizes
categories = ['ALSO-X', 'CVaR']  # The three categories

# Create a DataFrame with dummy data
data = []
for x in x_values:
    for category in categories:
        
        if x == 70:
            if category == 'CVaR':
                revenues = sums_1_CVa
            else:
                revenues = sums_1
        elif x == 28:
            if category == 'CVaR':
                revenues = sums_2_CVa
            else:
                revenues = sums_2
        elif x == 14:
            if category == 'CVaR':
                revenues = sums_4_CVa
            else:
                revenues = sums_4
        elif x == 10:
            if category == 'CVaR':
                revenues = sums_7_CVa
            else:
                revenues = sums_7
        elif x == 7:
            if category == 'CVaR':
                revenues = sums_10_CVa
            else:
                revenues = sums_10
        elif x == 4:
            if category == 'CVaR':
                revenues = sums_14_CVa
            else:
                revenues = sums_14
        elif x == 2:
            if category == 'CVaR':
                revenues = sums_28_CVa
            else:
                revenues = sums_28
        else:
            if category == 'CVaR':
                revenues = sums_70_CVa
            else:
                revenues = sums_70
            
            
        # Generate some random revenue data for each x value and category
        #revenues = np.random.normal(loc=x * 10, scale=5, size=100)
        for revenue in revenues:
            data.append({'x_value': x, 'Revenue': revenue, 'Category': category})

# Convert the list of dictionaries to a DataFrame
long_df = pd.DataFrame(data)


color_palette = {"ALSO-X": "steelblue", "CVaR": "burlywood"}

# Now, let's plot the violin plot using seaborn
plt.figure(figsize=(18, 13))
sns.boxplot(x='x_value', y='Revenue', hue='Category', data=long_df, palette=color_palette, showfliers=False)

x_values = np.array([1, 2, 4, 7, 10, 14, 28, 70])
# New x-positions for equal spacing
x_positions = np.arange(len(x_values))
x_positions = np.flip(x_positions)

x_values_2 = np.array([1400, 700, 350, 200, 140, 100, 50, 20])
x_labels = [f"{x}\n({y})" for x, y in zip(x_values, x_values_2)]
plt.xticks(x_positions, x_labels)

# Adding labels and title
plt.xlabel('Number of bundles\n(Number of CBs in bundle)')
plt.ylabel('Summed revenue of all 1400 CBs (DKK/hour)')
#plt.title("OOS Annual Hourly Revenue Distribution for a 1400 CB Portfolio")



# Adding legend, grid, and customizing axes
plt.legend(title='Category', loc='upper left')
plt.grid(color='gray', linestyle='--', linewidth=0.5, alpha=0.0)
plt.ylim(0,440)
# Show the plot
plt.show()
