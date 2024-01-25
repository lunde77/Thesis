# -*- coding: utf-8 -*-
"""
Created on Tue Jan  2 18:25:52 2k24

@author: Gustav
"""

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import matplotlib.lines as mlines
#####


# Replace this with your actual file reading code
L1 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\results_N_bundles_LER_1.csv")
L2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\results_N_bundles_LER_2.csv")
L3 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\results_N_bundles_LER_4.csv")
L8 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\results_N_bundles_LER_7.csv")
L4 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\results_N_bundles_LER_10.csv")
L5 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\results_N_bundles_LER_14.csv")
L6 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\results_N_bundles_LER_28.csv")
L7 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\results_N_bundles_LER_70.csv")


L1O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Overbid_distribution_N_bundles_LER_1.csv")
L2O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Overbid_distribution_N_bundles_LER_2.csv")
L3O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Overbid_distribution_N_bundles_LER_4.csv")
L8O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Overbid_distribution_N_bundles_LER_7.csv")
L4O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Overbid_distribution_N_bundles_LER_10.csv")
L5O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Overbid_distribution_N_bundles_LER_14.csv")
L6O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Overbid_distribution_N_bundles_LER_28.csv")
L7O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\plot 8 (LER sensitivitet)\Overbid_distribution_N_bundles_LER_70.csv")


flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_70.csv")
flex_2 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_2_70.csv")
flex_3 = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_3_70.csv")
    
a28_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_28.csv")
a14_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_14.csv")
a10_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_10.csv")
a7_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_4_7.csv")
a4_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_4.csv")
a2_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_2.csv")
a1_flex = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\nok ikke bruges\results_N_bundles_4_1.csv")

k = 0
LER = np.zeros(7)
LER[0] = (np.sum(L2.iloc[:, k])+np.sum(L1.iloc[:, k])+np.sum(L3.iloc[:, k])+np.sum(L4.iloc[:, k])+np.sum(L5.iloc[:, k])+np.sum(L6.iloc[:, k])+np.sum(L8.iloc[:, k])+np.sum(L7.iloc[:, k]))/(8*24)

k = 1
LER[1] = (np.sum(L2.iloc[:, k])+np.sum(L1.iloc[:, k])+np.sum(L3.iloc[:, k])+np.sum(L4.iloc[:, k])+np.sum(L5.iloc[:, k])+np.sum(L6.iloc[:, k])+np.sum(L8.iloc[:, k])+np.sum(L7.iloc[:, k]))/8/24

k = 11
LER[2] = (np.mean(L2.iloc[:, k])+np.mean(L1.iloc[:, k])+np.mean(L3.iloc[:, k])+np.mean(L4.iloc[:, k])+np.mean(L5.iloc[:, k])+np.mean(L6.iloc[:, k])+np.mean(L8.iloc[:, k])+np.mean(L7.iloc[:, k]))/8

k = 12
LER[3] = (np.mean(L2.iloc[:, k])+np.mean(L1.iloc[:, k])+np.mean(L3.iloc[:, k])+np.mean(L4.iloc[:, k])+np.mean(L5.iloc[:, k])+np.mean(L6.iloc[:, k])+np.mean(L8.iloc[:, k])+np.mean(L7.iloc[:, k]))/8

k = 5
LER[4] = (np.mean(L2.iloc[:, k])+np.mean(L1.iloc[:, k])+np.mean(L3.iloc[:, k])+np.mean(L4.iloc[:, k])+np.mean(L5.iloc[:, k])+np.mean(L6.iloc[:, k])+np.mean(L8.iloc[:, k])+np.mean(L7.iloc[:, k]))/8

k = 3
LER[5] = (np.mean(L2.iloc[:, k])+np.mean(L1.iloc[:, k])+np.mean(L3.iloc[:, k])+np.mean(L4.iloc[:, k])+np.mean(L5.iloc[:, k])+np.mean(L6.iloc[:, k])+np.mean(L8.iloc[:, k])+np.mean(L7.iloc[:, k]))/8

k = 2
LER[6] = (np.mean(L2.iloc[:, k])+np.mean(L1.iloc[:, k])+np.mean(L3.iloc[:, k])+np.mean(L4.iloc[:, k])+np.mean(L5.iloc[:, k])+np.mean(L6.iloc[:, k])+np.mean(L8.iloc[:, k])+np.mean(L7.iloc[:, k]))/8

#LER[5] = (np.mean(L1O.iloc[:,:][L1O.iloc[:,:] !=0])[0]+np.mean(L2O.iloc[:,:][L2O.iloc[:,:] !=0])[0]+np.mean(L3O.iloc[:,:][L3O.iloc[:,:] !=0])[0]+np.mean(L4O.iloc[:,:][L4O.iloc[:,:] !=0])[0]+np.mean(L5O.iloc[:,:][L5O.iloc[:,:] !=0])[0]+np.mean(L6O.iloc[:,:][L6O.iloc[:,:] !=0])[0]+np.mean(L7O.iloc[:,:][L7O.iloc[:,:] !=0])[0])/7


k = 0
NON = np.zeros(9)
NON[0] = (np.sum(a28_flex.iloc[:, k])+np.sum(a7_flex.iloc[:, k])+np.sum(flex.iloc[:, k])+np.sum(flex_2.iloc[:, k])+np.sum(flex_3.iloc[:, k])+np.sum(a14_flex.iloc[:, k])+np.sum(a10_flex.iloc[:, k])+np.sum(a4_flex.iloc[:, k])+np.sum(a2_flex.iloc[:, k])+np.sum(a1_flex.iloc[:, k]))/8/24

k = 1
NON[1] = (np.sum(a28_flex.iloc[:, k])+np.sum(a7_flex.iloc[:, k])+np.sum(flex.iloc[:, k])+np.sum(flex_2.iloc[:, k])+np.sum(flex_3.iloc[:, k])+np.sum(a14_flex.iloc[:, k])+np.sum(a10_flex.iloc[:, k])+np.sum(a4_flex.iloc[:, k])+np.sum(a2_flex.iloc[:, k])+np.sum(a1_flex.iloc[:, k]))/8/24

k = 11
NON[2] = (np.mean(a28_flex.iloc[:, k])+np.mean(a7_flex.iloc[:, k])+(np.mean(flex.iloc[:, k])+np.mean(flex_2.iloc[:, k])+np.mean(flex_3.iloc[:, k]))/3+np.mean(a14_flex.iloc[:, k])+np.mean(a10_flex.iloc[:, k])+np.mean(a4_flex.iloc[:, k])+np.mean(a2_flex.iloc[:, k])+np.mean(a1_flex.iloc[:, k]))/8

k = 12
NON[3] = (np.mean(a28_flex.iloc[:, k])+np.mean(a7_flex.iloc[:, k])+(np.mean(flex.iloc[:, k])+np.mean(flex_2.iloc[:, k])+np.mean(flex_3.iloc[:, k]))/3+np.mean(a14_flex.iloc[:, k])+np.mean(a10_flex.iloc[:, k])+np.mean(a4_flex.iloc[:, k])+np.mean(a2_flex.iloc[:, k])+np.mean(a1_flex.iloc[:, k]))/8

k = 5
NON[4] = (np.mean(a28_flex.iloc[:, k])+np.mean(a7_flex.iloc[:, k])+(np.mean(flex.iloc[:, k])+np.mean(flex_2.iloc[:, k])+np.mean(flex_3.iloc[:, k]))/3+np.mean(a14_flex.iloc[:, k])+np.mean(a10_flex.iloc[:, k])+np.mean(a4_flex.iloc[:, k])+np.mean(a2_flex.iloc[:, k])+np.mean(a1_flex.iloc[:, k]))/8

k = 3
NON[5] = (np.mean(a28_flex.iloc[:, k])+np.mean(a7_flex.iloc[:, k])+(np.mean(flex.iloc[:, k])+np.mean(flex_2.iloc[:, k])+np.mean(flex_3.iloc[:, k]))/3+np.mean(a14_flex.iloc[:, k])+np.mean(a10_flex.iloc[:, k])+np.mean(a4_flex.iloc[:, k])+np.mean(a2_flex.iloc[:, k])+np.mean(a1_flex.iloc[:, k]))/8

k = 2
NON[6] = (np.mean(a28_flex.iloc[:, k])+np.mean(a7_flex.iloc[:, k])+(np.mean(flex.iloc[:, k])+np.mean(flex_2.iloc[:, k])+np.mean(flex_3.iloc[:, k]))/3+np.mean(a14_flex.iloc[:, k])+np.mean(a10_flex.iloc[:, k])+np.mean(a4_flex.iloc[:, k])+np.mean(a2_flex.iloc[:, k])+np.mean(a1_flex.iloc[:, k]))/8

k = 11
NON[7] = (np.mean(a28_flex.iloc[:, k])+np.mean(a7_flex.iloc[:, k])+(np.mean(flex.iloc[:, k])+np.mean(flex_2.iloc[:, k])+np.mean(flex_3.iloc[:, k]))/3+np.mean(a14_flex.iloc[:, k])+np.mean(a10_flex.iloc[:, k])+np.mean(a4_flex.iloc[:, k])+np.mean(a2_flex.iloc[:, k])+np.mean(a1_flex.iloc[:, k]))/8

k = 12
NON[8] = (np.mean(a28_flex.iloc[:, k])+np.mean(a7_flex.iloc[:, k])+(np.mean(flex.iloc[:, k])+np.mean(flex_2.iloc[:, k])+np.mean(flex_3.iloc[:, k]))/3+np.mean(a14_flex.iloc[:, k])+np.mean(a10_flex.iloc[:, k])+np.mean(a4_flex.iloc[:, k])+np.mean(a2_flex.iloc[:, k])+np.mean(a1_flex.iloc[:, k]))/8

###


a70_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_70.csv")  
a28_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_28.csv")
a14_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_14.csv")
a10_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_10.csv")
a7_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_7.csv")
a4_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_4.csv")
a2_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_2.csv")
a1_flex_C = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\Plot 6\results filer\CVaRresults_N_bundles_2_1.csv")


k = 0
CVA = np.zeros(9)

k = 11
CVA[7] = (np.mean(a28_flex_C.iloc[:, k])+np.mean(a7_flex_C.iloc[:, k])+np.mean(a70_flex_C.iloc[:, k])+np.mean(a14_flex_C.iloc[:, k])+np.mean(a10_flex_C.iloc[:, k])+np.mean(a4_flex_C.iloc[:, k])+np.mean(a2_flex_C.iloc[:, k])+np.mean(a1_flex_C.iloc[:, k]))/8

k = 12
CVA[8] = (np.mean(a28_flex_C.iloc[:, k])+np.mean(a7_flex_C.iloc[:, k])+np.mean(a70_flex_C.iloc[:, k])+np.mean(a14_flex_C.iloc[:, k])+np.mean(a10_flex_C.iloc[:, k])+np.mean(a4_flex_C.iloc[:, k])+np.mean(a2_flex_C.iloc[:, k])+np.mean(a1_flex_C.iloc[:, k]))/8

a70_flex_O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\oracle bundles\results_N_bundles_Oracle_70.csv")  
a28_flex_O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\oracle bundles\results_N_bundles_Oracle_28.csv")
a14_flex_O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\oracle bundles\results_N_bundles_Oracle_14.csv")
a10_flex_O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\oracle bundles\results_N_bundles_Oracle_10.csv")
a7_flex_O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\oracle bundles\results_N_bundles_Oracle_7.csv")
a4_flex_O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\oracle bundles\results_N_bundles_Oracle_4.csv")
a2_flex_O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\oracle bundles\results_N_bundles_Oracle_2.csv")
a1_flex_O = pd.read_csv(r"C:\Users\Gustav\Documents\Thesis\Git\3. Simulations\Stochastic results\oracle bundles\results_N_bundles_Oracle_1.csv")


k = 0
ORacle = np.zeros(9)

k = 11
ORacle[7] = (np.mean(a28_flex_O.iloc[:, k])+np.mean(a7_flex_O.iloc[:, k])+np.mean(a70_flex_O.iloc[:, k])+np.mean(a14_flex_O.iloc[:, k])+np.mean(a10_flex_O.iloc[:, k])+np.mean(a4_flex_O.iloc[:, k])+np.mean(a2_flex_O.iloc[:, k])+np.mean(a1_flex_O.iloc[:, k]))/8

k = 12
ORacle[8] = (np.mean(a28_flex_O.iloc[:, k])+np.mean(a7_flex_O.iloc[:, k])+np.mean(a70_flex_O.iloc[:, k])+np.mean(a14_flex_O.iloc[:, k])+np.mean(a10_flex_O.iloc[:, k])+np.mean(a4_flex_O.iloc[:, k])+np.mean(a2_flex_O.iloc[:, k])+np.mean(a1_flex_O.iloc[:, k]))/8




