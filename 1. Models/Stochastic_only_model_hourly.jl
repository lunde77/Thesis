using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
# total_flex_do                      # downwards flexibity to each minute and sample of hour 60x216
# total_flex_up                      # upwards flexibityto to each  minute and sample  of hour  60x216
# total_res_20                       # Energy flexibity to each mi minute and sample nute of hour  60x216

# return (varies per day):
# varible C_up                       # upwards bid for aggregator in kW (not optimized)
# value C_do                         # downwards bid for aggregator in kW (not optimized)
# Mo                                 # Whole model
# Con                                # constraint binding the overbids - sum of Y
# Y                                  # varible Y  (not optimized)

function Stochastic_chancer_model_hourly(total_flex_do, total_flex_up, total_res_20, q)

   global start = time_ns()
   #************************************************************************
   # Static Parameters
   M = 60 # minutes in an hour
   Pi = 1/S

   # calculate the values of the big Ms
   M_do = findmax(total_flex_do)[1]
   M_up = findmax(total_flex_up)[1]
   M_e  = findmax(total_res_20)[1]


   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)
   set_optimizer_attribute(Mo, "OutputFlag", 0)

   # Bid Varibles
   @variable(Mo, 0 <= C_do)                    # Chosen downwards bid
   @variable(Mo, 0 <= C_up)                    # Chosen Upwards bid

   # Objetives
   @variable(Mo, Capacity)                     # Total  capacity

   # Binary relaxed varible
   @variable(Mo, 0 <= Y[m=1:M,s=1:S] )         # Binary varibles chosing when to overbid downwards flexibity

   ### Obejective ###
   @objective(Mo, Max,  Capacity ) ###

   # summerizing constraints
   @constraint(Mo, Capacity == C_do+C_up )

   #### P10/bid available in 85% approximation constraints -> model to hit 10\% ###
   # upwards power flexibity
   @constraint(Mo, [m=1:M, s=1:S], C_do-total_flex_do[m,s] <= M_do*Y[m,s] )

   # downwards power flexibity
   @constraint(Mo, [m=1:M, s=1:S], C_do*0.2+C_up-total_flex_up[m,s] <= M_up*Y[m,s] )

   # downwards power flexibity
   @constraint(Mo, [m=1:M, s=1:S], C_do-total_res_20[m,s] <= M_e*Y[m,s] )

   # overall violation needs to be below q
   @constraint(Mo, Con, sum(Y[m,s] for s=1:S, m=1:M) <= q)

   #### Consstraint overbid ####
   @constraint(Mo, [m=1:M, s=1:S], Y[m,s]  <= 1 )

   # optimize
   optimize!(Mo)

   return Mo, Con, Y, C_do, C_up
end
