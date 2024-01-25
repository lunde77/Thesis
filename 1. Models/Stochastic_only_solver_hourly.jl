using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
# varible C_up                       # upwards bid for aggregator in kW (not optimized)
# value C_do                         # downwards bid for aggregator in kW (not optimized)
# Mo                                 # Whole model
# Con                                # constraint binding the overbids - sum of Y
# Y                                  # varible Y  (not optimized)

# return (varies per day):
# value.(C_up)                       # upwards bid for aggregator in kW
# value.(C_do)                       # downwards bid for aggregator in kW
# value.(Y)                          # Sum of overbids
# objective_value(Mo)                # objective value of solved model

function Stochastic_chancer_solver_hourly(Mo, Con, Y, C_do, C_up, q)

   # Now change the RHS of the constraint to 20
   JuMP.set_normalized_rhs(Con, q)
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

   return value.(Y), value(C_do), value(C_up), objective_value(Mo)
end
