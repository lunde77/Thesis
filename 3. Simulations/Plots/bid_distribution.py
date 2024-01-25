# -*- coding: utf-8 -*-
"""
Created on Tue Jan  2 16:18:15 2024

@author: Gustav
"""
# -*- coding: utf-8 -*-
"""
Created on Tue Jan  2 16:00:05 2024

@author: Gustav
"""



import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import gaussian_kde
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import pandas as pd
import matplotlib.cm as cm
import matplotlib.colors as colors
from matplotlib.colors import Normalize
from matplotlib.colors import LinearSegmentedColormap
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

plt.rcParams.update({'font.size': 13.2})  # You can adjust the size as needed



# Load and process your line data
line1_y_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\Downwards_bids_N_bundles_4_1.csv")  # Replace with an array of 1440 y-values for line 1
line2_y_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Downwards_bids_N_bundles_LER_1.csv")
line1_y_values = np.mean(line1_y_data, axis=1)
line2_y_values = np.mean(line2_y_data, axis=1)

# Load your KDE data
your_data = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\data\EV\Flexibility\Downwards_flexibilities.csv")
your_data = your_data.iloc[:, 139]

# ... [previous parts of your code] ...

# Create a list containing 1440 empty lists
data_1400 = [[] for _ in range(1440)]
counter = -1
for j in range(525600):
    counter = counter + 1
    data_1400[counter].append(your_data[j])
    if counter == 1439:
        counter = -1


# Define the axes for the plot
x = np.linspace(1, 1440, 1440)  # x-values, representing 'Minute of Day'
y = np.linspace(0, 7500, 363)  # y-values, representing 'KW'

# Create the meshgrid for X and Y
X, Y = np.meshgrid(x, y)

# Calculate the KDE values for Z, ensuring Z has the same shape as X and Y
Z = np.zeros_like(X)
for i, xi in enumerate(x):
    # Ensure that data_1400[i] is not empty and has more than one unique value
    if len(data_1400[i]) > 1 and np.var(data_1400[i]) > 0:
        kde = gaussian_kde(data_1400[i])
        Z[:, i] = kde(y)  # Evaluate KDE on the y-range

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
X, Y = np.meshgrid(x, np.linspace(0, 7500, 363))
# Compute Z values for the lines from the KDE surface
line1_Z = find_surface_z_values(x, line1_y_values, X, Y, Z)
line2_Z = find_surface_z_values(x, line2_y_values, X, Y, Z)

# Plot the surface
fig = plt.figure(figsize=(24, 16))

ax = fig.add_subplot(111, projection='3d')
# Define a custom colormap (e.g., "cividis") for the plot
# Define a custom colormap with more colors
num_colors = 256  # You can choose any number of colors
custom_colormap = plt.get_cmap("viridis", num_colors)  # You can choose any colormap
power = 0.41  # You can adjust this exponent to control the exaggeration
# Apply a power-law mapping to exaggerate the differences for small probabilities
def power_law_mapping(probability):

    return probability ** power

# Normalize the probabilities using the power-law mapping
normalized_probabilities = np.vectorize(power_law_mapping)(Z)

# Plot the surface with the custom colormap and normalized probabilities
surf = ax.plot_surface(X, Y, normalized_probabilities, cmap=custom_colormap, rstride=1, cstride=1, antialiased=True)

# Create a colorbar with a label
# Create a colorbar with a label
cbar = fig.colorbar(surf, ax=ax, shrink=0.35, aspect=15, pad=-0.05)
cbar.ax.set_yticklabels([])  # Remove number labels
cbar.ax.set_ylabel('Probability Density', fontsize=13) 

#
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
ax.yaxis.set_tick_params(pad=13) 
ax.plot(x, line1_y_values, line1_Z**power, color='silver', linewidth=3, label='LER requirement', zorder=5, alpha=0.9)
ax.plot(x, line2_y_values, line2_Z**power, color='darkorange', linewidth=3, label='Non-LER requirements', zorder=5, alpha=0.9)


# Set axis labels
ax.set_xlabel('Minute of Day', labelpad=18)
ax.set_ylabel('kW',  labelpad=25)
ax.set_zlabel('Probability Density',labelpad=30)
ax.legend(loc='upper center', bbox_to_anchor=(0.5, 0.87))
# Optionally, set the view angle
ax.view_init(elev=89.9, azim=-90)  # Adjust elevation and azimuth to get the desired view

# Show the plot
plt.show()