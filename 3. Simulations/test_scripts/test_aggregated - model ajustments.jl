using CSV
using DataFrames
using Random

# input what to test

model = ALSO # ALSO or CVaR
Sampling = 4 # 1-4
N_CB = 500 # nuber of CBs to test

DUMMY = true # do not change, as real data is not availble

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
test =[2,4]
for q in test
    CB_Is = collect(1:500)
    if q <= 2
        if q == 1
            results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,1:NF], Downwards_bids[:,1:NF], xxx, xxx, hourly_revenue[:,q], hourly_penalty[:,q] =  Main_stochastic_CC_OSS_folded( collect(1001:1020), "hourly", 4)
        else
            results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,1:NF], Downwards_bids[:,1:NF], xxx, xxx, hourly_revenue[:,q], hourly_penalty[:,q] =  Main_stochastic_CC_OSS_folded( collect(1021:1040), "hourly", 4)
        end
        results_df = DataFrame(results, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\results_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(Overbid_distribution, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Overbid_distribution_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(Upwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(Downwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(hourly_penalty, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Hourly_penalty_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(hourly_revenue, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Hourly_revenue_hourly_vs_daily.csv", results_df)
    else
        if q==3
            global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,1:NF], Downwards_bids[:,1:NF], xxx, xxx, hourly_revenue[:,q], hourly_penalty[:,q] =  Main_stochastic_CVAR_OSS_folded(collect(1001:1020), "hourly", 4)
        else q ==4
            global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,1:NF], Downwards_bids[:,1:NF], xxx, xxx, hourly_revenue[:,q], hourly_penalty[:,q] =  Main_stochastic_CVAR_OSS_folded(collect(1021:1040), "hourly", 4)
        end
        results_df = DataFrame(results, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\results_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(Overbid_distribution, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Overbid_distribution_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(Upwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(Downwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(hourly_penalty, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Hourly_penalty_hourly_vs_daily.csv", results_df)

        results_df = DataFrame(hourly_revenue, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Hourly_revenue_hourly_vs_daily.csv", results_df)
    end


end
