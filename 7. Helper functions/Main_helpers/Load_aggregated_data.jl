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
    if CB_Is[1] > 1
        global energy_20_all = EV_20_dataframes["$(CB_Is[end])"][:,1] - EV_20_dataframes["$(CB_Is[1]-1)"][:,1]
    else
        global energy_20_all = EV_20_dataframes["$I"][:,1]
    end
    # Loop through each vector and add it to the matrix
    for i=CB_Is[1]:CB_Is[end]

        Max_Power_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,5]
        po_cap_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,1]
        kWh_cap_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,2]
        Power_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,3]
        Connected_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,4]
        Upwards_flex_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,8]
        Downwards_flex_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,7]

        # midlettidligt fix
        if Max_Power_all[2,i-CB_Is[1]+1]> 30
            println(dataframe_names[CB_Is[i-CB_Is[1]+1]])
            Max_Power_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,5]*0
            po_cap_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,1]*0
            kWh_cap_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,2]*0
            Power_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,3]*0
            Connected_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,4]*0
            Upwards_flex_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,8]*0
            Downwards_flex_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,7]*0
        end
    end



    if Sampling == 1
        global dis = zeros(3,21900,24)                                                                          # The minute-resolution distribution of each hour, the first index gives which distribution assesing -> dis[1]= upwards, dis[2], downwards, dis[3]= energy
        for d=1:365                                                                                             # The second index is the samples, and the third is hour of concer, i.e. the hour we're inspecting
            for t=1:24
                for m=1:M
                    dis[1,(d-1)*60+m,t] = float(sum( Downwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
                    dis[2,(d-1)*60+m,t] = float(sum( Upwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
                    dis[3,(d-1)*60+m,t] = float(sum( energy_20_all[(d-1)*1440+(t-1)*60+m,:] )*60)
                end
            end
        end
    elseif Sampling == 2
        global dis = zeros(3,365,24,60)                                                                          # The minute-resolution distribution of each hour, the first index gives which distribution assesing -> dis[1]= upwards, dis[2], downwards, dis[3]= energy
        for d=1:365                                                                                             # The second index is the samples, and the third is hour of concer, i.e. the hour we're inspecting
            for t=1:24
                for m=1:M
                    dis[1,d,t,m] = float(sum( Downwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
                    dis[2,d,t,m] = float(sum( Upwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
                    dis[3,d,t,m] = float(sum( energy_20_all[(d-1)*1440+(t-1)*60+m,:] )*60)
                end
            end
        end
    end
end
