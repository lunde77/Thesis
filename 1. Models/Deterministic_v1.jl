using Gurobi
using JuMP
using Plots
# Define the base folder path
Emil = false

if Emil
    base_path = "C:\\Users\\ASUS\\Documents\\11. sem - kand\\github\\Thesis\\"
else
    base_path = "C:\\Users\\Gustav\\Documents\\Thesis\\Git\\"
end

include("$base_path"*"data_load.jl")

#************************************************************************
# Static Parameters
T = 24 # hours on a day
M = 60 # minuites in an hour
M_d = T*M # minues per model, i.e. per day


# Inputs, could be turned into function :
La_do = Do_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices down for d-1
La_up = Up_prices_d1[(Day-1)*T+1:(Day)*T]                                                  # prices up for d-1
Ac_do = Ac_do[(Day-1)*M_d+1:(Day)*M_d]                                                     # activation % downwards
Ac_up = Ac_up[(Day-1)*M_d+1:(Day)*M_d]                                                     # activation % upwards
Max_Power =  EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 5]                 # max power of box
po_cap = EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 1]                     # % of resovior stored
kWh_cap = EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 2]                    # kWh of resovior charged
Power = EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 3]                      # baseline power
Connected = EV_dataframes[dataframe_names[1]][(Day-1)*M_d+1:(Day)*M_d, 4]                  # minutes where CB is connected
Day = 4 # day of concern
SoC_start = 0


#************************************************************************
# Model
Mo  = Model(Gurobi.Optimizer)

# varibles
@variable(Mo, 0 <= Po[1:M_d])       # power delivered after activation - kW
@variable(Mo, 0 <= C_up[1:M_d])     # Upwards bid - kW
@variable(Mo, 0 <= C_do[1:M_d])     # Downwards bid - kW
@variable(Mo, 0 <= Ma[1:M_d])       # Max power - kW
@variable(Mo, 0 <= SoC[1:M_d])      # Energy resovior level - kWh

# obejective
@objective(Mo, Max, sum( C_up[(t-1)*60+1]*La_up[t] + C_do[(t-1)*60+1]*La_do[t] for t=1:T) )

# bid constraiants
@constraint(Mo, [m=1:M_d], Ma[m]-Po[m] >= C_up[m]+C_do[m]*0.2 )                   # the upwards flexibility has to be greater than the the the bids regulation
@constraint(Mo, [m=1:M_d], Po[m] >= C_up[m]*0.2+C_do[m] )                         # the downwards flexibility has to be greater than the the the bids regulation

# Max power constraint
@constraint(Mo, [m=1:M_d], Ma[m] <= Max_Power[m]  )                               # max charger power must be higher than max power
for m=2:M_d
   if Connected[m] == 1 && Connected[m-1] != 0  # we need to look at m-1 for the resovior levels, as the power delivered at m, is what gives the SoC at the end
      @constraint(Mo, Ma[m] <= (kWh_cap[m-1]/po_cap[m-1]-kWh_cap[m-1] )*60  )     # the charging must not violaate the resovior max
   end
end

# power constraint
@constraint(Mo, [m=1:M_d], Po[m] == Power[m]+Ac_up[m]*C_up[m]-Ac_do[m]*C_do[m])   # The power is the baseline + the activation power


for m=1:M_d
   if Connected[m] == 0
      @constraint(Mo, SoC[m] ==  0)                                               # The SoC is to itepreted after the minutes, i.e. af after a non Connected minute, the SoC must be zero
   else
      if m ==  1
         @constraint(Mo, SoC[m] ==  SoC_start+Po[m]/60)                           # Update the SoC to have the power realized stored
         @constraint(Mo, SoC[m] <= kWh_cap[m]/po_cap[m] )                         # the SoC is not allowed to be greater or equal to the end SoC for chargin seesion
      else
         @constraint(Mo, SoC[m] ==  SoC[m-1]+Po[m]/60)                            # Update the SoC to have the power realized stored
         @constraint(Mo, SoC[m] <= kWh_cap[m]/po_cap[m] )                         # the SoC is not allowed to be greater or equal to the end SoC for chargin seesion
      end
   end
end


# bid cosntraints
@constraint(Mo, [m=1:M_d],  C_up[m] <= Connected[m]*M )                           # only bid when charger is Connected
@constraint(Mo, [m=1:M_d],  C_do[m] <= Connected[m]*M )                           # only bid when charger is Connected

@constraint(Mo, [m=2:M, t=1:T], C_up[(t-1)*60+1] == C_up[(t-1)*60+m] )            # bid must equal for all minutes in a hour
@constraint(Mo, [m=2:M, t=1:T], C_do[(t-1)*60+1] == C_do[(t-1)*60+m] )            # bid must equal for all minutes in a hour


#************************************************************************
# Solve
solution = optimize!(Mo)
println("Termination status: $(termination_status(Mo))")
#************************************************************************

if termination_status(Mo) == MOI.OPTIMAL
   println("Optimal objective value: $(objective_value(Mo))")
else
   println("No optimal solution available")
end
#************************************************************************
# plots




# Plot 1: Realized bids for each hour
plot(minutes, value.(C_up), label="Upwards bids", xlabel="Hours", ylabel="kW", title="Bids for Each Hour")
plot!(minutes, value.(C_do), label="Downwards bids")
savefig("$base_path"*"4. Tests\Plots\Deterministic d1\bids.png")

# Plot 2: Power after activation and original power
minutes = 1:M_d
plot(minutes, value.(Po), label="Power after activation", xlabel="Minutes", ylabel="Power", title="Power Comparison")
plot!(minutes, Power, label="Original power")
savefig("$base_path"*"4. Tests\Plots\Deterministic d1\power.png")

# Plot 3: SoC kWh_cap and realized SoC
plot(minutes, kWh_cap, label="SoC baseline", xlabel="Minutes", ylabel="SoC", title="State of Charge (SoC) Comparison")
plot!(minutes, value.(SoC), label="Realized SoC")
savefig("$base_path"*"4. Tests\Plots\Deterministic d1\SoC.png")
