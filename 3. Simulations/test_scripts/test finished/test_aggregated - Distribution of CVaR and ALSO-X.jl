using CSV
using DataFrames
using Random

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

TE = 2

results = zeros(TE,15)
Overbid_distribution = zeros(365,TE)
Upwards_bids = zeros(24,TE)
Downwards_bids = zeros(24,TE)

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



for i=1:1
    CB_Is = collect(1:250)
    global start = time_ns()

    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], overbidder, Overbid_distribution[:,i], Upwards_bids[:,i], Downwards_bids[:,i] = Main_stochastic_CVAR_OSS(CB_Is, 2, 162)
    global results[i+1,1], results[i+1,2], results[i+1,3:6], results[i+1,7:9], results[i+1,10:11], results[i+1,12], results[i+1,13], results[i+1,14], results[i+1,15], overbidder, Overbid_distribution[:,i+1], Upwards_bids[:,i+1], Downwards_bids[:,i+1] = Main_stochastic_CC_OSS(CB_Is, 2, 162, 0.0001)

    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR VS ALSO-X generel results.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR VS ALSO-X overbid_distribution.csv", results_df)
end
