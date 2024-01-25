# -*- coding: utf-8 -*-
"""
Created on Wed Jan 17 11:33:01 2024

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



df1_daily = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 5\freq_overbids_N_bundles_Oracle_test_500.csv")


df1_mag = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 5\magnitue_overbids_N_bundles_Oracle_test_500.csv")



import seaborn as sns
import matplotlib.pyplot as plt

plt.rcParams.update({'font.size': 18.5})  # You can adjust the size as needed


# Create a 2x2 grid of subplots
fig, axs = plt.subplots(1, 2, figsize=(21, 7))  # Adjust the size as needed

# First subplot data preparation
combined_data1 = df1_mag.iloc[:,0]
combined_data1 = combined_data1[combined_data1 != 0]
combined_data1 = combined_data1 * 100  # Change to %
mean_value1 = combined_data1.mean()
num_bins1 = int((combined_data1.max() - combined_data1.min()) / 1)
# Plotting first subplot
sns.histplot(combined_data1, color="Darkmagenta", bins=num_bins1, kde=False, label="Minutes with overbids", ax=axs[1])
axs[1].axvline(x=mean_value1, color="green", linestyle=(0, (1, 2)), label=f"Mean = {mean_value1:.2f}%", lw=4.85, zorder=0)
axs[1].set_xlabel("% of Flexibility Bid Missing")
axs[1].set_ylabel("Count of Minutes")
axs[1].set_title("Magnitude of Overbids - Oracle")
axs[1].set_xlim([-1, 101])
axs[1].set_ylim([0, 21700])
axs[1].yaxis.grid(True)
axs[1].xaxis.grid(False)
axs[1].legend(fontsize=17.5)




combined_data = df1_daily.iloc[:,0]
combined_data = combined_data*100
data_min = combined_data.min()
data_max = combined_data.max()
num_bins = int((data_max - data_min) / 1)
mean_value = combined_data.mean()
# Third subplot (you need to define combined_data3 and mean_value3 based on your third dataset)

bin_edges = np.arange(-0.99, 17.5, 0.5)  # Generates an array from -1 to 60


sns.histplot(combined_data, color="Darkmagenta", bins=bin_edges, kde=False, label="All days", ax=axs[0])
axs[0].patches[0].set_facecolor('Darkgoldenrod')

# Adding lines and legends to the second subplot
axs[0].axvline(x=10, color="indianred", linestyle=(5, (10, 3)), label="p10 target line(10%)", lw=4.85, zorder=0)
axs[0].axvline(x=15, color="darkred", linestyle=(1, (5, 2)), label="exclusion line(15%)", lw=4.85, zorder=0)
axs[0].axvline(x=mean_value, color="green", linestyle=(0, (1, 2)), label=f"Mean = {mean_value:.2f}%", lw=4.85, zorder=0)
axs[0].set_xlabel("Frequency of Overbid %")
axs[0].set_ylabel("Count of Days")
axs[0].set_title("Frequency of Overbids - Oracle")
axs[0].set_xlim([-1.6, 18])
axs[0].set_ylim([0, 325])
axs[0].yaxis.grid(True)
axs[0].xaxis.grid(False)

# Creating legend handles
#first_bar_patch = mpatches.Patch(color='Darkgoldenrod', label='Days without overbids')
other_bars_patch = mpatches.Patch(color='Darkmagenta', label='Days with overbid')
p10_line = mlines.Line2D([], [], color="indianred", linestyle=(5, (10, 3)), lw=4.85, label="P10 target line(10%)")
exclusion_line = mlines.Line2D([], [], color="darkred", linestyle=(1, (5, 2)), lw=4.85, label="Exclusion line(15%)")
mean_line = mlines.Line2D([], [], color="green", linestyle=(0, (1, 2)), lw=4.85, label=f"Mean = {mean_value:.2f}%")

# Adding the legend to the second subplot
axs[0].legend(fontsize=14)
axs[0].legend(handles=[other_bars_patch, p10_line, exclusion_line, mean_line],fontsize=17.5)

# Show the plot
plt.show()