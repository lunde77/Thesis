# inputs:
#Power_rate                 # charging power rate of box in m 1440x1
#po_cap                     # % of resovior stored in m 1440x1
#kWh_cap                    # kWh of resovior charged in m 1440x1
#Power                      # baseline power in m 1440x1
#Connected                  # minutes where CB is connected in m 1440x1

# return:
#Power                      # baseline power in m 1440x1, now altered to not violate SoC limits

function baseline_altering(Power, SoC_start, Connected, po_cap, kWh_cap)

        # Static Parameters
        T = 24 # hours on a day
        M = 60 # minutes in an hour
        M_d = T*M # minutes per model, i.e. per day
        SoC_syn = zeros(M_d) # synwhtic SoC if baseline is followed


        m = 1
        while Connected[m] == 1 # only chech for fist charge session, as power baseline will not violate capacity unless it carries over

                # intialize SoC after power delivered
                if m==1
                        SoC_syn[m] = SoC_start +  Power[m]/60
                else
                        SoC_syn[m] = SoC_syn[m-1] +  Power[m]/60
                end

                if SoC_syn[m] > kWh_cap[m]/po_cap[m] # if the power put the SoC over it's limit, it mean we must alter the power baseline
                        println("it was at m =  $m")
                        println("it was at m =  $m")
                        if m==1
                                Power[m] = 0
                        else
                                Power[m] =  (kWh_cap[m]/po_cap[m] - SoC_syn[m-1])*60
                        end
                        m = m + 1
                        while Connected[m] == 1
                                Power[m] = 0
                                m = m + 1
                                if  M_d < m
                                        println(m)
                                        return Power, false
                                end
                        end
                        println(m)
                        print("her")
                        println(SoC_syn[m] )
                        return Power, false
                end

                m = m + 1
                if  M_d < m
                        return Power, true
                end
        end
        return Power, true
end
