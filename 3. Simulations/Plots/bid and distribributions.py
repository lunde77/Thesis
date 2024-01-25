# -*- coding: utf-8 -*-
"""
Created on Tue Jan  2 11:28:08 2024

@author: Gustav
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import gaussian_kde
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import gaussian_kde
from mpl_toolkits.mplot3d import Axes3D
import pandas as pd
import matplotlib.cm as cm
import matplotlib.colors as colors

# Define the y-values for the two lines
line1_y_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\Downwards_bids_N_bundles_4_1.csv")  # Replace with an array of 1440 y-values for line 1
line2_y_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Downwards_bids_N_bundles_LER_1.csv")
line1_y_values = np.zeros(1440)
line2_y_values = np.zeros(1440)
for j in range(1440):
    line1_y_values[j] = np.sum(line1_y_data.iloc[j,:])/3
    line2_y_values[j] = np.sum(line2_y_data.iloc[j,:])/3
    

# Assuming you have 1440 x-values and for each x you have 363 samples
# Replace 'your_data' with your actual data array
# your_data should be a list of arrays, each containing 363 samples for each x-value
your_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\data\EV\Flexibility\Downwards_flexibilities.csv")
your_data = your_data.iloc[:,139]
# Create a list containing 1440 empty lists
data_1400 = [[] for _ in range(1440)]
counter = -1
for j in range(525600):
    print(j)
    counter = counter + 1
    data_1400[counter].append(your_data[j])
    if counter == 1439:
        counter = -1

x = np.linspace(1, 1440, 1440)  # x-values
samples_per_x = 363  # Number of samples per x-value
Z = np.zeros((samples_per_x, len(x)))  # Placeholder for KDE results

# Calculate the Gaussian KDE for each set of samples
for i, xi in enumerate(x):
    # Replace 'your_data[i]' with the actual samples for this x-value
    kde = gaussian_kde(data_1400[i])
    Z[:, i] = kde(np.linspace(6500, 0, samples_per_x))  # Evaluate KDE on a y-range from 0 to 3000

#offset = 0.1  # Adjust this value as needed
# Compute the corresponding Z values for the lines
#line1_Z = np.array([kde(line1_y_values[i])[0] for i, kde in enumerate([gaussian_kde(data) for data in data_1400])]) + offset
#line2_Z = np.array([kde(line2_y_values[i])[0] for i, kde in enumerate([gaussian_kde(data) for data in data_1400])])+ offset

def find_surface_z_values(x_values, y_values, X_grid, Y_grid, Z_surface):
    z_values = []
    for x_val, y_val in zip(x_values, y_values):
        # Find the nearest index in the grid
        x_idx = np.abs(X_grid[0] - x_val).argmin()
        y_idx = np.abs(Y_grid[:, 0] - y_val).argmin()
        
        # Get the Z value from the surface at this index
        z_val = Z_surface[y_idx, x_idx]
        z_values.append(z_val)
    return np.array(z_values)


# Create a grid for plotting
X, Y = np.meshgrid(x, np.linspace(0, 6500, samples_per_x))
# Compute Z values for the lines from the KDE surface
line1_Z = find_surface_z_values(x, line1_y_values, X, Y, Z)
line2_Z = find_surface_z_values(x, line2_y_values, X, Y, Z)


# Create the plot
fig = plt.figure(figsize=(14, 10))
ax = fig.add_subplot(111, projection='3d')

# Plot the surface with X and Y swapped
surf = ax.plot_surface(Y, X, Z, cmap=cm.viridis, norm=colors.Normalize(vmin=Z.min(), vmax=Z.max()), rstride=1, cstride=1, antialiased=True, alpha=0.5)

ax.grid(False)
ax.xaxis.pane.fill = True  # Removes the pane background
ax.yaxis.pane.fill = True
ax.zaxis.pane.fill = False
ax.zaxis.set_ticklabels([])
ax.zaxis.set_ticks([])
ax.set_facecolor('white')
ax.w_xaxis.set_pane_color((1.0, 1.0, 1.0, 0.0))
ax.w_yaxis.set_pane_color((1.0, 1.0, 1.0, 0.0))
ax.w_zaxis.set_pane_color((1.0, 1.0, 1.0, 0.0))

# Create a colorbar with a label
cbar = fig.colorbar(surf, shrink=0.5, aspect=5)
cbar.set_label('Probability Density')

# Plot the lines with X and Y swapped
ax.plot(line1_y_values, x, line1_Z, color='r', linewidth=3, label='LER requirement', zorder=5, alpha=0.9)
ax.plot(line2_y_values, x, line2_Z, color='b', linewidth=3, label='Non-LER bid requirements', zorder=5, alpha=0.9)

# Set the labels with X and Y swapped
ax.set_xlabel('KW')
ax.set_ylabel('Minute of Day')

# Remove the Z-axis components
ax.zaxis.line.set_visible(False)
ax.zaxis.set_ticklabels([])
ax.zaxis.set_ticks([])

# Add legend
ax.legend()

# Set the view to be directly above by setting elevation to 90 degrees
ax.view_init(elev=90, azim=270)

# Show the plot
plt.show()
