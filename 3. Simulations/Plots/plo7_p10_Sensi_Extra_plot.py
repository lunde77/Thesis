# -*- coding: utf-8 -*-
"""
Created on Wed Dec 27 11:25:16 2023

@author: Gustav
"""
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import matplotlib.lines as mlines
##### load magnitudes of overbids ####
if True:
    df1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_500.csv")
    df2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_2_500.csv")
    data_500 =[ [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [] ]
    for j in range(17):
        print(j)
        for q in range(525600):
            if j >= 14:
                if df2.iloc[q,j] > 0:
                    data_500[j].append(df2.iloc[q,j]*100)
            else:
                if df1.iloc[q,j] > 0:
                    data_500[j].append(df1.iloc[q,j]*100)
    df1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_50.csv")
    df2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_2_50.csv")
    data_50 =[ [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [] ]
    for j in range(17):
        print(j)
        for q in range(525600):           
            if j >= 14:
                if df2.iloc[q,j] > 0:
                    data_50[j].append(df2.iloc[q,j]*100)
            else:
                if df1.iloc[q,j] > 0:
                    data_50[j].append(df1.iloc[q,j]*100)      
    df1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_100.csv")
    df2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_2_100.csv")
    data_100 =[ [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [] ]
    for j in range(17):
        print(j)
        for q in range(525600):
            if j >= 14:
                if df2.iloc[q,j] > 0:
                    data_100[j].append(df2.iloc[q,j]*100)
            else:
                if df1.iloc[q,j] > 0:
                    data_100[j].append(df1.iloc[q,j]*100) 
    df1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_250.csv")
    df2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_2_250.csv")
    data_250 =[ [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [] ]
    for j in range(17):
        print(j)
        for q in range(525600):
            if j >= 14:
                if df2.iloc[q,j] > 0:
                    data_250[j].append(df2.iloc[q,j]*100)
            else:
                if df1.iloc[q,j] > 0:
                    data_250[j].append(df1.iloc[q,j]*100) 
                
        
    df1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_1400_n4-15.csv")
    df2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_2_1400.csv")
    df3 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 7 (P10 rule sisitivitet)\Magnituede_N_CBS_3_1400.csv")
    data_1400 =[ [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [] ]
    for j in range(17):
        print(j)
        for q in range(525600):
            if j < 3:
                if df3.iloc[q,j] > 0:
                    data_1400[j].append(df3.iloc[q,j]*100)
            elif j < 14:
                if df1.iloc[q,j] > 0:
                    data_1400[j].append(df1.iloc[q,j]*100)
            else:
                if df2.iloc[q,j] > 0:
                    data_1400[j].append(df2.iloc[q,j]*100) 

all_data =[ [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [] ]

for j in range(17):
    print(j)
    all_data[j].extend(data_500[j])
    all_data[j].extend(data_250[j])
    all_data[j].extend(data_100[j])
    all_data[j].extend(data_50[j])
    all_data[j].extend(data_1400[j])



simulated_data = all_data
means = [np.median(arr)  for arr in simulated_data]

# Calculate percentiles
p5 = [np.percentile(data, 0) for data in simulated_data[1:17]]
p5.insert(0,0)
p25 = [np.percentile(data, 25) for data in simulated_data[1:17]]
p25.insert(0,0)
p75 = [np.percentile(data, 75) for data in simulated_data[1:17]]
p75.insert(0,0)
p95 = [np.percentile(data, 100) for data in simulated_data[1:17]]
p95.insert(0,0)


# Setting up the X-axis from 0 to 20 in steps of 2
x_values = list(np.arange(0, 2, 0.5))
x_values_1 = list(np.arange(2, 21, 2))

# Append 50 and 100 to the x_values list
# Append 50 and 100 to the x_values list
x_values.extend(x_values_1)
x_values.extend([30,40,50])
x_positions = x_values
# Create the plot
plt.figure(figsize=(12, 8))

# Plot the mean line

# Plot percentile lines
plt.plot(x_positions[1:17], means[1:17], color='black', label='median', zorder=3)
plt.plot(x_positions[1:17], p5[1:17], color='black', alpha=0.1, linestyle='--', zorder=2)
plt.plot(x_positions[1:17], p25[1:17], color='black', alpha=0.4, linestyle='--', label='25th-75th Percentile range', zorder=2)
plt.plot(x_positions[1:17], p75[1:17], color='black', alpha=0.4, linestyle='--', zorder=2)
plt.plot(x_positions[1:17], p95[1:17], color='black', alpha=0.1, linestyle='--', label='min-max range', zorder=2)
# Shaded areas (approximating gradient effect)
n_shades = 10  # Number of layers to simulate the gradient
for i in range(n_shades):
    lower_percentile = 0 + (i * (50 / n_shades))
    upper_percentile = 100 - (i * (50 / n_shades))
    lower_bound = [np.percentile(data, lower_percentile) for data in simulated_data[1:17]]
    upper_bound = [np.percentile(data, upper_percentile) for data in simulated_data[1:17]]
    alpha_value = (i / n_shades) * 0.05 + 0.05  # Gradually increasing alpha
    if i==10: 
        plt.fill_between(x_positions[1:17], lower_bound, upper_bound, color='black', alpha=alpha_value, label="5% quantile change", zorder=2)
    else:
        plt.fill_between(x_positions[1:17], lower_bound, upper_bound, color='black', alpha=alpha_value)
        
        
# Add axis labels
plt.ylabel('% of bid missing in overbid minutes') 
plt.xlabel('Frequency of Overbids Allowed (%)')
# Show the legend with a higher zorder
leg = plt.legend(loc='upper left')

# Set the zorder of the legend
leg.set_zorder(5)

# Show the plot
plt.show()