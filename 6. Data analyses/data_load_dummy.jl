using CSV
using DataFrames
using XLSX

##### Output:

#Up_prices_d1:  Upregulation prices for d-1 per hour in DKK/kW
#Up_prices_d2:  Upregulation prices for d-2 per hour in DKK/kW
#Do_prices_d1: Downregulation prices for d-1 per hour in DKK/kW
#Do_prices_d2: Downregulation prices for d-2 per hour in DKK/kW

# Ac_up: activation rate per minue in % for up regulation
# Ac_do: activation rate per minue in % for down regulation


####### Paths ########

# replace with your own path
base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"


####### Load Activations rates ########

Freq_data =  XLSX.readxlsx("$base_path"*"6. Data analyses\\dummy_data\\Frequency\\Activation.xlsx")
global Ac_dowards =  Freq_data["Sheet1!A2:A525601"]  # in %
global Ac_upwards =  Freq_data["Sheet1!B2:B525601"]  # in %

Freq_data_max =  XLSX.readxlsx("$base_path"*"6. Data analyses\\dummy_data\\Frequency\\Max_Activation.xlsx")
global Ac_dowards_M =  Freq_data_max["Sheet1!A2:A525601"]  # in %
global Ac_upwards_M =  Freq_data_max["Sheet1!B2:B525601"]  # in %

# convert from Any matrix to float vector
Ac_dowards_M = vec(Ac_dowards_M)
Ac_dowards_M = [parse(Float64, string(x)) for x in Ac_dowards_M]
Ac_upwards_M = vec(Ac_upwards_M)
Ac_upwards_M = [parse(Float64, string(x)) for x in Ac_upwards_M]



####### Load FCR-D prices ########

xf_FCR_D_Prices = XLSX.readxlsx("$base_path"*"6. Data analyses\\dummy_data\\Price\\FCR_prices.xlsx")
global Do_prices_d1 =  xf_FCR_D_Prices["Sheet1!A2:A8761"]  # in DKK/kW
global Do_prices_d2 =  xf_FCR_D_Prices["Sheet1!B2:B8761"]  # in DKK/kW
global Up_prices_d1  =  xf_FCR_D_Prices["Sheet1!C2:C8761"]  # in DKK/kW
global Up_prices_d2  =  xf_FCR_D_Prices["Sheet1!D2:D8761"]  # in DKK/kW

# file missing data with zeros
Up_prices_d1 = coalesce.(Up_prices_d1, 0)
Up_prices_d2 = coalesce.(Up_prices_d2, 0)
Do_prices_d1 = coalesce.(Do_prices_d1, 0)
Do_prices_d2 = coalesce.(Do_prices_d2, 0)

Mi = 24*365

# convert to danish DKK
for m=1:Mi
        global Up_prices_d1[m] = Up_prices_d1[m]/1000*7.8
        global Up_prices_d2[m] = Up_prices_d2[m]/1000*7.8
        global Do_prices_d1[m] = Do_prices_d1[m]/1000*7.8
        global Do_prices_d2[m] = Do_prices_d2[m]/1000*7.8
end
