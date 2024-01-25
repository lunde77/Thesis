using StatsPlots
using CSV
using DataFrames
using XLSX


flex = CSV.File(raw"C:\Users\Gustav\Documents\Thesis\data\EV\20_minute data\ssall.csv")|> DataFrame
# Sample data for demonstration
group1 =  flex[1:1261,1]
group2 = flex[1:1261,2]
group3 = flex[1:1261,3]

# Plotting boxplots with labeled x-axis
boxplot([group1, group2, group3], labels=["Group 1", "Group 2", "Group 3"], legend=false,
        title="Boxplot of Three Groups", xlabel="Groups", ylabel="Values")

# Save the plot if needed
#savefig("boxplot.png")
