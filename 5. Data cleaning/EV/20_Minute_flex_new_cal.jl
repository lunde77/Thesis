using CSV
using DataFrames
using XLSX

println("I'm starting now")
Emil = false
if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\data\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\"
end

# Get a list of all CSV files in the folder
file_names = readdir("$base_path"*"EV\\cleaned_data_RM90\\", join=true)
dataframe_names = file_names
# Create a dictionary to store the loaded DataFrames
global EV_dataframes = Dict{String, DataFrame}()

global results = zeros(1440,3)

for i=1:1400
    if i==1
        global large_matrix_total = zeros(1440*365,20)
        global aggregated = collect(10:10:1420)
    end
    global num_files_to_load = 1420
    global M_d = 1440
    global Days = 365
    if i > num_files_to_load
        break
    end
    println(i)
    file_path = file_names[i]

    if endswith(file_path, ".csv")
        #_, filename, _ = splitpath(file_path)  # Extract the file name without extension
        filename = file_path
        if Emil
            dataframe_name = filename[66:69]
        else
            dataframe_name = filename[60:63]  # Remove the first 3 characters
        end
        dataframe_names[i] = dataframe_name
        println("File Path: $file_path")
        println("Dataframe Name: $dataframe_name")
        global EV_dataframes[dataframe_name] = CSV.File(file_path) |> DataFrame
    end


    global po_cap_all =  Matrix{Float64}(undef, M_d*Days,1)                                                # % of resovior stored
    global kWh_cap_all = Matrix{Float64}(undef, M_d*Days,1)                                                # kWh of resovior charged
    global Power_all =  Matrix{Float64}(undef, M_d*Days,1)                                                 # baseline power
    global Connected_all =  Matrix{Float64}(undef, M_d*Days,1)                                             # minutes where CB is connected

    po_cap_all[:] = EV_dataframes[dataframe_names[i]][:,1]
    kWh_cap_all[:] = EV_dataframes[dataframe_names[i]][:,2]
    Connected_all[:] = EV_dataframes[dataframe_names[i]][:,4]

    global large_matrix = Matrix{Float64}(undef, 0, 20)  # Empty matrix with 20 columns and 0 rows

    for Day=1:365
        po_cap_r = po_cap_all[(Day-1)*M_d+1:(Day)*M_d]                                            # % of resovior stored
        kWh_cap_r  = kWh_cap_all[(Day-1)*M_d+1:(Day)*M_d]                                         # kWh of resovior charged
        Connected_r  = Connected_all[(Day-1)*M_d+1:(Day)*M_d]                                     # minutes where CB is connected

        day_20_flex = resoivior_avaible_excel(Connected_r, po_cap_r, kWh_cap_r, 0.9)

        large_matrix = vcat(large_matrix, day_20_flex)
    end
    #large_matrix_total = large_matrix_total + large_matrix

    global minute_flex_20 = zeros(1440*365,1)
    for Day=1:365
        Threads.@threads for m=1:M_d
            minute_flex_20[(Day-1)*M_d+m] = findmin(large_matrix[(Day-1)*M_d+m,:])[1]
        end
    end
    global results[i,1] =  sum(minute_flex_20*60)/1000
    global results[i,2] =  sum(EV_dataframes[dataframe_names[i]][:,7])/1000
    global results[i,3] =  sum(EV_dataframes[dataframe_names[i]][:,8])/1000

    results_df = DataFrame(results, :auto)
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\EV\\20_minute data\\ss"
    CSV.write(base_path*"all.csv", results_df)

end
