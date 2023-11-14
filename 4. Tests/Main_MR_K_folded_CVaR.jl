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

function Main_stochastic_CVAR_OSS_folded(CB_Is)

    # Static Parameters
    global NF = 5                                           # Number of folds
    global test_type = "T2"
    global T = 24                                           # hours on a day
    global M = 60                                           # minutes in an hour
    global S = Int32(floor(365/NF) )*4                      # number of samples in IS
    global M_d = T*M                                        # minutes per model, i.e. per day
    global Pen_e_coef = 3                                   # multiplier on energy for not delivering the activation -> 6, implies we have to pay the capacity back and that it 5 times as expensive tp buy the capacity back
    global Days = 365
    global I = size(CB_Is)[1]
    global RM = 0.9                                         # %-end SoC assumed, e.g. 0.9 means we assume all charges charge to 90%
    global Sampling = 4
    global q_epilon = 0.0001
    global start_1 = time_ns()



    global start_1 = time_ns()


    # results data are intialized to be stored
    load_results_storer()

    # load all the aggregated data
    Load_aggregated(CB_Is)

    ###### iload the folds for in and out of sample days ######
    sampled_numbers, OOS_days =  make_folds(NF)

    ### run test on the sample days
    println(sampled_numbers)
    println(OOS_days)

    for w=1:NF
        i = 1
        ###### intialize sampling data, so it's loaded ######
        total_flex_do_s, total_flex_up_s, res_20_s, xxxx, xxxx = load_sampling_data(1, sampled_numbers[w,:]) # XX imples that the output is not used


        println(round((time_ns() - start_1) / 1e9, digits = 3))
        global start_2 = time_ns()
        global C_do = zeros(24)
        global C_up = zeros(24)
        for t=1:24
            C_do[t], C_up[t] = Stochastic_chancer_model_hourly_CVAR(total_flex_do_s[t,:,:], total_flex_up_s[t,:,:], res_20_s[t,:,:])
            for m=1:60
                global Do_bids_A[(t-1)*60+m,1] = C_do[t]
                global Up_bids_A[(t-1)*60+m,1] = C_up[t]
            end
        end
        global model_runtime = round((time_ns() - start_2) / 1e9, digits = 3)
        global n_days = Int32(floor(365/NF) )

        Threads.@threads for j=1:n_days
            Day = OOS_days[w,j]
            println("day is $Day")

            start_2 = time_ns()

            ###### intialize all daily data, so it's loaded ######
            La_do_r, La_up_r, Ac_do_M_r, Ac_up_M_r, total_flex_do_r, total_flex_up_r, res_20_r = load_daily_data(Day)
            println("daily data took")
            println(round((time_ns() - start_2) / 1e9, digits = 3))
            println("the 20 minutes average is $(mean(res_20_r[1:10]))")

            ###### Simulate day of operation on realized data ######
            obj, pen, missing_delivery_storer[1,Day,:], missing_capacity_storer[1,Day,:], missing_capacity_storer_per[1,Day,:, :]  = operation(total_flex_up_r, total_flex_do_r, res_20_r, Ac_do_M_r, Ac_up_M_r, Do_bids_A[:,1], Up_bids_A[:,1], La_do_r, La_up_r)

            # update results:
            Total_flex_up[1,:, Day]   = total_flex_up_r
            Total_flex_do[1,:, Day]   = total_flex_do_r

            revenue[1] = revenue[1] + obj
            penalty[1] = penalty[1] + pen

        end
    end
    pr_flex_used_up[1] = round( sum( Up_bids_A )*n_days/sum(Total_flex_up[1,:,:] ), digits= 3 )  # % of upwards flexibity bid into market
    pr_flex_used_do[1] = round( sum( Do_bids_A )*n_days/sum(Total_flex_do[1,:,:] ), digits= 3 )  # % of downwards flexibity bid into market

    total_cap_missed[1,1] = round( (sum(missing_capacity_storer[1,:,1]))/(n_days*NF),  digits= 3 )  # % of minute where down capacity were missed
    total_cap_missed[1,2] = round( sum(missing_capacity_storer[1,:,2])/(n_days*NF) ,  digits= 3 )   # % of minute where up capacity were missed
    total_cap_missed[1,3] = round( sum(missing_capacity_storer[1,:,3])/(n_days*NF) ,  digits= 3 )   # % of minute where energy capacity were missed
    total_cap_missed[1,4] = round( sum(missing_capacity_storer[1,:,4])/(n_days*NF) ,  digits= 3 )   # % of minute where we overbid in any category

    average_cap_missed[1,1] = round( sum(missing_capacity_storer_per[1,:,:,1]) / (sum(missing_capacity_storer[1,:,1])*M_d+0.0001) ,  digits= 3 )   # average overbid down
    average_cap_missed[1,2] = round( sum(missing_capacity_storer_per[1,:,:,2]) / (sum(missing_capacity_storer[1,:,2])*M_d+0.0001) ,  digits= 3 )   #  average overbid up
    average_cap_missed[1,3] = round( sum(missing_capacity_storer_per[1,:,:,3]) / (sum(missing_capacity_storer[1,:,3])*M_d+0.0001) ,  digits= 3 )   #  average overbid

    total_delivery_missed[1,1] =  round( sum(missing_delivery_storer[1,:,1])/(n_days*NF) ,  digits= 3 )   # % of of down bids that could not be delivered
    total_delivery_missed[1,2] =  round( sum(missing_delivery_storer[1,:,2])/(n_days*NF) ,  digits= 3 )   # % of of up bids that could not be delivered

    revenue[1] = revenue[1]/(n_days*NF)       # normlize it so it on a daily scale
    penalty[1] = penalty[1]/(n_days*NF)       # normlize it so it on a daily scale

    println("The revenue for the entery perioed was $(revenue[1])")
    println("The Penalty would be $(penalty[1])")


    clock = round((time_ns() - start_1) / 1e9, digits = 3)
    return revenue[1], penalty[1], total_cap_missed[1,:], average_cap_missed[1,:], total_delivery_missed[1,:], pr_flex_used_up[1], pr_flex_used_do[1], model_runtime, clock, missing_capacity_storer[1,:,4], C_up, C_do
end