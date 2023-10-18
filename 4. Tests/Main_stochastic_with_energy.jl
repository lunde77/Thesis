function Main_stochastic(CB_Is)

    # Static Parameters
    global T = 24 # hours on a day
    global M = 60 # minutes in an hour
    global M_d = T*M # minutes per model, i.e. per day
    global Days = 365
    global I = size(CB_Is)[1]
    global S = 10
    global RM = 0.9 # %-end SoC assumed, e.g. 0.9 means we assume all charges charge to 90%

    # test days
    start_day = 1
    end_day = 365
    global start_1 = time_ns()


    # results data are intialized to be stored
    load_results_storer()


    # load all the aggregated data
    Load_aggregated(CB_Is)

    for Day=start_day:end_day
        println("day is $Day")


        ###### intialize all daily data, so it's loaded ######
        load_daily_data(Day)

        ###### run model - make the bids ######
        global C_up, C_do, model_runtime = Stochastic_d1_model(La_do_s, La_up_s, Ac_do_s, Ac_up_s, total_flex_up_s, total_flex_do_s, S)


        for t=1:24
            for m=1:60
                global Do_bids_A[(t-1)*60+m,Day] = C_do[t]
                global Up_bids_A[(t-1)*60+m,Day] = C_up[t]
            end
        end

        ###### Initialize the SoC for the begining of th day ######
        for i=1:I
            if Day == start_day
                global SoC_start_r[i] = 0
            else
                global SoC_start_r[i] = SoC_end[i]
            end
            # Alter the power if it's conflicting with the SoC limits
            Power_r[:,i], altered = baseline_altering(Power_r[:,i], SoC_start_r[i], Connected_r[:,i], po_cap_r[:,i], kWh_cap_r[:,i])
        end


        ###### Simulate day of operation on realized data ######
        obj, SoC_end, missing_del, A_E, missing_delivery_storer[Day,:] = operation(kWh_cap_r, po_cap_r, Power_r, SoC_start_r, Max_Power_r, Connected_r, Ac_do_r, Ac_up_r, Do_bids_A[:,Day], Up_bids_A[:,Day], La_do_r, La_up_r, RM)

        # update results:
        missing_delivery[1]  = missing_delivery[1] + missing_del
        Total_flex_up[Day]   = sum(total_flex_up_r)
        Total_flex_do[Day] = sum(total_flex_do_r)

        revenue[1] = revenue[1] + obj
        println("The revenue for day $Day was $obj")

        global SoC_end
    end

    pr_flex_used_up = sum( Up_bids_A )/sum(Total_flex_up )
    pr_flex_used_do = sum( Do_bids_A )/sum(Total_flex_do )


    total_cap_missed[1] = sum(missing_delivery_storer[:,1])/(-start_day+end_day+1)
    total_cap_missed[2] = sum(missing_delivery_storer[:,2])/(-start_day+end_day+1)
    println("The revenue for the entery perioed was $(revenue[1])")
    println("The missing delivery would be $(missing_delivery[1])")

    clock = round((time_ns() - start_1) / 1e9, digits = 3)

    return revenue[1], missing_delivery[1], total_cap_missed, model_runtime, clock, pr_flex_used_up, pr_flex_used_do
end
