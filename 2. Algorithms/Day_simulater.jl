

function operation(kWh_cap, po_cap, Power, SoC_start, ac_up, ac_do, C_do, C_up)
    missing_del = 0

    for m=1:M
        # for each minutes intialize minute varibles
        ac = -ac_up[m]+ac_do[m]         # Find the summed activation
        ac_p = 0                        # The percentual activation of each connected unit
        flex = zeros(I)                 # for each unit, find it's flexibility in activation direction
        leftover = 0                    # activation not met

        for i=1:I
            # cap baseline power if SoC does not allow for it to be followed
            if m==1
                if kWh_cap[m,i]/po_cap[m,i] > Power[m,i]/60+SoC_start[i]
                    Power[m,i] = (kWh_cap[m,i]/po_cap[m,i]-SoC_start[i])*60
                end
            else
                if kWh_cap[m,i]/po_cap[m,i] > Power[m,i]/60+SoC[m-1,i]
                    Power[m,i] = (kWh_cap[m,i]/po_cap[m,i]-SoC[m-1,i])*60
                end
            end

            # for all Connections find flexibility in activation direction
            if Connected[i] == 1
                if ac > 0
                    # see if power rate or SoC is limitd factor for flexibility
                    if (kWh_cap[m,i]/po_cap[m,i]-SoC[m,i-1])*60 < Power_rate[m,i]
                        if m==1
                            flex[i] = (kWh_cap[m,i]/po_cap[m,i]-SoC_start[i])*60-power[m,i]
                        else
                            flex[i] = (kWh_cap[m,i]/po_cap[m,i]-SoC[m-1,i])*60-power[m,i]
                        end
                    else
                        flex[i] = Power_rate[m,i]-power[m,i]
                    end
                # find power to downwards flexibility
                elseif ac < 0
                    flex[i] = power[m,i]
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
        if ac > 0
            ac_p = (ac*C_do[m])/sum(flex)
        elseif ac < 0
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
            if m == 1
                SoC[m,i] = Power[i,m] + flex[i]*ac_p + SoC_start[i]
            else
                SoC[m,i] = Power[i,m] + flex[i]*ac_p + SoC[m-1,i]
            end
        end

        # update missing_delivery
        missing_del = missing_del + leftover
    end

    return SoC, missing_del
end
