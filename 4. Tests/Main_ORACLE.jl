using Statistics

# input:
# CB_Is: number of chargeboxses used


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
# Up_bids_A: uowards bid to each hour of the periode
# Do_bids_A: downwards each hour of the the periode
# Freq_overbid_h: frequecy of overbid for each hour
# revenue[1]: the total revenue realized for whole testing period [DKK]
# penalty[1]: The total penalty realized for whole testing period [DKK]

function Main_Oracle(CB_Is)

    # Static Parameters
    global T = 24                                           # hours on a day
    global M = 60                                           # minutes in an hour
    global M_d = T*M                                        # minutes per model, i.e. per day
    global Pen_e_coef = 6                                   # multiplier on energy for not delivering the activation -> 6, implies we have to pay the capacity back and that it 5 times as expensive tp buy the capacity back
    global Days = 365
    global Sampling = 0                                     # means no smapling
    global S = 1                                            # i.e. Deterministic moddeling
    global I = size(CB_Is)[1]
    global start_1 = time_ns()

    # results data are intialized to be stored
    load_results_storer()

    # load all the aggregated data
    Load_aggregated(CB_Is)

    ### run test for days in a year
    global n_days = Int32(floor(Days))
#
    Threads.@threads for j=1:363
        Day = j+1 # we're not looking at the first and final day
        println("day is $Day")
        # if sampling of day's chose bid accordinly
        #if Day ∈ D_w
        #    b =  w
        #else
        #    b = w+NF
        #end
        La_do_r, La_up_r, Ac_do_M_r, Ac_up_M_r, total_flex_do_r, total_flex_up_r, res_20_r = load_daily_data(Day)

        start = time_ns()
        for t=1:24
            C_do, C_up = Oracle_model(total_flex_do_r[(t-1)*60+1:t*60], total_flex_up_r[(t-1)*60+1:t*60], res_20_r[(t-1)*60+1:t*60])

            for m=1:60
                Do_bids_A[(t-1)*60+m,Day] = C_do
                Up_bids_A[(t-1)*60+m,Day] = C_up
            end
        end

        model_runtime = round((time_ns() - start) / 1e9, digits = 3)

        ###### Simulate day of operation on realized data ######                                                                                                                                             operation(Total_flex_up, Total_flex_do, res_20_r, ac_do_m, ac_up_m, C_do, C_up, La_do, La_up)
        revenue[1+(Day-1)*24:Day*24,1], penalty[1+(Day-1)*24:Day*24,1], missing_delivery_storer[1,Day,:], missing_capacity_storer[1,Day,:], missing_capacity_storer_per[1,Day,:, :], Freq_overbid_h[Day,:] = operation(total_flex_up_r, total_flex_do_r, res_20_r, Ac_do_M_r, Ac_up_M_r, Do_bids_A[:,Day], Up_bids_A[:,Day], La_do_r, La_up_r)

        # update results:
        Total_flex_up[1,:, Day]   = total_flex_up_r
        Total_flex_do[1,:, Day]   = total_flex_do_r

    end


    pr_flex_used_up[1] = round( (sum( Up_bids_A ))/sum(Total_flex_up[1,:,2:364] ), digits= 3 )  # % of upwards flexibity bid into market
    pr_flex_used_do[1] = round( (sum( Do_bids_A ))/sum(Total_flex_do[1,:,2:364] ), digits= 3 )  # % of downwards flexibity bid into market

    total_cap_missed[1,1] = round( sum(missing_capacity_storer[1,:,1])/(n_days),  digits= 3 )    # % of minute where down capacity were missed
    total_cap_missed[1,2] = round( sum(missing_capacity_storer[1,:,2])/(n_days) ,  digits= 3 )   # % of minute where up capacity were missed
    total_cap_missed[1,3] = round( sum(missing_capacity_storer[1,:,3])/(n_days) ,  digits= 3 )   # % of minute where energy capacity were missed
    total_cap_missed[1,4] = round( sum(missing_capacity_storer[1,:,4])/(n_days) ,  digits= 3 )   # % of minute where we overbid in any category

    average_cap_missed[1,1] = round( sum(missing_capacity_storer_per[1,:,:,1]) / (sum(missing_capacity_storer[1,:,1])*M_d+0.0001) ,  digits= 3 )   # average overbid down
    average_cap_missed[1,2] = round( sum(missing_capacity_storer_per[1,:,:,2]) / (sum(missing_capacity_storer[1,:,2])*M_d+0.0001) ,  digits= 3 )   #  average overbid up
    average_cap_missed[1,3] = round( sum(missing_capacity_storer_per[1,:,:,3]) / (sum(missing_capacity_storer[1,:,3])*M_d+0.0001) ,  digits= 3 )   #  average overbid

    total_delivery_missed[1,1] =  round( sum(missing_delivery_storer[1,:,1])/(n_days) ,  digits= 3 )   # % of of down bids that could not be delivered
    total_delivery_missed[1,2] =  round( sum(missing_delivery_storer[1,:,2])/(n_days) ,  digits= 3 )   # % of of up bids that could not be delivered

    rev_mean = sum(revenue[:,1])/(n_days)       # normlize it so it on a daily scale
    pen_mean = sum(penalty[:,1])/(n_days)       # normlize it so it on a daily scale

    println("The revenue for the entery perioed was $(sum(revenue))")
    println("The Penalty would be $(sum(penalty))")

    for d=2:364
        Threads.@threads for m=1:M_d
            if missing_capacity_storer_per[1,d,m,1] >  missing_capacity_storer_per[1,d,m,2] &&   missing_capacity_storer_per[1,d,m,1] >  missing_capacity_storer_per[1,d,m,3]
                missing_capacity_storer_per_max[(d-1)*M_d+m] = missing_capacity_storer_per[1,d,m,1]
            elseif missing_capacity_storer_per[1,d,m,2] > missing_capacity_storer_per[1,d,m,3]
                missing_capacity_storer_per_max[(d-1)*M_d+m] = missing_capacity_storer_per[1,d,m,2]
            else
                missing_capacity_storer_per_max[(d-1)*M_d+m] = missing_capacity_storer_per[1,d,m,3]
            end
        end
    end


    clock = round((time_ns() - start_1) / 1e9, digits = 3)
    return rev_mean, pen_mean, total_cap_missed[1,:], average_cap_missed[1,:], total_delivery_missed[1,:], pr_flex_used_up[1], pr_flex_used_do[1], model_runtime, clock, missing_capacity_storer[1,:,4], Up_bids_A[:,2:n_days-1], Do_bids_A[:,2:n_days-1], Freq_overbid_h, missing_capacity_storer_per_max, revenue[:,1], penalty[:,1]
end
