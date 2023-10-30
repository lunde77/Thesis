function ALSO_X(total_flex_up_s, total_flex_do_s, res_20_s)
    global start_also = time_ns()

    C_do_all = zeros(24)
    C_up_all = zeros(24)

    Threads.@threads for t=1:24
        println("hour is $t")
        ###### run model - make the bids ######
        fail_rate = 0.1
        q_L = 0
        q_H = fail_rate*M*S
        # store the itteration
        counter = 1

        q = (q_H+q_L)/2

        Mo, Con, Y_v, C_do_v, C_up_v = Stochastic_chancer_model_hourly(total_flex_do_s[t,:,:], total_flex_up_s[t,:,:], res_20_s[t,:,:], q)

        C_do_v = C_do_v
        C_up_v = C_up_v
        q_H_counter = zeros(100)
        q_L_counter = zeros(100)
        C_do_s = zeros(100)
        C_up_s = zeros(100)

        while (-q_L+q_H) > 0.001  && counter < 200
            println(counter)


            q = (q_H+q_L)/2


            y, C_do_m, C_up_m, obj = Stochastic_chancer_solver_hourly(Mo, Con, Y_v, C_do_v, C_up_v, q)

            C_do_s[counter] = deepcopy(C_do_m)
            C_up_s[counter] = deepcopy(C_up_m)


            Y_counter_up = count(x -> x == 0, y)

            if Y_counter_up >= (1-fail_rate)*M*S
                q_L = q
            else
                q_H = q
            end
            q_L_counter[counter] = q_L
            q_H_counter[counter] = q_H

            counter = counter + 1
            println(C_do_m)
            println(C_do_m)
            C_do_all[t] = C_do_m
            C_up_all[t] = C_up_m
        end
<<<<<<< HEAD
        C_do_all[t] = C_do
        C_up_all[t] = C_up
=======



>>>>>>> c691cb34d8611d0475af2cdebd9e34d97e387ff1
    end

    model_runtime = round((time_ns() - start_also) / 1e9, digits = 3)
    return C_do_all, C_up_all, model_runtime
end
