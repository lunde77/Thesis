function make_flexibility_excel(CB_Is)
    # Initialize an empty matrix with the same number of rows as your vectors and the number of columns equal to the number of vectors
    #global Max_Power_all =   Matrix{Float64}(undef, M_d*Days, I)                                            # max power of box
    #global po_cap_all =  Matrix{Float64}(undef, M_d*Days, I)                                                # % of resovior stored
    #global kWh_cap_all = Matrix{Float64}(undef, M_d*Days, I)                                                # kWh of resovior charged
    #global Power_all =  Matrix{Float64}(undef, M_d*Days, I)                                                 # baseline power
    #global Connected_all =  Matrix{Float64}(undef, M_d*Days, I)                                             # minutes where CB is connected
    global Upwards_flex_all =  Matrix{Float64}(undef, M_d*Days, I)                                          # Upwards flexibity for all charge boxses
    global Downwards_flex_all =  Matrix{Float64}(undef, M_d*Days, I)                                        # downwards flexibity for all charge boxses
    global Upwards_flex_excel =  Matrix{Float64}(undef, M_d*Days, Int64(1420/10))                              # Upwards flexibity for all charge boxses
    global Downwards_flex_excel =  Matrix{Float64}(undef, M_d*Days,  Int64(1420/10))                                        # downwards flexibity for all charge boxses

    #global SoC_A_cap_all = zeros(M_d*Days)
                                                                    # the total capacity for each scenario
    # Loop through each vector and add it to the matrix
    counter = 0 # count numbers of charge boxes loaded to keep user updated
    Threads.@threads for i=CB_Is[1]:CB_Is[end]
        counter = counter + 1 # new
        Upwards_flex_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,8]
        Downwards_flex_all[:,i-CB_Is[1]+1]= EV_dataframes[dataframe_names[CB_Is[i-CB_Is[1]+1]]][:,7]
        if counter % 10 == 0
            println("the number of charge box loaded are $counter")
        end
    end

    for i=1:142
        println(i)
        for d=1:365                                                                                             # The second index is the samples, and the third is hour of concer, i.e. the hour we're inspecting
            for t=1:24
                Threads.@threads for m=1:60
                    Downwards_flex_excel[(d-1)*1440+(t-1)*60+m,i] = float(sum( Downwards_flex_all[(d-1)*1440+(t-1)*60+m, 1:Int64(i*10)] ))
                    Upwards_flex_excel[(d-1)*1440+(t-1)*60+m,i] = float(sum( Upwards_flex_all[(d-1)*1440+(t-1)*60+m, 1:Int64(i*10)] ))
                end
            end
        end
    end

    results_df = DataFrame(Downwards_flex_excel, :auto)
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\EV\\Downwards_flexibilities"
    CSV.write(base_path*".csv", results_df)

    results_df = DataFrame(Upwards_flex_excel, :auto)
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\EV\\Upwards_flexibilities"
    CSV.write(base_path*".csv", results_df)
end
