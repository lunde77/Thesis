### input:
# kWh_cap:          The expected SoC for each CB to all minues - kWh - 1440xI
# po_cap:           The expected %SoC for each CB to all minues - % - 1440xI
# Power:            The Baseline power for each CB to all minues - kW - 1440xI
# SoC_start:        The SoC to start for each CB - kWh - 1xI
# ac_up:            The percentual upwards activation for all minutes - % - 1xM
# ac_up:            The percentual downwards activation for all minutes - % - 1xM
# C_do:             The aggregated downwards bid for all minutes  - kW - 1xM
# C_up:             The aggregated upwards bid for all minutes  - kW - 1xM

### output:
# revenue:          The profti generated from bid quntities
# penalty:          The cost of not meetning the acatvation
# M_C:              The % of the time the entire bid were not available - up and down [2]
# M_A:              How much of the activation were not meet - up and down [2]

function operation(kWh_cap, po_cap, Power, SoC_start, Power_rate, Connected, ac_do_e, ac_up_e, ac_do_m, ac_up_m, C_do, C_up, La_do, La_up, RM)


    missing_del = 0
    I = size(SoC_start)[1]
    M = 1440
    T= 24
    SoC = zeros(M,I)
    Act_E = zeros(M,I) # see activation energy
    Missing_capacity_storer = zeros(M,2) # Store how much less capacity we have realtive to the bid
    Missing_activation_storer = zeros(M,2) # Store the missed activation - this is not energy - but power missed

    #println(SoC_start[:])

    for m=1:M
        # for each minutes intialize minute varibles
        ac = -ac_up_e[m]+ac_do_e[m]     # Find the summed activation (relative to the energy)
        ac_p = 0                        # The percentual activation of each connected unit
        flex = zeros(I,2)               # for each unit, find it's flexibility in each activation direction, for flex = 1 downwards flex and vice versa
        leftover = zeros(2)             # activation not met in both direction

        for i=1:I

            # for all Connections find flexibility in both direction
            if Connected[m,i] == 1

                # cap baseline power if SoC does not allow for it to be followed
                if m==1
                    if kWh_cap[m,i]/po_cap[m,i]/RM < Power[m,i]/60+SoC_start[i]
                        Power[m,i] = (kWh_cap[m,i]/po_cap[m,i]/RM-SoC_start[i])*60
                    end
                else
                    if kWh_cap[m,i]/po_cap[m,i] < Power[m,i]/60+SoC[m-1,i]
                        Power[m,i] = (kWh_cap[m,i]/po_cap[m,i]/RM-SoC[m-1,i])*60
                    end
                end

                # see if power rate or SoC is limitd factor for flexibility
                # and find downwards flexibility
                if m==1
                    if (kWh_cap[m,i]/po_cap[m,i]/RM-SoC_start[i])*60 < Power_rate[m,i]
                        flex[i,1] = (kWh_cap[m,i]/po_cap[m,i]/RM-SoC_start[i])*60-Power[m,i]
                    else
                        flex[i,1] = Power_rate[m,i]-Power[m,i]
                    end
                else
                    if (kWh_cap[m-1,i]/po_cap[m-1,i]/RM-SoC[m-1,i])*60 < Power_rate[m,i]
                        flex[i,1] = (kWh_cap[m-1,i]/po_cap[m-1,i]/RM-SoC[m-1,i])*60-Power[m,i]
                    else
                        flex[i,1] = Power_rate[m,i]-Power[m,i]
                    end
                end
                # find power to upwards flexibility
                flex[i,2] = Power[m,i]
            # if not connected flexibility is set to zero
            else
                flex[i,:] = [0,0]
            end
        end

        # find potential flexibility issues, as wee need to have enough flexibility in both direction concerning the activátion level
        if sum(flex[:,1]) < C_do[m]
            Missing_capacity_storer[m,1] = 1
        end
        if sum(flex[:,2]) < C_up[m]+C_do[m]*0.2
            Missing_capacity_storer[m,2] = 1
        end

        # find the actual that we could not meet
        if sum(flex[:,1]) < C_do[m]*ac_do_m[m]
            Missing_activation_storer[m,1] =  -sum(flex[:,1])+C_up[m]*ac_do_m       # find difference between actual flexibility and activation
        end
        if sum(flex[:,2]) < C_up[m]*ac_up_m[m]
            Missing_activation_storer[m,2] =  -sum(flex[:,2])+C_up[m]*ac_up_m       # find difference between actual flexibility and activation
        end


        # find % activation energy for each unit, used to update the SoC
        if ac > 0 && C_do[m] > 0
            ac_p = (ac*C_do[m])/sum(flex[:,1])
            flex = flex[:,1] # cahnge flexibility to only look at one direction
            if ac_p > 1 # we cannot deliver more than 100 % of our flexibility
                ac_p = 1
            end
        elseif ac < 0 && C_up[m] > 0
            ac_p = (ac*C_up[m])/sum(flex[:,2])
            flex = flex[:,2] # cahnge flexibility to only look at one direction
            if  ac_p < -1 # we cannot deliver more than 100 % of our flexibility
                ac_p = -1
            end
        else
            ac_p = 0
        end


        # update the SoC, as function of altered baseline power and activation
        for i=1:I
            if Connected[m,i] == 1
                if m == 1
                    SoC[m,i] = Power[m,i]/60 + flex[i]*ac_p/60 + SoC_start[i]
                else
                    SoC[m,i] = Power[m,i]/60 + flex[i]*ac_p/60 + SoC[m-1,i]
                end
            else
                SoC[m,i] = 0
            end
            # store results:
            Act_E[m,i] = flex[i]*ac_p
        end

    end


    Pen_activation_up = zeros(24)
    Pen_activation_do = zeros(24)
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
    penalty = sum( (Pen_activation_up[t]*La_up[t]*pen_mul + Pen_activation_do[t]*La_do[t]*pen_mul) for t=1:T)
    # calculate the actual revenue
    revenue = sum( (C_up[(t-1)*60+1]*La_up[t] + C_do[(t-1)*60+1]*La_do[t]) for t=1:T)

    # calculate the % where the capacity where over bid
    M_C = zeros(2)
    M_C[2] = sum(Missing_capacity_storer[:,2])/M                 # % of time capacity were missed up
    M_C[1] = sum(Missing_capacity_storer[:,1])/M                 # % of time capacity were missed down

    # calculate the % of bids where we did not meet the activation
    M_A = zeros(2)
    if sum(C_up[m]*ac_up_m[m] for m=1:M_d) > 0
        M_A[2] = sum(Missing_activation_storer[:,2])/sum(C_up[m]*ac_up_m[m] for m=1:M_d)/M                 # % of total bid we did not meet up
    else
        M_A[2] = 0
    end
    if  sum(C_do[m]*ac_do_m[m] for m=1:M_d) > 0
        M_A[1] = sum(Missing_activation_storer[:,1])/sum(C_do[m]*ac_do_m[m] for m=1:M_d)/M                 # % of total bid we did not meet down
    else
        M_A[1] = 0
    end
    return revenue, penalty, M_C, M_A
end
