
# run all files, so all functions are intialized

# Define the base folder path
Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

include("C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"*"data_load.jl") # funciton for loading all data


Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

include("$base_path"*"4. Tests\\Main.jl")
include("$base_path"*"4. Tests\\Plots\\Deterministic d1\\plot_function.jl") # function for plotting data
include("$base_path"*"7. Helper functions\\baseline_atering.jl")
include("$base_path"*"1. Models\\Deterministic_v1.jl")
