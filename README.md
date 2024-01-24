Overview
This repository contains the implementation of an optimal bidding strategy for distributed units. The code is organized into the following folders:
1.	Models: This directory contains all the decisions models(LPs) utilized in the project.
2.	Algorithms: Here, you can find various algorithms, such as the "also-x" and realization algorithm, which are integral parts of the evaluation methods.
3.	Simulations: Results and test scripts are stored in this folder. It serves as a repository for simulation outcomes and scripts for testing purposes.
4.	Tests: This directory is dedicated to storing the evaluation methods used in the project.
5.	Data Cleaning: The initial steps of data processing occur in this folder. It includes scripts and processes for cleaning and preparing the data.
6.	Data Analyses: All data is loaded here for subsequent extraction and analysis in later stages of the project.
7.	Helper Functions: This directory houses small functions that support the main code or are used for data transformation. These functions are designed for the reader's convenience during the evaluation process.
8.	Old Files: This functions as a bin for old files that may not be used again but are retained temporarily in case they prove useful before submission.

The most critical aspects are the models, algorithms and test.
It will cover a large part of the method framework developed in the thesis.

The most critical code for each folder is preset in the folder, i.e. not in a subfolder. Scripts stored in a subfolder, are typically scripts, which are under development or don't provide much information about the overall implementation. A Radme files is avaible in each folder, which shortly present the scripts.

Necessities to run code 
To use the code in this repository, ensure that the following packages are installed:
•	Gurobi
•	JuMP
•	Random
•	Plots
•	Statistics
•	CSV
•	DataFrames


Additionally, the program utilizes threads to optimize runtime. Ensure that your Julia environment has initialized threads for computational efficiency.

Lastly, the user needs to obtain permission to gain access to the data. For now, it is not available.
A dummy data set has been set up, so the code can be tried. The steps to acsses the dummy test:

1. go to the data_load_dummy.jl and update path
2.  intiliaze all function and data by runing the "run all.jl" file
3.  go to the dummy tester in the simulation folder and input desried option to test

Additionally, the program utilizes threads to optimize runtime. Ensure that your Julia environment has initialized threads for computational efficiency.


 
