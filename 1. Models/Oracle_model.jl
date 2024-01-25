using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
#total_flex_do                      # downwards flexibity to each minute of hour 1x60
#total_flex_up                      # upwards flexibityto to each minute of hour 1x60
#total_res_20                       # Energy flexibity to each minute of hour 1x60

# return (varies per day):
# value.(C_up)              # upwards bid for aggregator in kW
# value.(C_do)              # downwards bid for aggregator in kW

function Oracle_model(total_flex_do, total_flex_up, total_res_20)


   #************************************************************************
   # Static Parameters
   M = 60 # minutes in an hour

   # find value of big Ms
   M_do = findmax(total_flex_do)[1]
   M_up = findmax(total_flex_up)[1]
   M_e  = findmax(total_res_20)[1]


   #*******************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)
   set_optimizer_attribute(Mo, "OutputFlag", 0)

   # Binary varible
   @variable(Mo, Y[m=1:M], Bin)                # Binary varibles chosing when to overbid downwards flexibity
   # Bid Varibles
   @variable(Mo, 0 <= C_do)                    # Chosen downwards bid
   @variable(Mo, 0 <= C_up)                    # Chosen Upwards bid

   # Objetives
   @variable(Mo, Capacity)                     # Total  capacity

   ### Obejective ###
   @objective(Mo, Max,  Capacity ) ###

   # summerizing constraints
   @constraint(Mo, Capacity == C_do+C_up )

   #### P90/bid available in 85% approximation constraints ###
   # upwards power flexibity
   @constraint(Mo, [m=1:M], C_do-total_flex_do[m]  <= M_do*Y[m] )

   # downwards power flexibity
   @constraint(Mo, [m=1:M], C_do*0.2+C_up-total_flex_up[m] <= M_up*Y[m]  )

   # downwards power flexibity
   @constraint(Mo, [m=1:M], C_do-total_res_20[m] <= M_e*Y[m]  )

   # overall violation needs to be below q
   @constraint(Mo, sum(Y[m] for m=1:M) <= 60*0.1)


   # optimize
   optimize!(Mo)



   return value(C_do), value(C_up)
end
