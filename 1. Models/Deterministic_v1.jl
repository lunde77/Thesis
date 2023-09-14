using Gurobi

# Define the base folder path
Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"
end

include("$base_path"*"data_load.jl")



#************************************************************************
# Model
Model  = Model(Cbc.Optimizer)

# varibles
@variable(Model, 0 <= Po[1:M])          # power delivered after activation
@variable(Model, 0 <= C_up[1:M])       # Upwards bid
@variable(Model, 0 <= C_down[1:M])     # Downwards bid
@variable(Model, 0 <= Ma[1:M])         # Max power
@variable(Model, 0 <= SoC[1:M+1])        # Energy resovior level

# obejective
@objective(Model, Max, sum( C_up[(t-1)*60+1]*La_up[t] + C_down[(t-1)*60+1]*La_down[t]  t=1:T))

# bid constraiants
@constraint(Model, [m=1:M], Ma[m]-Po[m] >= C_up[m]+C_down[m]*0.2 )                   # the upwards flexibility has to be greater than the the the bids regulation
@constraint(Model, [m=1:M], Po[m] <= C_up[m]*0.2+C_down[m] )                         # the downwards flexibility has to be greater than the the the bids regulation

# Max power constraint
@constraint(Model, [m=1:M], Ma[m] <= Max_Power[m]  )                                 # max charger power must be higher than max power
@constraint(Model, [m=1:M], Ma[m] <= (kWh_cap[m]/po_cap[m]-kWh_cap[m] )*60           # the charging must not violaate the resovior max

# power constraint
@constraint(Model, [m=1:M], Po[m] = Power[m]+Ac_up[m]*C_up[m]-Ac_down[m]*C_down[m])  # The power is the baseline + the activation power

# SoC/Resovior constraints
@constraint(model, SoC[1] == 0)                                                      # The SoC must be zero at m=1, as it's before any operation
for m=2:M
   if Connected[m] == 0
      @constraint(Model, SoC[m+1] ==  0)                                             # The SoC is to itepreted after the minutes, i.e. af after a non Connected minute, the SoC must be zero
   else
      @constraint(Model, SoC[m+1] ==  SoC[m]+Po[m]/60)                               # Update the SoC to have the power realized stored
   end
end
@constraint(model, SoC[m+1] <= kWh_cap[m]/po_cap[m] )                                # the SoC is not allowed to be greater or equal to the end SoC for chargin seesion

# bid cosntraints
@constraint(model, [m=1:M],  C_up[m] <= Connected[m]*M )                             # only bid when charger is Connected
@constraint(model, [m=1:M],  C_down[m] <= Connected[m]*M )                           # only bid when charger is Connected

@constraint(model, [m=2:M, T=1:T], C_up[(t-1)*60 +1] == C_up[(t-1)*60 +m] )          # bid must equal for all minutes in a hour
@constraint(model, [m=2:M, T=1:T], C_down[(t-1)*60 +1] == C_down[(t-1)*60 +m] )      # bid must equal for all minutes in a hour


#************************************************************************
# Solve
solution = optimize!(Model)
println("Termination status: $(termination_status(Model))")
#************************************************************************

if termination_status(Model) == MOI.OPTIMAL
   println("Optimal objective value: $(objective_value(Model))")

else
   println("No optimal solution available")
end
#************************************************************************
