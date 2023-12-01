function load_results_storer()
    global revenue =  zeros(2)                                                                              # DKK of revenue during Simulation periode
    global penalty =  zeros(2)                                                                              # DKK of penalty during Simulation periode
    global missing_delivery = zeros(2,1)                                                                      # kWh of missed delivery during Simulations
    global Up_bids_A = zeros(M_d,Days)                                                                      # total up bid i kW for each day and minute                                                    # not used
    global Do_bids_A = zeros(M_d,Days)                                                                      # total down bid i kW for each day and minute                                                  # not used
    #global Up_bids_I = zeros(M_d,Days,I,S)                                                                  # total up bid distribued amongst charges for each scenario in kW for each day and minute      # not used
    #global Do_bids_I = zeros(M_d,Days,I,S)                                                                  # total down bid distribued amongst charges for each scenario in kW for each day and minute    # not used
    global ex_p_do = zeros(2,M_d,Days,S)                                                                      # expected penalty cost for down bid
    global ex_p_up = zeros(2,M_d,Days,S)                                                                      # expected penalty cost for up bid
    global ex_p_total = zeros(2,Days)                                                                         # total expected pentalty
    #global Activation_energy = zeros(M_d,Days,I)                                                            # sum of activated energy for each day to each minute for each charger                         # not used
    global after_Activation = zeros(2,M_d,Days, S)                                                            # sum of activated energy for each day to each minute for each charger
    global missing_delivery_storer = zeros(2,Days,2)                                                          # % of bid that could not be meet
    global missing_capacity_storer = zeros(2,Days,4)                                                          # % of all time minutes where capacity were not availeble
    #global Power_A = zeros(M_d,Days,S)                                                                      # The aggregated power for each scenario without activation                                    # not used
    #global SoC_A = zeros(M_d,Days,S)                                                                        # The aggregated SoC for each scenario without activation                                      # not used
    #global MA_A = zeros(M_d,Days,S)                                                                         # The aggregated Ma effect for each scenario without activation                                # not used
    global expected_over_do = zeros(2,M_d, Days, S )                                                             # How many % did we overbid on our capacity
    global expected_over_up = zeros(2,M_d, Days, S )                                                             # How many % did we overbid on our capacity

    global Total_flex_up = zeros(2,M_d, Days)                                                                       # How many % did we overbid on our capacity
    global Total_flex_do = zeros(2,M_d, Days)                                                                       # How many % did we overbid on our capacity
    global total_cap_missed = zeros(2,4)                                                                       # how often were we overbidbing
    global average_cap_missed = zeros(2,3)                                                                            # our aveage overbid when overbidbing
    global total_delivery_missed = zeros(2,2)                                                                  # how large a proption of the activation we missed
    global missing_capacity_storer_per = zeros(2,Days, M_d, 3)
    global pr_flex_used_up = zeros(2)                                                                           # percante of upwarrds flexibity used
    global pr_flex_used_do = zeros(2)                                                                           # percante of downwards flexibity used
    global CB_flex_bid = zeros(2, M_d, Days)                                                                           # amount of up and downwards flexibility bid in, 1=upwards, 2=downwards

    #### in sample result storer
    global revenue_in =  zeros(1)                                                                              # DKK of revenue during Simulation periode
    global penalty_in =  zeros(1)                                                                              # DKK of penalty during Simulation periode
    global missing_delivery_in = zeros(1)                                                                      # kWh of missed delivery during Simulations
    #global Up_bids_I = zeros(M_d,Days,I,S)                                                                  # total up bid distribued amongst charges for each scenario in kW for each day and minute      # not used
    #global Do_bids_I = zeros(M_d,Days,I,S)                                                                  # total down bid distribued amongst charges for each scenario in kW for each day and minute    # not used
    global ex_p_do_in = zeros(M_d,Days,S)                                                                      # expected penalty cost for down bid
    global ex_p_up_in = zeros(M_d,Days,S)                                                                      # expected penalty cost for up bid
    global ex_p_total_in = zeros(Days)                                                                         # total expected pentalty
    #global Activation_energy = zeros(M_d,Days,I)                                                            # sum of activated energy for each day to each minute for each charger                         # not used
    global after_Activation_in = zeros(M_d,Days, S)                                                            # sum of activated energy for each day to each minute for each charger
    global missing_delivery_storer_in = zeros(Days,2)                                                          # % of bid that could not be meet
    global missing_capacity_storer_in = zeros(Days,4)                                                          # % of all time minutes where capacity were not availeble
    #global Power_A = zeros(M_d,Days,S)                                                                      # The aggregated power for each scenario without activation                                    # not used
    #global SoC_A = zeros(M_d,Days,S)                                                                        # The aggregated SoC for each scenario without activation                                      # not used
    #global MA_A = zeros(M_d,Days,S)                                                                         # The aggregated Ma effect for each scenario without activation                                # not used
    global expected_over_do_in = zeros(M_d, Days, S )                                                             # How many % did we overbid on our capacity
    global expected_over_up_in = zeros(M_d, Days, S )                                                             # How many % did we overbid on our capacity

    global Total_flex_up_in = zeros(M_d, Days)                                                                       # How many % did we overbid on our capacity
    global Total_flex_do_in = zeros(M_d, Days)                                                                       # How many % did we overbid on our capacity
    global total_cap_missed_in = zeros(4)                                                                       # how often were we overbidbing
    global average_cap_missed_in = zeros(3)                                                                            # our aveage overbid when overbidbing
    global total_delivery_missed_in = zeros(2)                                                                  # how large a proption of the activation we missed
    global missing_capacity_storer_per_in = zeros(Days, M_d, 3)

end
