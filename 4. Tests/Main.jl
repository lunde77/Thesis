
function test_main(CB_I)


    global revenue =  0

    for Day=1:365
        print("day is $Day")


        # Static Parameters
        T = 24 # hours on a day
        M = 60 # minutes in an hour
        M_d = T*M # minutes per model, i.e. per day

        # Inputs to determic model:
        global La_do = Do_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1
        global La_up = Up_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1
        global Ac_do = Ac_dowards[(Day-1)*M_d+1:(Day)*M_d]                                                # activation % downwards
        global Ac_up = Ac_upwards[(Day-1)*M_d+1:(Day)*M_d]                                                # activation % upwards
        global Max_Power =  EV_dataframes[dataframe_names[CB_I]][(Day-1)*M_d+1:(Day)*M_d, 5]                 # max power of box
        global po_cap = EV_dataframes[dataframe_names[CB_I]][(Day-1)*M_d+1:(Day)*M_d, 1]                     # % of resovior stored
        global kWh_cap = EV_dataframes[dataframe_names[CB_I]][(Day-1)*M_d+1:(Day)*M_d, 2]                    # kWh of resovior charged
        global Power = EV_dataframes[dataframe_names[CB_I]][(Day-1)*M_d+1:(Day)*M_d, 3]                      # baseline power
        global Connected = EV_dataframes[dataframe_names[CB_I]][(Day-1)*M_d+1:(Day)*M_d, 4]                  # minutes where CB is connected

        if Day == 1
            global SoC_start = kWh_cap[1]
        else
            global SoC_start = SoC_end
        end

        Power, altered = baseline_altering(Power, SoC_start, Connected, po_cap, kWh_cap)
        Up_bid, down_bid, SoC_end, obj = deterministic_model(La_do, La_up, Ac_do, Ac_up, Max_Power, po_cap, kWh_cap, Power, Connected, SoC_start)

        revenue = revenue + obj

        global SoC_end
    end

    println("The revenue in oracle mode would be $revenue")
end


function test_A(CB_Is)
    # Static Parameters
    global T = 24 # hours on a day
    global M = 60 # minutes in an hour
    global M_d = T*M # minutes per model, i.e. per day
    global Days = 365
    global I = size(CB_Is)[1]


    global revenue =  0
    global Up_bids_A = zeros(M_d,Days,I)
    global Do_bids_A = zeros(M_d,Days,I)
    global Up_bids_I = zeros(M_d,Days,I)
    global Do_bids_I = zeros(M_d,Days,I)

    for Day=1:365
        print("day is $Day")

        global La_do = Do_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1
        global La_up = Up_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1
        global Ac_do = Ac_dowards[(Day-1)*M_d+1:(Day)*M_d]                                                # activation % downwards
        global Ac_up = Ac_upwards[(Day-1)*M_d+1:(Day)*M_d]                                                # activation % upwards
        # Initialize an empty matrix with the same number of rows as your vectors and the number of columns equal to the number of vectors
        global Max_Power =   Matrix{Float64}(undef, M_d, I)                                            # max power of box
        global po_cap =  Matrix{Float64}(undef, M_d, I)                                                # % of resovior stored
        global kWh_cap = Matrix{Float64}(undef, M_d, I)                                                # kWh of resovior charged
        global Power =  Matrix{Float64}(undef, M_d, I)                                                 # baseline power
        global Connected =  Matrix{Float64}(undef, M_d, I)                                             # minutes where CB is connected
        global SoC_start = zeros(I)
        global SoC_A_cap = zeros(M_d)

        # Loop through each vector and add it to the matrix
        for i=1:I
            Max_Power[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,5]
            po_cap[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,1]
            kWh_cap[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,2]
            Power[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,3]
            Connected[:, i] = EV_dataframes[dataframe_names[CB_Is[i]]][:,4]
            if Day == 1
                global SoC_start[i] = kWh_cap[1,i]
            else
                global SoC_start[i] = SoC_end[i]
            end
            for m=1:525600
                if Connected[m,i] == 1
                    global SoC_A_cap[m] = SoC_A_cap[m]+kWh_cap[m,i]/po_cap[m,i]
                end
            end
        end


        for i=1:I
            Power[:,i], altered = baseline_altering(Power[:,i], SoC_start[i], Connected[:,i], po_cap[:,i], kWh_cap[:,i])
        end
        Up_bids_A[:,d], Do_bids_A[:,d], Up_bids_A[:,d,:], Do_bids_A[:,d,:], SoC_end, obj = deterministic_model(La_do, La_up, Ac_do, Ac_up, Max_Power, po_cap, kWh_cap, Power, Connected, SoC_start, SoC_A_cap, I)

        println(SoC_end)

        revenue = revenue + obj

        global SoC_end
    end

    println("The revenue in oracle mode would be $revenue")
end
