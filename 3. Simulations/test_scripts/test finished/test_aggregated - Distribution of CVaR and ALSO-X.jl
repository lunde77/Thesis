using CSV
using DataFrames
using Random

global Emil = true

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

TE = 10

results = zeros(TE,15)
Overbid_distribution = zeros(365,TE)
#Upwards_bids = zeros(24,TE)
#Downwards_bids = zeros(24,TE)

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



<<<<<<< HEAD:3. Simulations/test_scripts/test_aggregated.jl
for i=2:25
    CB_Is = collect(1:250)
    global start = time_ns()

    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], overbidder, Overbid_distribution[:,i], Upwards_bids[:,i], Downwards_bids[:,i] = Main_stochastic_CC_OSS(CB_Is, 2, 162)


    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Bid_difference_damm.csv", results_df)

    results_df2 = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Bid_difference_2damm.csv", results_df2)
=======
for i=1:1
    CB_Is = collect(1:250*i)
    global start = time_ns()

    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], Overbid_distribution[:,i], Upwards_bids[:,i], Downwards_bids[:,i] = Main_stochastic_CC_OSS_folded(CB_Is)
    global results[i+5,1], results[i+5,2], results[i+5,3:6], results[i+5,7:9], results[i+5,10:11], results[i+5,12], results[i+5,13], results[i+5,14], results[i+5,15], Overbid_distribution[:,i+5], Upwards_bids[:,i+5], Downwards_bids[:,i+5] = Main_stochastic_CVAR_OSS_folded(CB_Is)

    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR VS ALSO-X generel results2.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
<<<<<<< HEAD
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR VS ALSO-X overbid_distribution2.csv", results_df)
=======
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR VS ALSO-X overbid_distribution.csv", results_df)
>>>>>>> f7d7bf97232319fd0e7d80f1416f6b1e54baf191:3. Simulations/test_scripts/test finished/test_aggregated - Distribution of CVaR and ALSO-X.jl
>>>>>>> 33fbb0ac395e4e927727969354dd286c5f99be6a
end


results_df3 = DataFrame(Upwards_bids, :auto)
CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Bid_difference_3damm.csv", results_df3)
#
results_df4 = DataFrame(Downwards_bids, :auto)
CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Bid_difference_4damm.csv", results_df4)