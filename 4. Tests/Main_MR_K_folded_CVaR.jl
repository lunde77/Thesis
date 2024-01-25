# input:
# CB_Is: number of chargeboxses used
# model_res: "hourly" or "daily" -> desiced if bid, should be made with a hourly of daily scope on P10
# Sampling_in mehotd: 1: random from houly, 2: undtional sampling from ninute, 3: dependent sampling on days, 4: base, condtional sampling from minute distribution

# output:
# rev_mean: average daily revenue [DKK]
# pen_mean: Averge daily penalty [DKK]
# total_cap_missed: % of the time we don't have the capacity to meet the bid - four dimensional - one for each flexibity and overall
# average_cap_missed: average capacity missed to each flexibity - 3 dimensional
# total_delivery_missed: How much of the total activation do we on daily average not deliver
# pr_flex_used_up: How much of the total upwards flexibity was bid into the market
# pr_flex_used_do: How much of the total downwards flexibity was bid into the market
# model_runtime: How long is takes solve the model (stochastig model)
# clock: Total runtime for the entery sumlation
# missing_capacity_storer: overbid in % for each minute - maximum for each ccategory
# Up_bids_A: uowards bid for each fold to each hour
# Do_bids_A: downwards bid for fold to each hour
# Freq_overbid_h: frequecy of overbid for each hour
# revenue[1]: the total revenue realized for whole testing period [DKK]
# penalty[1]: The total penalty realized for whole testing period [DKK]

function Main_stochastic_CVAR_OSS_folded(CB_Is, model_res, Sampling_in)

    # Static Parameters
    global NF = 3                                           # Number of folds
    global test_type = "T2"                                 # sample input -> don't change (specefic for folded mains)
    global T = 24                                           # hours on a day
    global M = 60                                           # minutes in an hour
    global S = 216                                          # number of samples in IS
    global M_d = T*M                                        # minutes per model, i.e. per day
    global Pen_e_coef = 6                                   # multiplier on energy for not delivering the activation -> 6, implies we have to pay the capacity back and that it 5 times as expensive tp buy the capacity back
    global Days = 365                                       # days in a year
    global I = size(CB_Is)[1]                               # Number of CBs in portfolio
    global RM = 0.9                                         # %-end SoC assumed, e.g. 0.9 means we assume all charges charge to 90%
    global Sampling = Sampling_in #5
    global start_1 = time_ns()

    # results data are intialized to be stored
    load_results_storer()

    # load all the aggregated data
    Load_aggregated(CB_Is)


    ###### iload the folds for in and out of sample days ######
    global sampled_numbers, OOS_days =  make_folds(NF)

    ### run test on the sample days
    println(sampled_numbers)
    println(OOS_days)

    ### run test on the sample days
    for w=1:NF
        i = 1
        if Sampling == 3
            i_n = 2
        else
            i_n = 1
        end
        total_flex_do_s, total_flex_up_s, res_20_s = load_sampling_data(1, sampled_numbers[w,:], "xxx") # XX imples that the output/input is not used
        for i=1:1
            ###### intialize sampling data, so it's loaded ######
            if i==1 && i_n == 2  # load samples for weekdays if sampling methods is chosen
                total_flex_do_s, total_flex_up_s, res_20_s = load_sampling_data(1, sampled_numbers[w,:], "W") # XX imples that the output/input is not used
            elseif i_n == 2# load samples for weekendays
                total_flex_do_s, total_flex_up_s, res_20_s = load_sampling_data(1, sampled_numbers[w,:], "S") # XX imples that the output is not used
            end



            global start_2 = time_ns()
            # intialize global bids
            global C_do = zeros(24)
            global C_up = zeros(24)
            ###### solve the model in a decomposed matter by appliying the CVaR method ######
            if model_res == "hourly"
                Threads.@threads for t=1:24 # dolve the hourly models in paralel
                    C_do[t], C_up[t] = Stochastic_chancer_model_hourly_CVAR(total_flex_do_s[t,:,:], total_flex_up_s[t,:,:], res_20_s[t,:,:])
                end
            elseif model_res == "daily"
                C_do, C_up = Stochastic_chancer_model_daily_CVAR(total_flex_do_s, total_flex_up_s, res_20_s)
            end

            # asaigning all bids to global varibles
            for t=1:24
                for m=1:60
                    global Do_bids_A[(t-1)*60+m,w+(i-1)*NF] = C_do[t]
                    global Up_bids_A[(t-1)*60+m,w+(i-1)*NF] = C_up[t]
                end
            end
        end
        global model_runtime = round((time_ns() - start_2) / 1e9, digits = 3)
        global n_days = Int32(floor(363/NF) )

        Threads.@threads for j=1:n_days
            Day = OOS_days[w,j]
            println("day is $Day")
            # if sampling of day's chose bid accordinly
            if Sampling == 3
                if Day ∈ D_w
                    b =  w
                else
                    b = w+NF
                end
            else
                b = w
            end

            start_2 = time_ns()

            ###### intialize all daily data, so it's loaded ######
            La_do_r, La_up_r, Ac_do_M_r, Ac_up_M_r, total_flex_do_r, total_flex_up_r, res_20_r = load_daily_data(Day)
            println("daily data took")
            println(round((time_ns() - start_2) / 1e9, digits = 3))

            ###### Simulate day of operation on realized data ######
            revenue[1+(Day-1)*24:Day*24,1], penalty[1+(Day-1)*24:Day*24,1], missing_delivery_storer[1,Day,:], missing_capacity_storer[1,Day,:], missing_capacity_storer_per[1,Day,:, :], Freq_overbid_h[Day,:]  = operation(total_flex_up_r, total_flex_do_r, res_20_r, Ac_do_M_r, Ac_up_M_r, Do_bids_A[:,b], Up_bids_A[:,b], La_do_r, La_up_r)

            # update results:
            Total_flex_up[1,:, Day]   = total_flex_up_r
            Total_flex_do[1,:, Day]   = total_flex_do_r


        end
    end

    if Sampling == 3 # if using dependent smapling the bids should accounted for how often they are used
        pr_flex_used_up[1] = round( (sum( Up_bids_A[:,1:NF] )*length(D_w)/NF+sum( Up_bids_A[:,NF+1:NF*2] )*length(D_s)/NF )/sum(Total_flex_up[1,:,:] ), digits= 3 )  # % of upwards flexibity bid into market
        pr_flex_used_do[1] = round( (sum( Do_bids_A[:,1:NF] )*length(D_w)/NF+sum( Do_bids_A[:,NF+1:NF*2] )*length(D_s)/NF )/sum(Total_flex_do[1,:,:] ), digits= 3 )  # % of downwards flexibity bid into market
    else
        pr_flex_used_up[1] = round( (sum( Up_bids_A )*n_days)/sum(Total_flex_up[1,:,:] ), digits= 3 )  # % of upwards flexibity bid into market
        pr_flex_used_do[1] = round( (sum( Do_bids_A )*n_days)/sum(Total_flex_do[1,:,:] ), digits= 3 )  # % of downwards flexibity bid into market
    end



    total_cap_missed[1,1] = round( (sum(missing_capacity_storer[1,:,1]))/(n_days*NF),  digits= 3 )  # % of minute where down capacity were missed
    total_cap_missed[1,2] = round( sum(missing_capacity_storer[1,:,2])/(n_days*NF) ,  digits= 3 )   # % of minute where up capacity were missed
    total_cap_missed[1,3] = round( sum(missing_capacity_storer[1,:,3])/(n_days*NF) ,  digits= 3 )   # % of minute where energy capacity were missed
    total_cap_missed[1,4] = round( sum(missing_capacity_storer[1,:,4])/(n_days*NF) ,  digits= 3 )   # % of minute where we overbid in any category

    average_cap_missed[1,1] = round( sum(missing_capacity_storer_per[1,:,:,1]) / (sum(missing_capacity_storer[1,:,1])*M_d+0.0001) ,  digits= 3 )   #  average overbid down
    average_cap_missed[1,2] = round( sum(missing_capacity_storer_per[1,:,:,2]) / (sum(missing_capacity_storer[1,:,2])*M_d+0.0001) ,  digits= 3 )   #  average overbid up
    average_cap_missed[1,3] = round( sum(missing_capacity_storer_per[1,:,:,3]) / (sum(missing_capacity_storer[1,:,3])*M_d+0.0001) ,  digits= 3 )   #  average overbid

    total_delivery_missed[1,1] =  round( sum(missing_delivery_storer[1,:,1])/(n_days*NF) ,  digits= 30 )   # % of of down bids that could not be delivered
    total_delivery_missed[1,2] =  round( sum(missing_delivery_storer[1,:,2])/(n_days*NF) ,  digits= 30 )   # % of of up bids that could not be delivered

    rev_mean = sum(revenue[:,1])/(n_days*NF)       # normlize it so it on a daily scale
    pen_mean = sum(penalty[:,1])/(n_days*NF)       # normlize it so it on a daily scale

    println("The revenue for the entery perioed was $(sum(revenue))")
    println("The Penalty would be $(sum(penalty))")

    for d=1:365
        for m=1:M_d
            if missing_capacity_storer_per[1,d,m,1] >= missing_capacity_storer_per[1,d,m,2] &&  missing_capacity_storer_per[1,d,m,1] >=  missing_capacity_storer_per[1,d,m,3]
                missing_capacity_storer_per_max[(d-1)*M_d+m] = missing_capacity_storer_per[1,d,m,1]
            elseif missing_capacity_storer_per[1,d,m,2] >= missing_capacity_storer_per[1,d,m,3]
                missing_capacity_storer_per_max[(d-1)*M_d+m] = missing_capacity_storer_per[1,d,m,2]
            else
                missing_capacity_storer_per_max[(d-1)*M_d+m] = missing_capacity_storer_per[1,d,m,3]
            end
        end
    end


    clock = round((time_ns() - start_1) / 1e9, digits = 3)

    return rev_mean, pen_mean, total_cap_missed[1,:], average_cap_missed[1,:], total_delivery_missed[1,:], pr_flex_used_up[1], pr_flex_used_do[1], model_runtime, clock,  missing_capacity_storer[1,:,4], Up_bids_A[:,1:NF], Do_bids_A[:,1:NF], Freq_overbid_h, missing_capacity_storer_per_max, revenue[:,1], penalty[:,1]
end
