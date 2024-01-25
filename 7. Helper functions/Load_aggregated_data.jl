function Load_aggregated(CB_Is)


    # extract the data column for the given portefolio size of inspection

    if DUMMY == true
        # Define the number of elements
        NC =  length(collect(1:599))
        n_elements = 525600
        # Generate three random random with n_elements - started between 0.1 and 0.5
        energy_20_all = rand(0.1:0.01:0.7, n_elements)
        Upwards_flex_all = rand(0.1:0.01:0.7, n_elements)
        Downwards_flex_all = rand(0.1:0.01:0.7, n_elements)
        # Multiply each element of the vector to caouse varibility between the vectors and reseable N of CBs
        Downwards_flex_all = Downwards_flex_all .* 4*NC
        energy_20_all = energy_20_all .* 5*NC
        Upwards_flex_all = Upwards_flex_all .* 1*NC
    else

        if CB_Is[1] > 1
            global energy_20_all = EV_20_dataframes["$(CB_Is[end])"][:,1] - EV_20_dataframes["$(CB_Is[1]-1)"][:,1]
            global Downwards_flex_all =  Downwards_flex_excel[:,Int16((CB_Is[end])/10)]-Downwards_flex_excel[:,Int16((CB_Is[1]-1)/10)]
            global Upwards_flex_all   =  Upwards_flex_excel[:,Int16((CB_Is[end])/10)]-Upwards_flex_excel[:,Int16((CB_Is[1]-1)/10)]
        elseif CB_Is[1] == 1 && CB_Is[end] == 1 # if we only want to look at CB1
            global energy_20_all = EV_20_dataframes["$I"][:,1]
            global Upwards_flex_all = EV_dataframes[dataframe_names[I-CB_Is[1]+1]][:,8]
            global Downwards_flex_all = EV_dataframes[dataframe_names[I-CB_Is[1]+1]][:,7]
        else
            global energy_20_all = EV_20_dataframes["$I"][:,1]
            global Downwards_flex_all = Downwards_flex_excel[:,Int16(I/10)]
            global Upwards_flex_all = Upwards_flex_excel[:,Int16(I/10)]
        end

        global energy_20_all = energy_20_all*60 # adjust data to fit scale

        # load data for first CB
        global Upwards_flex_CB1 = EV_dataframes[dataframe_names[1]][:,8]
        global Downwards_flex_CB1 = EV_dataframes[dataframe_names[1]][:,7]

    end
    # create distributions
    if Sampling == 1
        global dis = zeros(3,21900,24)                                                                          # The hourly-resolution distribution, the first index gives which distribution assesing -> dis[1]= upwards, dis[2], downwards, dis[3]= energy
        for d=1:365                                                                                             # The second index is the samples, and the third is hour of concer, i.e. the hour we're inspecting
            for t=1:24
                for m=1:M
                    dis[1,(d-1)*60+m,t] = float(sum( Downwards_flex_all[(d-1)*1440+(t-1)*60+m] ))
                    dis[2,(d-1)*60+m,t] = float(sum( Upwards_flex_all[(d-1)*1440+(t-1)*60+m] ))
                    dis[3,(d-1)*60+m,t] = float(energy_20_all[(d-1)*1440+(t-1)*60+m])
                end
            end
        end
    elseif  Sampling == 4 || Sampling == 3 ||  Sampling == 2 || Sampling == 5
        global dis = zeros(3,365,24,60)                                                                          # The minute-resolution distribution of each hour, the first index gives which distribution assesing -> dis[1]= upwards, dis[2], downwards, dis[3]= energy
        for d=1:365                                                                                             # The second index is the samples, and the third is hour of concer, i.e. the hour we're inspecting
            for t=1:24
                for m=1:M
                    dis[1,d,t,m] = float(sum( Downwards_flex_all[(d-1)*1440+(t-1)*60+m] ))
                    dis[2,d,t,m] = float(sum( Upwards_flex_all[(d-1)*1440+(t-1)*60+m] ))
                    dis[3,d,t,m] = float(energy_20_all[(d-1)*1440+(t-1)*60+m])
                end
            end
        end
    end


    # defines which days that are weekdays and which day are weekendays
    global D_s = Vector{Float64}()                  # weekendays
    global D_w = Vector{Float64}()                  # weekdays
    push!(D_s, 4)
    push!(D_s, 5)
    push!(D_w, 1)
    push!(D_w, 2)
    push!(D_w, 3)

    global counter = zeros(1)
    for j=1:360
        counter[1] = counter[1] + 1
        println(counter[1])
        if counter[1] <= 5
            push!(D_w, j+5)
        else
            push!(D_s, j+5)
        end

        if counter[1] >= 7
            counter[1] = 0
        end
    end

end
