using CSV
using DataFrames
using Random

global Emil = true

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"
end

TE = 25

results = zeros(TE,15)
Overbid_distribution_out = zeros(365,TE)# the overbid distribution for out sample tests
Overbid_distribution_in = zeros(365,TE) # the overbid distribution for in sample tests
Upwards_bids = zeros(1440,TE)             # 18: Upwards bid for each hour
Downwards_bids = zeros(1440,TE)           # 18: downwards bid for each hour

#that is saved in results matrix:
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



for i=3:3

    CB_Is = collect(1:100)

    global start = time_ns()

    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], Overbid_distribution_out[:,i], Upwards_bids[:,i], Downwards_bids[:,i] = Main_stochastic_CC_admm(CB_Is, 3, 162)

<<<<<<< HEAD
    results_df1 = DataFrame(Upwards_bids, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids.csv", results_df1)

    results_df2 = DataFrame(Downwards_bids, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids.csv", results_df2)
=======
    #results_df = DataFrame(Upwards_bids, :auto)
    #CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Upwards_bids.csv", results_df)

    #results_df = DataFrame(Downwards_bids, :auto)
    #CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Downwards_bids.csv", results_df)
>>>>>>> 311eab45732e68a272a2bd0633dbb39050d24d15
end
