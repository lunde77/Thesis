function ALSO_X_hourly(total_flex_up_s, total_flex_do_s, res_20_s)
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
        q_H_counter = zeros(200)
        q_L_counter = zeros(200)
        C_do_s = zeros(200)
        C_up_s = zeros(200)
        y_counter_c = zeros(200)


        while (-q_L+q_H) > q_epilon  && counter < 200
            println(counter)


            q = (q_H+q_L)/2
            if  2.0e-5 > q
                q = 0.0
                numerical_end = false
                println(numerical_end)
            end

            println(q)


            y, C_do_m, C_up_m, obj = Stochastic_chancer_solver_hourly(Mo, Con, Y_v, C_do_v, C_up_v, q)

            C_do_s[counter] = deepcopy(C_do_m)
            C_up_s[counter] = deepcopy(C_up_m)


            Y_counter = count(x -> x == 0, y)
            y_counter_c[counter] = Y_counter
            println(q_epilon)
            println(Y_counter)

            if Y_counter >= (1-fail_rate)*M*S
                q_L = q
            else
                q_H = q
            end
            q_L_counter[counter] = q_L
            q_H_counter[counter] = q_H

            counter = counter + 1
            if C_do_m <  1.0e-2
                C_do_m = 0
            end
            if C_up_m < 1.0e-2
                C_up_m = 0
            end
            println(C_do_m)
            println(C_up_m)
            C_do_all[t] = C_do_m
            C_up_all[t] = C_up_m

            # check if have run into numerical reason to terminate
            if  q == 0
                break
            end

        end

    end

    model_runtime = round((time_ns() - start_also) / 1e9, digits = 3)
    return C_do_all, C_up_all, model_runtime
end
