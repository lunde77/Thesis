using CSV
using DataFrames

global Emil = true

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

TE = 11

results = zeros(TE,15)


Overbid_distribution = zeros(365,TE)

# 1: revenue *
# 2: penalty *
# 3: down capacity missed
# 4: up capacity missed
# 5: energy capacity missed
# 6: avg. missed down capacity total *
# 6: avg. missed down capacity missed
# 7: avg. missed up capacity missed
# 8: avg. missed energy capacity missed
# 9: % down acatvation missed
# 10: % up acatvation missed
# 11: % of total upwards flexibity bid into the marked *
# 12: % of total downwards flexibity bid into the marked *
# 13: time taken for model to run
# 14: time taken to load all data
global Sampling = 1

for i=1:11
    if i <= 10
        CB_Is = collect((i-1)*50+1:50*i)
    else
        CB_Is = collect(1:500)
    end
    global start = time_ns()
    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], overbidder, Overbid_distribution[:,i] =  Main_stochastic_CC(CB_Is)
    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\50x10_vs_500.csv", results_df)

    #results_df = DataFrame(results, :auto)
    #CSV.write("$base_path"*"3. Simulations\\Stochastic results\\tester_2.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\50x10_vs_500_bid.csv", results_df)
end
