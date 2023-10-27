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

function Stochastic_chancer_model(La_do, La_up, Ac_do, Ac_up, total_flex_do, total_flex_up, total_res_20, q_do, q_up, q_e)

   global start = time_ns()
   #************************************************************************
   # Static Parameters
   T = 24 # hours on a day
   M = 60 # minutes in an hour
   M_d = T*M # minutes per model, i.e. per day
   Pen_do = deepcopy(La_do)*Pen_e_coef  # intialize penalty cost
   Pen_up = deepcopy(La_up)*Pen_e_coef  # intialize penalty cost
   Pi = 1/S
   epsilon = 0.001                 # helper, so demominator won't become zero

   # CVaR related parameters
   # k is defined as input to the model
   alpha = 0.9


   M_do = findmax(total_flex_do)[1]+1000
   M_up = findmax(total_flex_up)[1]+1000
   M_e  = findmax(total_res_20)[1]*60+1000


   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # Bid Varibles
   @variable(Mo, 0 <= C_do[1:T])                    # Chosen downwards bid
   @variable(Mo, 0 <= C_up[1:T])                    # Chosen Upwards bid

   # pentalty Varibles
   @variable(Mo, 0 <= Ap_P_up[1:T, 1:S])              # The biggest total failed activation for a given we need to par for up
   @variable(Mo, 0 <= Ap_P_do[1:T, 1:S])              # The biggest total failed activation for a given  we need to par for down

   # Objetives
   @variable(Mo, Income)                              # Total income on capacity
   @variable(Mo, Penalty)                              # Total income on capacity

   # Binary relaxed varible
   @variable(Mo, 0 <= Y_do[m=1:M_d,s=1:S] )            # Binary varibles chosing when to overbid downwards flexibity
   @variable(Mo, 0 <= Y_up[m=1:M_d,s=1:S] )            # Binary varibles chosing when to overbid Upwards flexibity
   @variable(Mo, 0 <= Y_e[m=1:M_d,s=1:S] )             # Binary varibles chosing when to overbid the energy available


   # CVaR related variables
   @variable(Mo, zeta[1:T])                      # zeta
   @variable(Mo, CVaR[1:T])                      # Total income on capacity
   @variable(Mo, 0 <= eta[1:T, 1:S])             # eta

   ### Obejective ###
   @objective(Mo, Max,  (1-k)*(Income-Penalty) + k*sum(CVaR[t] for t=1:T)) ###

   # summerizing constraints
   @constraint(Mo, Income == sum( (C_do[t]*La_do[t,s]+C_up[t]*La_up[t,s])*Pi for t=1:T, s=1:S) )
   @constraint(Mo, Penalty == sum(  (Ap_P_up[t,s]*Pen_up[t,s]+Ap_P_do[t,s]*Pen_do[t,s])*Pi for s=1:S, t=1:T) ) ###


   #### CVaR constraints ####
   @constraint(Mo, [t=1:T], CVaR[t] == zeta[t] - 1/(1-alpha)*sum(Pi*eta[t,s] for s=1:S) )
   @constraint(Mo, [s=1:S, t=1:T], zeta[t] - (C_up[t]*La_up[t,s]+C_do[t]*La_do[t,s]-Ap_P_up[t,s]*Pen_up[t,s]-Ap_P_do[t,s]*Pen_do[t,s]) <= eta[t,s])


   #### P90/bid available in 85% approximation constraints ###
   # upwards power flexibity
   @constraint(Mo, [m=1:M, t=1:T, s=1:S], -M_do*(1-Y_do[(t-1)*60+m,s]) <= C_do[t]-total_flex_do[(t-1)*60+m,s] )
   @constraint(Mo, [m=1:M, t=1:T, s=1:S], C_do[t]-total_flex_do[(t-1)*60+m,s] <= M_do*Y_do[(t-1)*60+m,s] )
   @constraint(Mo, Con_do, sum(Y_do[m,s] for s=1:S, m=1:M_d) <= q_do)

   # downwards power flexibity
   @constraint(Mo, [m=1:M, t=1:T, s=1:S], -M_up*(1-Y_up[(t-1)*60+m,s]) <= C_do[t]*0.2+C_up[t]-total_flex_up[(t-1)*60+m,s] )
   @constraint(Mo, [m=1:M, t=1:T, s=1:S], C_do[t]*0.2+C_up[t]-total_flex_up[(t-1)*60+m,s] <= M_up*Y_up[(t-1)*60+m,s] )
   @constraint(Mo, Con_up, sum(Y_up[m,s] for s=1:S, m=1:M_d) <= q_up)

   # downwards power flexibity
   @constraint(Mo, [m=1:M, t=1:T, s=1:S], -M_e*(1-Y_e[(t-1)*60+m,s]) <= C_do[t]-total_res_20[(t-1)*60+m,s]*60 )
   @constraint(Mo, [m=1:M, t=1:T, s=1:S], C_do[t]-total_res_20[(t-1)*60+m,s]*60 <= M_e*Y_e[(t-1)*60+m,s] )
   @constraint(Mo, Con_e, sum(Y_e[m,s] for s=1:S, m=1:M_d) <= q_e)


   #### activation pentalty ####
   @constraint(Mo, [t=1:T, m=1:M, s=1:S],  Ap_P_up[t,s] >= C_up[t]*Ac_up[(t-1)*60+m,s]-total_flex_up[(t-1)*60+m,s] )      # for wach hour, the minute we miss most acatvation decides the pentalty (up)
   @constraint(Mo, [t=1:T, m=1:M, s=1:S],  Ap_P_do[t,s] >= C_do[t]*Ac_do[(t-1)*60+m,s]-total_flex_do[(t-1)*60+m,s] )      # for wach hour, the minute we miss most acatvation decides the pentalty (down)

   #### Consstraint overbid ####
   @constraint(Mo, [m=M_d, s=1:S], Y_do[m,s] <= 1 )
   @constraint(Mo, [m=M_d, s=1:S], Y_up[m,s] <= 1 )
   @constraint(Mo, [m=M_d, s=1:S], Y_e[m,s]  <= 1 )

   return Mo, Con_do, Con_up, Con_e, Y_do, Y_up, Y_e, C_do, C_up
end
