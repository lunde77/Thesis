using CSV
using DataFrames

results = zeros(10,1)

for i=1:10
    CB_Is = collect(1:i*5)
    results[i] = test_A(CB_Is)
end

results_df = DataFrame(results, :auto)
CSV.write("$base_path"*"3. Simulations\\agregated_1_50_5.csv", results_df)
