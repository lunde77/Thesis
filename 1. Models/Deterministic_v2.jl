using Gurobi
using JuMP

#************************************************************************
# input parameters (varies per day):
#La_do                      # prices down for d-1 in h 24x1
#La_up                      # prices up for d-1 in h 24x1
#Ac_do                      # activation % downwards in m 1440x1
#Ac_up                      # activation % upwards in m 1440x1
#Power_rate                 # charging power rate of box in m 1440x1
#po_cap                     # % of resovior stored in m 1440x1
#kWh_cap                    # kWh of resovior charged in m 1440x1
#Power                      # baseline power in m 1440x1
#Connected                  # minutes where CB is connected in m 1440x1


# return (varies per day):
# value.(C_up)              # upwards bid in kW in m 1440x1
# value.(C_do)              # downwards bid in kW in m 1440x1
# value(SoC[M_d])           # the expected Energy resovior in kWh at the end of the day 1x1

function deterministic_model(La_do, La_up, Ac_do, Ac_up, Power_rate, po_cap, kWh_cap, Power, Connected, SoC_start)

   #************************************************************************
   # Static Parameters
   T = 24 # hours on a day
   M = 60 # minutes in an hour
   M_d = T*M # minutes per model, i.e. per day
   RM = 1 # %-end SoC assumed

   #************************************************************************
   # Model
   Mo  = Model(Gurobi.Optimizer)

   # varible per individual CB
   @variable(Mo, 0 <= Po[1:M_d, 1:I])       # Power delivered after activation - kW
   @variable(Mo, 0 <= Ma[1:M_d, 1:I])       # Max power - kW
   @variable(Mo, 0 <= SoC[1:M_d, 1:I])      # Energy resovior level - kWh
   @variable(Mo, 0 <= C_up_A[1:M_d, 1:I])   # Upwards bid placed on CB I - kW
   @variable(Mo, 0 <= C_do_A[1:M_d, 1:I])   # Downwards bid  on CB I  - kW

   # varible for aggregator
   @variable(Mo, 0 <= Po_A[1:M_d])          # aggregator Power delivered after activation - kW
   @variable(Mo, 0 <= Power_A[1:M_d])       # aggregator Power delivered before activation - kW
   @variable(Mo, 0 <= C_up_A[1:M_d])        # aggregator Upwards bid - kW
   @variable(Mo, 0 <= C_do_A[1:M_d])        # aggregator Downwards bid - kW
   @variable(Mo, 0 <= Ma_A[1:M_d])          # aggregator Max power - kW


   # Obejective
   @objective(Mo, Max, sum( C_up_A[(t-1)*60+1]*La_up[t] + C_do_A[(t-1)*60+1]*La_do[t] for t=1:T) )

   # aggregator helper varibles
   @constraint(Mo, [m=1:M_d], Ma_A[m] = sum(Ma[m,i] for i=1:I) )                     # The maximum charge is the sum of all max charging rates
   @constraint(Mo, [m=1:M_d], Po_A[m] = sum(Po[m,i] for i=1:I) )                     # The power delivered for the aggregator is the sum of all
   @constraint(Mo, [m=1:M_d], Power_A[m] = sum(Power[m,i] for i=1:I) )               # The power delivered for the aggregator is the sum of all

   # Bid constraiants
   @constraint(Mo, [m=1:M_d], Ma_A[m]-Power_A[m] >= C_up_A[m]+C_do_A[m]*0.2 )        # The upwards flexibility has to be greater than the the the bids regulation
   @constraint(Mo, [m=1:M_d], Power_A[m] >= C_up_A[m]*0.2+C_do_A[m] )                # The downwards flexibility has to be greater than the the the bids regulation

   # Max power constraint
   @constraint(Mo, [m=1:M_d], Ma[m] <= Power_rate[m]  )                              # The charging power rate of the box must be higher than the Max power (Ma)
   for m=2:M_d
      if Connected[m] == 1 && Connected[m-1] != 0  # We need to look at m-1 for the resovior levels, as the power delivered at m, is what gives the SoC at the end
         @constraint(Mo, Ma[m] <= (kWh_cap[m-1]/po_cap[m-1]-kWh_cap[m-1] )*60  )     # The charging must not violaate the resovior max
      end
   end

   # Power constraint
   @constraint(Mo, [m=1:M_d], Po[m] == Power[m]+Ac_up[m]*C_up[m]-Ac_do[m]*C_do[m])   # The power is the baseline + the activation power

   for m=1:M_d
      if Connected[m] == 0
         @constraint(Mo, SoC[m] ==  0)                                               # The SoC is to itepreted after the minutes, i.e. af after a non Connected minute, the SoC must be zero
      else
         if m ==  1
            @constraint(Mo, SoC[m] ==  SoC_start+Po[m]/60)                           # Update the SoC to have the power realized stored
            @constraint(Mo, SoC[m] <= kWh_cap[m]/po_cap[m]/RM )                         # The SoC is not allowed to be greater or equal to the end SoC for chargin seesion
         else
            @constraint(Mo, SoC[m] ==  SoC[m-1]+Po[m]/60)                            # Update the SoC to have the power realized stored
            @constraint(Mo, SoC[m] <= kWh_cap[m]/po_cap[m]/RM )                         # The SoC is not allowed to be greater or equal to the end SoC for chargin seesion
         end
      end
   end


   # Bid cosntraints
   @constraint(Mo, [m=1:M_d],  C_up[m] <= Connected[m]*M )                           # Only bid when charger is Connected
   @constraint(Mo, [m=1:M_d],  C_do[m] <= Connected[m]*M )                           # Only bid when charger is Connected

   @constraint(Mo, [m=2:M, t=1:T], C_up[(t-1)*60+1] == C_up[(t-1)*60+m] )            # Bid must equal for all minutes in a hour
   @constraint(Mo, [m=2:M, t=1:T], C_do[(t-1)*60+1] == C_do[(t-1)*60+m] )            # Bid must equal for all minutes in a hour


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

   return value.(C_up), value.(C_do), value(SoC[M_d]), objective_value(Mo)
end
