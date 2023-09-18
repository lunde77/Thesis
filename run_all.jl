
# run all files, so all functions are intialized

# Define the base folder path
Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    global base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"
end

include("$base_path"*"data_load.jl") # funciton for loading all data

include("$base_path"*"4. Tests\\Plots\\Deterministic d1\\plot_function.jl") # function for plotting data
include(raw"C:\Users\Gustav\Documents\Thesis\Git\4. Tests\Main.jl")
