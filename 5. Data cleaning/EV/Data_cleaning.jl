using CSV
using DataFrames
using Dates
#using Plots

#file_path = raw"C:\Users\Gustav\Documents\Thesis\data\EV\metervalues_pull_23_03_23_xx.csv"

# Load the CSV file into a DataFrame
#df = CSV.File(file_path) |> DataFrame

# Replace target_cbid with the CBID you want to filter by
CBIDs =  unique(df."CBID")

global M =  24*60*365

# Specify column names (replace with your own column names)
column_names = ["energy_resovior (%)", "SoC (kWh)", "power(kW)", "connected (1 or 0)",  "max_effect of charger (kW)",  "minute of year"]
#global my_list = []
for i=1540:1649
    println(i)
    global EV_DATA_done = zeros(M, 6)
    global EV_DATA_done[:,:], work, avg_resolution = make_data(CBIDs[i])

    if work == true
        println("the charger is turned on $(sum(EV_DATA_done[:,4])/(24*60*365))% of the time")


        EV_data_df = DataFrame(EV_DATA_done,  :auto)
        rename!(EV_data_df, Symbol.(column_names))

        # Specify the file path where you want to save the Excel file
        base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\EV\\"
        CSV.write(base_path*"CD_$(CBIDs[i]).csv", EV_data_df) # send it to a

        append!(my_list, avg_resolution)
    end


end

# Step 3: Calculate the mean of the elements in the list
mean_value =  sum(my_list)/size(my_list)[1]

println("List: ", my_list)
println("Mean: ", mean_value)

#plot(EV_DATA_done[:,3], label = "Power")
#plot!(EV_DATA_done[:,1], label = "resovior- %")
#plot!(EV_DATA_done[:,2], label = "resovior - kWh ")
#plot!(EV_DATA_done[:,4], label = "conncted")
#plot!(EV_DATA_done[:,5], label = "Max charger power")
