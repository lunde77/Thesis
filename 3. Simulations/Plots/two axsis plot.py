# -*- coding: utf-8 -*-
"""
Created on Fri Nov 10 15:00:02 2023

@author: Gustav
"""

import matplotlib.pyplot as plt
import numpy as np


import pandas as pd
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression

import seaborn as sns
import matplotlib.pyplot as plt


# Load the first CSV file
df1 = pd.read_csv( r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\test 6 runtime based on q\Runtime results.csv")
Overibid = df1.iloc[1:7, 5]*100
rutime = df1.iloc[1:7, 13]

q = [0.000001, 0.0001, 0.005, 0.1, 0.2, 0.3, 1, 2, 11]

Overibid = [0.107*100, 10.7, 11.7] + list(Overibid)
rutime = [260, 267.664, 231] + list(rutime)

Overibid = Overibid

# Plotting
fig, ax1 = plt.subplots(figsize=(10, 6))

# Plotting veribid on the primary y-axis
ax1.plot(q, Overibid, label='Freguency of overbid', marker='o', color='b')
ax1.set_xlabel('Value of δ')
ax1.set_ylabel('Freqeuncy of overbid % in OSS', color='b')
ax1.tick_params('y', colors='b')

# Add a horizontal dashed line at y=0.1 for veribid
ax1.axhline(y=10, color='b', linestyle='--', label='P90 Threadshold')
plt.legend(loc='upper left')

# Creating a secondary y-axis for rutime
ax2 = ax1.twinx()
ax2.plot(q, rutime, label='runtime', marker='x', color='r')
ax2.set_ylabel('Also-X runtime (s.)', color='r')
ax2.tick_params('y', colors='r')

# Set y-axis limits
ax1.set_ylim(0, 110)  # Adjust the limits as needed for veribid
ax2.set_ylim(100, 300)    # Adjust the limits as needed for rutime


# Set log scale on x-axis
ax1.set_xscale('log')

# Title and legend
fig.tight_layout()
plt.legend()

# Show the plot
plt.show()



