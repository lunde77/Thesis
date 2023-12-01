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
# value.(Power_A)           # The aggregated power without activation for each scenario 1440xIxS
# value.(SoC[M_d,:])        # the expected Energy resovior in kWh at the end of the day 1xI
# value.(SoC_A)             # the expected Energy resovior in kWh for all minutes for the aggregated resovior
# value.(Ma_A)              # the expected Ma charging rate for the aggregator
# objective_value(Mo)       # The expected net ernings after pentalty

function Stochastic_chancer_model_hourly_CVAR(total_flex_do, total_flex_up, total_res_20)

   global start = time_ns()
   #************************************************************************
   # Static Parameters
   M = 60 # minutes in an hour
   T = 24
   Pi = 1/(S*M)
   epsilon = 0.001                 # helper, so demominator won't become zero
   alpha = 0.1

   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # Bid Varibles
   @variable(Mo, 0 <= C_do)                    # Chosen downwards bid
   @variable(Mo, 0 <= C_up)                    # Chosen Upwards bid

   # CVaR related variables
   @variable(Mo, zeta[1:M,1:S])                   # zeta
   @variable(Mo, 0 >= beta)                    # eta


   # Objetives
   @variable(Mo, Capacity)                              # Total  capacity

   ### Obejective ###
   @objective(Mo, Max,  Capacity ) ###

   # summerizing constraints
   @constraint(Mo, Capacity == C_do+C_up )
   ## CVaR
   #@constraint(Mo, [m=1:M, s=1:S],  C_do-total_flex_do[m,s]   <=  zeta[m,s] )
   #@constraint(Mo, [m=1:M, s=1:S],  C_do*0.2+C_up-total_flex_up[m,s]  <=  zeta[m,s] )
   #@constraint(Mo, [m=1:M, s=1:S],  C_do-total_res_20[m,s]   <=  zeta[m,s] )
   #@constraint(Mo, [m=1:M], sum(zeta[m,s] for s=1:S)*Pi-(1-alpha)*beta[m] <= 0 )
   #@constraint(Mo, [m=1:M, s=1:S], zeta[m,s]  >= beta[m] )

   @constraint(Mo, [m=1:M, s=1:S],  C_do-total_flex_do[m,s]   <=  zeta[m,s] )
   @constraint(Mo, [m=1:M, s=1:S],  C_do*0.2+C_up-total_flex_up[m,s]  <=  zeta[m,s] )
   @constraint(Mo, [m=1:M, s=1:S],  C_do-total_res_20[m,s]   <=  zeta[m,s] )
   @constraint(Mo, sum(zeta[m,s] for s=1:S, m=1:M)*Pi-(1-alpha)*beta <= 0 )
   @constraint(Mo, [m=1:M, s=1:S], zeta[m,s]  >= beta )

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
   global zeta_v = value.(zeta)
   global beta_v = value.(beta)
   return value.(C_do), value.(C_up)
end
