using CSV
using DataFrames

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

results = zeros(2,8)

# 1: objetive
# 2: missed actation
# 3: down capacity missed
# 4: up capacity missed
# 5: down labmda change at last itteration
# 6: up lambda change at last itteration
# 7: itteation in last bid shcudle creation
# 8: time taken

for i=1:1
    CB_Is = collect(1:150+i*50)
    global start = time_ns()

    results[i,1], results[i,2], results[i,3:4], results[i,5], results[i,6], results[i,7] = Main_stochastic_admm(CB_Is)
    results[i,8] = round((time_ns() - start) / 1e9, digits = 3)
    results_df = DataFrame(results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\aggregated_200_250_50_test.csv", results_df)
end
