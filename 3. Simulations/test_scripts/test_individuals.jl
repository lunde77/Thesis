using CSV
using DataFrames


global Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end


Objetives = zeros(150,1)
Missing_del_results = zeros(150,1)
cap_missed_results = zeros(150,2)

for i=1:1
    CB_Is = [i]
    Objetives[i], Missing_del_results[i], cap_missed_results[i,:]  = Main_stochastic(CB_Is)
end

results_df = DataFrame(Objetives, :auto)
CSV.write("$base_path"*"3. Simulations\\Stochastic results\\indvidual_objs_1_150.csv", results_df)
results_df = DataFrame(Missing_del_results, :auto)
CSV.write("$base_path"*"3. Simulations\\Stochastic results\\indvidual_missing_del_1_150.csv", results_df)
results_df = DataFrame(cap_missed_results, :auto)
CSV.write("$base_path"*"3. Simulations\\Stochastic results\\indvidual_cap_misssed_1_150.csv", results_df)
