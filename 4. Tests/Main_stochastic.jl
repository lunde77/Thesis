function Main_stochastic(CB_Is)
    # Static Parameters
    global T = 24 # hours on a day
    global M = 60 # minutes in an hour
    global M_d = T*M # minutes per model, i.e. per day
    global Days = 365
    global I = size(CB_Is)[1]
    global S = 10

    # results to be stored
    global revenue =  0
    global missing_delivery = 0
    global Up_bids_A = zeros(M_d,Days)
    global Do_bids_A = zeros(M_d,Days)
    global Up_bids_I = zeros(M_d,Days,I,S)
    global Do_bids_I = zeros(M_d,Days,I,S)
    global ex_p_do = zeros(M_d,Days,S)
    global ex_p_up = zeros(M_d,Days,S)
    global ex_p_total = zeros(Days)
    global Activation_energy = zeros(M_d,Days,I)
    global missing_delivery_storer = zeros(M_d,Days,2)
    global Power_A = zeros(M_d,Days,S)
    global SoC_A = zeros(M_d,Days,S)
    global MA_A = zeros(M_d,Days,S)

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



    for Day=1:1
        println("day is $Day")
        global SoC_start_r = zeros(I)

        ###### Initialize the realized data for the given day ######
        global La_do_r = Do_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1
        global La_up_r = Up_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1
        global Ac_do_r = Ac_dowards[(Day-1)*M_d+1:(Day)*M_d]                                                # activation % downwards
        global Ac_up_r = Ac_upwards[(Day-1)*M_d+1:(Day)*M_d]                                                # activation % upwards

        global Max_Power_r =  Max_Power_all[(Day-1)*M_d+1:(Day)*M_d, :]                                     # max power of box
        global po_cap_r = po_cap_all[(Day-1)*M_d+1:(Day)*M_d, :]                                            # % of resovior stored
        global kWh_cap_r  = kWh_cap_all[(Day-1)*M_d+1:(Day)*M_d, :]                                         # kWh of resovior charged
        global Power_r  = Power_all[(Day-1)*M_d+1:(Day)*M_d, :]                                             # baseline power
        global Connected_r  = Connected_all[(Day-1)*M_d+1:(Day)*M_d, :]                                     # minutes where CB is connected
        global SoC_A_cap_r  = SoC_A_cap_all[(Day-1)*M_d+1:(Day)*M_d]                                        # The aggregated resovior capacity


        ###### Initialize the scenarios for the given day ######

        global La_do_s = scenario_generation_m(Do_prices_d1, Day, 1)                                           # Scenarios for prices down for d-1
        global La_up_s = scenario_generation_m(Up_prices_d1, Day, 1)                                           # Scenarios for prices up for d-1
        global Ac_do_s = scenario_generation_m(Ac_dowards, Day, 1)                                             # Scenarios for activation % downwards
        global Ac_up_s = scenario_generation_m(Ac_upwards, Day, 1)                                             # Scenarios for activation % upwards

        global Max_Power_s =  scenario_generation_m(Max_Power_all, Day, 2)                                     # Scenarios for max power of box
        global po_cap_s =  scenario_generation_m(po_cap_all, Day, 2)                                           # Scenarios for % of resovior stored
        global kWh_cap_s  = scenario_generation_m(kWh_cap_all, Day, 2)                                         # Scenarios for kWh of resovior charged
        global Power_s  = scenario_generation_m(Power_all, Day, 2)                                             # Scenarios for baseline power
        global Connected_s  = scenario_generation_m(Connected_all, Day, 2)                                     # Scenarios for minutes where CB is connected
        global SoC_A_cap_s  = scenario_generation_m(SoC_A_cap_all, Day, 1)                                     # Scenarios for The aggregated resovior capacity
        global SoC_start_s = scenario_generation_d1(kWh_cap_all, Day)                                          # Scenarios for the start SoC



        ###### Initialize the SoC for the begining of th day ######
        for i=1:I
            if Day == 1
                global SoC_start_r[i] = 0
            else
                global SoC_start_r[i] = SoC_end[i]
            end
            # Alter the power if it's conflicting with the SoC limits
            Power_r[:,i], altered = baseline_altering(Power_r[:,i], SoC_start_r[i], Connected_r[:,i], po_cap_r[:,i], kWh_cap_r[:,i])
        end


        ###### derrive bids based on stochastic model ######
        Up_bids_A[:,Day], Do_bids_A[:,Day], Up_bids_I[:,Day,:,:], Do_bids_I[:,Day,:,:], Power_A[:,Day,:], MA_A[:,Day,:], SoC_A[:,Day,:], ex_p_up[:,Day,:], ex_p_do[:,Day,:], ex_p_total[Day] = Stochastic_d1_model(La_do_s, La_up_s, Ac_do_s, Ac_up_s, Max_Power_s, po_cap_s, kWh_cap_s, Power_s, Connected_s, SoC_start_s, SoC_A_cap_s, I, S)

        ###### Simulate day of operation on realized data ######
        obj, SoC_end, missing_del, A_E, missing_delivery_storer[:,Days,:] = operation(kWh_cap_r, po_cap_r, Power_r, SoC_start_r, Max_Power_r, Connected_r, Ac_do_r, Ac_up_r, Do_bids_A[:,Day], Up_bids_A[:,Day], La_do_r, La_up_r)

        println(SoC_end)

        # update results:
        Activation_energy[:,Day,:] = A_E
        revenue = revenue + obj
        missing_delivery = missing_delivery + missing_del

        global SoC_end
    end

    println("The revenue  mode would be $revenue")
    println("The missing delivery would be $missing_delivery")
    return revenue, missing_delivery
end
