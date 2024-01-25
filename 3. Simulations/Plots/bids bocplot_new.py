import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

plt.rcParams.update({'font.size': 18.5})

# Replace these file paths with your actual CSV file paths
csv_file_path1 = r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 9 (conditinal bud)\Upwards_bids_ALSO_3).csv"
csv_file_path2 = r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 9 (conditinal bud)\Upwards_bids_ALSO_condtional).csv"

# Specify the columns you want to use (e.g., ['A', 'B', 'C', 'D', 'E'])
# columns_to_use = ['column1', 'column2', 'column3', 'column4', 'column5']

# Load the CSV files
file2 = pd.read_csv(csv_file_path1, usecols=['x1', 'x2', 'x3'])
file1 = pd.read_csv(csv_file_path2, usecols=['x4', 'x5', 'x6'])
file3 = pd.read_csv(csv_file_path2, usecols=['x1', 'x2', 'x3'])

# Reshape the data into 24x5 matrices
matrix1 = file1.iloc[::60, :].values.reshape(24, 3)
matrix2 = file2.iloc[::60, :].values.reshape(24, 3)
matrix3 = file3.iloc[::60, :].values.reshape(24, 3)
# Function to plot a single boxplot for all rows

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Patch

# Function to plot combined data points with colors, labels, and mean lines
def plot_combined_points(matrix1, matrix2, matrix3, annotations):
    plt.figure(figsize=(20, 10))
    colors = ['blue', 'green', 'red']  # Colors for each dataset

    means1 = np.mean(matrix1, axis=1)
    means2 = np.mean(matrix2, axis=1)
    means3 = np.mean(matrix3, axis=1)
    
    # Plotting mean lines
    plt.plot(range(1, 25), means1, color='blue', linestyle='-', lw=2.3, alpha=1, label='Mean CSV 1')
    plt.plot(range(1, 25), means2, color='green', linestyle='-', lw=2.3, alpha=1, label='Mean CSV 2')
    plt.plot(range(1, 25), means3, color='red', linestyle='-', lw=2.3, alpha=1, label='Mean CSV 3')
    
    # Plotting each dataset's values on the same x-axis position
    for i in range(24):
        plt.scatter([i + 1] * 3, matrix1[i, :], color='blue', alpha=0.3, edgecolor='black')
        plt.scatter([i + 1] * 3, matrix2[i, :], color='green', alpha=0.3,  edgecolor='black')
        plt.scatter([i + 1] * 3, matrix3[i, :], color='red', alpha=0.3,  edgecolor='black')
        # Adding annotations
        
    for i, (x, y, label, color) in enumerate(annotations):
        plt.text(x, y, label, fontsize=22, ha='right', va='bottom', color=color)



    # Setting x-tick labels
    plt.xticks(range(1, 25), [str(i) for i in range(1, 25)])
    #plt.title("Upwards Regulation Bid")
    plt.xlabel('Hour of Day')
    plt.ylabel('Bid (kW)')
    plt.grid(True)
    #plt.suptitle('500 CB portfolio', fontsize=20, color='black', weight='bold')


    # Creating a custom legend
    legend_elements = [Patch(facecolor=colors[0], label='Weekend days bids'),
                       Patch(facecolor=colors[1], label='All days bids'),
                       Patch(facecolor=colors[2], label='Weekdays bids')]
    plt.legend(handles=legend_elements, loc='upper center')

    plt.tight_layout()
    plt.grid(axis='y', alpha=0.22)
    plt.grid(axis='x', alpha=0.22)
    plt.show()

annotations = [
    # Format: (x-coordinate, y-coordinate, 'label', 'color')
    # Add your specific data points here
    (24, matrix1[23, 0], '70', 'blue'),  # Example annotation for the first point in matrix1
    (24, matrix1[23, 2], '72', 'blue'),  # Example annotation for a point in matrix2
    (23.9, matrix2[23, 0]-10, '142', 'green'),  # Example annotation for the first point in matrix1
    (23.9, matrix2[23, 2]-10, '143', 'green'),  # Example annotation for a point in matrix2
    (25, matrix2[23, 1]-10, '144', 'green'),  # Example annotation for a point in matrix2
    (13, matrix1[12, 1]+1, '38', 'blue'),  # Example annotation for a point in matrix2
    (13, matrix3[12, 2]-28, '178', 'red'),  # Example annotation for a point in matrix2
    # Add more as needed, with colors
]

plot_combined_points(matrix1, matrix2, matrix3, annotations)


bids_day_dependent = (sum(sum(matrix3))/7*5+sum(sum(matrix1))/7*2)/5

bids_not_d = sum(sum(matrix2))/5

print(bids_day_dependent/bids_not_d)