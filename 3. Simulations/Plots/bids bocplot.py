import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Replace these file paths with your actual CSV file paths
csv_file_path1 = r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\old results\CVaR VS ALSO-X downwards bids.csv"
csv_file_path2 = r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Downwards_bids day dependent distributions.csv"

# Specify the columns you want to use (e.g., ['A', 'B', 'C', 'D', 'E'])
columns_to_use = ['column1', 'column2', 'column3', 'column4', 'column5']

# Load the CSV files
file2 = pd.read_csv(csv_file_path1, usecols=['x6', 'x9', 'x7', 'x8', 'x10'])
file1 = pd.read_csv(csv_file_path2, usecols=['x6', 'x9', 'x7', 'x8', 'x10'])
file3 = pd.read_csv(csv_file_path2, usecols=['x1', 'x2', 'x3', 'x4', 'x5'])

# Reshape the data into 24x5 matrices
matrix1 = file1.iloc[::60, :].values.reshape(24, 5)
matrix2 = file2.iloc[::60, :].values.reshape(24, 5)
matrix3 = file3.iloc[::60, :].values.reshape(24, 5)
# Function to plot a single boxplot for all rows

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Patch

# Function to plot combined boxplots with colors, labels, and mean lines
def plot_combined_boxplots(matrix1, matrix2, matrix3):
    plt.figure(figsize=(20, 10))
    colors = ['blue', 'green', 'red']  # Colors for each dataset

    means1 = np.mean(matrix1, axis=1)
    means2 = np.mean(matrix2, axis=1)
    means3 = np.mean(matrix3, axis=1)
    
    # Plotting mean lines with transparency and centered on the x-axis
    plt.plot([i*3+2 for i in range(24)], means1, color='blue', linestyle='-', alpha=0.25, label='Mean CSV 1')
    plt.plot([i*3+2 for i in range(24)], means2, color='green', linestyle='-', alpha=0.25, label='Mean CSV 2')
    plt.plot([i*3+2 for i in range(24)], means3, color='red', linestyle='-', alpha=0.25, label='Mean CSV 3')
    
    # Plotting each dataset with a specific color
    for i in range(24):
        data_to_plot = [matrix1[i, :], matrix2[i, :], matrix3[i, :]]
        positions = [i * 3 + k + 1 for k in range(3)]  # [1, 2, 3] for the first set, then [4, 5, 6], etc.
        for j, data in enumerate(data_to_plot):
            plt.boxplot(data, positions=[positions[j]], patch_artist=True, 
                        boxprops=dict(facecolor=colors[j]),
                        medianprops=dict(color='yellow'),
                        capprops=dict(color=colors[j]),
                        whiskerprops=dict(color=colors[j]),
                        flierprops=dict(color=colors[j], markeredgecolor=colors[j]),
                        zorder=j)
    
    # Setting x-tick labels and positions
    tick_labels = [str(i) for i in range(1, 25)]
    tick_positions = [i * 3 + 2 for i in range(24)]  # Center of each group of box plots
    plt.xticks(tick_positions, tick_labels)
    plt.title("Downwards regulation bid")
    plt.xlabel('hour of day')
    plt.ylabel('KW')
    plt.grid(True)

    # Creating a custom legend
    legend_elements = [Patch(facecolor=colors[0], label='Weekend days bids'),
                       Patch(facecolor=colors[1], label='All days bids'),
                       Patch(facecolor=colors[2], label='Weekdays bids')]
    plt.legend(handles=legend_elements, loc='upper right')

    plt.tight_layout()
    plt.show()

plot_combined_boxplots(matrix1, matrix2, matrix3)


bids_day_dependent = (sum(sum(matrix3))/7*5+sum(sum(matrix1))/7*2)/5

bids_not_d = sum(sum(matrix2))/5

print(bids_day_dependent/bids_not_d)