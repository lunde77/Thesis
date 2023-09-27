
# run all files, so all functions are intialized

global Emil = true

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"

end

# load all functions:
include("$base_path"*"1. Models\\Deterministic.jl")
include("$base_path"*"2. Algorithms\\Day_simulater.jl")
include("$base_path"*"3. Simulations\\Plots\\Deterministic\\plot_function.jl")
include("$base_path"*"4. Tests\\Main_determistic.jl")
include("$base_path"*"4. Tests\\Main_stochastic.jl")
include("$base_path"*"7. Helper functions\\baseline_atering.jl")
include("$base_path"*"7. Helper functions\\scenario_generation.jl")
<<<<<<< HEAD
include("$base_path"*"7. Helper functions\\scenario_generation_1d.jl")
include("$base_path"*"7. Helper functions\\Power_90_scenario.jl")
=======
include("$base_path"*"7. Helper functions\\90_scenario.jl")
>>>>>>> 8817b62d408aee5424ca90e12013a2a5e8bce428

include("$base_path"*"6. Data analyses\\data_load.jl") # funciton for loading all data, needs to be last, as base_path is altered
