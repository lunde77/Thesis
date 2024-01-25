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

global N_size = [1400, 700, 350, 200, 140, 100, 50, 20]
global N_bundles   = [1, 2, 4, 7, 10, 14, 28, 70]
#global N_size = [20]
#global N_bundles = [70]

z = [1,2,3,4,5,6,7,8]
for x in z[4:4]

    TE = N_bundles[x]
    NF = 3
    global results = zeros(TE,15)
    global Overbid_distribution = zeros(365,TE)
    global Upwards_bids = zeros(1440,TE*NF)
    global Downwards_bids = zeros(1440,TE*NF)
    global hourly_revenue = zeros(8760,TE)
    global hourly_penalty = zeros(8760,TE)

    for q=1:TE
        CB_Is = collect((q-1)*N_size[x]+1:q*N_size[x])


        global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,(q-1)*NF+1:q*NF], Downwards_bids[:,(q-1)*NF+1:q*NF], xxx, xxx, hourly_revenue[:,q], hourly_penalty[:,q] = Main_stochastic_CC_OSS_folded_LER(CB_Is, "hourly" , 0.1)


        results_df = DataFrame(results, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\results_N_bundles_LER_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(Overbid_distribution, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Overbid_distribution_N_bundles_LER_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(Upwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids_N_bundles_LER_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(Downwards_bids, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids_N_bundles_LER_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(hourly_penalty, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Hourly_penalty_N_bundles_LER_$(N_bundles[x]).csv", results_df)

        results_df = DataFrame(hourly_revenue, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Hourly_revenue_N_bundles_LER_$(N_bundles[x]).csv", results_df)

    end
end
