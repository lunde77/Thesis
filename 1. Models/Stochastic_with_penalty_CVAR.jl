using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
#La_do                      # prices down for d-1 in h 24xS
#La_up                      # prices up for d-1 in h 24xS
#Ac_do                      # the maximum activation % downwards in m 1440xS
#Ac_up                      # the maximum activation % upwards in m 1440xS
#total_flex_up              # the aggregated baseline flexibility for the prtfolio upwards
#total_flex_do              # the aggregated baseline flexibility for the prtfolio downwards
#S                          # number of scenarios included

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

function Stochastic_d1_model(La_do, La_up, Ac_do, Ac_up, total_flex_up, total_flex_do, total_res_20, S)

   global start = time_ns()
   #************************************************************************
   # Static Parameters
   T = 24 # hours on a day
   M = 60 # minutes in an hour
   M_d = T*M # minutes per model, i.e. per day

   Pen_do = deepcopy(La_do)*Pen_e_coef  # intialize penalty cost
   Pen_up = deepcopy(La_up)*Pen_e_coef  # intialize penalty cost
   S = 10
   Pi = 1/S
   epsilon = 0.001                 # helper, so demominator won't become zero

   # CVaR related parameters
   k = 0.9
   alpha = 0.9


   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)
   #Mo  = Model(optimizer_with_attributes(Gurobi.Optimizer,  "Threads" => 8))
   #Mo  = Model(optimizer_with_attributes(Gurobi.Optimizer,  "Threads" => 1))

   # Bid Varibles
   @variable(Mo, 0 <= C_up[1:T])                    # Chosen upwards bid
   @variable(Mo, 0 <= C_do[1:T])                    # Chosen downwards bid

   # pentalty Varibles
   @variable(Mo, 0 <= per_dev_do[1:M_d, 1:S])         # The percentual over bid in respect to capacity for down bid
   @variable(Mo, 0 <= per_dev_up[1:M_d, 1:S])         # The percentual over bid in respect to capacity for up bid
   @variable(Mo, 0 <= Ap_P_up[1:T, 1:S])              # The biggest total failed activation for a given we need to par for up
   @variable(Mo, 0 <= Ap_P_do[1:T, 1:S])              # The biggest total failed activation for a given  we need to par for down

   # Objetives
   @variable(Mo, Income)                              # Total income on capacity
   @variable(Mo, Penalty)                             # Total income on capacity

   # CVaR related variables
   @variable(Mo, zeta[1:T])                           # zeta
   @variable(Mo, CVaR[1:T])                           # CVaR
   @variable(Mo, 0 <= eta[1:T, 1:S])                  # eta
                             
   ### Obejective ###
   @objective(Mo, Max,  (1-k)*(Income-Penalty) + k*sum(CVaR[t] for t=1:T)) ###

   @constraint(Mo, (1-k)*(Income-Penalty) + k*sum(CVaR[t] for t=1:T) <= 1100000)

   # summerizing constraints
   @constraint(Mo, Income == sum( (C_up[t]*La_up[t,s] + C_do[t]*La_do[t,s])*Pi for t=1:T, s=1:S) ) ###
   @constraint(Mo, Penalty == sum(  (Ap_P_up[t,s]*Pen_up[t,s]+Ap_P_do[t,s]*Pen_do[t,s])*Pi for s=1:S, t=1:T) ) ###

   # CVaR 
   @constraint(Mo, [t=1:T], CVaR[t] == zeta[t] - 1/(1-alpha)*sum(Pi*eta[t,s] for s=1:S) )
   @constraint(Mo, [s=1:S, t=1:T], zeta[t] - (C_up[t]*La_up[t,s]+C_do[t]*La_do[t,s]-Ap_P_up[t,s]*Pen_up[t,s]-Ap_P_do[t,s]*Pen_do[t,s]) <= eta[t,s]) 
   

   #### activation pentalty ####
   @constraint(Mo, [t=1:T, m=1:M, s=1:S],  Ap_P_up[t,s] >= C_up[t]*Ac_up[(t-1)*60+m,s]-total_flex_up[(t-1)*60+m,s] )      # for wach hour, the minute we miss most acatvation decides the pentalty (up)
   @constraint(Mo, [t=1:T, m=1:M, s=1:S],  Ap_P_do[t,s] >= C_do[t]*Ac_do[(t-1)*60+m,s]-total_flex_do[(t-1)*60+m,s] )      # for wach hour, the minute we miss most acatvation decides the pentalty (down)


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

   println("The expeceted penalty is")
   println(value(Penalty))
   println(sum(value.(Ap_P_up)))
   println(sum(value.(Ap_P_do)))


   return value.(C_up), value.(C_do), round((time_ns() - start) / 1e9, digits = 3), NaN   #, shadow_price.(binder)
end
