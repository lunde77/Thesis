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

function baseline_flex_realized(kWh_cap, po_cap, Power, Power_rate, Connected, SoC_starts, RM)


    I = size(SoC_starts)[1]
    M = 1440

    flex = zeros(M,I,2)

    total_flex = zeros(M,2)


    #println(SoC_start[:])

    for m=1:M
        # for each minutes intialize minute varibles
        for i=1:I

            # for all Connections find flexibility in both direction
            if Connected[m,i] == 1

                # see if power rate or SoC is limitd factor for flexibility
                # and find downwards flexibility
                if m==1
                    if (kWh_cap[m,i]/po_cap[m,i]/RM-SoC_starts[i])*60 < Power_rate[m,i]
                        flex[m,i,1] = (kWh_cap[m,i]/po_cap[m,i]/RM-SoC_starts[i])*60-Power[m,i]
                    else
                        flex[m,i,1] = Power_rate[m,i]-Power[m,i]
                    end
                else
                    if (kWh_cap[m-1,i]/po_cap[m-1,i]/RM-kWh_cap[m-1,i])*60 < Power_rate[m,i]
                        flex[m,i,1] = (kWh_cap[m,i]/po_cap[m,i]/RM-kWh_cap[m-1,i])*60-Power[m,i]
                    else
                        flex[m,i,1] = Power_rate[m,i]-Power[m,i]
                    end
                end
                # find power to upwards flexibility
                flex[m,i,2] = Power[m,i]
            # if not connected flexibility is set to zero
            else
                flex[m,i,:] = [0,0]
            end
        end
        total_flex[m,1] = sum(flex[m,:,1])
        total_flex[m,2] = sum(flex[m,:,2])
    end





    return flex[:,:,1], flex[:,:,2], total_flex[:,1], total_flex[:,2]
end
