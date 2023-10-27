using CSV
using DataFrames

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

results = zeros(1,15)

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


for k_in=1:0
    k_model = (k_in-1)*0.2
    for i=1:9
        CB_Is = collect(1:i*50)
        global start = time_ns()

        global results[i,1], results[i,2], results[i,3:5], results[i,6:8], results[i,9:10], results[i,11], results[i,12], results[i,13], results[i,14], overbidder = Main_stochastic_CC(CB_Is, k_model)
        results_df = DataFrame(results, :auto)
        CSV.write("$base_path"*"3. Simulations\\Stochastic results\\also_x_results_$k.csv", results_df)
    end
end

for i=1:1
    CB_Is = collect(1:i*250)
    global start = time_ns()

    global results[i,1], results[i,2], results[i,3:6], results[i,7:9], results[i,10:11], results[i,12], results[i,13], results[i,14], results[i,15], overbidder  = Main_stochastic_CC(CB_Is)
    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\also_x_tester.csv", results_df)
end
