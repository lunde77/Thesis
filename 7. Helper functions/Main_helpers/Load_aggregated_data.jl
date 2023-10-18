function Load_aggregated(CB_Is)
    # Initialize an empty matrix with the same number of rows as your vectors and the number of columns equal to the number of vectors
    global Max_Power_all =   Matrix{Float64}(undef, M_d*Days, I)                                            # max power of box
    global po_cap_all =  Matrix{Float64}(undef, M_d*Days, I)                                                # % of resovior stored
    global kWh_cap_all = Matrix{Float64}(undef, M_d*Days, I)                                                # kWh of resovior charged
    global Power_all =  Matrix{Float64}(undef, M_d*Days, I)                                                 # baseline power
    global Connected_all =  Matrix{Float64}(undef, M_d*Days, I)                                             # minutes where CB is connected
    global Upwards_flex_all =  Matrix{Float64}(undef, M_d*Days, I)                                          # Upwards flexibity for all charge boxses
    global Downwards_flex_all =  Matrix{Float64}(undef, M_d*Days, I)                                        # downwards flexibity for all charge boxses

    global SoC_A_cap_all = zeros(M_d*Days)                                                                  # the total capacity for each scenario

    global energy_20_all = EV_20_dataframes["$I"][:,1]
    # Loop through each vector and add it to the matrix
    for i=1:I
        Max_Power_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,5]
        po_cap_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,1]
        kWh_cap_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,2]
        Power_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,3]
        Connected_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,4]
        Upwards_flex_all[:,i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,8]
        Downwards_flex_all[:,i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,7]

        #for m=1:525600
        #    if Connected_all[m,i] == 1
        #        global SoC_A_cap_all[m] = SoC_A_cap_all[m]+kWh_cap_all[m,i]/po_cap_all[m,i]
        #    end
        #end

    end
end
