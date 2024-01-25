
# run all files, so all functions are intialized


# replace with your own path
base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

# load all functions:
include("$base_path"*"1. Models\\reference models\\Deterministic.jl")
include("$base_path"*"1. Models\\reference models\\Stochastic.jl")
include("$base_path"*"1. Models\\reference models\\Stochastic_with_penalty.jl")
include("$base_path"*"1. Models\\Stochastic_only_model_hourly _CVAR.jl")
include("$base_path"*"1. Models\\Stochastic_only_model_hourly.jl")
include("$base_path"*"1. Models\\Stochastic_only_solver_hourly.jl")
include("$base_path"*"1. Models\\Oracle_model.jl")


include("$base_path"*"1. Models\\sensitivity\\Stochastic_only_model_daily _CVAR.jl")
include("$base_path"*"1. Models\\sensitivity\\Stochastic_only_model_daily.jl")
include("$base_path"*"1. Models\\sensitivity\\Stochastic_only_solver_daily.jl")

include("$base_path"*"2. Algorithms\\reference algorithms\\Day_simulater_with_energy.jl")
include("$base_path"*"2. Algorithms\\Day_simulater_without_energy.jl")
include("$base_path"*"2. Algorithms\\ALSO_X_hourly.jl")
include("$base_path"*"2. Algorithms\\sensitivity\\ALSO_X_daily.jl")

include("$base_path"*"3. Simulations\\Plots\\Deterministic\\plot_function.jl")

include("$base_path"*"4. Tests\\Reference mains\\Main_determistic.jl")
include("$base_path"*"4. Tests\\Reference mains\\Main_OR.jl")
include("$base_path"*"4. Tests\\Main_MR_K_folded.jl")
include("$base_path"*"4. Tests\\Reference mains\\Main_MR_CVAR.jl")
include("$base_path"*"4. Tests\\Reference mains\\Main_MR.jl")
include("$base_path"*"4. Tests\\Main_MR_K_folded_CVAR.jl")
include("$base_path"*"4. Tests\\Main_ORACLE.jl")
include("$base_path"*"4. Tests\\Main_MR_K_folded_eval1CB.jl")

include("$base_path"*"7. Helper functions\\Non main function\\baseline_atering.jl")
include("$base_path"*"7. Helper functions\\Non main function\\scenario_generation.jl")
include("$base_path"*"7. Helper functions\\Non main function\\scenario_generation_1d.jl")
include("$base_path"*"7. Helper functions\\Non main function\\90_scenario_power.jl")
include("$base_path"*"7. Helper functions\\Non main function\\90_scenario_reservoir.jl")
include("$base_path"*"7. Helper functions\\Non main function\\baseline_flexibility.jl")
include("$base_path"*"7. Helper functions\\Non main function\\Max_power_rate_now.jl")
include("$base_path"*"7. Helper functions\\Non main function\\SoC_start_r.jl")
include("$base_path"*"7. Helper functions\\Load_aggregated_data.jl")
include("$base_path"*"7. Helper functions\\Load_daily_data.jl")
include("$base_path"*"7. Helper functions\\load_results_storer.jl")
include("$base_path"*"7. Helper functions\\Load_sampling.jl")
include("$base_path"*"7. Helper functions\\load_folds.jl")

#include("$base_path"*"6. Data analyses\\data_load.jl") # funciton for loading all data, needs to be last, as base_path is altered
include("$base_path"*"6. Data analyses\\data_load_dummy.jl") # funciton for loading all data, needs to be last, this one without CB data
