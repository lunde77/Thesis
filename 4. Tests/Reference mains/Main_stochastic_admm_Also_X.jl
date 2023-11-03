

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

function Main_stochastic_CC_admm(CB_Is)

    # Static Parameters
    global T = 24 # hours on a day
    global M = 60 # minutes in an hour
    global S = 162 #162
    global M_d = T*M # minutes per model, i.e. per day
    global Pen_e_coef = 3 # multiplier on energy for not delivering the activation -> 6, implies we have to pay the capacity back and that it 5 times as expensive tp buy the capacity back
    global Days = 365
    global I = size(CB_Is)[1]
    global RM = 0.9 # %-end SoC assumed, e.g. 0.9 means we assume all charges charge to 90%
#    global k = k_in[1] # set coefecient for how to value "bad scenarios"

    # test days
    global start_day = 1
    global end_day = 1

    global start_1 = time_ns()


    # results data are intialized to be stored
    load_results_storer()


    # load all the aggregated data
    Load_aggregated(CB_Is)

    for Day=start_day:end_day
        println("day is $Day")

        global start_2 = time_ns()

        ###### intialize all daily data, so it's loaded ######
        load_daily_data(Day)
        println("daily data took")
        println(round((time_ns() - start_2) / 1e9, digits = 3))


        ###### derrive bids based on stochastic model ######

        global count_to = 25
        global Y_input = zeros(T)
        global C_up = zeros(T)
        global C_do = zeros(T)
        global slack_up = zeros(T)
        global slack_do = zeros(T)
        global Y_out = zeros(T)
        global Y_zeros = ones(T)*60*S
        lambda = zeros(count_to+1)
        lambda[1] = 0.14*I  # upwards gamma Penalty
        gamma = lambda[1]/5+1   # upwards gamma Penalty
        global change_lambda_up = 100
        global change_lambda_do = 100
        global counter =  1

        while change_lambda_up >= 0.01  && counter <= count_to

            for t=1:T
                println("at hour $t")

                Y_in = sum(Y_out)-Y_out[t]
                Y_in_zeros = sum(Y_zeros)-Y_zeros[t]

                C_do[t], C_up[t], Y_out[t], Y_zeros[t] = ALSO_X_admm(total_flex_up_s, total_flex_do_s, res_20_s, Y_in, Y_in_zeros, lambda[counter], gamma, t)

            end


            if counter < count_to*0.7
                lambda[counter+1] = lambda[counter]+(gamma-(counter*gamma/count_to/0.9)   )*( ( S*M_d-sum(Y_zeros)/(S*M_d) )  - 0.1)
            else
                lambda[counter+1] = lambda[counter]+(gamma-(counter*gamma/count_to/0.9)   )*( ( S*M_d-sum(Y_zeros)/(S*M_d) )  - 0.1)
            end

            println("the bids were:")
            println(C_do)
            println(C_up)

            global change_lambda_up = abs(lambda[counter+1] -lambda[counter])
            println("lambda change is")
            println(abs(lambda[counter+1] -lambda[counter]) )

            global counter = counter + 1

            println(counter)
        end

        for t=1:24
            for m=1:60
                global Do_bids_A[(t-1)*60+m,Day] = C_do[t]
                global Up_bids_A[(t-1)*60+m,Day] = C_up[t]
            end
        end

        ###### Simulate day of operation on realized data ######
        obj, pen, missing_delivery_storer[Day,:], missing_capacity_storer[Day,:], missing_capacity_storer_per[Day,:, :]  = operation(total_flex_up_r, total_flex_do_r, res_20_r, Ac_do_M_r, Ac_up_M_r, Do_bids_A[:,Day], Up_bids_A[:,Day], La_do_r, La_up_r)

        # update results:
        global Total_flex_up[:, Day]   = total_flex_up_r
        global Total_flex_do[:, Day]   = total_flex_do_r

        revenue[1] = revenue[1] + obj
        penalty[1] = penalty[1] + pen

    end

    pr_flex_used_up = round( sum( Up_bids_A )/sum(Total_flex_up ), digits= 3 )
    pr_flex_used_do = round( sum( Do_bids_A )/sum(Total_flex_do ), digits= 3 )

    total_cap_missed[1] = round( (sum(missing_capacity_storer[:,1]))/(-start_day+end_day+1),  digits= 3 )   # % of minute where down capacity were missed
    total_cap_missed[2] = round( sum(missing_capacity_storer[:,2])/(-start_day+end_day+1) ,  digits= 3 )   # % of minute where up capacity were missed
    total_cap_missed[3] = round( sum(missing_capacity_storer[:,3])/(-start_day+end_day+1) ,  digits= 3 )   # % of minute where energy capacity were missed
    total_cap_missed[4] = round( sum(missing_capacity_storer[:,4])/(-start_day+end_day+1) ,  digits= 3 )   # % of minute where we overbid in any category

    average_cap_missed[1] = round( sum(missing_capacity_storer_per[:,:,1]) / (sum(missing_capacity_storer[:,1])*M_d+0.0001) ,  digits= 3 ) # average overbid down
    average_cap_missed[2] = round( sum(missing_capacity_storer_per[:,:,2]) / (sum(missing_capacity_storer[:,2])*M_d+0.0001) ,  digits= 3 )  #  average overbid up
    average_cap_missed[3] = round( sum(missing_capacity_storer_per[:,:,3]) / (sum(missing_capacity_storer[:,3])*M_d+0.0001) ,  digits= 3 )   #  average overbid

    total_delivery_missed[1] =  round( sum(missing_delivery_storer[:,1])/(-start_day+end_day+1) ,  digits= 3 )   # % of of down bids that could not be delivered
    total_delivery_missed[2] =  round( sum(missing_delivery_storer[:,2])/(-start_day+end_day+1) ,  digits= 3 )  # % of of up bids that could not be delivered

    println("The revenue for the entery perioed was $(revenue[1])")
    println("The Penalty would be $(penalty[1])")

    clock = round((time_ns() - start_1) / 1e9, digits = 3)

    return revenue[1], penalty[1], total_cap_missed, average_cap_missed, total_delivery_missed, pr_flex_used_up, pr_flex_used_do, model_runtime, clock, missing_capacity_storer_per
end
