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

function operation(kWh_cap, po_cap, Power, SoC_start, Power_rate, ac_up, ac_do, C_do, C_up)

    missing_del = 0
    I = size(SoC_start)[1]
    M = 1440
    SoC = zeros(M,I)

    println(" the start SoC was $(SoC_start[:]) ")

    #println(SoC_start[:])

    for m=1:M
        # for each minutes intialize minute varibles
        ac = -ac_up[m]+ac_do[m]         # Find the summed activation
        ac_p = 0                        # The percentual activation of each connected unit
        flex = zeros(I)                 # for each unit, find it's flexibility in activation direction
        leftover = 0                    # activation not met

        for i=1:I

            # for all Connections find flexibility in activation direction
            if Connected[m,i] == 1
                # cap baseline power if SoC does not allow for it to be followed
                if m==1
                    if kWh_cap[m,i]/po_cap[m,i] < Power[m,i]/60+SoC_start[i]
                        Power[m,i] = (kWh_cap[m,i]/po_cap[m,i]-SoC_start[i])*60
                    end
                else
                    if kWh_cap[m,i]/po_cap[m,i] < Power[m,i]/60+SoC[m-1,i]
                        Power[m,i] = (kWh_cap[m,i]/po_cap[m,i]-SoC[m-1,i])*60
                    end
                end

                if ac > 0
                    # see if power rate or SoC is limitd factor for flexibility
                    if m==1
                        if (kWh_cap[m,i]/po_cap[m,i]-SoC_start[i])*60 < Power_rate[m,i]
                            flex[i] = (kWh_cap[m,i]/po_cap[m,i]-SoC_start[i])*60-power[m,i]
                        else
                            flex[i] = Power_rate[m,i]-Power[m,i]
                        end
                    else
                        if (kWh_cap[m,i]/po_cap[m,i]-SoC[m,i-1])*60 < Power_rate[m,i]
                            flex[i] = (kWh_cap[m,i]/po_cap[m,i]-SoC[m-1,i])*60-power[m,i]
                        else
                            flex[i] = Power_rate[m,i]-Power[m,i]
                        end
                    end
                # find power to downwards flexibility
                elseif ac < 0
                    flex[i] = Power[m,i]
                # if not activated flexibility is set to zero
                else
                    flex[i] = 0
                end
            # if not connected flexibility is set to zero
            else
                flex[i] = 0
            end
        end

        # find % activation for each unit
        if ac > 0 && C_do[m] > 0
            ac_p = (ac*C_do[m])/sum(flex)
        elseif ac < 0 && C_up[m] > 0
            ac_p = (ac*C_up[m])/sum(flex)
        else
            ac_p = 0
        end

        # if the percentual activation if higher than flexibility, we cannot deliver, hence we have a leftover
        if ac_p > 1
            leftover = ac_p-1
            ac_p = 1
        elseif ac_p < -1
            leftover = (ac_p+1)*(-1)
            ac_p = -1
        end

        # update the SoC, as function of altered baseline power and activation
        for i=1:I
            if Connected[m,i] == 1
                if m == 1
                    #println("The SoC start was $(SoC_start[:])")
                    #println("Power was $(Power[m,i]) ")
                    #println("flex was $(flex[i]) ")
                    #println("SoC_start was $(SoC_start[i]) ")
                    #println("ac_p was $(ac_p) ")
                    SoC[m,i] = Power[m,i]/60 + flex[i]*ac_p/60 + SoC_start[i]
                else
                    if Power[m,i] > 5
                        println("Power was $(Power[m,i]) ")
                        println("m was $m ")
                        println("i was $i ")
                    end
                    #println("flex was $(flex[i]) ")
                    #println("SoC_start was $(SoC[m-1,i]) ")
                    #println("ac_p was $(ac_p) ")
                    SoC[m,i] = Power[m,i]/60 + flex[i]*ac_p/60 + SoC[m-1,i]
                end
            else
                SoC[m,i] = 0
            end
        end



        # update missing_delivery
        missing_del = missing_del + leftover
    end
    println(" the end SoC was $(SoC[M,:]) ")

    return SoC[M,:], missing_del
end
