using CSV
using DataFrames

global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

Objetives = zeros(5,1)
Missing_del_results = zeros(5,1)
cap_missed_results = zeros(5,2)


for i=1:3
    CB_Is = collect(1:i*50)
    Objetives[i], Missing_del_results[i], cap_missed_results[i,:]  = Main_stochastic(CB_Is)
    Objetives[i] = round(Objetives[i])
    Missing_del_results[i] = round(Missing_del_results[i])
    cap_missed_results[i] = round(cap_missed_results[i])
    results_df = DataFrame(Objetives, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\aggregated_objs_50_150.csv", results_df)
    results_df = DataFrame(Missing_del_results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\aggregated_missing_del_50_150.csv", results_df)
    results_df = DataFrame(cap_missed_results, :auto)
    CSV.write("$base_path"*"3. Simulations\\Stochastic results\\aggregated_cap_misssed_50_150.csv", results_df)

end
