using CSV
using DataFrames

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

results = zeros(8,10)

# 1: revenue
# 2: penalty
# 3: down capacity missed
# 4: up capacity missed
# 5: % down acatvation missed
# 6: % up acatvation missed
# 7: % of total upwards flexibity bid into the marked
# 8: % of total downwards flexibity bid into the marked
# 9: time taken for model to run
# 10: time taken to load all data



for i=1:1
    CB_Is = collect(1:i*50)
    global start = time_ns()

    results[i,1], results[i,2], results[i,3:4], results[i,5:6], results[i,7], results[i,8], results[i,9], results[i,10] = Main_stochastic_CC(CB_Is)
    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\also_x.csv", results_df)
end
