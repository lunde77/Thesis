
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
