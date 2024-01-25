using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
#total_flex_do                      # downwards flexibity to each minute and sample of hour 60x216
#total_flex_up                      # upwards flexibityto to each  minute and sample  of hour  60x216
#total_res_20                       # Energy flexibity to each mi minute and sample nute of hour  60x216

# return (varies per day):
# value.(C_up)                      # upwards bid for aggregator in kW
# value.(C_do)                       # downwards bid for aggregator in kW


function Stochastic_chancer_model_hourly_CVAR(total_flex_do, total_flex_up, total_res_20)

   global start = time_ns()
   #************************************************************************
   # Static Parameters
   M = 60               # minutes in an hour
   Pi = 1/(S*M)         # probability
   alpha = 0.1          # allowance rate

   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)
   set_optimizer_attribute(Mo, "OutputFlag", 0) # no output -> speed up effect

   # Bid Varibles
   @variable(Mo, 0 <= C_do)                    # Chosen downwards bid
   @variable(Mo, 0 <= C_up)                    # Chosen Upwards bid

   # CVaR related variables
   @variable(Mo, zeta[1:M,1:S])                # zeta
   @variable(Mo, 0 >= beta)                    # eta


   # Objetives
   @variable(Mo, Capacity)                              # Total  capacity

   ### Obejective ###
   @objective(Mo, Max,  Capacity ) ###

   # summerizing constraints
   @constraint(Mo, Capacity == C_do+C_up )

   # overbids calcuattions
   @constraint(Mo, [m=1:M, s=1:S],  C_do-total_flex_do[m,s]   <=  zeta[m,s] )
   @constraint(Mo, [m=1:M, s=1:S],  C_do*0.2+C_up-total_flex_up[m,s]  <=  zeta[m,s] )
   @constraint(Mo, [m=1:M, s=1:S],  C_do-total_res_20[m,s]   <=  zeta[m,s] )

   # overbids control
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

   return value.(C_do), value.(C_up)
end
