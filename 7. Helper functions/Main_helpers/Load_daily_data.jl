
# all data is made gloabl, so It can be used in the mail
function load_daily_data(Day)

    ###### Initialize the realized data for the given day ######
    global La_do_r = Do_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1
    global La_up_r = Up_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1
    global Ac_do_M_r = Ac_dowards_M[(Day-1)*M_d+1:(Day)*M_d]                                            # max activation downwards per minute
    global Ac_up_M_r = Ac_upwards_M[(Day-1)*M_d+1:(Day)*M_d]                                            # max activation upwards per minute


    global Max_Power_r =  Max_Power_all[(Day-1)*M_d+1:(Day)*M_d, :]                                     # max power of box
    global po_cap_r = po_cap_all[(Day-1)*M_d+1:(Day)*M_d, :]                                            # % of resovior stored
    global kWh_cap_r  = kWh_cap_all[(Day-1)*M_d+1:(Day)*M_d, :]                                         # kWh of resovior charged
    global Power_r  = Power_all[(Day-1)*M_d+1:(Day)*M_d, :]                                             # baseline power
    global Connected_r  = Connected_all[(Day-1)*M_d+1:(Day)*M_d, :]                                     # minutes where CB is connected
    global flex_do_r  = Downwards_flex_all[(Day-1)*M_d+1:(Day)*M_d, :]                                  # Upwards flexibity for all charge boxses
    global flex_up_r  = Upwards_flex_all[(Day-1)*M_d+1:(Day)*M_d, :]                                    # downwards flexibity for all charge boxses
    global res_20_r =  energy_20_all[(Day-1)*M_d+1:(Day)*M_d]                                           # calcualte the 20 resovior level avaible when having to be avaivble for 20 minutes


    # calculate the start SoC, if day = 1, we assume start SoC of zero
    if Day==1
        global SoC_start_r = zeros(I)
    else
        global SoC_start_r = SoC_starter_realized(kWh_cap_all[(Day-1)*M_d,:], po_cap_all[(Day-1)*M_d,:])    # load the SoC start
    end

    # Aggreagte the summed flexibity for up and down, which is bound to be realized
    global total_flex_do_r = zeros(M_d)
    global total_flex_up_r = zeros(M_d)
    for m=1:M_d
        total_flex_do_r[m] = sum(flex_do_r[m,:])                                                        # compute the aggregated realized flexibity - down
        total_flex_up_r[m] = sum(flex_up_r[m,:])                                                        # compute the aggregated realized flexibity - up
    end


    ###### Initialize the scenarios for the given day ######
    global La_do_s = scenario_generation_m(Do_prices_d1, Day, 1)                                        # Scenarios for prices down for d-1
    global La_up_s = scenario_generation_m(Up_prices_d1, Day, 1)                                        # Scenarios for prices up for d-1
    global Ac_do_M_s = scenario_generation_m(Ac_dowards_M, Day, 1)                                      # Scenarios for max activation per minue % downwards
    global Ac_up_M_s = scenario_generation_m(Ac_upwards_M, Day, 1)                                      # Scenarios for max activation per minue % Upwards
    global res_20_s = scenario_generation_m(energy_20_all, Day, 1)                                      # Scenarios for max activation per minue % Upwards

    global flex_do_s  = scenario_generation_m(Downwards_flex_all, Day, 2)                               # Scenarios for downwards flexibity
    global flex_up_s  = scenario_generation_m(Upwards_flex_all, Day, 2)                                 # Scenarios for Upwards flexibity

    global SoC_start_s = scenario_generation_d1(kWh_cap_all, Day)                                       # Scenarios for the start SoC

    # Aggreagte the summed flexibity for up and down, which is bound to be in the scenarios
    global total_flex_do_s = zeros(M_d,S)
    global total_flex_up_s = zeros(M_d,S)
    for m=1:M_d
        for s=1:S
            total_flex_do_s[m,s] = sum(flex_do_s[m,:,s])                                                # compute the aggregated realized flexibity for all scenarios - down
            total_flex_up_s[m,s] = sum(flex_up_s[m,:,s])                                                # compute the aggregated realized flexibity for all scenarios - up
        end
    end


end
