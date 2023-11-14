using Random
# all data is made gloabl, so It can be used in the mail
function load_daily_data(Day)

    ###### Initialize the realized data for the given day ######
    La_do_r = Do_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1
    La_up_r = Up_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1
    Ac_do_M_r = Ac_dowards_M[(Day-1)*M_d+1:(Day)*M_d]                                            # max activation downwards per minute
    Ac_up_M_r = Ac_upwards_M[(Day-1)*M_d+1:(Day)*M_d]                                            # max activation upwards per minute
    flex_do_r  = Downwards_flex_all[(Day-1)*M_d+1:(Day)*M_d, :]                                          # Upwards flexibity for all charge boxses
    flex_up_r  = Upwards_flex_all[(Day-1)*M_d+1:(Day)*M_d, :]                                            # downwards flexibity for all charge boxses
    res_20_r =  energy_20_all[(Day-1)*M_d+1:(Day)*M_d]                                                   # calcualte the 20 resovior level avaible when having to be avaivble for 20 minutes

    # Aggreagte the summed flexibity for up and down, which is bound to be realized
    total_flex_do_r = zeros(M_d)
    total_flex_up_r = zeros(M_d)
    for m=1:M_d
        total_flex_do_r[m] = sum(flex_do_r[m,:])                                                        # compute the aggregated realized flexibity - down
        total_flex_up_r[m] = sum(flex_up_r[m,:])                                                        # compute the aggregated realized flexibity - up
    end


    ###### Initialize the samples for the given day ######

    # Set the range and the number of samples
    num_samples = S

    total_flex_up_s = zeros(24, 60, num_samples)
    total_flex_do_s = zeros(24, 60, num_samples)
    res_20_s = zeros(24, 60, num_samples)

    N_OSS = 50 # set number of OOS days to be 50

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
            OOS_numbers = [1+num_samples:N_OSS+num_samples]
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
            OOS_numbers = shuffled_values[1+num_samples:N_OSS+num_samples]
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
            shuffled_values = randperm(length(collect(1:365)))
            sampled_numbers = shuffled_values[1:num_samples]
            while Day in sampled_numbers # make sure the day we test OSS are not included in in-sample set
                shuffled_values = randperm(length(collect(1:365)))
                sampled_numbers = all_values[shuffled_values[1:num_samples]]
            end
        else
            Random.seed!(3) # set this to a number if we want to have same in sample and out sample across samples
            sampled_numbers_tester = randperm(length(collect(1:365)))
            sampled_numbers = sampled_numbers_tester[1:num_samples]
            OOS_numbers = sampled_numbers_tester[1+num_samples:N_OSS+num_samples]
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
    return total_flex_do_s, total_flex_up_s, res_20_s, OOS_numbers, sampled_numbers, La_do_r, La_up_r, Ac_do_M_r, Ac_up_M_r, total_flex_do_r, total_flex_up_r, res_20_r
end
