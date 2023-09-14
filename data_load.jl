using CSV
using DataFrames


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

















# Define the base folder path
Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\EV data"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\EV\\cleaned data"
end





####### LOAD DATA FOR EV CHARGE box ########


# Get a list of all CSV files in the folder
file_names = readdir(base_path, join=true)
dataframe_names = file_names
# Create a dictionary to store the loaded DataFrames
global EV_dataframes = Dict{String, DataFrame}()

# Load only CSV files and store them in the dictionary
global i = 0
for file_path in file_names
    global i = i + 1
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
