using CSV
using DataFrames
using Random

global Emil = true

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

global N_size = [1400, 700, 350, 200, 140, 100, 56, 35, 20, 10]
global N_bundles   = [1, 2, 4, 7, 10, 14, 25, 40, 70, 140]

for x=1:10
    TE = N_bundles[x]

    results = zeros(TE,15)
    Overbid_distribution = zeros(365,TE)
    Upwards_bids = zeros(1440,TE*10)
    Downwards_bids = zeros(1440,TE*10)

    for q=1:TE
        CB_Is = collect((q-1)*N_size[x]+1:q*N_size[x])


        global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,(q-1)*10+1:q*10], Downwards_bids[:,(q-1)*10+1:q*10] = Main_stochastic_CC_OSS_folded(CB_Is, "hourly")

        results_df = DataFrame(results, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\results_N_bundles_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(Overbid_distribution, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Overbid_distribution_N_bundles_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(Upwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids_N_bundles_$(Upwards_bids[x]).csv", results_df)

        results_df = DataFrame(Downwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids_N_bundles_$(Upwards_bids[x]).csv", results_df)

    end
end
