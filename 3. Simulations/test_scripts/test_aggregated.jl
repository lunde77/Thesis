using CSV
using DataFrames

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

TE = 10

results_Cvar = zeros(TE,15)


Overbid_distribution = zeros(365,TE)

# 1: revenue
# 2: penalty
# 3: down capacity missed
# 4: up capacity missed
# 5: energy capacity missed
# 6: avg. missed down capacity missed
# 7: avg. missed up capacity missed
# 8: avg. missed energy capacity missed
# 9: % down acatvation missed
# 10: % up acatvation missed
# 11: % of total upwards flexibity bid into the marked
# 12: % of total downwards flexibity bid into the marked
# 13: time taken for model to run
# 14: time taken to load all data



for i=1:5
    CB_Is = collect(1:i*100)
    global start = time_ns()

    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], overbidder, Overbid_distribution[:,i] = Main_stochastic_CVAR_OSS(CB_Is, 2)

    global start = time_ns()
    global results[i+5,1], results[i+5,2], results[i+5,3:6], results[i+5,7:9], results[i+5,10:11], results[i+5,12], results[i+5,13], results[i+5,14], results[i+5,15], overbidder, Overbid_distribution[:,i+5] = Main_stochastic_CVAR_OSS(CB_Is, 1)


    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR results.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\CVaR overbidder .csv", results_df)
end

for i=1:5
    CB_Is = collect(1:i*100)
    global start = time_ns()

    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], overbidder, Overbid_distribution[:,i] = Main_stochastic_CC_OSS(CB_Is, 2)

    global start = time_ns()
    global results[i+5,1], results[i+5,2], results[i+5,3:6], results[i+5,7:9], results[i+5,10:11], results[i+5,12], results[i+5,13], results[i+5,14], results[i+5,15], overbidder, Overbid_distribution[:,i+5] = Main_stochastic_CC_OSS(CB_Is, 1)


    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\Also-X results.csv", results_df)

    results_df = DataFrame(Overbid_distribution, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\also-x overbidder .csv", results_df)
end
