using CSV
using DataFrames
using Random

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

TE = 18

results = zeros(TE,15)
Overbid_distribution = zeros(365,TE)
Upwards_bids = zeros(1440,TE*365)
Downwards_bids = zeros(1440,TE*365)

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
    CB_Is = collect(1:100)
    q=1
    global results[q,1], results[q,2], results[q,3:6], results[q,7:9], results[q,10:11], results[q,12], results[q,13], results[q,14], results[q,15], overbidder_CVAR_hourly, Overbid_distribution[:,q], Upwards_bids[:,q], Downwards_bids[:,q] =  Main_stochastic_CC_admm(CB_Is, 3, 50)

    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\ADMM and ALSO-X.csv", results_df)

end
