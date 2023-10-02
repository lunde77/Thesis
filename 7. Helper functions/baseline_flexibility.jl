### input:
# kWh_cap:          The expected SoC for each CB to all minues - kWh - 1440xIxS
# po_cap:           The expected %SoC for each CB to all minues - % - 1440xIxS
# Power:            The Baseline power for each CB to all minues - kW - 1440xIxS
# SoC_start:        The SoC to start for each CB - kWh - 1xIxS
# Power_rate:       The power rate of the individual CBs   - 1440xIxS
# Power_rate:       The connection of the individual CBs   - 1440xIxS
# S:                Number of scenarios

### output:
# flex[:,:,1]:              The individual downwards flexibility
# flex[:,:,2]:              The individual Upwards flexibility
# total_flex[:,:,1]:        The total downwards flexibility
# total_flex[:,:,2]:        The total Upwards flexibility

function baseline_flex(kWh_cap, po_cap, Power, Power_rate, Connected, SoC_starts, S)


    I = size(SoC_starts)[1]
    M = 1440

    flex = zeros(M,I,S,2)

    total_flex = zeros(M,S,2)


    #println(SoC_start[:])
    for s=1:S
        for m=1:M
            # for each minutes intialize minute varibles
            for i=1:I

                # for all Connections find flexibility in both direction
                if Connected[m,i,s] == 1

                    # see if power rate or SoC is limitd factor for flexibility
                    # and find downwards flexibility
                    if m==1
                        if (kWh_cap[m,i,s]/po_cap[m,i,s]-SoC_starts[i,s])*60 < Power_rate[m,i,s]
                            flex[m,i,s,1] = (kWh_cap[m,i,s]/po_cap[m,i,s]-SoC_starts[i,s])*60-Power[m,i,s]
                        else
                            flex[m,i,s,1] = Power_rate[m,i,s]-Power[m,i,s]
                        end
                    else
                        if (kWh_cap[m-1,i,s]/po_cap[m-1,i,s]-kWh_cap[m-1,i,s])*60 < Power_rate[m,i,s]
                            flex[m,i,s,1] = (kWh_cap[m,i,s]/po_cap[m,i,s]-kWh_cap[m-1,i,s])*60-Power[m,i,s]
                        else
                            flex[m,i,s,1] = Power_rate[m,i,s]-Power[m,i,s]
                        end
                    end
                    # find power to upwards flexibility
                    flex[m,i,s,2] = Power[m,i,s]
                # if not connected flexibility is set to zero
                else
                    flex[m,i,s,:] = [0,0]
                end
            end
            total_flex[m,s,1] = sum(flex[m,:,s,1])
            total_flex[m,s,2] = sum(flex[m,:,s,2])
        end
    end




    return flex[:,:,:,1], flex[:,:,:,2], total_flex[:,:,1], total_flex[:,:,2]
end
