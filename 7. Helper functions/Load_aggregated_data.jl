function Load_aggregated(CB_Is)
    # Initialize an empty matrix with the same number of rows as your vectors and the number of columns equal to the number of vectors
    global Max_Power_all =   Matrix{Float64}(undef, M_d*Days, I)                                            # max power of box
    global po_cap_all =  Matrix{Float64}(undef, M_d*Days, I)                                                # % of resovior stored
    global kWh_cap_all = Matrix{Float64}(undef, M_d*Days, I)                                                # kWh of resovior charged
    global Power_all =  Matrix{Float64}(undef, M_d*Days, I)                                                 # baseline power
    global Connected_all =  Matrix{Float64}(undef, M_d*Days, I)                                             # minutes where CB is connected
    global Upwards_flex_all =  Matrix{Float64}(undef, M_d*Days, I)                                          # Upwards flexibity for all charge boxses
    global Downwards_flex_all =  Matrix{Float64}(undef, M_d*Days, I)                                        # downwards flexibity for all charge boxses

    global SoC_A_cap_all = zeros(M_d*Days)
                                                                    # the total capacity for each scenario
    if CB_Is[1] > 1
        global energy_20_all = EV_20_dataframes["$(CB_Is[end])"][:,1] - EV_20_dataframes["$(CB_Is[1]-1)"][:,1]
    else
        global energy_20_all = EV_20_dataframes["$I"][:,1]
    end
    global energy_20_all = energy_20_all*60
    # Loop through each vector and add it to the matrix
    counter = 0 # count numbers of charge boxes loaded to keep user updated
    Threads.@threads for i=CB_Is[1]:CB_Is[end]
        counter = counter + 1 # new
        if counter % 10 == 0
            println("the number of charge box loaded are $counter")
        end
        Max_Power_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,5]
        po_cap_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,1]
        kWh_cap_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,2]
        Power_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,3]
        Connected_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,4]
        Upwards_flex_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,8]
        Downwards_flex_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,7]

    end



    if Sampling == 1
        global dis = zeros(3,21900,24)                                                                          # The minute-resolution distribution of each hour, the first index gives which distribution assesing -> dis[1]= upwards, dis[2], downwards, dis[3]= energy
        for d=1:365                                                                                             # The second index is the samples, and the third is hour of concer, i.e. the hour we're inspecting
            for t=1:24
                for m=1:M
                    dis[1,(d-1)*60+m,t] = float(sum( Downwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
                    dis[2,(d-1)*60+m,t] = float(sum( Upwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
                    dis[3,(d-1)*60+m,t] = float(energy_20_all[(d-1)*1440+(t-1)*60+m])
                end
            end
        end
    elseif Sampling == 3 ||  Sampling == 2
        global dis = zeros(3,365,24,60)                                                                          # The minute-resolution distribution of each hour, the first index gives which distribution assesing -> dis[1]= upwards, dis[2], downwards, dis[3]= energy
        for d=1:365                                                                                             # The second index is the samples, and the third is hour of concer, i.e. the hour we're inspecting
            for t=1:24
                for m=1:M
                    dis[1,d,t,m] = float(sum( Downwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
                    dis[2,d,t,m] = float(sum( Upwards_flex_all[(d-1)*1440+(t-1)*60+m,:] ))
                    dis[3,d,t,m] = float(energy_20_all[(d-1)*1440+(t-1)*60+m])
                end
            end
        end
    end
end
