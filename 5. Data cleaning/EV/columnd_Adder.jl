using Plots

for i=301:500
  println(i)
  CB = i
  M_d = 1440
  Days = 365

  Max_Power = EV_dataframes[dataframe_names[CB]][:,5]  # max power of box
  po_cap = EV_dataframes[dataframe_names[CB]][:,1]     # % of resovior stored
  kWh_cap = EV_dataframes[dataframe_names[CB]][:,2]    # kWh of resovior charged
  Power = EV_dataframes[dataframe_names[CB]][:,3]      # baseline power
  Connected = EV_dataframes[dataframe_names[CB]][:,4]  # minutes where CB is connected

  Downwards_flex, upwards_flex =  baseline_flex_realized(kWh_cap, po_cap, Power, Max_Power, Connected, 0.9)

  plot(Downwards_flex)
  plot!(upwards_flex)

  EV_dataframes[dataframe_names[CB]].Downwards_flex  = Downwards_flex
  EV_dataframes[dataframe_names[CB]].upwards_flex = upwards_flex

  base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\data\\EV\\cleaned_data_RM90\\"

  CSV.write(base_path*"$(dataframe_names[CB]).csv", EV_dataframes[dataframe_names[CB]])
end
