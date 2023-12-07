using CSV
using DataFrames
using Random

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end


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
TE = 2
NF = 3
results = zeros(TE,15)
daily_overbids = zeros(365,24,TE)
magnitudes_overbids =  zeros(365*1440,TE)
Overbid_distribution = zeros(365,TE)
Upwards_bids = zeros(1440,TE*NF)
Downwards_bids = zeros(1440,TE*NF)
hourly_revenue = zeros(8760,TE)
hourly_penalty = zeros(8760,TE)


for q=1:2
    CB_Is = collect(1:500)

    if q==1
        global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,(q-1)*NF+1:q*NF], Downwards_bids[:,(q-1)*NF+1:q*NF], daily_overbids[:,:,q], magnitudes_overbids[:,q], hourly_revenue[:,q], hourly_penalty[:,q] = Main_stochastic_CC_OSS_folded(CB_Is, "hourly")
        results_df = DataFrame(daily_overbids[:,:,q], :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\daily_overbids $q bid over.csv", results_df)

    else
        global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,(q-1)*NF+1:q*NF], Downwards_bids[:,(q-1)*NF+1:q*NF], daily_overbids[:,:,q], magnitudes_overbids[:,q], hourly_revenue[:,q], hourly_penalty[:,q] = Main_stochastic_CVAR_OSS_folded(CB_Is, "hourly")
        results_df = DataFrame(daily_overbids[:,:,q], :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\daily_overbids $q bid over.csv", results_df)
    end

    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\results_N_bundlesCVAR vs ALSO bid over.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Overbid_distribution_N_bundlesCVAR vs ALSO bid over.csv", results_df)

    results_df = DataFrame(Upwards_bids, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids_N_bundles_CVAR vs ALSO bid over.csv", results_df)

    results_df = DataFrame(Downwards_bids, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids_N_bundles_CVAR vs ALSO bid over.csv", results_df)

    results_df = DataFrame( magnitudes_overbids , :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ magnitudes_overbids vs ALSO bid over.csv", results_df)


end
