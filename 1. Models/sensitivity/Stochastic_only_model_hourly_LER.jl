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

function Stochastic_chancer_model_hourly_LER(total_flex_do, total_flex_up, total_res_20, q)

   global start = time_ns()
   #************************************************************************
   # Static Parameters
   M = 60 # minutes in an hour
   Pi = 1/S


   M_do = findmax(total_flex_do)[1]+100000
   M_up = findmax(total_flex_up)[1]+100000
   M_e  = findmax(total_res_20)[1]+100000


   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)
   set_optimizer_attribute(Mo, "OutputFlag", 0)

   # Bid Varibles
   @variable(Mo, 0 <= C_do)                    # Chosen downwards bid
   @variable(Mo, 0 <= C_up)                    # Chosen Upwards bid

   # Objetives
   @variable(Mo, Capacity)                              # Total  capacity

   # Binary relaxed varible
   @variable(Mo, 0 <= Y[m=1:M,s=1:S] )            # Binary varibles chosing when to overbid downwards flexibity

   ### Obejective ###
   @objective(Mo, Max,  Capacity ) ###

   # summerizing constraints
   @constraint(Mo, Capacity == C_do+C_up )

   #### P90/bid available in 85% approximation constraints ###
   # upwards power flexibity
   #@constraint(Mo, [m=1:M, s=1:S], -M_do*(1-Y[m,s]) <= C_do-total_flex_do[m,s] )
   @constraint(Mo, [m=1:M, s=1:S], C_do-total_flex_do[m,s] <= M_do*Y[m,s] )

   # downwards power flexibity
   #@constraint(Mo, [m=1:M, s=1:S], -M_up*(1-Y[m,s]) <= C_do*0.2+C_up-total_flex_up[m,s] )
   @constraint(Mo, [m=1:M, s=1:S], C_up-total_flex_up[m,s] <= M_up*Y[m,s] )

   # overall violation needs to be below q
   @constraint(Mo, Con, sum(Y[m,s] for s=1:S, m=1:M) <= q)

   #### Consstraint overbid ####
   @constraint(Mo, [m=1:M, s=1:S], Y[m,s]  <= 1 )

   # optimize
   optimize!(Mo)

   return Mo, Con, Y, C_do, C_up
end
