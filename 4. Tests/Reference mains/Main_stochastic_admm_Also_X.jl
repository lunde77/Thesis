

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

function Main_stochastic_CC_admm(CB_Is, S_method, samples_in)

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
    global q_epilon = 0.001
    global start_1 = time_ns()


    # results data are intialized to be stored
    load_results_storer()


    # load all the aggregated data
    Load_aggregated(CB_Is)

    ###### intialize all daily data, so it's loaded - yet here is just to get the samples ######
    total_flex_do_s, total_flex_up_s, res_20_s, OOS_numbers, sampled_numbers = load_sampling_data(1,0, "XX")# XX imples that the output is not used


    ###### derrive bids based on stochastic model ######

    global count_to = 2 # do coun_to minues 1 itteration
    Y_input = zeros(T)
    C_up = zeros(T)
    C_do = zeros(T)
    slack_up = zeros(T)
    slack_do = zeros(T)
    Y_out = ones(T)*M*S*0.1
    Y_zeros = zeros(T)
    global Y_zeros_tracker = zeros(count_to)
    global lambda = zeros(count_to+1)
    lambda_in = zeros(1)
    lambda[1] = 0.025*I/(S/20)          # upwards gamma Penalty
    gamma = lambda[1]*0.8        # upwards gamma Penalty
    model_runtime = ones(1)
    global change_lambda_up = 100
    global counter =  ones(1)

    while change_lambda_up >= 0.000001  && Int32(counter[1]) < count_to
        lambda_in = lambda[Int32(counter[1])]
        Threads.@threads for t=1:T
            println("at hour $t")

            Y_in = sum(Y_out)-Y_out[t]
            Y_in_zeros = sum(Y_zeros)-Y_zeros[t]

            C_do[t], C_up[t], Y_out[t], Y_zeros[t], model_runtime[1] = ALSO_X_admm(total_flex_up_s, total_flex_do_s, res_20_s, Y_in, Y_in_zeros, lambda_in, gamma, t)

        end

        Y_zeros_tracker[Int32(counter[1])] =  (1 -sum(Y_zeros)/(S*M_d))

        input = (1 -sum(Y_zeros)/(S*M_d)) - 0.1

        if input > 0.1
            input = 0.1
        end




        if Int32(counter[1]) > count_to*1.1
            lambda[Int32(counter[1])+1] = lambda[Int32(counter[1])]+(gamma)*( input )
        else
            lambda[Int32(counter[1])+1] = lambda[Int32(counter[1])]+(gamma)*(count_to*1.25-Int32(counter[1])*gamma/count_to/0.9)*(input)
        end

        if lambda[Int32(counter[1])+1] < 0
            lambda[Int32(counter[1])+1] = 0.5
        end

        println("the bids were:")
        println(C_do)
        println(C_up)

        global change_lambda_up = abs(lambda[Int32(counter[1])+1] -lambda[Int32(counter[1])])
        println("lambda change is")
        println(abs(lambda[Int32(counter[1])+1] -lambda[Int32(counter[1])]) )

        global counter[1] = Int32(counter[1]) + 1

        println(Int32(counter[1]))
    end

    for t=1:24
        for m=1:60
            global Do_bids_A[(t-1)*60+m,1] = C_do[t]
            global Up_bids_A[(t-1)*60+m,1] = C_up[t]
        end
    end


    n_days = length(OOS_numbers)

    Threads.@threads for j=1:n_days
        Day = OOS_numbers[j]
        println("day is $Day")

        start_2 = time_ns()

        ###### intialize all daily data, so it's loaded ######
        La_do_r, La_up_r, Ac_do_M_r, Ac_up_M_r, total_flex_do_r, total_flex_up_r, res_20_r = load_daily_data(Day)
        println("daily data took")
        println(round((time_ns() - start_2) / 1e9, digits = 3))

        ###### Simulate day of operation on realized data ######
        obj, pen, missing_delivery_storer[1,Day,:], missing_capacity_storer[1,Day,:], missing_capacity_storer_per[1,Day,:, :]  = operation(total_flex_up_r, total_flex_do_r, res_20_r, Ac_do_M_r, Ac_up_M_r, Do_bids_A[:,1], Up_bids_A[:,1], La_do_r, La_up_r)

        # update results:
        Total_flex_up[1,:, Day]   = total_flex_up_r
        Total_flex_do[1,:, Day]   = total_flex_do_r

        revenue[1] = revenue[1] + obj
        penalty[1] = penalty[1] + pen

    end

    pr_flex_used_up[1] = round( (sum( Up_bids_A )*n_days)/sum(Total_flex_up[1,:,:] ), digits= 3 )  # % of upwards flexibity bid into market
    pr_flex_used_do[1] = round( (sum( Do_bids_A )*n_days)/sum(Total_flex_do[1,:,:] ), digits= 3 )  # % of downwards flexibity bid into market

    total_cap_missed[1,1] = round( (sum(missing_capacity_storer[1,:,1]))/(n_days),  digits= 3 )  # % of minute where down capacity were missed
    total_cap_missed[1,2] = round( sum(missing_capacity_storer[1,:,2])/(n_days) ,  digits= 3 )   # % of minute where up capacity were missed
    total_cap_missed[1,3] = round( sum(missing_capacity_storer[1,:,3])/(n_days) ,  digits= 3 )   # % of minute where energy capacity were missed
    total_cap_missed[1,4] = round( sum(missing_capacity_storer[1,:,4])/(n_days) ,  digits= 3 )   # % of minute where we overbid in any category

    average_cap_missed[1,1] = round( sum(missing_capacity_storer_per[1,:,:,1]) / (sum(missing_capacity_storer[1,:,1])*M_d+0.0001) ,  digits= 3 )   #  average overbid down
    average_cap_missed[1,2] = round( sum(missing_capacity_storer_per[1,:,:,2]) / (sum(missing_capacity_storer[1,:,2])*M_d+0.0001) ,  digits= 3 )   #  average overbid up
    average_cap_missed[1,3] = round( sum(missing_capacity_storer_per[1,:,:,3]) / (sum(missing_capacity_storer[1,:,3])*M_d+0.0001) ,  digits= 3 )   #  average overbid

    total_delivery_missed[1,1] =  round( sum(missing_delivery_storer[1,:,1])/(n_days) ,  digits= 3 )   # % of of down bids that could not be delivered
    total_delivery_missed[1,2] =  round( sum(missing_delivery_storer[1,:,2])/(n_days) ,  digits= 3 )   # % of of up bids that could not be delivered

    revenue[1] = revenue[1]/(n_days)       # normlize it so it on a daily scale
    penalty[1] = penalty[1]/(n_days)       # normlize it so it on a daily scale

    println("The revenue for the entery perioed was $(revenue[1])")
    println("The Penalty would be $(penalty[1])")

    clock = round((time_ns() - start_1) / 1e9, digits = 3)

    return revenue[1], penalty[1], total_cap_missed[1,:], average_cap_missed[1,:], total_delivery_missed[1,:], pr_flex_used_up[1], pr_flex_used_do[1], model_runtime[1], clock, missing_capacity_storer[1,:,4], Up_bids_A[:,1], Do_bids_A[:,1]
end
