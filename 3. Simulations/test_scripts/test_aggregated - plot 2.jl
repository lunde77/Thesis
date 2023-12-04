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

global N_size = [1400, 700, 350, 200, 140, 100, 56, 35, 20, 10]
global N_bundles   = [1, 2, 4, 6, 10, 14, 25, 40, 70, 140]

TE = 1
results = zeros(TE,15)
results_CB_1 = zeros(TE,2)
Overbid_distribution = zeros(365,TE)
Upwards_bids = zeros(1440,TE*5)
Downwards_bids = zeros(1440,TE*5)


for q=1:TE
    CB_Is = collect(1:1)

    global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], Overbid_distribution[:,q], Upwards_bids[:,(q-1)*5+1:q*5], Downwards_bids[:,(q-1)*5+1:q*5], results_CB_1[q,1], results_CB_1[q,2]  = Main_stochastic_CC_OSS_folded_one(CB_Is, "hourly")

    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\results_tester_1BC_1.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Overbid_distribution_tester_1BC_1.csv", results_df)

    results_df = DataFrame(Upwards_bids, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids_tester_1BC_1.csv", results_df)

    results_df = DataFrame(Downwards_bids, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids_tester_1BC_1.csv", results_df)


    results_df = DataFrame(results_CB_1, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\1BSresultss_tester_1BC_1.csv", results_df)


end
