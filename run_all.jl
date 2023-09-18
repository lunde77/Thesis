
# run all files, so all functions are intialized

# Define the base folder path
Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    global base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"
    print(base_path)

    include("C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"*"data_load.jl") # funciton for loading all data
    include(raw"C:\Users\Gustav\Documents\Thesis\Git\4. Tests\Main.jl")
    include("C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"*"4. Tests\\Plots\\Deterministic d1\\plot_function.jl") # function for plotting data
end
