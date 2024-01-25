# -*- coding: utf-8 -*-
"""
Created on Mon Dec 11 14:08:06 2023

@author: Gustav
"""


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
import matplotlib.patches as mpatches
import matplotlib.lines as mlines


df_do = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 4\flex_used_down_m_tester_1BC_1.csv")
df_up = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 4\flex_used_up_m_tester_1BC_1.csv")

def filter_column_values(df, column_name, start_row, end_row):
    if start_row < 0 or end_row > len(df):
        raise ValueError("Specified range is out of DataFrame bounds.")
    filtered_values = df.loc[start_row:end_row, column_name]
    filtered_indices = filtered_values[filtered_values != -1].index
    return filtered_values[filtered_values != -1], filtered_indices


# Specify the row range
start_row = 1441
end_row = 525599 - 1440

# Apply the filter_column_values function to a specific column
filtered_values, filtered_indices = filter_column_values(df_do, "x2", start_row, end_row)



# Initialize an empty list to store the results
results = []

df_CB = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\data\EV\cleaned_data_RM90\1544.csv")

# Iterate over each column in the DataFrame
for column in df_do.columns:
    # Apply the filter_column_values function
    down, d_index = filter_column_values(df_do, column, start_row, end_row)
    up, d_index = filter_column_values(df_up, column, start_row, end_row)
    
    
    # Use the indices to select values from a different column
    up_flex = df_CB.loc[d_index, "upwards_flex"]
    do_flex = df_CB.loc[d_index, "Downwards_flex"]
    
    
    d = (up_flex*up+do_flex*down)/(do_flex+up_flex)
    
    
    # Calculate mean, 0.05 quantile, and 0.95 quantile
    mean_value = np.mean(down)
    quantile_05 = d.quantile(0.05)
    quantile_95 = d.quantile(0.95)

    # Append the results to the list
    results.append([quantile_05, mean_value, quantile_95])

