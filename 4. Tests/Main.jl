

for Day=1:365

    # Inputs to determic model:
    La_do = Do_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1
    La_up = Up_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1
    Ac_do = Ac_do[(Day-1)*M_d+1:(Day)*M_d]                                                     # activation % downwards
    Ac_up = Ac_up[(Day-1)*M_d+1:(Day)*M_d]                                                     # activation % upwards
    Max_Power =  EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 5]                 # max power of box
    po_cap = EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 1]                     # % of resovior stored
    kWh_cap = EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 2]                    # kWh of resovior charged
    Power = EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 3]                      # baseline power
    Connected = EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 4]                  # minutes where CB is connected

    if Day == 1
        SoC_start = kWh_cap[1]
    else
        SoC_start = SoC_end
    end


    Up_bid, down_bid, SoC_end = deterministic_model(La_do, La_up, Ac_do, Ac_up, Max_Power, po_cap, kWh_cap, Power, Connected, SoC_start)

end
