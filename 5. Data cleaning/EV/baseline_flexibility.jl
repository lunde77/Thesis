### input:
# kWh_cap:          The expected SoC for each CB to all minues - kWh - 1440xI
# po_cap:           The expected %SoC for each CB to all minues - % - 1440xI
# Power:            The Baseline power for each CB to all minues - kW - 1440xI
# SoC_start:        The SoC to start for each CB - kWh - 1xI
# Power_rate:       The power rate of the individual CBs   - 1440xI
# Power_rate:       The connection of the individual CBs   - 1440xI

### output:
# total_flex[:,1]:        The total downwards flexibility
# total_flex[:,2]:        The total Upwards flexibility

function baseline_flex_realized(kWh_cap, po_cap, Power, Power_rate, Connected, RM)

    SoC_start = 0
    M = 1440*365

    flex = zeros(M,2)

    #println(SoC_start[:])

    for m=1:M
        # for each minutes intialize minute varibles

        # for all Connections find flexibility in both direction
        if Connected[m] == 1
            # see if power rate or SoC is limitd factor for flexibility
            # and find downwards flexibility
            if m==1
                if (kWh_cap[m]/po_cap[m]/RM-SoC_start)*60 < Power_rate[m]
                    flex[m,1] = (kWh_cap[m]/po_cap[m]/RM-SoC_starts)*60-Power[m]
                else
                    flex[m,1] = Power_rate[m]-Power[m]
                end
            else
                if (kWh_cap[m-1]/po_cap[m-1]/RM-kWh_cap[m-1])*60 < Power_rate[m]
                    flex[m,1] = (kWh_cap[m]/po_cap[m]/RM-kWh_cap[m-1])*60-Power[m]
                else
                    flex[m,1] = Power_rate[m]-Power[m]
                end
            end
            # find power to upwards flexibility
            flex[m,2] = Power[m]
        # if not connected flexibility is set to zero
        else
            flex[m,:] = [0,0]
        end

    end


    return flex[:,1], flex[:,2]
end
