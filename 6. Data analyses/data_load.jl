using CSV
using DataFrames
using XLSX

##### Output:

# EV_dataframes: containt dataframe for all CB data.
    # each dataframe can be acsssed by the stating the number of the charge box, as e.g. EV_dataframes["2067"]
    # or the simply by given the index, as the names of each charge box is stored in dataframe_names, e.g. charce boc 5 is loaded by:  EV_dataframes[dataframe_names[5]]
    # it has 6 column:
        # %-resovior
        # kWh resovior
        # Power kW
        # Connected 1 or 0
        # max effect kW
        # minute of year (also the index)

#Up_prices_d1:  Upregulation prices for d-1 per hour in DKK/kW
#Up_prices_d2:  Upregulation prices for d-2 per hour in DKK/kW
#Do_prices_d1: Downregulation prices for d-1 per hour in DKK/kW
#Do_prices_d2: Downregulation prices for d-2 per hour in DKK/kW

# Ac_up: activation rate per minue in % for up regulation
# Ac_do: activation rate per minue in % for down regulation


####### Paths ########

<<<<<<< HEAD:data_load.jl
# Define the base folder path
Emil = true

=======
>>>>>>> 9a75575bffdb57dddc81864c3cf45d299bd450ac:6. Data analyses/data_load.jl
if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\data\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\"
end


####### Load Activations rates ########

Freq_data =  XLSX.readxlsx("$base_path"*"Frequency\\Activation.xlsx")
global Ac_dowards =  Freq_data["Sheet1!A2:A525601"]  # in %
global Ac_upwards =  Freq_data["Sheet1!B2:B525601"]  # in #



####### Load FCR-D prices ########

xf_FCR_D_Prices = XLSX.readxlsx("$base_path"*"Price\\FCR_prices.xlsx")
global Do_prices_d1 =  xf_FCR_D_Prices["Sheet1!A2:A8761"]  # in DKK/kW
global Do_prices_d2 =  xf_FCR_D_Prices["Sheet1!B2:B8761"]  # in DKK/kW
global Up_prices_d1  =  xf_FCR_D_Prices["Sheet1!C2:C8761"]  # in DKK/kW
global Up_prices_d2  =  xf_FCR_D_Prices["Sheet1!D2:D8761"]  # in DKK/kW

# file missing data with zeros
Up_prices_d1 = coalesce.(Up_prices_d1, 0)
Up_prices_d2 = coalesce.(Up_prices_d2, 0)
Do_prices_d1 = coalesce.(Do_prices_d1, 0)
Do_prices_d2 = coalesce.(Do_prices_d2, 0)

Mi = 24*365

# convert to danish DKK
for m=1:Mi
        global Up_prices_d1[m] = Up_prices_d1[m]/1000*7.8
        global Up_prices_d2[m] = Up_prices_d2[m]/1000*7.8
        global Do_prices_d1[m] = Do_prices_d1[m]/1000*7.8
        global Do_prices_d2[m] = Do_prices_d2[m]/1000*7.8
end


####### LOAD DATA FOR EV CHARGE box ########

# Get a list of all CSV files in the folder
file_names = readdir("$base_path"*"EV\\cleaned data\\", join=true)
dataframe_names = file_names
# Create a dictionary to store the loaded DataFrames
global EV_dataframes = Dict{String, DataFrame}()

# Set the number of files to load - defount is all
#num_files_to_load = size(dataframe_names)[1] # outcomment this (not delete), if other option than all is selceted
num_files_to_load = 50

# Load only CSV files and store them in the dictionary
global i = 0
for file_path in file_names
    global i = i + 1

    if i > num_files_to_load
        break
    end
    if endswith(file_path, ".csv")
        #_, filename, _ = splitpath(file_path)  # Extract the file name without extension
        filename = file_path

        dataframe_name = filename[58:61]  # Remove the first 3 characters
        dataframe_names[i] = dataframe_name
        println("File Path: $file_path")
        println("Dataframe Name: $dataframe_name")
        global EV_dataframes[dataframe_name] = CSV.File(file_path) |> DataFrame
    end
end
