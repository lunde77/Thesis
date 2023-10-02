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
    end_day = 5

    # results data are intialized to be stored
    load_results_storer()

    # load all the aggregated data
    Load_aggregated(CB_Is)


    for Day=start_day:end_day
        println("day is $Day")


        ###### intialize all daily data, so it's loaded ######
        load_daily_data(Day)

        ###### derrive bids based on stochastic model ######
        Up_bids_A[:,Day], Do_bids_A[:,Day], Up_bids_I[:,Day,:,:], Do_bids_I[:,Day,:,:], ex_p_up[:,Day,:], ex_p_do[:,Day,:],
            ex_p_total[Day], expected_over[:,Day,:], after_Activation[:,Day], expected_pen = Stochastic_d1_model(La_do_s, La_up_s, Ac_do_s, Ac_up_s, Max_Power_s, po_cap_s, kWh_cap_s, Power_s, Connected_s, SoC_start_s, SoC_A_cap_s, flex_up_s, flex_do_s, total_flex_up_s, total_flex_do_s, I, S, RM)


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
        Activation_energy[:,Day,:] = A_E
        revenue[1] = revenue[1] + obj
        println("The revenue  mode would be $obj")
        missing_delivery[1] = missing_delivery[1] + missing_del

        global SoC_end
        global expected_pen = expected_pen
    end

    println("The revenue  mode would be $(revenue[1])")
    println("The missing delivery would be $(missing_delivery[1])")
    return revenue[1], missing_delivery[1]
end
