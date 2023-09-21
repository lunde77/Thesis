using CSV
using DataFrames

results = zeros(5,1)

for i=1:5
    CB_Is = collect(1:i*10)
    results[i] = test_A(CB_Is)
    results[i] = round(results[i])
end

results_df = DataFrame(results, :auto)
CSV.write("$base_path"*"3. Simulations\\aggregated_1_50_10.csv", results_df)
# Extracting the first column into a vector
