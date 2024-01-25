# -*- coding: utf-8 -*-
"""
Created on Thu Dec  7 14:15:35 2023

@author: Gustav
"""

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

import matplotlib.lines as mlines
#####
plt.rcParams.update({'font.size': 20.5})  # You can adjust the size as needed



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

# Oracle results

#####

Oracæe_sums_28 = np.zeros(8760)
Oracæe_sums_14 = np.zeros(8760)
Oracæe_sums_10 = np.zeros(8760)
Oracæe_sums_7 = np.zeros(8760)
Oracæe_sums_4 = np.zeros(8760)
Oracæe_sums_2 = np.zeros(8760)
Oracæe_sums_1 = np.zeros(8760)

for j in range(8760):
    Oracæe_sums_28[j] = a28_flex.iloc[j, :].sum()
    Oracæe_sums_14[j] = a14_flex.iloc[j, :].sum()
    Oracæe_sums_10[j]  = a10_flex.iloc[j, :].sum()
    Oracæe_sums_7[j] = a7_flex.iloc[j, :].sum()
    Oracæe_sums_4[j] = a4_flex.iloc[j, :].sum()
    Oracæe_sums_2[j]  = a2_flex.iloc[j, :].sum()
    Oracæe_sums_1[j] = a1_flex.iloc[j, :].sum()
    
      
      
a70_flex_1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_3_70.csv")  
a70_flex_0 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_70_1_39.csv") 
a28_flex_0 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_3_28.csv")
a28_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_28.csv")
a14_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_14.csv")
a10_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_10.csv")
a7_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_7.csv")
a4_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_4.csv")
a2_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_2.csv")
a1_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\Hourly_revenue_N_bundles_Oracle_1.csv")

# Convert all columns to numeric, coercing errors to NaN, then fill NaNs with zero
a70_flex = a70_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a28_flex = a28_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a14_flex = a14_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a10_flex = a10_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a7_flex = a7_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a4_flex = a4_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a2_flex = a2_flex.apply(pd.to_numeric, errors='coerce').fillna(0)
a1_flex = a1_flex.apply(pd.to_numeric, errors='coerce').fillna(0)

Oracæe_sums_70 = np.zeros(8760)
Oracæe_sums_28 = np.zeros(8760)
Oracæe_sums_14 = np.zeros(8760)
Oracæe_sums_10 = np.zeros(8760)
Oracæe_sums_7 = np.zeros(8760)
Oracæe_sums_4 = np.zeros(8760)
Oracæe_sums_2 = np.zeros(8760)
Oracæe_sums_1 = np.zeros(8760)

for j in range(8760):
    Oracæe_sums_70[j] = a70_flex_1.iloc[j, :].sum()+a70_flex_0.iloc[j, :].sum()
    Oracæe_sums_28[j] = a28_flex.iloc[j, :].sum()+a28_flex_0.iloc[j, :].sum()
    Oracæe_sums_14[j] = a14_flex.iloc[j, :].sum()
    Oracæe_sums_10[j]  = a10_flex.iloc[j, :].sum()
    Oracæe_sums_7[j] = a7_flex.iloc[j, :].sum()
    Oracæe_sums_4[j] = a4_flex.iloc[j, :].sum()
    Oracæe_sums_2[j]  = a2_flex.iloc[j, :].sum()
    Oracæe_sums_1[j] = a1_flex.iloc[j, :].sum()
#####



# Original example data
x_values = np.array([1, 2, 4, 7, 10, 14, 28, 70])
# New x-positions for equal spacing
x_positions = np.arange(len(x_values))
x_positions = np.flip(x_positions)
# Simulate variability for demonstration
np.random.seed(0)  # For reproducible results

simulated_data = [sums_1, sums_2, sums_4, sums_7, sums_10, sums_14, sums_28, sums_70]
simulated_data_also = simulated_data
means = [np.median(arr)  for arr in simulated_data]
means = np.flip(means)
# Calculate percentiles
p5 = [np.percentile(data, 5) for data in simulated_data]
p25 = [np.percentile(data, 25) for data in simulated_data]
p75 = [np.percentile(data, 75) for data in simulated_data]
p95 = [np.percentile(data, 95) for data in simulated_data]
means = np.flip(means)


# Create the plot
plt.figure(figsize=(18, 13))

# Plot the mean line
plt.plot(x_positions, means, color='steelblue', marker='o', label='ALSO-X Median',  linewidth=3)

# Plot percentile lines
#plt.plot(x_positions, p5, color='blue', alpha=0.5, linestyle='--', label='5th Percentile')
#plt.plot(x_positions, p25, color='steelblue', alpha=0.4, linestyle='--',  linewidth=2.2)
#plt.plot(x_positions, p75, color='steelblue', alpha=0.4, linestyle='--',  linewidth=2.2)
#plt.plot(x_positions, p95, color='blue', alpha=0.5, linestyle='--', label='95th Percentile')

# Shaded areas (approximating gradient effect)
n_shades = 0  # Number of layers to simulate the gradient
for i in range(n_shades):
    lower_percentile = 25 + (i * (25 / n_shades))
    upper_percentile = 75 - (i * (25 / n_shades))
    lower_bound = [np.percentile(data, lower_percentile) for data in simulated_data]
    upper_bound = [np.percentile(data, upper_percentile) for data in simulated_data]
    alpha_value = (i / n_shades) * 0.05 + 0.05  # Gradually increasing alpha
    if i==9: 
        plt.fill_between(x_positions, lower_bound, upper_bound, color='steelblue', alpha=alpha_value, label="5% quantile")
    else:
        plt.fill_between(x_positions, lower_bound, upper_bound, color='steelblue', alpha=alpha_value)
    
simulated_data = [sums_1_CVa, sums_2_CVa, sums_4_CVa, sums_7_CVa, sums_10_CVa, sums_14_CVa, sums_28_CVa, sums_70_CVa]
means = [np.median(arr)  for arr in simulated_data]

plt.plot(x_positions, means, color='burlywood', marker='x', label='CVaR Median',  linewidth=3)

for i in range(n_shades):
    lower_percentile = 25 + (i * (25 / n_shades))
    upper_percentile = 75 - (i * (25 / n_shades))
    lower_bound = [np.percentile(data, lower_percentile) for data in simulated_data]
    upper_bound = [np.percentile(data, upper_percentile) for data in simulated_data]
    alpha_value = (i / n_shades) * 0.05 + 0.05  # Gradually increasing alph
    if i==9: 
        plt.fill_between(x_positions, lower_bound, upper_bound, color='burlywood', alpha=alpha_value, label="5% quantile deviation")
    else:
        plt.fill_between(x_positions, lower_bound, upper_bound, color='burlywood', alpha=alpha_value)

# Set the x-ticks to use the original x_values as labels
#plt.fill_between(x_positions,  [0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0], linestyle='--', color='grey', alpha=0.1, label="25th to 75th inner quantile range")
p5 = [np.percentile(data, 5) for data in simulated_data]
p25 = [np.percentile(data, 25) for data in simulated_data]
p75 = [np.percentile(data, 75) for data in simulated_data]
p95 = [np.percentile(data, 95) for data in simulated_data]
means = np.flip(means)

#plt.plot(x_positions, p25, color='burlywood', alpha=0.4, linestyle='--', linewidth=2.2)
#plt.plot(x_positions, p75, color='burlywood', alpha=0.4, linestyle='--', linewidth=2.2)

## Oracle add on to plot 


simulated_data = [Oracæe_sums_1, Oracæe_sums_2, Oracæe_sums_4, Oracæe_sums_7, Oracæe_sums_10, Oracæe_sums_14, Oracæe_sums_28, Oracæe_sums_70]
means = [np.median(arr)  for arr in simulated_data]

plt.plot(x_positions, means, color='Darkmagenta', marker='*', label='Oracle Median',  linewidth=3)

for i in range(n_shades):
    lower_percentile = 25 + (i * (25 / n_shades))
    upper_percentile = 75 - (i * (25 / n_shades))
    lower_bound = [np.percentile(data, lower_percentile) for data in simulated_data]
    upper_bound = [np.percentile(data, upper_percentile) for data in simulated_data]
    alpha_value = (i / n_shades) * 0.05 + 0.05  # Gradually increasing alph
    if i==9: 
        plt.fill_between(x_positions, lower_bound, upper_bound, color='burlywood', alpha=alpha_value, label="5% quantile deviation")
    else:
        plt.fill_between(x_positions, lower_bound, upper_bound, color='burlywood', alpha=alpha_value)

# Set the x-ticks to use the original x_values as labels
#plt.fill_between(x_positions,  [0,0,0,0,0,0,0,0], [0,0,0,0,0,0,0,0], linestyle='--', color='grey', alpha=0.1, label="25th to 75th inner quantile range")
p5 = [np.percentile(data, 5) for data in simulated_data]
p25 = [np.percentile(data, 25) for data in simulated_data]
p75 = [np.percentile(data, 75) for data in simulated_data]
p95 = [np.percentile(data, 95) for data in simulated_data]
means = np.flip(means)

#plt.plot(x_positions, p25, color='Darkmagenta', alpha=0.4, linestyle='--', linewidth=2.2)
#plt.plot(x_positions, p75, color='Darkmagenta', alpha=0.4, linestyle='--', linewidth=2.2)




x_values_2 = np.array([1400, 700, 350, 200, 140, 100, 50, 20])
means = np.flip(x_values_2)
x_labels = [f"{x}\n({y})" for x, y in zip(x_values, x_values_2)]
plt.xticks(x_positions, x_labels)

# Adding labels and title
plt.xlabel('Number of bundles\n(Number of CBs in bundle)')
plt.ylabel('Median profit for all 1400 CBs [DKK/hour]')
#plt.title("OOS Annual Hourly Revenue Distribution for a 1400 CB Portfolio")

# Customizing the grid to look rough
#plt.grid(color='gray', linestyle='--', linewidth=0.5, alpha=0.0)
#plt.plot([], [], color='grey', linestyle='--', alpha= 0.6, label='Quartile Range (25-75%)')


start_point = (1.8, 80)
end_point = (3.3, 80)

# Add a tan, horizontal arrow
plt.annotate('', 
             xy=end_point, xytext=start_point,
             arrowprops=dict(facecolor='black', shrink=0.05))

# Add text above the middle of the arrow
mid_point_x = (start_point[0] + end_point[0]) / 2
plt.text(mid_point_x, start_point[1] + 4.2, 'Increased Synergy', 
         horizontalalignment='center')

plt.ylim(-1,155)
# Adding a legend
plt.legend()

# Show the plot
plt.show()
