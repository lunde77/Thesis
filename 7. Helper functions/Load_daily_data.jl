using Random
# input:
# Day of concern

# output, see function, where describtions is provided 

function load_daily_data(Day)

    ###### Initialize the realized data for the given day ######
    La_do_r = Do_prices_d2[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1 early
    La_up_r = Up_prices_d2[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1 early
    Ac_do_M_r = Ac_dowards_M[(Day-1)*M_d+1:(Day)*M_d]                                            # max activation downwards per minute
    Ac_up_M_r = Ac_upwards_M[(Day-1)*M_d+1:(Day)*M_d]                                            # max activation upwards per minute
    flex_do_r  = Downwards_flex_all[(Day-1)*M_d+1:(Day)*M_d]                                     # Upwards flexibity for all charge boxses
    flex_up_r  = Upwards_flex_all[(Day-1)*M_d+1:(Day)*M_d]                                       # downwards flexibity for all charge boxses
    res_20_r =  energy_20_all[(Day-1)*M_d+1:(Day)*M_d]                                           # calcualte the 20 resovior level avaible when having to be avaivble for 20 minutes

    # Aggreagte the summed flexibity for up and down, which is bound to be realized
    total_flex_do_r = flex_do_r                                                                  # change name
    total_flex_up_r = flex_up_r                                                                  # change name

    return La_do_r, La_up_r, Ac_do_M_r, Ac_up_M_r, total_flex_do_r, total_flex_up_r, res_20_r
end
