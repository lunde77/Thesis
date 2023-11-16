# input:
# CB_Is: number of chargeboxses used

# output:
# revenue[1]: the total revenue realized
# penalty[1]: The total
# total_cap_missed: % of the time we don't have the capacity to meet the bid
# total_delivery_missed: How much of the total activation do we on daily average not deliver
# pr_flex_used_up: How much of the total upwards flexibity was bid into the market
# pr_flex_used_do: How much of the total downwards flexibity was bid into the market
# model_runtime: How long is takes solve the model (stochastig model)
# clock: Total runtime for the entery sumlation

function Main_stochastic_CC_OSS(CB_Is, S_method, samples_in)

    # Static Parameters
    global test_type = "T2"
    global T = 24 # hours on a day
    global M = 60 # minutes in an hour
    global M_d = T*M # minutes per model, i.e. per day
    global Pen_e_coef = 3 # multiplier on energy for not delivering the activation -> 6, implies we have to pay the capacity back and that it 5 times as expensive tp buy the capacity back
    global Days = 365
    global I = size(CB_Is)[1]
    global RM = 0.9 # %-end SoC assumed, e.g. 0.9 means we assume all charges charge to 90%
    global Sampling = S_method
    global S = samples_in
    global q_epilon = 0.0001
    global start_1 = time_ns()


    # results data are intialized to be stored
    load_results_storer()

    # load all the aggregated data
    Load_aggregated(CB_Is)

    ###### intialize all daily data, so it's loaded - yet here is just to get the samples ######
    total_flex_do_s, total_flex_up_s, res_20_s, OOS_numbers, sampled_numbers = load_sampling_data(1,0)# XX imples that the output is not used

    ###### solve the model in a decomposed matter, and by appliying the Also-x method ######
    global C_do, C_up, model_runtime = ALSO_X(total_flex_up_s, total_flex_do_s, res_20_s)

    for t=1:24
        for m=1:60
            global Do_bids_A[(t-1)*60+m,1] = C_do[t]
            global Up_bids_A[(t-1)*60+m,1] = C_up[t]
        end
    end

    ### run test on the sample days
    println(sampled_numbers)
    println(OOS_numbers)
    for i=1:1 # set to only loop to one, as we only want OOS results for now
        if i == 1
            test_days = OOS_numbers
        else # we test in sample days
            test_days = sampled_numbers
        end
        n_days = length(test_days)

        Threads.@threads for j=1:n_days
            Day = test_days[j]
            println("day is $Day")

            start_2 = time_ns()

            ###### intialize all daily data, so it's loaded ######
            La_do_r, La_up_r, Ac_do_M_r, Ac_up_M_r, total_flex_do_r, total_flex_up_r, res_20_r = load_daily_data(Day)
            println("daily data took")
            println(round((time_ns() - start_2) / 1e9, digits = 3))
            println("the 20 minutes average is $(mean(res_20_r[1:10]))")

            ###### Simulate day of operation on realized data ######
            obj, pen, missing_delivery_storer[i,Day,:], missing_capacity_storer[i,Day,:], missing_capacity_storer_per[i,Day,:, :]  = operation(total_flex_up_r, total_flex_do_r, res_20_r, Ac_do_M_r, Ac_up_M_r, Do_bids_A[:,1], Up_bids_A[:,1], La_do_r, La_up_r)

            # update results:
            Total_flex_up[i,:, Day]   = total_flex_up_r
            Total_flex_do[i,:, Day]   = total_flex_do_r

            revenue[i] = revenue[i] + obj
            penalty[i] = penalty[i] + pen

        end

        pr_flex_used_up[i] = round( sum( Up_bids_A )*n_days/sum(Total_flex_up[i,:,:] ), digits= 3 )  # % of upwards flexibity bid into market
        pr_flex_used_do[i] = round( sum( Do_bids_A )*n_days/sum(Total_flex_do[i,:,:] ), digits= 3 )  # % of downwards flexibity bid into market

        total_cap_missed[i,1] = round( (sum(missing_capacity_storer[i,:,1]))/(n_days),  digits= 3 )  # % of minute where down capacity were missed
        total_cap_missed[i,2] = round( sum(missing_capacity_storer[i,:,2])/(n_days) ,  digits= 3 )   # % of minute where up capacity were missed
        total_cap_missed[i,3] = round( sum(missing_capacity_storer[i,:,3])/(n_days) ,  digits= 3 )   # % of minute where energy capacity were missed
        total_cap_missed[i,4] = round( sum(missing_capacity_storer[i,:,4])/(n_days) ,  digits= 3 )   # % of minute where we overbid in any category

        average_cap_missed[i,1] = round( sum(missing_capacity_storer_per[i,:,:,1]) / (sum(missing_capacity_storer[i,:,1])*M_d+0.0001) ,  digits= 3 )   # average overbid down
        average_cap_missed[i,2] = round( sum(missing_capacity_storer_per[i,:,:,2]) / (sum(missing_capacity_storer[i,:,2])*M_d+0.0001) ,  digits= 3 )   #  average overbid up
        average_cap_missed[i,3] = round( sum(missing_capacity_storer_per[i,:,:,3]) / (sum(missing_capacity_storer[i,:,3])*M_d+0.0001) ,  digits= 3 )   #  average overbid

        total_delivery_missed[i,1] =  round( sum(missing_delivery_storer[i,:,1])/(n_days) ,  digits= 3 )   # % of of down bids that could not be delivered
        total_delivery_missed[i,2] =  round( sum(missing_delivery_storer[i,:,2])/(n_days) ,  digits= 3 )   # % of of up bids that could not be delivered

        revenue[i] = revenue[i]/n_days       # normlize it so it on a daily scale
        penalty[i] = penalty[i]/n_days       # normlize it so it on a daily scale

        println("The revenue for the entery perioed was $(revenue[i])")
        println("The Penalty would be $(penalty[i])")
    end

    clock = round((time_ns() - start_1) / 1e9, digits = 3)
    return revenue[1], penalty[1], total_cap_missed[1,:], average_cap_missed[1,:], total_delivery_missed[1,:], pr_flex_used_up[1], pr_flex_used_do[1], model_runtime, clock, missing_capacity_storer[1,:,4], C_up, C_do, revenue[2], penalty[2], total_cap_missed[2,:], average_cap_missed[2,:], total_delivery_missed[2,:], pr_flex_used_up[2], pr_flex_used_do[2], model_runtime, clock, missing_capacity_storer[2,:,4]
end
