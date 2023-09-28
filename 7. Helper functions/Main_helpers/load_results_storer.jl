function load_results_storer()
    global revenue =  zeros(1)                                                                              # DKK of revenue during Simulation periode
    global missing_delivery = zeros(1)                                                                      # kWh of missed delivery during Simulations
    global Up_bids_A = zeros(M_d,Days)                                                                      # total up bid i kW for each day and minute
    global Do_bids_A = zeros(M_d,Days)                                                                      # total down bid i kW for each day and minute
    global Up_bids_I = zeros(M_d,Days,I,S)                                                                  # total up bid distribued amongst charges for each scenario in kW for each day and minute
    global Do_bids_I = zeros(M_d,Days,I,S)                                                                  # total down bid distribued amongst charges for each scenario in kW for each day and minute
    global ex_p_do = zeros(M_d,Days,S)                                                                      # expected penalty cost for down bid
    global ex_p_up = zeros(M_d,Days,S)                                                                      # expected penalty cost for up bid
    global ex_p_total = zeros(Days)                                                                         # total expected pentalty
    global Activation_energy = zeros(M_d,Days,I)                                                            # sum of activated energy for each day to each minute for each charger
    global missing_delivery_storer = zeros(Days,2)                                                          # missed energy for both up and down
    global Power_A = zeros(M_d,Days,S)                                                                      # The aggregated power for each scenario without activation
    global SoC_A = zeros(M_d,Days,S)                                                                        # The aggregated SoC for each scenario without activation
    global MA_A = zeros(M_d,Days,S)                                                                         # The aggregated Ma effect for each scenario without activation
    global expected_over = zeros(M_d, Days, S )                                                             # How many % did we overbid on our capacity
end
