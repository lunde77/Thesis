function ALSO_X_admm(total_flex_up_s, total_flex_do_s, res_20_s, Y_else, Y_zeros, lambda, gamma, t)
    global start_also = time_ns()

    C_do_all = zeros(1)
    C_up_all = zeros(1)
    Y_sum = 0
    y_counter = 0


    println("hour is $t")
    ###### run model - make the bids ######
    fail_rate = 0.1
    q_L = 0
    q_H = fail_rate*M_d*S
    # store the itteration
    counter = 1

    q = (q_H+q_L)/2

    Mo, Con, Y_v, C_do_v, C_up_v = Stochastic_chancer_model_hourly(total_flex_do_s[t,:,:], total_flex_up_s[t,:,:], res_20_s[t,:,:], Y_else, q, lambda, gamma)

    C_do_v = C_do_v
    C_up_v = C_up_v
    q_H_counter = zeros(100)
    q_L_counter = zeros(100)
    C_do_s = zeros(100)
    C_up_s = zeros(100)

    while (-q_L+q_H) > 0.01  && counter < 20
        println(counter)
        println(counter)


        q = (q_H+q_L)/2


        y, C_do_m, C_up_m, obj = Stochastic_chancer_solver_hourly(Mo, Con, Y_v, C_do_v, C_up_v, q)

        C_do_s[counter] = deepcopy(C_do_m)
        C_up_s[counter] = deepcopy(C_up_m)


        Y_counter = count(x -> x == 0, y) + Y_zeros

        Y_sum = sum(y)

        if Y_counter >= (1-fail_rate)*M_d*S
            q_L = q
        else
            q_H = q
        end
        q_L_counter[counter] = q_L
        q_H_counter[counter] = q_H

        counter = counter + 1
        println(C_do_m)
        println(C_do_m)
        C_do_all[1] = C_do_m
        C_up_all[1] = C_up_m
    end



    model_runtime = round((time_ns() - start_also) / 1e9, digits = 3)

    return C_do_all[1], C_up_all[1], Y_sum, y_counter
end
