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
# SoC[M,:]:         The SoC at end of the day for each CB - kWh - 1XI
# missing_del:      The total amount of activation delivery missed - kWh

function operation(kWh_cap, po_cap, Power, SoC_start, Power_rate, Connected, ac_do, ac_up, C_do, C_up, La_do, La_up, RM)


    missing_del = 0
    I = size(SoC_start)[1]
    M = 1440
    T= 24
    SoC = zeros(M,I)
    Act_E = zeros(M,I) # see activation energy
    Leftover_storer = zeros(M,2) # see activation energy


    #println(SoC_start[:])

    for m=1:M
        # for each minutes intialize minute varibles
        ac = -ac_up[m]+ac_do[m]         # Find the summed activation
        ac_p = 0                        # The percentual activation of each connected unit
        flex = zeros(I,2)               # for each unit, find it's flexibility in each activation direction, for flex = 1 downwards flex and vice versa
        leftover = zeros(2)             # activation not met in both direction

        for i=1:I

            # for all Connections find flexibility in both direction
            if Connected[m,i] == 1
                # cap baseline power if SoC does not allow for it to be followed
                if m==1
                    if kWh_cap[m,i]/po_cap[m,i] < Power[m,i]/60+SoC_start[i]
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
                    if (kWh_cap[m,i]/po_cap[m,i]-SoC_start[i])*60 < Power_rate[m,i]
                        flex[i,1] = (kWh_cap[m,i]/po_cap[m,i]/RM-SoC_start[i])*60-Power[m,i]
                    else
                        flex[i,1] = Power_rate[m,i]-Power[m,i]
                    end
                else
                    if (kWh_cap[m-1,i]/po_cap[m-1,i]-SoC[m-1,i])*60 < Power_rate[m,i]
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
            Leftover_storer[m,1] = 1
        end
        if sum(flex[:,2]) < C_up[m]+C_do[m]*0.2
            Leftover_storer[m,2] = 1
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

        # update missing_delivery - store results:
        missing_del = missing_del + sum(leftover)
    end

    # calculate the actual revenue
    revenue = sum( (C_up[(t-1)*60+1]*La_up[t] + C_do[(t-1)*60+1]*La_do[t]) for t=1:T)

    # calculate the % where the capacity where over bid
    pr = zeros(2)
    pr[2] = sum(Leftover_storer[:,2])/M                 # % of time missed up
    pr[1] = sum(Leftover_storer[:,1])/M                 # % of time missed down

    return revenue, SoC[M,:], missing_del, Act_E, pr
end
