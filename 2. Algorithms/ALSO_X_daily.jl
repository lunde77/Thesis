function ALSO_X_daily(total_flex_up_s, total_flex_do_s, res_20_s)
    global start_also = time_ns()
    ###### run model - make the bids ######
    C_do_all = zeros(24)
    C_up_all = zeros(24)
    fail_rate = 0.1
    q_L = 0
    q_H = fail_rate*M_d*S
    # store the itteration
    counter = 1

    q = (q_H+q_L)/2
    Mo, Con, Y_v, C_do_v, C_up_v  = Stochastic_chancer_model_daily(total_flex_do_s, total_flex_up_s, res_20_s, q)

    # intialize bids and potentially itteration analyser Parameters
    C_do_v = C_do_v
    C_up_v = C_up_v
    global q_H_counter = zeros(100)
    global q_L_counter = zeros(100)
    global C_do_s = zeros(100,24)
    global C_up_s = zeros(100,24)


    while (-q_L+q_H) > q_epilon  && counter < 10000
        println(counter)

        q = (q_H+q_L)/2
        y, C_do_all, C_up_all, obj = Stochastic_chancer_solver_daily(Mo, Con, Y_v, C_do_v, C_up_v,  q)

        C_do_s[counter,:] = deepcopy(C_do_all)
        C_up_s[counter,:] = deepcopy(C_up_all)


        Y_counter = count(x -> x == 0, y)

        if Y_counter >= (1-fail_rate)*M_d*S
            q_L = q
        else
            q_H = q
        end
        q_L_counter[counter] = q_L
        q_H_counter[counter] = q_H

        counter = counter + 1
    end


    model_runtime = round((time_ns() - start_also) / 1e9, digits = 3)
    return C_do_all, C_up_all, model_runtime
end
