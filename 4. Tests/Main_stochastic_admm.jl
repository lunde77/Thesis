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
    end_day = 1
    global clock = zeros(5)
    global start = time_ns()
    # results data are intialized to be stored
    load_results_storer()
    clock[1] = round((time_ns() - start) / 1e9, digits = 3)

    println(clock[1])
    println(clock[1])

    global start = time_ns()
    # load all the aggregated data
    Load_aggregated(CB_Is)
    clock[2] = round((time_ns() - start) / 1e9, digits = 3)

    println(clock[2])
    println(clock[2])


    for Day=start_day:end_day
        println("day is $Day")


        ###### intialize all daily data, so it's loaded ######
        global start = time_ns()

        load_daily_data(Day)

        clock[3] = round((time_ns() - start) / 1e9, digits = 3)
        global start = time_ns()

        println(clock[3])
        println(clock[3])
        ###### derrive bids based on stochastic model ######



        global count_to = 15
        global per_dev_up_input = ones(M_d,S)*0.5
        global per_dev_do_input = ones(M_d,S)*0.5
        global slack_in_up = 1-sum(per_dev_up_input)/(M_d*S)
        global slack_in_do = 1-sum(per_dev_do_input)/(M_d*S)
        per_dev_up_input_in_loop, per_dev_do_input_in_loop = deepcopy(per_dev_up_input), deepcopy(per_dev_do_input)
        global C_up = zeros(T)
        global C_do = zeros(T)
        global slack_up = ones(T)*slack_in_up/24
        global slack_do = ones(T)*slack_in_do/24

        lambda = zeros(2,count_to+1)
        lambda[1,1] = 0.14*I  # upwards gamma Penalty
        lambda[2,1] = I/3  # downwards gamma Penalty
        gamma = zeros(2)
        gamma[1] = lambda[1,1]/5+1   # upwards gamma Penalty
        gamma[2] = lambda[2,1]/5+1   # upwards gamma Penalty
        global change_lambda_up = 100
        global change_lambda_do = 100
        global counter =  1


        while (change_lambda_up >= 0.01 || change_lambda_do >= 0.01) && counter <= count_to
            for t=1:T
                do_input = (sum(per_dev_do_input)-sum(per_dev_do_input[(t-1)*60+m,s] for m=1:M, s=1:S))
                up_input = (sum(per_dev_up_input)-sum(per_dev_up_input[(t-1)*60+m,s] for m=1:M, s=1:S))
                #slack_in_up = sum(slack_in_up)-slack_up[t]
                #slack_in_up = sum(slack_in_do)-slack_do[t]

                println(lambda[:,counter])

                global C_up[t], C_do[t], per_dev_up_input_in_loop[(t-1)*60+1:t*60,:], per_dev_do_input_in_loop[(t-1)*60+1:t*60,:], slack_up[t], slack_do[t] = Stochastic_d1_model_hourly(La_do_s, La_up_s, Ac_do_s, Ac_up_s, Max_Power_s, po_cap_s, kWh_cap_s, Power_s, Connected_s, SoC_start_s, SoC_A_cap_s, flex_up_s, flex_do_s, total_flex_up_s, total_flex_do_s, I, S, t, RM, gamma, lambda[:,counter], up_input, do_input)
                #per_dev_up_input, per_dev_do_input = deepcopy(per_dev_up_input_in_loop), deepcopy(per_dev_do_input_in_loop)
                #lambda[1,counter] = lambda[1,counter]+(gamma[1])*(sum(per_dev_up_input)/(S*M_d)+sum(slack_up)/24-1)
                #lambda[2,counter] = lambda[2,counter]+(gamma[2])*(sum(per_dev_do_input)/(S*M_d)+sum(slack_do)/24-1)

                println("the bids were:")
                println(C_do[t])
                println(C_up[t])

            end

            per_dev_up_input, per_dev_do_input = deepcopy(per_dev_up_input_in_loop), deepcopy(per_dev_do_input_in_loop)
            if counter < count_to*0.7
                lambda[1,counter+1] = lambda[1,counter]+(gamma[1]-(counter*gamma[1]/count_to/0.9)   )*(sum(per_dev_up_input)/(S*M_d)-1)
                lambda[2,counter+1] = lambda[2,counter]+(gamma[2]-(counter*gamma[2]/count_to/0.9)  )*(sum(per_dev_do_input)/(S*M_d)-1)
            else
                lambda[1,counter+1] = lambda[1,counter]+(gamma[1]-(count_to*0.7*gamma[1]/count_to/0.75)  )*(sum(per_dev_up_input)/(S*M_d)-1)
                lambda[2,counter+1] = lambda[2,counter]+(gamma[2]-(count_to*0.7*gamma[2]/count_to/0.75)  )*(sum(per_dev_do_input)/(S*M_d)-1)
            end
            println("the bids were:")
            println(C_do)
            println(C_up)

            global change_lambda_up = abs(lambda[1,counter+1] -lambda[1,counter])
            global change_lambda_do = abs(lambda[2,counter+1] -lambda[2,counter])
            println("lambda change is")
            println(abs(lambda[1,counter+1] -lambda[1,counter]) )
            println(abs(lambda[2,counter+1] -lambda[2,counter]) )


            global counter = counter + 1

            println(counter)
        end

        println(counter )

        global lambda = lambda
        #global down_shadow = down_shadow
        global per_dev_up_input = per_dev_up_input
        global C_do = C_do
        global C_up = C_up

        clock[4] = round((time_ns() - start) / 1e9, digits = 3)




    end
    return
end
