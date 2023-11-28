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

function Stochastic_chancer_model_daily(total_flex_do, total_flex_up, total_res_20, q)

   global start = time_ns()
   #************************************************************************
   # Static Parameters
   T = 24
   M = 60 # minutes in an hour
   Pi = 1/S

   epsilon = 0.001                 # helper, so demominator won't become zero

   max_up = zeros(24)
   max_do = zeros(24)
   max_e = zeros(24)
   for t=1:T
      max_up[t] = findmax(total_flex_up[t,:,:])[1]
      max_do[t] = findmax(total_flex_do[t,:,:])[1]
      max_e[t] = findmax(total_res_20[t,:,:])[1]
   end

   #M_do = findmax(total_flex_do)[1]+10000
   #M_up = findmax(total_flex_up)[1]+10000
   #M_e  = findmax(total_res_20)[1]+10000


   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # Bid Varibles
   @variable(Mo, 0 <= C_do[t=1:T])                    # Chosen downwards bid
   @variable(Mo, 0 <= C_up[t=1:T])                    # Chosen Upwards bid

   # Objetives
   @variable(Mo, Capacity)                            # Total  capacity

   # Binary relaxed varible
   @variable(Mo, 0 <= Y[t=1:T,m=1:M,s=1:S] )            # Binary varibles chosing when to overbid downwards flexibity

   ### Obejective ###
   @objective(Mo, Max,  Capacity ) ###

   # summerizing constraints
   @constraint(Mo, Capacity == sum(C_do[t]+C_up[t] for t=1:T) )

   #### P90/bid available in 85% approximation constraints ###
   # upwards power flexibity

   @constraint(Mo, [t=1:T, m=1:M, s=1:S], C_do[t]-total_flex_do[t,m,s] <= max_do[t]*Y[t,m,s])               # (max_do[t]-total_flex_do[t,m,s]/max_do[t]*max_do[t])*Y[t,m,s] )#
   # downwards power flexibity

   @constraint(Mo, [t=1:T, m=1:M, s=1:S], C_do[t]*0.2+C_up[t]-total_flex_up[t,m,s] <=  max_up[t]*Y[t,m,s])  # (max_up[t]-total_flex_up[t,m,s]/max_up[t]*max_up[t])*Y[t,m,s] )

   # downwards power flexibity
   @constraint(Mo, [t=1:T, m=1:M, s=1:S], C_do[t]-total_res_20[t,m,s] <=  max_e[t]*Y[t,m,s])                #(max_e[t]-total_res_20[t,m,s]/max_e[t]*max_e[t])*Y[t,m,s] )

   # overall violation needs to be below q
   @constraint(Mo, Con, sum(Y[t,m,s] for t=1:T, s=1:S, m=1:M) <= q)

   #### Consstraint overbid ####
   @constraint(Mo, [t=1:T, m=1:M, s=1:S], Y[t,m,s]  <= 1 )

   ### cosntraint the bids to alsoways have a non-zero change of not being an ovebid (hence, don't allow bids higher than max flexibity in an hour)
   #@constraint(Mo, [t=1:T], max_up[t] >= C_up[t])
   #@constraint(Mo, [t=1:T], max_do[t] >= C_do[t])

   # optimize
   optimize!(Mo)

   return Mo, Con, Y, C_do, C_up
end
