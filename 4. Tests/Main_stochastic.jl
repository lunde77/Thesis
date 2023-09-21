function Main_stochastic(CB_Is)
    # Static Parameters
    global T = 24 # hours on a day
    global M = 60 # minutes in an hour
    global M_d = T*M # minutes per model, i.e. per day
    global Days = 365
    global I = size(CB_Is)[1]


    global revenue =  0
    global missing_delivery = 0
    global Up_bids_A = zeros(M_d,Days)
    global Do_bids_A = zeros(M_d,Days)
    global Up_bids_I = zeros(M_d,Days,I)
    global Do_bids_I = zeros(M_d,Days,I)
    global Power_A = zeros(M_d,Days)
    global SoC_A = zeros(M_d,Days)
    global MA_A = zeros(M_d,Days)

    # Initialize an empty matrix with the same number of rows as your vectors and the number of columns equal to the number of vectors
    global Max_Power_all =   Matrix{Float64}(undef, M_d*Days, I)                                            # max power of box
    global po_cap_all =  Matrix{Float64}(undef, M_d*Days, I)                                                # % of resovior stored
    global kWh_cap_all = Matrix{Float64}(undef, M_d*Days, I)                                                # kWh of resovior charged
    global Power_all =  Matrix{Float64}(undef, M_d*Days, I)                                                 # baseline power
    global Connected_all =  Matrix{Float64}(undef, M_d*Days, I)                                             # minutes where CB is connected

    global SoC_A_cap_all = zeros(M_d*Days)

    # Loop through each vector and add it to the matrix
    for i=1:I
        Max_Power_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,5]
        po_cap_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,1]
        kWh_cap_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,2]
        Power_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,3]
        Connected_all[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,4]

        for m=1:525600
            if Connected_all[m,i] == 1
                global SoC_A_cap_all[m] = SoC_A_cap_all[m]+kWh_cap_all[m,i]/po_cap_all[m,i]
            end
        end
    end



    for Day=1:5
        print("day is $Day")
        global SoC_start = zeros(I)
        global La_do = Do_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1
        global La_up = Up_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1
        global Ac_do = Ac_dowards[(Day-1)*M_d+1:(Day)*M_d]                                                # activation % downwards
        global Ac_up = Ac_upwards[(Day-1)*M_d+1:(Day)*M_d]                                                # activation % upwards

        global Max_Power =  Max_Power_all[(Day-1)*M_d+1:(Day)*M_d, :]                                     # max power of box
        global po_cap = po_cap_all[(Day-1)*M_d+1:(Day)*M_d, :]                                            # % of resovior stored
        global kWh_cap = kWh_cap_all[(Day-1)*M_d+1:(Day)*M_d, :]                                          # kWh of resovior charged
        global Power = Power_all[(Day-1)*M_d+1:(Day)*M_d, :]                                              # baseline power
        global Connected = Connected_all[(Day-1)*M_d+1:(Day)*M_d, :]                                      # minutes where CB is connected
        global SoC_A_cap = SoC_A_cap_all[(Day-1)*M_d+1:(Day)*M_d]                                         # The aggregated resovior capacity




        for i=1:I
            if Day == 1
                global SoC_start[i] = kWh_cap[1,i]
            else
                global SoC_start[i] = SoC_end[i]
            end
            Power[:,i], altered = baseline_altering(Power[:,i], SoC_start[i], Connected[:,i], po_cap[:,i], kWh_cap[:,i])
        end

        Up_bids_A[:,Day], Do_bids_A[:,Day], Up_bids_I[:,Day,:], Do_bids_I[:,Day,:], Power_A[:,Day], MA_A[:,Day], SoC_A[:,Day], SoC_end, obj = deterministic_model(La_do, La_up, Ac_do, Ac_up, Max_Power, po_cap, kWh_cap, Power, Connected, SoC_start, SoC_A_cap, I)

        println(SoC_end)

        SoC_end, missing_del =  operation(kWh_cap, po_cap, Power, SoC_start, Max_Power, Ac_up, Ac_do, Do_bids_A, Up_bids_A)

        println(SoC_end)

        revenue = revenue + obj
        missing_delivery = missing_delivery + missing_del

        global SoC_end
    end

    println("The revenue in oracle mode would be $revenue")
    println("The missing delivery in oracle mode would be $missing_delivery")
    return revenue, missing_delivery
end
