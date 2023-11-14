function Max_power_rate_now(df_resovior, df_soc, df_connected, df_max_power)

    ### The input dataset will have the dimension M_dxIxS where M_d is the minutes per day, I is amount of CBs and S is the amount of scenarios
    # M_d is always 1440
    # I is always unknown
    # S is always userdefined
    
    # 3=dim matrix (M_d x I x S) that hold values of the max resevoir in kWh per charging
    Full_resevoir = ifelse.(df_resovior .== 0, 0, (1 ./ df_resovior) .* df_soc .* df_connected)

    df_Max_power_rate_now = zeros(M_d, I, S)

    
    for i in 1:I
        for s in 1:S
            for md in 1:M_d

                if 1 < md # remember that the max power rate that can be delivered now is based on what happened in md-1. 
                          # The first step is therefore based on "SoC_start_r" on that given day
        
                    if (df_max_power[md-1,i,s]/60 + df_soc[md-1,i,s]) <= Full_resevoir[md-1,i,s]
                        df_Max_power_rate_now[md,i,s] = df_max_power[md-1,i,s]
                    else
                        df_Max_power_rate_now[md,i,s] = (Full_resevoir[md-1,i,s]-df_soc[md-1,i,s])*1000/60
                    end
                        
                else
                    df_Max_power_rate_now[md,i,s] = SoC_start_r[i]
                end
                    

            end
                
        end
    end


    # summing over the second dimension (1:I) to get the aggregated sum
    df_Max_power_rate_now = sum(df_Max_power_rate_now, dims=2)
    # dropping the scond dimension
    df_Max_power_rate_now = dropdims(df_Max_power_rate_now, dims=2)

    return df_Max_power_rate_now

end
