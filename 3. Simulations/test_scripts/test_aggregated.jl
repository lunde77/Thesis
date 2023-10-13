using CSV
using DataFrames

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

results = zeros(5,8)

# 1: objetive
# 2: missed actation
# 3: down capacity missed
# 4: up capacity missed
# 5: down labmda change at last itteration # not used
# 6: up lambda change at last itteration #not used
# 7: itteation in last bid shcudle creation #not used
# 8: time taken for model to run
# 9: time taken to load all data
# 10: % of total upwards flexibity bid into the marked
# 11: % of total downwards flexibity bid into the marked

for i=1:5
    CB_Is = collect(1:i*100)
    global start = time_ns()

    results[i,1], results[i,2], results[i,3:4], results[i,5], results[i,6], results[i,7], results[i,8] = Main_stochastic(CB_Is)
    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\100_500_100.csv", results_df)
end
