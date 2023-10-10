
# all data is made gloabl, so It can be used in the mail
function load_daily_data(Day)
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
    global flex_do_s, flex_up_s, total_flex_do_s, total_flex_up_s = baseline_flex(kWh_cap_s, po_cap_s, Power_s, Max_Power_s, Connected_s, SoC_start_s, S, RM)                # find the total and idivudal flexibilities of each unit M×CB×S, or MxS

    global P90_Power = Power_scenario_90(Power_s)                                                          # The aggregated power in p90 scenario
    global P90_MP = Power_scenario_90(Max_Power_s)                                                         # The aggregated max power in p90 scenario
end
