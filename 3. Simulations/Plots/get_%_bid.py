# -*- coding: utf-8 -*-
"""
Created on Thu Jan 18 00:47:29 2024

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
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import matplotlib.lines as mlines
#####
plt.rcParams.update({'font.size': 20.5})  # You can adjust the size as needed

flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_70.csv")
flex_2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_2_70.csv")
flex_3 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_3_70.csv")
non_zero_elements = flex.iloc[:,5][flex.iloc[:,5] != 0]
non_zero_elements_2 = flex_2.iloc[:,5][flex_2.iloc[:,5] != 0]
non_zero_elements_3 = flex_3.iloc[:,5][flex_3.iloc[:,5] != 0]
flex.iloc[:,5]

a70_flex = np.concatenate([non_zero_elements, non_zero_elements_2,non_zero_elements_3])

a28_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_28.csv")
a14_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_14.csv")
a10_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_10.csv")
a7_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_7.csv")
a4_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_4.csv")
a2_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_2.csv")
a1_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\results_N_bundles_1.csv")




a70_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_70.csv")  
a28_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_28.csv")
a14_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_14.csv")
a10_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_10.csv")
a7_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_7.csv")
a4_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_4.csv")
a2_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_2.csv")
a1_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_1.csv")


for j in range(8760):
    sums_28[j] = a28_flex.iloc[j, :].sum()
    sums_14[j] = a14_flex.iloc[j, :].sum()
    sums_10[j]  = a10_flex.iloc[j, :].sum()
    sums_7[j] = a7_flex.iloc[j, :].sum()
    sums_4[j] = a4_flex.iloc[j, :].sum()
    sums_2[j]  = a2_flex.iloc[j, :].sum()
    sums_1[j] = a1_flex.iloc[j, :].sum()
    



# Adjust font size
plt.rcParams.update({'font.size': 20.5})

# Generate dummy data (the same as before)
np.random.seed(0)
x_values = np.array([1, 2, 4, 7, 10, 14, 28, 70])
categories = ['ALSO-X', 'CVaR']
data = []
for x in x_values:
    for category in categories:
        if x == 70:
            if category == "ALSO-X":
                revenues = a1_flex.iloc[:,5]*100
            else:
                revenues = a1_flex_C.iloc[:,5]*100
            
        elif x == 28:
            if category == "ALSO-X":
                revenues = a2_flex.iloc[:,5]*100
            else:
                revenues = a2_flex_C.iloc[:,5]*100
            
            
        elif x==14:
            if category == "ALSO-X":
                revenues = a4_flex.iloc[:,5]*100
            else:
                revenues = a4_flex_C.iloc[:,5]*100
            
        elif x==10:
            if category == "ALSO-X":
                revenues = a7_flex.iloc[:,5]*100
            else:
                revenues = a7_flex_C.iloc[:,5]*100
            
        elif x==7:
            if category == "ALSO-X":
                revenues = a10_flex.iloc[:,5]*100
            else:
                revenues = a10_flex_C.iloc[:,5]*100
            
        elif x==4:
            if category == "ALSO-X":
                revenues = a14_flex.iloc[:,5]*100
            else:
                revenues = a14_flex_C.iloc[:,5]*100
            
        elif x==2:
            if category == "ALSO-X":
                revenues = a28_flex.iloc[:,5]*100
            else:
                revenues = a28_flex_C.iloc[:,5]*100
            
        else:
            if category == "ALSO-X":
                revenues = a70_flex*100
            else:
                revenues = a70_flex_C.iloc[:,5]*100
            
            
        
        
