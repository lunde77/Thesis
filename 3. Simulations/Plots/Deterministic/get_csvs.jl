using CSV
using DataFrames



results_df = DataFrame(Up_bids_I[:,2,:], :auto)
CSV.write("$base_path"*"3. Simulations\\Up_bids_I.csv", results_df)
