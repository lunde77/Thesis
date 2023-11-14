using Random
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
    #global La_do_s = scenario_generation_m(Do_prices_d1, Day, 1)                                        # Scenarios for prices down for d-1
    #global La_up_s = scenario_generation_m(Up_prices_d1, Day, 1)                                        # Scenarios for prices up for d-1
    #global Ac_do_M_s = scenario_generation_m(Ac_dowards_M, Day, 1)                                      # Scenarios for max activation per minue % downwards
    #global Ac_up_M_s = scenario_generation_m(Ac_upwards_M, Day, 1)                                      # Scenarios for max activation per minue % Upwards
    #global res_20_s = scenario_generation_m(energy_20_all, Day, 1)                                      # Scenarios for max activation per minue % Upwards

    #global flex_do_s  = scenario_generation_m(Downwards_flex_all, Day, 2)                               # Scenarios for downwards flexibity
    #global flex_up_s  = scenario_generation_m(Upwards_flex_all, Day, 2)                                 # Scenarios for Upwards flexibity

    #global SoC_start_s = scenario_generation_d1(kWh_cap_all, Day)                                       # Scenarios for the start SoC

    # Aggreagte the summed flexibity for up and down, which is bound to be in the scenarios
    #global total_flex_do_s = zeros(M_d,S)
    #global total_flex_up_s = zeros(M_d,S)
    #for m=1:M_d
    #    for s=1:S
    #        total_flex_do_s[m,s] = sum(flex_do_s[m,:,s])                                                # compute the aggregated realized flexibity for all scenarios - down
    #        total_flex_up_s[m,s] = sum(flex_up_s[m,:,s])                                                # compute the aggregated realized flexibity for all scenarios - up
    #    end
    #end

    # Set the range and the number of samples
    num_samples = S

    global total_flex_up_s = zeros(24, 60, num_samples)
    global total_flex_do_s = zeros(24, 60, num_samples)
    global res_20_s = zeros(24, 60, num_samples)

    global N_OSS = 50 # set number of OOS days to be 50

    if Sampling == 1 # radnom sampling with drawing from hourly Overbid_distribution
        # Create an array containing all possible values in the range
        start_range = 1
        end_range = 21900
        all_values = collect(start_range:end_range)


        if test_type == "T1" # if we test bid on one days
            # exlucde samples from the given OSS day
            all_values = [x for x in all_values if !((Day-1)*60+1 <= x <= Day*60)]
        else # if we test bid on multiple days
            # find the OSS days
            Random.seed!(3) # set this to a number if we want to have same out sample across samples
            shuffled_values = randperm(length(collect(1:365)))
            global OOS_numbers = [1+num_samples:N_OSS+num_samples]
            Random.seed!() # reset so it random
            # exclude samples from OSS in the distribution wich is drwan from
            sorted_numbers_exclude = sort(OOS_numbers, rev=true)
            for j in sorted_numbers_exclude
                all_values = [x for x in all_values if !((j-1)*60+1 <= x <= j*60)]
            end
        end


        for t=1:24
            for m=1:60
                # Shuffle the array randomly
                shuffled_values = randperm(length(all_values))
                # Select the first num_samples values from the shuffled array
                sampled_numbers = all_values[shuffled_values[1:num_samples]]

                total_flex_do_s[t,m,:] = dis[1,sampled_numbers,t]
                total_flex_up_s[t,m,:] = dis[2,sampled_numbers,t]
                res_20_s[t,m,:] = dis[3,sampled_numbers,t]
            end
        end
<<<<<<< HEAD:7. Helper functions/Main_helpers/Load_daily_data.jl
    elseif Sampling == 2 # if we want to capture teh correlation, hence
        if test_type == "T1"
=======
    elseif Sampling == 2 # Minute-to_minute distribution sampled in correaltion
        # Create an array containing all possible values in the range
        start_range = 1
        end_range = 365
        all_values = collect(start_range:end_range)
        if test_type == "T1" # if we test bid on one days
            # exlucde samples from the given OSS day
            all_values = [x for x in all_values if !(Day <= x <= Day)]
        else # if we test bid on multiple days
            # find the OSS days
            Random.seed!(3) # set this to a number if we want to have same out sample across samples
            shuffled_values = randperm(length(collect(1:365)))
            global OOS_numbers = shuffled_values[1+num_samples:N_OSS+num_samples]
            Random.seed!() # reset so it random
            # exclude samples from OSS in the distribution wich is drwan from
            sorted_numbers_exclude = sort(OOS_numbers, rev=true)
            for j in sorted_numbers_exclude
                all_values = [x for x in all_values if !(j <= x <= j)]
            end

        end
        for t=1:24
            for m=1:60
                # Shuffle the array randomly
                shuffled_values = randperm(length(all_values))
                # Select the first num_samples values from the shuffled array
                sampled_numbers = all_values[shuffled_values[1:num_samples]]

                total_flex_do_s[t,m,:] = dis[1,sampled_numbers,t,m]
                total_flex_up_s[t,m,:] = dis[2,sampled_numbers,t,m]
                res_20_s[t,m,:] = dis[3,sampled_numbers,t,m]
            end
        end

    elseif Sampling == 3 # Minute-to_minute distribution sampled in correaltion
        if test_type == "T1" # t1 refers to we are making a new bid for every test day
>>>>>>> f7d7bf97232319fd0e7d80f1416f6b1e54baf191:7. Helper functions/Non main function/Load_daily_data_with_energy.jl
            shuffled_values = randperm(length(collect(1:365)))
            sampled_numbers = shuffled_values[1:num_samples]
            while Day in sampled_numbers # make sure the day we test OSS are not included in in-sample set
                shuffled_values = randperm(length(collect(1:365)))
                sampled_numbers = all_values[shuffled_values[1:num_samples]]
            end
        else
<<<<<<< HEAD:7. Helper functions/Main_helpers/Load_daily_data.jl
            # Random.seed!(3) # set this to a number if we want to have same in sample and out sample across samples  
=======
            Random.seed!(3) # set this to a number if we want to have same in sample and out sample across samples
>>>>>>> f7d7bf97232319fd0e7d80f1416f6b1e54baf191:7. Helper functions/Non main function/Load_daily_data_with_energy.jl
            sampled_numbers_tester = randperm(length(collect(1:365)))
            sampled_numbers = sampled_numbers_tester[1:num_samples]
            global OOS_numbers = sampled_numbers_tester[1+num_samples:N_OSS+num_samples]
        end

        # draw samples, all samplesa re drawn form the same random days
        for t=1:24
            for m=1:60
                total_flex_do_s[t,m,:] = dis[1,sampled_numbers,t,m]
                total_flex_up_s[t,m,:] = dis[2,sampled_numbers,t,m]
                res_20_s[t,m,:] = dis[3,sampled_numbers,t,m]
            end
        end
    end

end
