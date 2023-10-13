using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
#La_do                      # prices down for d-1 in h 24xS
#La_up                      # prices up for d-1 in h 24xS
#Ac_do                      # activation % downwards in m 1440xS
#Ac_up                      # activation % upwards in m 1440xS
#Power_rate                 # charging power rate of box in m 1440xIxS
#po_cap                     # % of resovior stored in m 1440xIxS
#kWh_cap                    # kWh of resovior charged in m 1440xIxS
#Power                      # baseline power in m 1440xIxS
#Connected                  # minutes where CB is connected in m 1440xIxS
# SoC_start                 # Start SoC for each CB to each scenario IxS
# SoC_A_cap                 # The aggregated SoC without activation MxS
# I                         # Number of charge boxses

# return (varies per day):
# value.(C_up)              # upwards bid for aggregator in kW in m 1440x1
# value.(C_do)              # downwards bid for aggregator in kW in m 1440x1
# value.(C_up_I)            # distributed of upwards bid in kW in m 1440xI
# value.(C_do_I)            # distributed of downwards bid in kW in m 1440xI
# value.(Power_A)           # The aggregated power without activation for each scenario 1440xIxS
# value.(SoC[M_d,:])        # the expected Energy resovior in kWh at the end of the day 1xI
# value.(SoC_A)             # the expected Energy resovior in kWh for all minutes for the aggregated resovior
# value.(Ma_A)              # the expected Ma charging rate for the aggregator
# objective_value(Mo)       # The expected net ernings after pentalty

function Stochastic_d1_model(La_do, La_up, Ac_do, Ac_up, Power_rate, Power, Connected, total_flex_up, total_flex_do, S)

   global start = time_ns()
   #************************************************************************
   # Static Parameters
   T = 24 # hours on a day
   M = 60 # minutes in an hour
   M_d = T*M # minutes per model, i.e. per day
   Pen_e_coef = 6 # multiplier on energy for not delivering the activation -> 6, implies we have to pay the capacity back and that it 5 times as expensive tp buy the capacity back
   Pen_do = deepcopy(La_do)*Pen_e_coef  # intialize penalty cost
   Pen_up = deepcopy(La_up)*Pen_e_coef  # intialize penalty cost
   S = 10
   Pi = 1/S
   epsilon = 0.001                 # helper, so demominator won't become zero

   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)


   # Bid Varibles
   @variable(Mo, 0 <= C_up[1:T])                    # Chosen upwards bid
   @variable(Mo, 0 <= C_do[1:T])                    # Chosen downwards bid

   # pentalty Varibles
   @variable(Mo, 0 <= per_dev_do[1:M_d, 1:S])         # The percentual over bid in respect to capacity for down bid
   @variable(Mo, 0 <= per_dev_up[1:M_d, 1:S])         # The percentual over bid in respect to capacity for up bid

   # Objetives
   @variable(Mo, Income)                              # Total income on capacity

   ### Obejective ###
   @objective(Mo, Max,  Income) ###

   # summerizing constraints
   @constraint(Mo, Income == sum( (C_up[t]*La_up[t,s] + C_do[t]*La_do[t,s])*Pi for t=1:T, s=1:S) ) ###


   #### P90/bid available in 85% approximation constraints ###

   @constraint(Mo, [t=1:T, m=1:M, s=1:S], 100*( ( total_flex_up[(t-1)*60+m,s]-(C_up[t]+C_do[t]*0.2)+ epsilon)/( total_flex_up[(t-1)*60+m,s]+epsilon))+per_dev_up[(t-1)*60+m,s]  >= 0  )   # The Upwards flexibility has to be greater than the downwards bids plus to be 20% of the upwards bid, otherwise we'll have to enforce a capacity penalty
   @constraint(Mo, [t=1:T, m=1:M, s=1:S], 100*( ( (total_flex_do[(t-1)*60+m,s]+epsilon)-C_do[t])/(total_flex_do[(t-1)*60+m,s]+epsilon))+per_dev_do[(t-1)*60+m,s] >= 0    )                  # The downwards flexibility must be higher than the upwards bid, o.w, we don't have the capacity

   @constraint(Mo, shadow_up, sum( per_dev_up[m,s] for m=1:M_d, s=1:S)/(S*M_d) <= 1 )                                     # the average over overbid must be less than 10%
   @constraint(Mo, shadow_do, sum( per_dev_do[m,s] for m=1:M_d, s=1:S)/(S*M_d) <= 1 )                                     # the average over overbid must be less than 10%


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

   return value.(C_up), value.(C_do), round((time_ns() - start) / 1e9, digits = 3)
end
