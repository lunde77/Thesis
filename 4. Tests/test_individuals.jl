using CSV
using DataFrames

results = zeros(50,1)

for i=1:50
    CB_Is = [i]
    results[i] = test_A(CB_Is)
end

results_df = DataFrame(results, :auto)
CSV.write("$base_path"*"3. Simulations\\indvidual_1_50.csv", results_df)
