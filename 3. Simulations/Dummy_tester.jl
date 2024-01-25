using CSV
using DataFrames
using Random

# input what to test
global model = "ALSO"#  or "CVaR"
global Sampling = 4 # 1-4
global N_CB = 500 # nuber of CBs to test
global model_res = "hourly" # or "daily"

global DUMMY = true # do not change, as real data is not availble
#outputs
# all results needs to asseced thru REL by print resultss


# 1: revenue
# 2: penalty
# 3: down capacity missed - frequecy of overbid
# 4: up capacity missed - frequecy of overbid
# 5: energy capacity missed - frequecy of overbid
# 6: Total capacity missed - frequecy of overbid
# 7: avg. missed down capacity missed
# 8: avg. missed up capacity missed
# 9: avg. missed energy capacity missed
# 10: % down acatvation missed
# 11: % up acatvation missed
# 12: % of total upwards flexibity bid into the marked
# 13: % of total downwards flexibity bid into the marked
# 14: time taken for model to run
# 15: time taken to load all data
# xxx: results not used
# 16: hourly_revenue: all revenue for hours
# 17: hourly_penalty: all penalty for hours
# 18: Upwards bid for each hour
# 18: downwards bid for each hour
TE = 4
NF = 3
results = zeros(TE,15)
daily_overbids = zeros(365,24,TE)
magnitudes_overbids =  zeros(365*1440,TE)
Overbid_distribution = zeros(365,TE)
Upwards_bids = zeros(1440,TE*NF)
Downwards_bids = zeros(1440,TE*NF)
hourly_revenue = zeros(8760,TE)
hourly_penalty = zeros(8760,TE)
hourly_overbid_freq = zeros(24,365,TE)
q=1
if model == "ALSO"
    results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,1:NF], Downwards_bids[:,1:NF], xxx, xxx, hourly_revenue[:,q], hourly_penalty[:,q] =  Main_stochastic_CC_OSS_folded(collect(1:N_CB), model_res, Sampling)
else
    results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,1:NF], Downwards_bids[:,1:NF], xxx, xxx, hourly_revenue[:,q], hourly_penalty[:,q] =  Main_stochastic_CVAR_OSS_folded(collect(1:N_CB), model_res, Sampling)
end
