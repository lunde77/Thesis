function ALSO_X(La_do_s, La_up_s, Ac_do_M_s, Ac_up_M_s, total_flex_up_s, total_flex_do_s, res_20_s)
    global start_also = time_ns()
    ###### run model - make the bids ######
    fail_rate = 0.1
    q_L_e, q_L_up, q_L_do = 0,0,0
    q_H_e, q_H_up, q_H_do = fail_rate*M_d*S, fail_rate*M_d*S, fail_rate*M_d*S
    # store the itteration
    counter = 1

    q_up = (q_H_up+q_L_up)/2
    q_do = (q_H_up+q_L_up)/2
    q_e = (q_H_e+q_L_e)/2

    Mo, Con_do, Con_up, Con_e, Y_do_v, Y_up_v, Y_e_v, C_do_v, C_up_v = Stochastic_chancer_model(La_do_s, La_up_s, Ac_do_M_s, Ac_up_M_s, total_flex_do_s, total_flex_up_s, res_20_s, q_do, q_up, q_e)

    global C_do_v = C_do_v
    global C_up_v = C_up_v
    global q_H_up_counter = zeros(100)
    global q_L_up_counter = zeros(100)
    global C_do_s = zeros(100,24)
    global C_up_s = zeros(100,24)

    while (-q_L_up+q_H_up) > 0.001 &&  (-q_L_do+q_H_do) > 0.001 &&  (-q_L_e+q_H_e) > 0.001 && counter < 200
        println(counter)

        q_up = (q_H_up+q_L_up)/2
        q_do = (q_H_do+q_L_do)/2
        q_e = (q_H_e+q_L_e)/2

        global y_do, y_up, y_e, C_do, C_up, obj = Stochastic_chancer_solver(Mo, Con_do, Con_up, Con_e, Y_do_v, Y_up_v, Y_e_v, C_do_v, C_up_v, q_do, q_up, q_e)

        C_do_s[counter,:] = C_do
        C_up_s[counter,:] = C_up


        global Y_counter_up = count(x -> x == 0, y_up)

        if Y_counter_up >= (1-fail_rate)*M_d*S
            q_L_up = q_up
        else
            q_H_up = q_up
        end
        q_L_up_counter[counter] = q_L_do
        q_H_up_counter[counter] = q_H_up

        global Y_counter_do = count(x -> x == 0, y_do)

        if Y_counter_do >= (1-fail_rate)*M_d*S
            q_L_do = q_do
        else
            q_H_do = q_do
        end

        global Y_counter_e = count(x -> x == 0, y_e)

        if Y_counter_e >= (1-fail_rate)*M_d*S
            q_L_e = q_e
        else
            q_H_e = q_e
        end


        counter = counter + 1
    end


    model_runtime = round((time_ns() - start_also) / 1e9, digits = 3)
    return C_do, C_up, model_runtime
end
