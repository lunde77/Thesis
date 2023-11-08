
println("I'm starting now")


for i=1:500
    if i==1
        global large_matrix_total = zeros(1440*365,20)
        global aggregated = collect(10:10:500)
    end
    println(i)
    CB = i
    global M_d = 1440
    global Days = 365


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

        global day_20_flex = resoivior_avaible_excel(Connected_r, po_cap_r, kWh_cap_r, 0.9)

        global large_matrix = vcat(large_matrix, day_20_flex)
    end
    large_matrix_total = large_matrix_total + large_matrix
    if i in aggregated
        global minute_flex_20 = zeros(1440*365,1)
        for Day=1:365
            for m=1:M_d
                global minute_flex_20[(Day-1)*M_d+m] = findmin(large_matrix_total[(Day-1)*M_d+m,:])[1]
            end
        end

        results_df = DataFrame(minute_flex_20, :auto)
        base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\EV\\20_minute data\\"
        CSV.write(base_path*"$i.csv", results_df)
    end
end
