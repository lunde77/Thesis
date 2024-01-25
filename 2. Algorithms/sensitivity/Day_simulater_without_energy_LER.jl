### input:
# Total_flex_up:    The total upwards flexibility of the entiery portefolio relative to baseline - 1440
# Total_flex_up:    The total downwards flexibility of the entiery portefolio relative to baseline - 1440
# ac_do_m:          The percentual maximum upwards activation for all minutes - % - 1xM
# ac_up_m:          The percentual maxsimum downwards activation for all minutes - % - 1xM
# La_up:            The price for the bids upwards - DKK 1x24
# La_down:          The price for the bids downwards - DKK 1x24
# C_do:             The aggregated downwards bid for all minutes  - kW - 1xM
# C_up:             The aggregated upwards bid for all minutes  - kW - 1xM

### output:
# revenue:          The profti generated from bid quntities
# penalty:          The cost of not meetning the acatvation
# M_C:              The % of the time the entire bid were not available - up and down [2]
# M_A:              How much of the activation were not meet - up and down [2]

function operation_LER(Total_flex_up, Total_flex_do, res_20_r, ac_do_m, ac_up_m, C_do, C_up, La_do, La_up)


    M_d = 1440
    T= 24
    Missing_capacity_storer_per = zeros(M_d,3)  # store how much we overbid when we do - it in %
    Missing_capacity_storer = zeros(M_d,4)      # Store how much less capacity we have realtive to the bid
    Missing_activation_storer = zeros(M_d,2)    # Store the missed activation - this is not energy - but power missed
    Pen_activation_up = zeros(24)               # penalty for upwards for ach hour
    Pen_activation_do = zeros(24)               # penalty for downwards for ach hour

    for m=1:M_d

        # find potential flexibility issues, as wee need to have enough flexibility in both direction concerning the activátion level
        if Total_flex_do[m] < C_do[m]
            Missing_capacity_storer[m,1] = 1
            Missing_capacity_storer_per[m,1] = (C_do[m]-Total_flex_do[m])/C_do[m]
        end
        if Total_flex_up[m] < C_up[m]
            Missing_capacity_storer[m,2] = 1
            Missing_capacity_storer_per[m,2] = (( C_up[m])-Total_flex_up[m])/( C_up[m])
        end
        if sum(Missing_capacity_storer[m,:]) > 0.0000001 # if any capacity is violated
            Missing_capacity_storer[m,4] = 1
        end

        # find the actual that we could not meet
        if Total_flex_do[m] < C_do[m]*ac_do_m[m]
            Missing_activation_storer[m,1] =  -Total_flex_do[m]+C_do[m]*ac_do_m[m]       # find difference between actual flexibility and activation
        end
        if Total_flex_up[m] < C_up[m]*ac_up_m[m]
            Missing_activation_storer[m,2] =  -Total_flex_up[m]+C_up[m]*ac_up_m[m]       # find difference between actual flexibility and activation
        end

    end



    # find maximum activation missed per hour, to find the pay-back per hour
    for t=1:24
        for m=1:60
            if Pen_activation_up[t] <= Missing_activation_storer[(t-1)*60+m,2]
                Pen_activation_up[t] = Missing_activation_storer[(t-1)*60+m,2]
            end
            if Pen_activation_do[t] <= Missing_activation_storer[(t-1)*60+m,1]
                Pen_activation_do[t] = Missing_activation_storer[(t-1)*60+m,1]
            end
        end
    end


    # calculate the actual penalty
    pen = zeros(24)
    for t=1:24
        pen[t] = (Pen_activation_up[t]*La_up[t]*Pen_e_coef + Pen_activation_do[t]*La_do[t]*Pen_e_coef)
    end
    # calculate the actual revenue
    rev = zeros(24)
    for t=1:24
        rev[t] = (C_up[(t-1)*60+1]*La_up[t] + C_do[(t-1)*60+1]*La_do[t])
    end

    # calculate the % where the capacity where over bid
    M_C = zeros(4)
    M_C[4] = sum(Missing_capacity_storer[:,4])/M_d                 # % of time capacity were missed in any of the catergories
    M_C[3] = sum(Missing_capacity_storer[:,3])/M_d                 # % of time capacity were missed energy
    M_C[2] = sum(Missing_capacity_storer[:,2])/M_d                 # % of time capacity were missed up
    M_C[1] = sum(Missing_capacity_storer[:,1])/M_d                 # % of time capacity were missed down

    M_C_B = zeros(T)
    for t=1:T # find frequency of overbid for each hour
        M_C_B[t] = sum(Missing_capacity_storer[(t-1)*60+1:60*t,4])/60                 # % of time capacity were missed in any of the catergories
    end

    # calculate the % of bids where we did not meet the activation
    M_A = zeros(2)
    if sum(C_up[m]*ac_up_m[m] for m=1:M_d) > 0
        M_A[2] = sum(Missing_activation_storer[:,2])/sum(C_up[m]*ac_up_m[m] for m=1:M_d)                 # % of total bid we did not meet up
    else
        M_A[2] = 0
    end
    if  sum(C_do[m]*ac_do_m[m] for m=1:M_d) > 0
        M_A[1] = sum(Missing_activation_storer[:,1])/sum(C_do[m]*ac_do_m[m] for m=1:M_d)                 # % of total bid we did not meet down
    else
        M_A[1] = 0
    end

    return rev, pen, M_A, M_C, Missing_capacity_storer_per, M_C_B
end
